import { factories } from '@strapi/strapi';
import { buildPagination, paginated, parsePagination, success } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';

export default factories.createCoreController('api::profile.profile', ({ strapi }) => ({
  async me(ctx) {
    try {
      const data = await strapi.service('api::profile.profile').getMe(ctx.state.user.id);
      ctx.body = success(data);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async updateMe(ctx) {
    try {
      const data = await strapi.service('api::profile.profile').updateMe(ctx.state.user.id, ctx.request.body);
      ctx.body = success(data);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async findByUsername(ctx) {
    try {
      const data = await strapi.service('api::profile.profile').getProfile(
        ctx.params.username,
        ctx.state.user?.id,
      );
      ctx.body = success(data);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async getPosts(ctx) {
    try {
      const { page, pageSize } = parsePagination(ctx.query as Record<string, unknown>);
      const { data, total } = await strapi.service('api::profile.profile').getUserPosts(
        ctx.params.username,
        page,
        pageSize,
        ctx.state.user?.id,
      );
      ctx.body = paginated(data, buildPagination(page, pageSize, total));
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async getFollowers(ctx) {
    try {
      const { page, pageSize } = parsePagination(ctx.query as Record<string, unknown>);
      const { data, total } = await strapi.service('api::profile.profile').getFollowers(
        ctx.params.username,
        page,
        pageSize,
      );
      ctx.body = paginated(data, buildPagination(page, pageSize, total));
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async getFollowing(ctx) {
    try {
      const { page, pageSize } = parsePagination(ctx.query as Record<string, unknown>);
      const { data, total } = await strapi.service('api::profile.profile').getFollowing(
        ctx.params.username,
        page,
        pageSize,
      );
      ctx.body = paginated(data, buildPagination(page, pageSize, total));
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async follow(ctx) {
    try {
      const data = await strapi.service('api::profile.profile').follow(
        ctx.params.username,
        ctx.state.user.id,
      );
      ctx.body = success(data);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async unfollow(ctx) {
    try {
      const data = await strapi.service('api::profile.profile').unfollow(
        ctx.params.username,
        ctx.state.user.id,
      );
      ctx.body = success(data);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
