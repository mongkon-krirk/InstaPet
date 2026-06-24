import { createStrapi } from '@strapi/strapi';

import seedData from './seed-data';

async function main() {
  process.env.SEED_DATA = 'false';
  const force = process.env.SEED_FORCE === 'true';
  const strapi = await createStrapi({ distDir: './dist' }).load();

  try {
    await seedData(strapi, { force: force || true });
  } finally {
    await strapi.destroy();
  }
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
