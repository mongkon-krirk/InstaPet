type UserEntity = {
  documentId?: string;
  id?: number;
  username?: string;
  email?: string;
  displayName?: string;
  bio?: string | null;
  avatar?: { url?: string } | null;
  isPrivate?: boolean;
  postsCount?: number;
  followersCount?: number;
  followingCount?: number;
  status?: string;
  profileCompleted?: boolean;
};

const mediaUrl = (file: { url?: string } | null | undefined, baseUrl: string) => {
  if (!file?.url) return null;
  if (file.url.startsWith('http')) return file.url;
  return `${baseUrl}${file.url}`;
};

export const toPublicUser = (
  user: UserEntity,
  baseUrl: string,
  extras: Record<string, unknown> = {},
) => ({
  documentId: user.documentId,
  username: user.username,
  displayName: user.displayName ?? user.username,
  bio: user.bio ?? '',
  avatarUrl: mediaUrl(user.avatar, baseUrl),
  isPrivate: user.isPrivate ?? false,
  postsCount: user.postsCount ?? 0,
  followersCount: user.followersCount ?? 0,
  followingCount: user.followingCount ?? 0,
  ...extras,
});

export const toMeUser = (user: UserEntity, baseUrl: string) => ({
  ...toPublicUser(user, baseUrl, { isMe: true }),
  email: user.email,
  profileCompleted: user.profileCompleted ?? false,
});

export const toPostMediaItem = (
  item: {
    image?: { url?: string; width?: number; height?: number };
    sortOrder?: number;
    altText?: string;
    id?: number;
    documentId?: string;
    width?: number;
    height?: number;
  },
  baseUrl: string,
) => {
  const width = item.image?.width ?? item.width;
  const height = item.image?.height ?? item.height;
  const aspectRatio =
    width && height ? Number((width / height).toFixed(4)) : null;

  return {
    documentId: item.documentId ?? String(item.id),
    url: mediaUrl(item.image, baseUrl),
    width,
    height,
    aspectRatio,
    sortOrder: item.sortOrder ?? 0,
    altText: item.altText ?? '',
  };
};
