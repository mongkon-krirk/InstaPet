export default (plugin: {
  controllers: { auth: { register: (ctx: unknown) => Promise<unknown> } };
}) => {
  const originalRegister = plugin.controllers.auth.register;

  plugin.controllers.auth.register = async (ctx: {
    request: { body: Record<string, string> };
  }) => {
    const body = ctx.request.body;
    if (body.username) {
      body.username = body.username.trim().toLowerCase();
    }
    if (body.email) {
      body.email = body.email.trim().toLowerCase();
    }
    return originalRegister(ctx);
  };

  return plugin;
};
