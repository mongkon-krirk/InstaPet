import type { Core } from '@strapi/strapi';
import { AppError, throwIf } from './errors';

const ALLOWED_MIMES = ['image/jpeg', 'image/png', 'image/webp'];

export const uploadOwnershipService = (strapi: Core.Strapi) => ({
  getBaseUrl() {
    const publicUrl = strapi.config.get('custom.publicApiUrl') as string | undefined;
    if (publicUrl) return publicUrl.replace(/\/api$/, '');
    const host = strapi.config.get('server.host') as string;
    const port = strapi.config.get('server.port') as number;
    return `http://${host === '0.0.0.0' ? 'localhost' : host}:${port}`;
  },

  getUploadLimits() {
    return {
      maxBytes: Number(process.env.UPLOAD_MAX_FILE_BYTES || 5242880),
      maxFiles: Number(process.env.UPLOAD_MAX_FILES_PER_REQUEST || 10),
      allowedTypes: (process.env.UPLOAD_ALLOWED_TYPES || ALLOWED_MIMES.join(',')).split(','),
    };
  },

  validateFiles(files: { size: number; mimetype: string }[]) {
    const { maxBytes, maxFiles, allowedTypes } = this.getUploadLimits();
    throwIf(files.length === 0, 'VALIDATION_ERROR', 'No files provided', 400);
    throwIf(files.length > maxFiles, 'MEDIA_LIMIT_EXCEEDED', `Maximum ${maxFiles} files allowed`, 400);

    for (const file of files) {
      throwIf(!allowedTypes.includes(file.mimetype), 'UNSUPPORTED_MEDIA_TYPE', 'Unsupported file type', 400);
      throwIf(file.size > maxBytes, 'VALIDATION_ERROR', 'File too large', 400);
    }
  },

  async uploadForUser(userId: number, files: unknown[], purpose: 'post' | 'avatar') {
    this.validateFiles(files as { size: number; mimetype: string }[]);

    const uploaded = await strapi.plugin('upload').service('upload').upload({
      data: {},
      files,
    });

    const results = [];
    for (const file of uploaded) {
      const owner = await strapi.documents('api::app-media-owner.app-media-owner').create({
        data: {
          uploadFile: file.id,
          user: userId,
          purpose,
          usageStatus: 'uploaded',
        },
      });
      results.push({ file, owner });
    }
    return results;
  },

  async getOwnerByFileId(fileId: number) {
    return strapi.db.query('api::app-media-owner.app-media-owner').findOne({
      where: { uploadFile: fileId },
      populate: ['user', 'uploadFile'],
    });
  },

  async assertOwnedByUser(fileIds: number[], userId: number) {
    for (const fileId of fileIds) {
      const owner = await this.getOwnerByFileId(fileId);
      throwIf(!owner, 'MEDIA_NOT_READY', 'Media not found', 404);
      throwIf(owner.user?.id !== userId, 'MEDIA_NOT_OWNED', 'Media not owned by user', 403);
      throwIf(owner.usageStatus === 'attached', 'MEDIA_NOT_READY', 'Media already attached', 400);
    }
  },

  async markAttached(fileIds: number[]) {
    for (const fileId of fileIds) {
      const owner = await this.getOwnerByFileId(fileId);
      if (owner) {
        await strapi.db.query('api::app-media-owner.app-media-owner').update({
          where: { id: owner.id },
          data: { usageStatus: 'attached' },
        });
      }
    }
  },

  async markUnused(fileIds: number[]) {
    for (const fileId of fileIds) {
      const owner = await this.getOwnerByFileId(fileId);
      if (owner) {
        await strapi.db.query('api::app-media-owner.app-media-owner').update({
          where: { id: owner.id },
          data: { usageStatus: 'unused' },
        });
      }
    }
  },

  async deleteIfUnused(fileId: number, userId: number) {
    const owner = await this.getOwnerByFileId(fileId);
    throwIf(!owner, 'RESOURCE_NOT_FOUND', 'File not found', 404);
    throwIf(owner.user?.id !== userId, 'FORBIDDEN', 'Not allowed', 403);
    throwIf(owner.usageStatus === 'attached', 'FORBIDDEN', 'File is in use', 400);

    const uploadFile = owner.uploadFile;
    if (uploadFile?.id) {
      await strapi.plugin('upload').service('upload').remove(uploadFile);
    }
    if (owner.documentId) {
      await strapi.documents('api::app-media-owner.app-media-owner').delete({
        documentId: owner.documentId,
      });
    }
  },

  toFileDto(
    file: {
      id: number;
      documentId?: string;
      name?: string;
      url?: string;
      mime?: string;
      size?: number;
      width?: number;
      height?: number;
    },
    purpose: string,
  ) {
    const baseUrl = this.getBaseUrl();
    const url = file.url?.startsWith('http') ? file.url : `${baseUrl}${file.url}`;
    return {
      id: file.id,
      documentId: file.documentId ?? String(file.id),
      name: file.name,
      url,
      mime: file.mime,
      sizeKb: file.size ? Number((file.size / 1024).toFixed(1)) : 0,
      width: file.width,
      height: file.height,
      purpose,
    };
  },
});

export const handleServiceError = (ctx: { status: number; body: unknown }, error: unknown) => {
  if (error instanceof AppError) {
    ctx.status = error.status;
    ctx.body = {
      data: null,
      meta: {},
      error: { code: error.code, message: error.message, details: error.details },
    };
    return;
  }
  throw error;
};
