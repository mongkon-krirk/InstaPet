import { factories } from '@strapi/strapi';
import { buildPagination, paginated, parsePagination } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';

export default factories.createCoreController('api::feed.feed', ({ strapi }) => ({
  async getFeed(ctx) {
    try {
      const user = ctx.state.user;
      const mode = (ctx.query.mode as string) || 'home';
      const { page, pageSize } = parsePagination(ctx.query as Record<string, unknown>);
      const { data, total } = await strapi.service('api::feed.feed').getFeed(user.id, mode, page, pageSize);
      ctx.body = paginated(data, buildPagination(page, pageSize, total));
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
