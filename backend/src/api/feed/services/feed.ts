import { factories } from '@strapi/strapi';

export default factories.createCoreService('api::feed.feed', ({ strapi }) => ({
  async getFeed(userId: number, mode: string, page: number, pageSize: number) {
    const postService = strapi.service('api::post.post');
    const start = (page - 1) * pageSize;

    let filters: Record<string, unknown> = { status: 'published' };

    if (mode === 'following') {
      const follows = await strapi.db.query('api::follow.follow').findMany({
        where: { follower: userId, status: 'accepted' },
        populate: ['following'],
      });
      const followingIds = follows.map((f: { following: { id: number } }) => f.following.id);
      followingIds.push(userId);
      filters = { ...filters, author: { id: { $in: followingIds } } };
    } else if (mode === 'discover') {
      filters = { ...filters, visibility: 'public' };
    } else {
      // home: following + own + public filler
      const follows = await strapi.db.query('api::follow.follow').findMany({
        where: { follower: userId, status: 'accepted' },
        populate: ['following'],
      });
      const followingIds = follows.map((f: { following: { id: number } }) => f.following.id);
      followingIds.push(userId);
      filters = {
        ...filters,
        $or: [
          { author: { id: { $in: followingIds } } },
          { visibility: 'public' },
        ],
      };
    }

    const posts = await strapi.documents('api::post.post').findMany({
      filters,
      populate: {
        author: { populate: ['avatar'] },
        mediaItems: { populate: ['image'] },
      },
      sort: { publishedAt: 'desc' },
      start,
      limit: pageSize,
    });

    const total = await strapi.db.query('api::post.post').count({ where: { status: 'published' } });

    const data = await Promise.all(
      posts.map((post) => postService.toPostDto(post as Record<string, unknown>, userId)),
    );

    return { data, total };
  },
}));
