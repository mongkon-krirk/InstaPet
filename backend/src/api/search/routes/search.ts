export default {
  routes: [
    {
      method: 'GET',
      path: '/search/users',
      handler: 'search.searchUsers',
      config: { policies: [], middlewares: [] },
    },
  ],
};
