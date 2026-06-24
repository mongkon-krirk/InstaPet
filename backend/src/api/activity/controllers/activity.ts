import { factories } from '@strapi/strapi';
import { buildPagination, paginated, parsePagination, success } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';

export default factories.createCoreController('api::activity.activity', ({ strapi }) => ({
  async list(ctx) {
    try {
      const { page, pageSize } = parsePagination(ctx.query as Record<string, unknown>);
      const { data, total } = await strapi.service('api::activity.activity').listForUser(
        ctx.state.user.id,
        page,
        pageSize,
      );
      ctx.body = paginated(data, buildPagination(page, pageSize, total));
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async markRead(ctx) {
    try {
      const { activityIds } = ctx.request.body as { activityIds: string[] };
      const result = await strapi.service('api::activity.activity').markRead(
        ctx.state.user.id,
        activityIds ?? [],
      );
      ctx.body = success(result);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
