import { factories } from '@strapi/strapi';
import { toPublicUser } from '../../../utils/dto';
import { getUploadOwnership } from '../../../utils/strapi-helpers';

export default factories.createCoreService('api::activity.activity', ({ strapi }) => ({
  async listForUser(userId: number, page: number, pageSize: number) {
    const start = (page - 1) * pageSize;
    const baseUrl = getUploadOwnership(strapi).getBaseUrl();

    const activities = await strapi.db.query('api::activity.activity').findMany({
      where: { recipient: userId },
      populate: {
        actor: { populate: ['avatar'] },
        post: { populate: { mediaItems: { populate: ['image'] } } },
      },
      orderBy: { createdAt: 'desc' },
      offset: start,
      limit: pageSize,
    });

    const total = await strapi.db.query('api::activity.activity').count({
      where: { recipient: userId },
    });

    return {
      data: activities.map((a: Record<string, unknown>) => ({
        documentId: a.documentId,
        type: a.type,
        isRead: a.isRead,
        createdAt: a.createdAt,
        actor: toPublicUser(a.actor as Parameters<typeof toPublicUser>[0], baseUrl),
        post: a.post
          ? {
              documentId: (a.post as { documentId: string }).documentId,
              caption: (a.post as { caption?: string }).caption,
            }
          : null,
      })),
      total,
    };
  },

  async markRead(userId: number, activityIds: string[]) {
    for (const documentId of activityIds) {
      const activity = await strapi.documents('api::activity.activity').findMany({
        filters: { documentId, recipient: { id: userId } },
        limit: 1,
      });
      if (activity[0]) {
        await strapi.db.query('api::activity.activity').update({
          where: { id: activity[0].id },
          data: { isRead: true },
        });
      }
    }
    return { updated: activityIds.length };
  },
}));
