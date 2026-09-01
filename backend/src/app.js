// Express app — Phase 2 (auth + patient identity)
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const routes = require('./routes');
const { notFound, errorHandler } = require('./middleware/errorHandler');

function createApp() {
    const app = express();

    // Basic middleware
    app.use(express.json({ limit: '1mb' }));

    // CORS — allow Flutter dev origins; tighten for production.
    app.use(
        cors({
            origin: true, // reflect request origin (dev). Restrict in production.
            credentials: false,
        })
    );

    // Rate limiting — protects auth endpoints from abuse.
    const authLimiter = rateLimit({
        windowMs: 15 * 60 * 1000,
        max: 100,
        standardHeaders: true,
        legacyHeaders: false,
    });

    app.use('/api/v1', authLimiter, routes);

    // 404 + error handling
    app.use(notFound);
    app.use(errorHandler);

    return app;
}

module.exports = { createApp };