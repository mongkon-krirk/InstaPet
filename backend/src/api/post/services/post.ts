import { factories } from '@strapi/strapi';
import { throwIf } from '../../../utils/errors';
import { toPostMediaItem, toPublicUser } from '../../../utils/dto';
import { getUploadOwnership } from '../../../utils/strapi-helpers';

export default factories.createCoreService('api::post.post', ({ strapi }) => ({
  getOwnershipService() {
    return getUploadOwnership(strapi);
  },

  async findPublishedByDocumentId(documentId: string) {
    const posts = await strapi.documents('api::post.post').findMany({
      filters: { documentId, status: 'published' },
      populate: {
        author: { populate: ['avatar'] },
        mediaItems: { populate: ['image'] },
      },
      limit: 1,
    });
    return posts[0] ?? null;
  },

  async toPostDto(post: Record<string, unknown>, currentUserId?: number) {
    const baseUrl = this.getOwnershipService().getBaseUrl();
    const author = post.author as Record<string, unknown>;
    const mediaItems = (post.mediaItems as Record<string, unknown>[]) ?? [];
    const postId = post.id as number;

    let likedByMe = false;
    if (currentUserId) {
      const like = await strapi.db.query('api::post-like.post-like').findOne({
        where: { post: postId, user: currentUserId },
      });
      likedByMe = Boolean(like);
    }

    return {
      documentId: post.documentId,
      caption: post.caption ?? '',
      visibility: post.visibility,
      likesCount: post.likesCount ?? 0,
      likedByMe,
      publishedAt: post.publishedAt,
      author: toPublicUser(author as Parameters<typeof toPublicUser>[0], baseUrl),
      mediaItems: mediaItems
        .sort((a, b) => (a.sortOrder as number) - (b.sortOrder as number))
        .map((item) => toPostMediaItem(item as Parameters<typeof toPostMediaItem>[0], baseUrl)),
      canDelete: currentUserId ? (author.id as number) === currentUserId : false,
    };
  },

  async createPost(
    userId: number,
    payload: {
      caption?: string;
      visibility?: string;
      mediaItems: { fileId: number; sortOrder: number; altText?: string }[];
    },
  ) {
    const { mediaItems, caption, visibility } = payload;
    throwIf(!mediaItems?.length, 'VALIDATION_ERROR', 'At least one image required', 400);
    throwIf(mediaItems.length > 10, 'MEDIA_LIMIT_EXCEEDED', 'Maximum 10 images', 400);

    const ownership = this.getOwnershipService();
    const fileIds = mediaItems.map((m) => m.fileId);
    await ownership.assertOwnedByUser(fileIds, userId);

    const sortOrders = mediaItems.map((m) => m.sortOrder);
    throwIf(new Set(sortOrders).size !== sortOrders.length, 'VALIDATION_ERROR', 'Duplicate sortOrder', 400);

    const componentItems = [];
    for (const item of mediaItems.sort((a, b) => a.sortOrder - b.sortOrder)) {
      const file = await strapi.db.query('plugin::upload.file').findOne({
        where: { id: item.fileId },
      });
      throwIf(!file, 'MEDIA_NOT_READY', 'Invalid media file', 400);
      componentItems.push({
        image: item.fileId,
        sortOrder: item.sortOrder,
        altText: item.altText ?? '',
        width: file.width,
        height: file.height,
      });
    }

    const post = await strapi.documents('api::post.post').create({
      data: {
        author: userId,
        caption: caption ?? '',
        visibility: (visibility as 'public' | 'followers') ?? 'public',
        status: 'published',
        likesCount: 0,
        publishedAt: new Date().toISOString(),
        mediaItems: componentItems,
      },
      populate: {
        author: { populate: ['avatar'] },
        mediaItems: { populate: ['image'] },
      },
    });

    await ownership.markAttached(fileIds);

    const user = await strapi.db.query('plugin::users-permissions.user').findOne({
      where: { id: userId },
    });
    if (user) {
      await strapi.db.query('plugin::users-permissions.user').update({
        where: { id: userId },
        data: { postsCount: (user.postsCount ?? 0) + 1 },
      });
    }

    return post;
  },

  async deletePost(documentId: string, userId: number) {
    const post = await strapi.documents('api::post.post').findMany({
      filters: { documentId },
      populate: { author: true, mediaItems: { populate: ['image'] } },
      limit: 1,
    });
    const found = post[0];
    throwIf(!found || found.status === 'deleted', 'POST_NOT_FOUND', 'Post not found', 404);
    throwIf((found.author as { id: number }).id !== userId, 'POST_NOT_OWNED', 'Not your post', 403);

    const fileIds = ((found.mediaItems as { image?: { id: number } }[]) ?? [])
      .map((m) => m.image?.id)
      .filter(Boolean) as number[];

    await strapi.db.query('api::post.post').update({
      where: { id: found.id },
      data: { status: 'deleted', deletedAt: new Date().toISOString() },
    });

    await strapi.db.query('api::post-like.post-like').deleteMany({ where: { post: found.id } });
    await strapi.db.query('api::activity.activity').deleteMany({ where: { post: found.id } });

    const ownership = this.getOwnershipService();
    await ownership.markUnused(fileIds);

    const author = found.author as { id: number; postsCount?: number };
    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: author.id },
      data: { postsCount: Math.max(0, (author.postsCount ?? 1) - 1) },
    });

    return { deleted: true };
  },

  async likePost(documentId: string, userId: number) {
    const post = await this.findPublishedByDocumentId(documentId);
    throwIf(!post, 'POST_NOT_FOUND', 'Post not found', 404);

    const existing = await strapi.db.query('api::post-like.post-like').findOne({
      where: { post: post.id, user: userId },
    });

    if (!existing) {
      await strapi.db.query('api::post-like.post-like').create({
        data: { post: post.id, user: userId },
      });
      await strapi.db.query('api::post.post').update({
        where: { id: post.id },
        data: { likesCount: (post.likesCount ?? 0) + 1 },
      });

      const author = post.author as { id: number };
      if (author.id !== userId) {
        await strapi.db.query('api::activity.activity').create({
          data: {
            recipient: author.id,
            actor: userId,
            type: 'post_like',
            post: post.id,
            isRead: false,
          },
        });
      }
    }

    const updated = await strapi.db.query('api::post.post').findOne({ where: { id: post.id } });
    return { liked: true, likesCount: updated?.likesCount ?? 0 };
  },

  async unlikePost(documentId: string, userId: number) {
    const post = await this.findPublishedByDocumentId(documentId);
    throwIf(!post, 'POST_NOT_FOUND', 'Post not found', 404);

    const existing = await strapi.db.query('api::post-like.post-like').findOne({
      where: { post: post.id, user: userId },
    });

    if (existing) {
      await strapi.db.query('api::post-like.post-like').delete({ where: { id: existing.id } });
      await strapi.db.query('api::post.post').update({
        where: { id: post.id },
        data: { likesCount: Math.max(0, (post.likesCount ?? 1) - 1) },
      });
    }

    const updated = await strapi.db.query('api::post.post').findOne({ where: { id: post.id } });
    return { liked: false, likesCount: updated?.likesCount ?? 0 };
  },
}));
