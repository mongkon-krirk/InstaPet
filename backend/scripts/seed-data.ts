import type { Core } from '@strapi/strapi';

import { uploadPetImage } from './seed-images';
import type { PetKind } from './seed-images';

const DEMO_PASSWORD = 'demo12345';

type DemoUser = {
  username: string;
  email: string;
  displayName: string;
  bio: string;
  petKind: PetKind;
};

const DEMO_USERS: DemoUser[] = [
  { username: 'milo_cat', email: 'milo@instapet.demo', displayName: 'Milo the Cat', bio: 'Sleep. Eat. Repeat.', petKind: 'cat' },
  { username: 'buddy_dog', email: 'buddy@instapet.demo', displayName: 'Buddy', bio: 'Good boy forever.', petKind: 'dog' },
  { username: 'luna_bunny', email: 'luna@instapet.demo', displayName: 'Luna', bio: 'Hop hop hop!', petKind: 'rabbit' },
  { username: 'pip_hamster', email: 'pip@instapet.demo', displayName: 'Pip', bio: 'Tiny but mighty.', petKind: 'hamster' },
  { username: 'kiwi_bird', email: 'kiwi@instapet.demo', displayName: 'Kiwi', bio: 'Chirp chirp!', petKind: 'bird' },
  { username: 'shelly_turtle', email: 'shelly@instapet.demo', displayName: 'Shelly', bio: 'Slow and steady.', petKind: 'turtle' },
  { username: 'goldie_fish', email: 'goldie@instapet.demo', displayName: 'Goldie', bio: 'Just keep swimming.', petKind: 'fish' },
  { username: 'pepper_parrot', email: 'pepper@instapet.demo', displayName: 'Pepper', bio: 'Polly wants a cracker.', petKind: 'parrot' },
  { username: 'cozy_guinea', email: 'cozy@instapet.demo', displayName: 'Cozy', bio: 'Snacks and naps.', petKind: 'guinea' },
  { username: 'shadow_ferret', email: 'shadow@instapet.demo', displayName: 'Shadow', bio: 'Chaos in a tiny package.', petKind: 'ferret' },
];

const CAPTIONS = [
  'Best day ever with my human!',
  'Nap time is the best time.',
  'Look at this adorable face!',
  'Adventure mode: ON',
  'Treats please!',
  'Sunbeam therapy session.',
  'New toy, who dis?',
  'Just vibing.',
  'Park day with friends.',
  'Cuddle break required.',
  'Mischief managed.',
  'Living my best pet life.',
];

const POSTS_PER_USER = 10;
const MIN_IMAGES = 1;
const MAX_IMAGES = 5;

function randomInt(min: number, max: number) {
  return min + Math.floor(Math.random() * (max - min + 1));
}

function daysAgo(days: number) {
  const date = new Date();
  date.setDate(date.getDate() - days);
  date.setHours(randomInt(8, 20), randomInt(0, 59), 0, 0);
  return date.toISOString();
}

async function clearDemoContent(strapi: Core.Strapi) {
  await strapi.db.query('api::activity.activity').deleteMany({ where: {} });
  await strapi.db.query('api::post-like.post-like').deleteMany({ where: {} });
  await strapi.db.query('api::follow.follow').deleteMany({ where: {} });
  await strapi.db.query('api::post.post').deleteMany({ where: {} });
  await strapi.db.query('api::app-media-owner.app-media-owner').deleteMany({ where: {} });

  const files = await strapi.db.query('plugin::upload.file').findMany();
  for (const file of files) {
    try {
      await strapi.plugin('upload').service('upload').remove(file);
    } catch {
      // ignore missing files on disk
    }
  }

  const users = await strapi.db.query('plugin::users-permissions.user').findMany();
  for (const user of users) {
    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: user.id },
      data: {
        postsCount: 0,
        followersCount: 0,
        followingCount: 0,
        avatar: null,
      },
    });
  }
}

async function ensureUser(strapi: Core.Strapi, demo: DemoUser, roleId: number) {
  const userService = strapi.plugin('users-permissions').service('user');
  const existing = await strapi.db.query('plugin::users-permissions.user').findOne({
    where: { username: demo.username },
    populate: ['avatar'],
  });

  if (existing) {
    return existing;
  }

  return userService.add({
    username: demo.username,
    email: demo.email,
    password: DEMO_PASSWORD,
    displayName: demo.displayName,
    bio: demo.bio,
    provider: 'local',
    confirmed: true,
    role: roleId,
    isPrivate: false,
    status: 'active',
    postsCount: 0,
    followersCount: 0,
    followingCount: 0,
    profileCompleted: true,
  });
}

async function ensureAvatar(
  strapi: Core.Strapi,
  user: { id: number; avatar?: { id: number } | null },
  petKind: PetKind,
  seed: number,
) {
  if (user.avatar?.id) return;

  const file = await uploadPetImage(strapi, user.id, petKind, seed, 'avatar');
  await strapi.db.query('plugin::users-permissions.user').update({
    where: { id: user.id },
    data: { avatar: file.id },
  });
  const owner = await strapi.db.query('api::app-media-owner.app-media-owner').findOne({
    where: { uploadFile: file.id },
  });
  if (owner) {
    await strapi.db.query('api::app-media-owner.app-media-owner').update({
      where: { id: owner.id },
      data: { usageStatus: 'attached' },
    });
  }
}

