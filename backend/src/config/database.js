// MongoDB Atlas connection
const mongoose = require('mongoose');
const { env } = require('./env');

/**
 * Connects to MongoDB Atlas using MONGODB_URI from environment.
 * Never log or expose the connection string.
 */
async function connectDatabase() {
    if (!env.mongoUri) {
        throw new Error('MONGODB_URI is required. See backend/.env.example.');
    }

    mongoose.set('strictQuery', true);

    await mongoose.connect(env.mongoUri, {
        serverSelectionTimeoutMS: 10000,
    });

    const host = mongoose.connection.host; // host only — never the credentials
    console.log(`[db] Connected to MongoDB Atlas (${host})`);
    return mongoose.connection;
}

async function disconnectDatabase() {
    if (mongoose.connection.readyState !== 0) {
        await mongoose.disconnect();
    }
}

module.exports = { connectDatabase, disconnectDatabase };