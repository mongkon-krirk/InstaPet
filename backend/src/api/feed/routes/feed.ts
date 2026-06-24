export default {
  routes: [
    {
      method: 'GET',
      path: '/feed',
      handler: 'feed.getFeed',
      config: { policies: [], middlewares: [] },
    },
  ],
};
