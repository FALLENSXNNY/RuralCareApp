// Server entry point
const { createApp } = require('./app');
const { connectDatabase, disconnectDatabase } = require('./config/database');
const { initializeFirebaseAdmin } = require('./config/firebase');
const { env, validateForRuntime } = require('./config/env');

async function main() {
    // Fail fast if runtime configuration is missing.
    validateForRuntime();

    // Initialize Firebase Admin (verifies credentials exist).
    initializeFirebaseAdmin();

    // Connect to MongoDB Atlas.
    await connectDatabase();

    const app = createApp();

    const host = process.env.HOST || '0.0.0.0';
    const server = app.listen(env.port, host, () => {
        console.log(`[server] RuralCare backend listening on http://${host}:${env.port}`);
    });

    // Graceful shutdown
    const shutdown = async () => {
        console.log('[server] Shutting down...');
        server.close();
        await disconnectDatabase();
        process.exit(0);
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
}

main().catch((err) => {
    console.error('[server] Failed to start:', err.message);
    process.exit(1);
});