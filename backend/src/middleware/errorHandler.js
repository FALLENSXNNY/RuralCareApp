// Central error handler — controlled responses, no stack traces to clients.
function notFound(req, res) {
    res.status(404).json({
        error: 'NOT_FOUND',
        message: 'The requested resource was not found.',
    });
}

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
    // Log server-side only. Never expose internals to the client.
    console.error('[error]', err.message);

    const isProduction = process.env.NODE_ENV === 'production';

    res.status(err.status || 500).json({
        error: 'SERVER_ERROR',
        message: isProduction
            ? 'We could not complete this request. Please try again.'
            : err.message,
    });
}

module.exports = { notFound, errorHandler };