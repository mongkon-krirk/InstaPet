import { factories } from '@strapi/strapi';
import { throwIf } from '../../../utils/errors';
import { toMeUser, toPublicUser, toPostMediaItem } from '../../../utils/dto';
import { getUploadOwnership } from '../../../utils/strapi-helpers';

export default factories.createCoreService('api::profile.profile', ({ strapi }) => ({
  getBaseUrl() {
    return getUploadOwnership(strapi).getBaseUrl();
  },

  async findByUsername(username: string) {
    return strapi.db.query('plugin::users-permissions.user').findOne({
      where: { username: username.toLowerCase(), status: 'active' },
      populate: ['avatar'],
    });
  },

  async getMe(userId: number) {
    const user = await strapi.db.query('plugin::users-permissions.user').findOne({
      where: { id: userId },
      populate: ['avatar'],
    });
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);
    return toMeUser(user, this.getBaseUrl());
  },

  async getProfile(username: string, currentUserId?: number) {
    const user = await this.findByUsername(username);
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    let isFollowing = false;
    let isMe = false;
    if (currentUserId) {
      isMe = user.id === currentUserId;
      if (!isMe) {
        const follow = await strapi.db.query('api::follow.follow').findOne({
          where: { follower: currentUserId, following: user.id, status: 'accepted' },
        });
        isFollowing = Boolean(follow);
      }
    }

    return toPublicUser(user, this.getBaseUrl(), { isFollowing, isMe });
  },

  async updateMe(
    userId: number,
    data: {
      displayName?: string;
      username?: string;
      bio?: string;
      isPrivate?: boolean;
      avatarFileId?: number;
    },
  ) {
    const user = await strapi.db.query('plugin::users-permissions.user').findOne({
      where: { id: userId },
    });
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    const updateData: Record<string, unknown> = {};

    if (data.displayName !== undefined) updateData.displayName = data.displayName.trim();
    if (data.bio !== undefined) updateData.bio = data.bio;
    if (data.isPrivate !== undefined) updateData.isPrivate = data.isPrivate;

    if (data.username !== undefined) {
      const normalized = data.username.trim().toLowerCase();
      if (normalized !== user.username) {
        const taken = await strapi.db.query('plugin::users-permissions.user').findOne({
          where: { username: normalized },
        });
        throwIf(taken && taken.id !== userId, 'USERNAME_TAKEN', 'Username already taken', 400);
        updateData.username = normalized;
      }
    }

    if (data.avatarFileId !== undefined) {
      const ownership = getUploadOwnership(strapi);
      await ownership.assertOwnedByUser([data.avatarFileId], userId);
      updateData.avatar = data.avatarFileId;
      await ownership.markAttached([data.avatarFileId]);
      updateData.profileCompleted = true;
    }

    if (data.displayName || data.bio) {
      updateData.profileCompleted = true;
    }

    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: userId },
      data: updateData,
    });

    return this.getMe(userId);
  },

  async getUserPosts(username: string, page: number, pageSize: number, viewerId?: number) {
    const user = await this.findByUsername(username);
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    const isOwner = viewerId === user.id;
    if (user.isPrivate && !isOwner) {
      return { data: [], total: 0, isPrivate: true };
    }

    const start = (page - 1) * pageSize;
    const posts = await strapi.documents('api::post.post').findMany({
      filters: { author: { id: user.id }, status: 'published' },
      populate: { mediaItems: { populate: ['image'] } },
      sort: { publishedAt: 'desc' },
      start,
      limit: pageSize,
    });

    const baseUrl = this.getBaseUrl();
    const data = posts.map((post) => {
      const media = ((post.mediaItems as Record<string, unknown>[]) ?? [])
        .sort((a, b) => (a.sortOrder as number) - (b.sortOrder as number));
      const cover = media[0]
        ? toPostMediaItem(media[0] as Parameters<typeof toPostMediaItem>[0], baseUrl)
        : null;
      return {
        documentId: post.documentId,
        coverUrl: cover?.url,
        mediaCount: media.length,
        publishedAt: post.publishedAt,
      };
    });

    const total = await strapi.db.query('api::post.post').count({
      where: { author: user.id, status: 'published' },
    });

    return { data, total, isPrivate: false };
  },

  async getFollowers(username: string, page: number, pageSize: number) {
    const user = await this.findByUsername(username);
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    const start = (page - 1) * pageSize;
    const follows = await strapi.db.query('api::follow.follow').findMany({
      where: { following: user.id, status: 'accepted' },
      populate: { follower: { populate: ['avatar'] } },
      orderBy: { createdAt: 'desc' },
      offset: start,
      limit: pageSize,
    });

    const total = await strapi.db.query('api::follow.follow').count({
      where: { following: user.id, status: 'accepted' },
    });

    const baseUrl = this.getBaseUrl();
    return {
      data: follows.map((f: { follower: Parameters<typeof toPublicUser>[0] }) =>
        toPublicUser(f.follower, baseUrl),
      ),
      total,
    };
  },

  async getFollowing(username: string, page: number, pageSize: number) {
    const user = await this.findByUsername(username);
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    const start = (page - 1) * pageSize;
    const follows = await strapi.db.query('api::follow.follow').findMany({
      where: { follower: user.id, status: 'accepted' },
      populate: { following: { populate: ['avatar'] } },
      orderBy: { createdAt: 'desc' },
      offset: start,
      limit: pageSize,
    });

    const total = await strapi.db.query('api::follow.follow').count({
      where: { follower: user.id, status: 'accepted' },
    });

    const baseUrl = this.getBaseUrl();
    return {
      data: follows.map((f: { following: Parameters<typeof toPublicUser>[0] }) =>
        toPublicUser(f.following, baseUrl),
      ),
      total,
    };
  },

  async follow(username: string, followerId: number) {
    const target = await this.findByUsername(username);
    throwIf(!target, 'RESOURCE_NOT_FOUND', 'User not found', 404);
    throwIf(target.id === followerId, 'CANNOT_FOLLOW_SELF', 'Cannot follow yourself', 400);

    const existing = await strapi.db.query('api::follow.follow').findOne({
      where: { follower: followerId, following: target.id },
    });

    if (!existing) {
      await strapi.db.query('api::follow.follow').create({
        data: { follower: followerId, following: target.id, status: 'accepted' },
      });

      const follower = await strapi.db.query('plugin::users-permissions.user').findOne({
        where: { id: followerId },
      });
      const following = await strapi.db.query('plugin::users-permissions.user').findOne({
        where: { id: target.id },
      });

      await strapi.db.query('plugin::users-permissions.user').update({
        where: { id: followerId },
        data: { followingCount: (follower?.followingCount ?? 0) + 1 },
      });
      await strapi.db.query('plugin::users-permissions.user').update({
        where: { id: target.id },
        data: { followersCount: (following?.followersCount ?? 0) + 1 },
      });

      await strapi.db.query('api::activity.activity').create({
        data: {
          recipient: target.id,
          actor: followerId,
          type: 'follow',
          isRead: false,
        },
      });
    }

    const updated = await strapi.db.query('plugin::users-permissions.user').findOne({
      where: { id: target.id },
    });

    return { following: true, followersCount: updated?.followersCount ?? 0 };
  },

  async unfollow(username: string, followerId: number) {
    const target = await this.findByUsername(username);
    throwIf(!target, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    const existing = await strapi.db.query('api::follow.follow').findOne({
      where: { follower: followerId, following: target.id },
    });

    if (existing) {
      await strapi.db.query('api::follow.follow').delete({ where: { id: existing.id } });

      const follower = await strapi.db.query('plugin::users-permissions.user').findOne({
        where: { id: followerId },
      });
      const following = await strapi.db.query('plugin::users-permissions.user').findOne({
        where: { id: target.id },
      });

      await strapi.db.query('plugin::users-permissions.user').update({
        where: { id: followerId },
        data: { followingCount: Math.max(0, (follower?.followingCount ?? 1) - 1) },
      });
      await strapi.db.query('plugin::users-permissions.user').update({
        where: { id: target.id },
        data: { followersCount: Math.max(0, (following?.followersCount ?? 1) - 1) },
      });
    }

    const updated = await strapi.db.query('plugin::users-permissions.user').findOne({
      where: { id: target.id },
    });

    return { following: false, followersCount: updated?.followersCount ?? 0 };
  },
}));
