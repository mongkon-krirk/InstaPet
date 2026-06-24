/**
 * Reconcile denormalized counter fields from actual relationships.
 * Run against the active database (SQLite local or PostgreSQL production).
 * No data migration — counters only.
 */
import { createStrapi } from '@strapi/strapi';

async function main() {
  const appContext = await createStrapi({ distDir: './dist' }).load();
  const strapi = appContext;

  const users = await strapi.db.query('plugin::users-permissions.user').findMany();
  for (const user of users) {
    const postsCount = await strapi.db.query('api::post.post').count({
      where: { author: user.id, status: 'published' },
    });
    const followersCount = await strapi.db.query('api::follow.follow').count({
      where: { following: user.id, status: 'accepted' },
    });
    const followingCount = await strapi.db.query('api::follow.follow').count({
      where: { follower: user.id, status: 'accepted' },
    });

    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: user.id },
      data: { postsCount, followersCount, followingCount },
    });
  }

  const posts = await strapi.db.query('api::post.post').findMany({
    where: { status: 'published' },
  });
  for (const post of posts) {
    const likesCount = await strapi.db.query('api::post-like.post-like').count({
      where: { post: post.id },
    });
    await strapi.db.query('api::post.post').update({
      where: { id: post.id },
      data: { likesCount },
    });
  }

  // eslint-disable-next-line no-console
  console.log(`Reconciled ${users.length} users and ${posts.length} posts.`);
  await strapi.destroy();
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
