import { success } from '../../../utils/response';

export default {
  async check(ctx) {
    ctx.body = success({
      status: 'ok',
      version: '1.0.0',
      time: new Date().toISOString(),
    });
  },
};
