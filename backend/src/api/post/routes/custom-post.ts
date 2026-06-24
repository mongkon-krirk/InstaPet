export default {
  routes: [
    {
      method: 'POST',
      path: '/posts',
      handler: 'post.create',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'GET',
      path: '/posts/:documentId',
      handler: 'post.findOne',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'DELETE',
      path: '/posts/:documentId',
      handler: 'post.delete',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'PUT',
      path: '/posts/:documentId/like',
      handler: 'post.like',
      config: { policies: [], middlewares: [] },
    },
    {
      method: 'DELETE',
      path: '/posts/:documentId/like',
      handler: 'post.unlike',
      config: { policies: [], middlewares: [] },
    },
  ],
};
