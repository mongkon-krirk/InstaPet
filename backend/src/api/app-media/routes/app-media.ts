export default {
  routes: [
    {
      method: 'POST',
      path: '/app-media/upload',
      handler: 'app-media.upload',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'DELETE',
      path: '/app-media/:fileId',
      handler: 'app-media.deleteFile',
      config: { policies: [], middlewares: [] },
    },
  ],
};