async function createPostForUser(
  strapi: Core.Strapi,
  userId: number,
  petKind: PetKind,
  seedBase: number,
  postIndex: number,
) {
  const imageCount = randomInt(MIN_IMAGES, MAX_IMAGES);
  const mediaItems = [];

  for (let i = 0; i < imageCount; i++) {
    try {
      const file = await uploadPetImage(strapi, userId, petKind, seedBase + postIndex * 10 + i, 'post');
      mediaItems.push({
        fileId: file.id,
        sortOrder: i,
        altText: `${petKind} photo ${i + 1}`,
      });
    } catch (error) {
      // eslint-disable-next-line no-console
      console.warn(`  ! skipped image ${i + 1} for post ${postIndex + 1}:`, (error as Error).message);
    }
  }

  if (mediaItems.length === 0) {
    throw new Error('No images could be downloaded for post');
  }

  const postService = strapi.service('api::post.post') as {
    createPost: (
      userId: number,
      payload: {
        caption?: string;
        visibility?: string;
        mediaItems: { fileId: number; sortOrder: number; altText?: string }[];
      },
    ) => Promise<{ id: number }>;
  };

  const post = await postService.createPost(userId, {
    caption: CAPTIONS[(seedBase + postIndex) % CAPTIONS.length],
    visibility: 'public',
    mediaItems,
  });

  await strapi.db.query('api::post.post').update({
    where: { id: post.id },
    data: { publishedAt: daysAgo(randomInt(0, 28)) },
  });
}

async function seedFollows(strapi: Core.Strapi, users: { id: number }[]) {
  for (let i = 0; i < users.length; i++) {
    const follower = users[i];
    const targets = [
      users[(i + 1) % users.length],
      users[(i + 3) % users.length],
    ].filter((u) => u.id !== follower.id);

    for (const target of targets) {
      const existing = await strapi.db.query('api::follow.follow').findOne({
        where: { follower: follower.id, following: target.id },
      });
      if (!existing) {
        await strapi.db.query('api::follow.follow').create({
          data: { follower: follower.id, following: target.id, status: 'accepted' },
        });
      }
    }
  }

  for (const user of users) {
    const followersCount = await strapi.db.query('api::follow.follow').count({
      where: { following: user.id, status: 'accepted' },
    });
    const followingCount = await strapi.db.query('api::follow.follow').count({
      where: { follower: user.id, status: 'accepted' },
    });
    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: user.id },
      data: { followersCount, followingCount },
    });
  }
}

export default async function seedData(strapi: Core.Strapi, options: { force?: boolean } = {}) {
  const postCount = await strapi.db.query('api::post.post').count();
  if (postCount > 0 && !options.force) {
    // eslint-disable-next-line no-console
    console.log('InstaPET seed skipped — posts already exist. Set SEED_FORCE=true to reseed.');
    return [];
  }

  if (options.force) {
    // eslint-disable-next-line no-console
    console.log('InstaPET seed: clearing existing demo content...');
    await clearDemoContent(strapi);
  }

  const role = await strapi.db.query('plugin::users-permissions.role').findOne({
    where: { type: 'authenticated' },
  });
  if (!role) throw new Error('Authenticated role not found');

  // eslint-disable-next-line no-console
  console.log('InstaPET seed: creating 10 users with avatars...');
  const users = [];
  for (let i = 0; i < DEMO_USERS.length; i++) {
    const demo = DEMO_USERS[i];
    const user = await ensureUser(strapi, demo, role.id);
    await ensureAvatar(strapi, user, demo.petKind, i * 100);
    users.push({ ...user, petKind: demo.petKind, username: demo.username });
    // eslint-disable-next-line no-console
    console.log(`  ✓ user ${demo.username}`);
  }

  // eslint-disable-next-line no-console
  console.log('InstaPET seed: creating posts (10 per user, 1-5 images each)...');
  let totalPosts = 0;
  for (let u = 0; u < users.length; u++) {
    const user = users[u];
    const existingPosts = await strapi.db.query('api::post.post').count({
      where: { author: user.id, status: 'published' },
    });
    const toCreate = Math.max(0, POSTS_PER_USER - existingPosts);

    for (let p = 0; p < toCreate; p++) {
      try {
        await createPostForUser(strapi, user.id, user.petKind, u * 1000, existingPosts + p);
        totalPosts += 1;
        // eslint-disable-next-line no-console
        console.log(`  ✓ ${user.username} post ${existingPosts + p + 1}/${POSTS_PER_USER}`);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.warn(`  ! failed post ${existingPosts + p + 1} for ${user.username}:`, (error as Error).message);
      }
    }

    const postsCount = await strapi.db.query('api::post.post').count({
      where: { author: user.id, status: 'published' },
    });
    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: user.id },
      data: { postsCount },
    });
  }

  // eslint-disable-next-line no-console
  console.log('InstaPET seed: creating follow relationships...');
  await seedFollows(strapi, users);

  // eslint-disable-next-line no-console
  console.log(`InstaPET seed complete — ${users.length} users, ${totalPosts} new posts.`);
  // eslint-disable-next-line no-console
  console.log(`Demo password for all users: ${DEMO_PASSWORD}`);

  return users;
}
