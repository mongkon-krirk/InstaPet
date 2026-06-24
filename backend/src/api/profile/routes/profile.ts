export default {
  routes: [
    {
      method: 'GET',
      path: '/profiles/me',
      handler: 'profile.me',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'PATCH',
      path: '/profiles/me',
      handler: 'profile.updateMe',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'GET',
      path: '/profiles/:username',
      handler: 'profile.findByUsername',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'GET',
      path: '/profiles/:username/posts',
      handler: 'profile.getPosts',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'GET',
      path: '/profiles/:username/followers',
      handler: 'profile.getFollowers',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'GET',
      path: '/profiles/:username/following',
      handler: 'profile.getFollowing',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'PUT',
      path: '/profiles/:username/follow',
      handler: 'profile.follow',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'DELETE',
      path: '/profiles/:username/follow',
      handler: 'profile.unfollow',
      config: { policies: [], middlewares: [] },
    },
  ],
};
