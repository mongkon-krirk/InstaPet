import type { Core } from '@strapi/strapi';
import { uploadOwnershipService } from './upload-ownership';

export const getUploadOwnership = (strapi: Core.Strapi) => uploadOwnershipService(strapi);
