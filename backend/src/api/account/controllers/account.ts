import { factories } from '@strapi/strapi';
import { success } from '../../../utils/response';
import { handleServiceError } from '../../../utils/upload-ownership';

export default factories.createCoreController('api::account.account', ({ strapi }) => ({
  async changePassword(ctx) {
    try {
      const { currentPassword, newPassword, newPasswordConfirmation } = ctx.request.body as {
        currentPassword: string;
        newPassword: string;
        newPasswordConfirmation: string;
      };
      const result = await strapi.service('api::account.account').changePassword(
        ctx.state.user.id,
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      ctx.body = success(result);
    } catch (error) {
      handleServiceError(ctx, error);
    }
  },
}));
