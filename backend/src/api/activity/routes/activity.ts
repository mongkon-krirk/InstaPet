export default {
  routes: [
    {
      method: 'GET',
      path: '/activities',
      handler: 'activity.list',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'POST',
      path: '/activities/read',
      handler: 'activity.markRead',
      config: { policies: [], middlewares: [] },
    },
  ],
};
