'use strict';

module.exports = function(env, ctx) {
  if (!env.ENABLE || !env.ENABLE.includes('sage')) return;

  const SAGE_URL = env.SAGE_URL;
  const SAGE_SENSOR = env.SAGE_SENSOR;

  async function fetchSage() {
    try {
      const res = await ctx.request.get(`${SAGE_URL}/sensor/${SAGE_SENSOR}`);
      const data = JSON.parse(res.body);

      ctx.bus.emit('devicestatus', {
        device: 'sage',
        created_at: new Date(),
        sage: data
      });

    } catch (err) {
      console.error('SAGE error:', err);
    }
  }

  setInterval(fetchSage, 60000);

  return { name: 'sage' };
};
