import type { Core } from '@strapi/strapi';

export default ({ env }: Core.Config.Shared.ConfigParams): Core.Config.Middlewares => {
  const isProduction = env('NODE_ENV') === 'production';
  const corsOrigins = isProduction
    ? (env('CORS_ORIGINS', '') as string).split(',').map((o) => o.trim()).filter(Boolean)
    : ['*'];

  return [
    'strapi::logger',
    'strapi::errors',
    'strapi::security',
    {
      name: 'strapi::cors',
      config: {
        origin: corsOrigins,
        headers: ['Content-Type', 'Authorization', 'Origin', 'Accept'],
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'],
      },
    },
    'strapi::poweredBy',
    'strapi::query',
    {
      name: 'strapi::body',
      config: {
        formLimit: '10mb',
        jsonLimit: '10mb',
        textLimit: '10mb',
        formidable: {
          maxFileSize: Number(env('UPLOAD_MAX_FILE_BYTES', 5242880)),
        },
      },
    },
    'strapi::session',
    'strapi::favicon',
    'strapi::public',
  ];
};
