import { factories } from '@strapi/strapi';
import { throwIf } from '../../../utils/errors';
import { toPublicUser } from '../../../utils/dto';
import { getUploadOwnership } from '../../../utils/strapi-helpers';

export default factories.createCoreService('api::search.search', ({ strapi }) => ({
  async searchUsers(query: string, page: number, pageSize: number) {
    const q = query.trim();
    throwIf(q.length < 2, 'VALIDATION_ERROR', 'Query must be at least 2 characters', 400);

    const start = (page - 1) * pageSize;
    const baseUrl = getUploadOwnership(strapi).getBaseUrl();

    const users = await strapi.documents('plugin::users-permissions.user').findMany({
      filters: {
        status: 'active',
        blocked: false,
        $or: [
          { username: { $containsi: q } },
          { displayName: { $containsi: q } },
        ],
      },
      populate: ['avatar'],
      start,
      limit: pageSize,
    });

    const total = users.length;

    return {
      data: users.map((user) => toPublicUser(user as Parameters<typeof toPublicUser>[0], baseUrl)),
      total,
    };
  },
}));
