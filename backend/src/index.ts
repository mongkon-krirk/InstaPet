import type { Core } from '@strapi/strapi';
import seedData from '../scripts/seed-data';

const PUBLIC_ACTIONS = new Set([
  'api::health.health.check',
  'plugin::users-permissions.auth.callback',
  'plugin::users-permissions.auth.register',
]);

const AUTHENTICATED_ACTIONS = new Set([
  'api::health.health.check',
  'api::feed.feed.getFeed',
  'api::profile.profile.me',
  'api::profile.profile.updateMe',
  'api::profile.profile.findByUsername',
  'api::profile.profile.getPosts',
  'api::profile.profile.getFollowers',
  'api::profile.profile.getFollowing',
  'api::profile.profile.follow',
  'api::profile.profile.unfollow',
  'api::post.post.create',
  'api::post.post.findOne',
  'api::post.post.delete',
  'api::post.post.like',
  'api::post.post.unlike',
  'api::app-media.app-media.upload',
  'api::app-media.app-media.deleteFile',
  'api::search.search.searchUsers',
  'api::activity.activity.list',
  'api::activity.activity.markRead',
  'api::account.account.changePassword',
  'plugin::users-permissions.auth.callback',
  'plugin::users-permissions.user.me',
]);

async function linkPermissionToRole(
  strapi: Core.Strapi,
  permissionId: number,
  roleId: number,
) {
  const knex = strapi.db.connection;
  const existing = await knex('up_permissions_role_lnk')
    .where({ permission_id: permissionId, role_id: roleId })
    .first();
  if (!existing) {
    await knex('up_permissions_role_lnk').insert({
      permission_id: permissionId,
      role_id: roleId,
      permission_ord: 1,
    });
  }
}

async function ensurePermission(strapi: Core.Strapi, action: string) {
  let permission = await strapi.db.query('plugin::users-permissions.permission').findOne({
    where: { action },
  });
  if (!permission) {
    permission = await strapi.db.query('plugin::users-permissions.permission').create({
      data: { action, publishedAt: new Date().toISOString() },
    });
  }
  return permission;
}

async function setupPermissions(strapi: Core.Strapi) {
  const publicRole = await strapi.db.query('plugin::users-permissions.role').findOne({
    where: { type: 'public' },
  });
  const authRole = await strapi.db.query('plugin::users-permissions.role').findOne({
    where: { type: 'authenticated' },
  });

  if (!publicRole || !authRole) return;

  const allActions = new Set([...PUBLIC_ACTIONS, ...AUTHENTICATED_ACTIONS]);

  for (const action of allActions) {
    const permission = await ensurePermission(strapi, action);
    if (PUBLIC_ACTIONS.has(action)) {
      await linkPermissionToRole(strapi, permission.id, publicRole.id);
    }
    if (AUTHENTICATED_ACTIONS.has(action)) {
      await linkPermissionToRole(strapi, permission.id, authRole.id);
    }
  }
}

export default {
  register({ strapi }: { strapi: Core.Strapi }) {
    strapi.config.set('custom.publicApiUrl', process.env.PUBLIC_API_URL || 'http://localhost:1338');

    strapi.db.lifecycles.subscribe({
      models: ['plugin::users-permissions.user'],
      async afterCreate(event) {
        const { result } = event;
        if (!result.displayName) {
          await strapi.db.query('plugin::users-permissions.user').update({
            where: { id: result.id },
            data: {
              displayName: result.username,
              isPrivate: false,
              status: 'active',
              postsCount: 0,
              followersCount: 0,
              followingCount: 0,
              profileCompleted: false,
              confirmed: true,
            },
          });
        }
      },
    });
  },

  async bootstrap({ strapi }: { strapi: Core.Strapi }) {
    await setupPermissions(strapi);

    if (process.env.SEED_DATA === 'true') {
      const force = process.env.SEED_FORCE === 'true';
      const postCount = await strapi.db.query('api::post.post').count();
      if (force || postCount === 0) {
        await seedData(strapi, { force });
      }
    }
  },
};
