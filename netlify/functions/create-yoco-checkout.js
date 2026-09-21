exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  const secret = process.env.YOCO_SECRET_KEY;
  if (!secret) {
    return { statusCode: 500, body: JSON.stringify({ error: 'Payment not configured' }) };
  }

  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return { statusCode: 400, body: JSON.stringify({ error: 'Invalid request body' }) };
  }

  const { amountCents, items, successUrl, cancelUrl } = body;

  if (!amountCents || amountCents < 100) {
    return { statusCode: 400, body: JSON.stringify({ error: 'Invalid amount' }) };
  }

  try {
    const res = await fetch('https://payments.yoco.com/api/checkouts', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${secret}`,
        'Content-Type': 'application/json',
        'Idempotency-Key': `${Date.now()}-${Math.random().toString(36).slice(2)}`,
      },
      body: JSON.stringify({
        amount: amountCents,
        currency: 'ZAR',
        successUrl,
        cancelUrl,
        metadata: { order_items: items },
      }),
    });

    const data = await res.json();

    if (!res.ok) {
      console.error('Yoco error:', JSON.stringify(data));
      return {
        statusCode: res.status,
        body: JSON.stringify({ error: data.displayMessage || data.message || 'Checkout creation failed' }),
      };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ redirectUrl: data.redirectUrl }),
    };
  } catch (err) {
    console.error('Function error:', err.message);
    return { statusCode: 500, body: JSON.stringify({ error: 'Internal error, please try again' }) };
  }
};
