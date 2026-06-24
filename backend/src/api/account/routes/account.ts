export default {
  routes: [
    {
      method: 'POST',
      path: '/account/change-password',
      handler: 'account.changePassword',
      config: { policies: [], middlewares: [] },
    },
  ],
};
