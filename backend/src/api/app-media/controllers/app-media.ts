import { factories } from '@strapi/strapi';
import { success } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';
import { getUploadOwnership } from '../../../utils/strapi-helpers';

export default factories.createCoreController('api::app-media.app-media', ({ strapi }) => ({
  async upload(ctx) {
    try {
      const user = ctx.state.user;
      const purpose = (ctx.request.body.purpose as 'post' | 'avatar') || 'post';
      const files = ctx.request.files?.files;
      const fileList = Array.isArray(files) ? files : files ? [files] : [];

      const ownership = getUploadOwnership(strapi);
      const results = (await ownership.uploadForUser(user.id, fileList, purpose)) as Array<{
        file: Parameters<typeof ownership.toFileDto>[0];
        owner: { purpose: string };
      }>;

      const data = results.map(({ file, owner }) =>
        ownership.toFileDto(file, owner.purpose),
      );

      ctx.body = success(data);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },

  async deleteFile(ctx) {
    try {
      const user = ctx.state.user;
      const fileId = Number(ctx.params.fileId);
      await getUploadOwnership(strapi).deleteIfUnused(fileId, user.id);
      ctx.body = success({ deleted: true });
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
