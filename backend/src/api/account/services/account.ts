import { factories } from '@strapi/strapi';
import bcrypt from 'bcryptjs';
import { throwIf } from '../../../utils/errors';

export default factories.createCoreService('api::account.account', ({ strapi }) => ({
  async changePassword(
    userId: number,
    currentPassword: string,
    newPassword: string,
    confirmation: string,
  ) {
    throwIf(newPassword.length < 8, 'VALIDATION_ERROR', 'Password must be at least 8 characters', 400);
    throwIf(newPassword !== confirmation, 'VALIDATION_ERROR', 'Passwords do not match', 400);

    const user = await strapi.db.query('plugin::users-permissions.user').findOne({
      where: { id: userId },
    });
    throwIf(!user, 'RESOURCE_NOT_FOUND', 'User not found', 404);

    const valid = await bcrypt.compare(currentPassword, user.password);
    throwIf(!valid, 'CURRENT_PASSWORD_INVALID', 'Current password is incorrect', 400);
    throwIf(currentPassword === newPassword, 'VALIDATION_ERROR', 'New password must differ', 400);

    const hashed = await bcrypt.hash(newPassword, 10);
    await strapi.db.query('plugin::users-permissions.user').update({
      where: { id: userId },
      data: { password: hashed },
    });

    return { success: true, message: 'Password changed. Please login again.' };
  },
}));
