import fs from 'fs';
import os from 'os';
import path from 'path';

import type { Core } from '@strapi/strapi';

export type PetKind = 'cat' | 'dog' | 'rabbit' | 'hamster' | 'bird' | 'fish' | 'turtle' | 'parrot' | 'guinea' | 'ferret';

function picsumUrl(seed: number) {
  return `https://picsum.photos/seed/instapet${seed}/800/600`;
}

const PET_LOREM_TAGS: Record<PetKind, string> = {
  cat: 'cat,kitten',
  dog: 'dog,puppy',
  rabbit: 'rabbit,bunny',
  hamster: 'hamster,pet',
  bird: 'bird,parakeet',
  fish: 'fish,aquarium',
  turtle: 'turtle,reptile',
  parrot: 'parrot,bird',
  guinea: 'guinea,pig,pet',
  ferret: 'ferret,pet',
};

export function petImageUrl(kind: PetKind, seed: number, width = 800, height = 600): string {
  if (kind === 'dog') {
    return `https://placedog.net/${width}/${height}?id=${seed % 50}`;
  }
  if (kind === 'cat') {
    return `https://placekitten.com/${width}/${height}?image=${(seed % 16) + 1}`;
  }
  const tag = PET_LOREM_TAGS[kind];
  return `https://loremflickr.com/${width}/${height}/${tag}?lock=${seed}`;
}

export function fallbackImageUrl(seed: number): string {
  return picsumUrl(seed);
}

export async function fetchImageBuffer(url: string): Promise<Buffer> {
  const response = await fetch(url, {
    redirect: 'follow',
    headers: { 'User-Agent': 'InstaPET-Seed/1.0' },
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status} for ${url}`);
  }
  const type = response.headers.get('content-type') ?? '';
  if (!type.startsWith('image/')) {
    throw new Error(`Not an image: ${url}`);
  }
  return Buffer.from(await response.arrayBuffer());
}

export async function fetchPetImage(kind: PetKind, seed: number): Promise<Buffer> {
  const urls = [
    petImageUrl(kind, seed),
    `https://placedog.net/800/600?id=${seed % 119}`,
    `https://placekitten.com/800/600?image=${(seed % 16) + 1}`,
    picsumUrl(seed),
    picsumUrl(seed + 17),
  ];

  let lastError: unknown;
  for (const url of urls) {
    try {
      return await fetchImageBuffer(url);
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function uploadBufferForUser(
  strapi: Core.Strapi,
  userId: number,
  buffer: Buffer,
  filename: string,
  purpose: 'post' | 'avatar',
) {
  const tmpPath = path.join(os.tmpdir(), `instapet-seed-${Date.now()}-${filename}`);
  fs.writeFileSync(tmpPath, buffer);

  try {
    const uploaded = await strapi.plugin('upload').service('upload').upload({
      data: {},
      files: {
        filepath: tmpPath,
        path: tmpPath,
        name: filename,
        type: 'image/jpeg',
        mimetype: 'image/jpeg',
        size: buffer.length,
      },
    });

    const file = Array.isArray(uploaded) ? uploaded[0] : uploaded;
    await strapi.documents('api::app-media-owner.app-media-owner').create({
      data: {
        uploadFile: file.id,
        user: userId,
        purpose,
        usageStatus: 'uploaded',
      },
    });

    return file as { id: number };
  } finally {
    if (fs.existsSync(tmpPath)) fs.unlinkSync(tmpPath);
  }
}

export async function uploadPetImage(
  strapi: Core.Strapi,
  userId: number,
  kind: PetKind,
  seed: number,
  purpose: 'post' | 'avatar',
) {
  const buffer = await fetchPetImage(kind, seed);
  const filename = `${kind}-${purpose}-${seed}.jpg`;
  const file = await uploadBufferForUser(strapi, userId, buffer, filename, purpose);
  await sleep(120);
  return file;
}
