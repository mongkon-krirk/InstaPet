import type { Core } from '@strapi/strapi';

export default ({ env }: Core.Config.Shared.ConfigParams): Core.Config.Plugin => {
  const provider = env('UPLOAD_PROVIDER', 'local');

  if (provider === 'cloudflare-r2') {
    return {
      upload: {
        config: {
          provider: '@strapi/provider-upload-aws-s3',
          providerOptions: {
            credentials: {
              accessKeyId: env('R2_ACCESS_KEY_ID'),
              secretAccessKey: env('R2_SECRET_ACCESS_KEY'),
            },
            region: 'auto',
            endpoint: env('R2_ENDPOINT'),
            params: {
              Bucket: env('R2_BUCKET'),
            },
            baseUrl: env('R2_PUBLIC_BASE_URL'),
          },
        },
      },
    };
  }

  return {
    upload: {
      config: {
        provider: 'local',
        providerOptions: {
          sizeLimit: Number(env('UPLOAD_MAX_FILE_BYTES', 5242880)),
        },
      },
    },
  };
};
