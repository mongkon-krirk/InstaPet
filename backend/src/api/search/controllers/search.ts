import { factories } from '@strapi/strapi';
import { buildPagination, paginated, parsePagination } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';

export default factories.createCoreController('api::search.search', ({ strapi }) => ({
  async searchUsers(ctx) {
    try {
      const q = (ctx.query.q as string) || '';
      const { page, pageSize } = parsePagination(ctx.query as Record<string, unknown>);
      const { data, total } = await strapi.service('api::search.search').searchUsers(q, page, pageSize);
      ctx.body = paginated(data, buildPagination(page, pageSize, total));
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
