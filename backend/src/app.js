// Express app — Phase 2 (auth + patient identity)
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const routes = require('./routes');
const { notFound, errorHandler } = require('./middleware/errorHandler');

function createApp() {
    const app = express();

    // Trust first proxy hop (Railway reverse proxy / edge gateway)
    app.set('trust proxy', 1);

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

    // Root & Health check for Railway uptime checks
    app.get('/', (req, res) => {
        res.status(200).json({
            status: 'ok',
            service: 'ruralcare-backend',
            message: 'RuralCare Backend API is running',
            health: '/health',
            api: '/api/v1'
        });
    });

    app.get('/health', (req, res) => {
        res.status(200).json({
            status: 'ok',
            service: 'ruralcare-backend',
            uptime: process.uptime(),
            timestamp: new Date().toISOString(),
        });
    });

    app.use('/api/v1', authLimiter, routes);

    // 404 + error handling
    app.use(notFound);
    app.use(errorHandler);

    return app;
}

module.exports = { createApp };