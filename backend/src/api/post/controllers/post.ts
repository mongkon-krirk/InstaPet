import { factories } from '@strapi/strapi';
import { success } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';

export default factories.createCoreController('api::post.post', ({ strapi }) => ({
  async create(ctx) {
    try {
      const user = ctx.state.user;
      const post = await strapi.service('api::post.post').createPost(user.id, ctx.request.body);
      const dto = await strapi.service('api::post.post').toPostDto(post as Record<string, unknown>, user.id);
      ctx.body = success(dto);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async findOne(ctx) {
    try {
      const { documentId } = ctx.params;
      const userId = ctx.state.user?.id;
      const post = await strapi.service('api::post.post').findPublishedByDocumentId(documentId);
      if (!post) {
        ctx.status = 404;
        ctx.body = { data: null, meta: {}, error: { code: 'POST_NOT_FOUND', message: 'Post not found', details: {} } };
        return;
      }
      const dto = await strapi.service('api::post.post').toPostDto(post as Record<string, unknown>, userId);
      ctx.body = success(dto);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async delete(ctx) {
    try {
      const user = ctx.state.user;
      const result = await strapi.service('api::post.post').deletePost(ctx.params.documentId, user.id);
      ctx.body = success(result);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async like(ctx) {
    try {
      const user = ctx.state.user;
      const result = await strapi.service('api::post.post').likePost(ctx.params.documentId, user.id);
      ctx.body = success(result);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async unlike(ctx) {
    try {
      const user = ctx.state.user;
      const result = await strapi.service('api::post.post').unlikePost(ctx.params.documentId, user.id);
      ctx.body = success(result);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
