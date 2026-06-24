const { describe, it } = require('node:test');
const assert = require('node:assert/strict');

describe('InstaPET health contract', () => {
  it('response envelope shape', () => {
    const response = {
      data: { status: 'ok', version: '1.0.0', time: new Date().toISOString() },
      meta: {},
      error: null,
    };
    assert.equal(response.error, null);
    assert.equal(response.data.status, 'ok');
  });

  it('error envelope shape', () => {
    const response = {
      data: null,
      meta: {},
      error: { code: 'UNAUTHORIZED', message: 'Forbidden', details: {} },
    };
    assert.ok(response.error.code);
  });
});
