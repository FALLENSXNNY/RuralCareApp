// Mongoose model for AI chat conversations and message history (Phase 7)
const mongoose = require('mongoose');

const aiConversationSchema = new mongoose.Schema(
    {
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Patient',
            required: true,
            index: true,
        },
        role: {
            type: String,
            enum: ['user', 'assistant', 'system'],
            required: true,
        },
        content: {
            type: String,
            required: true,
            trim: true,
        },
        isEmergency: {
            type: Boolean,
            default: false,
        },
    },
    {
        timestamps: true,
    }
);

aiConversationSchema.index({ patientId: 1, createdAt: -1 });

module.exports = mongoose.model('AiConversation', aiConversationSchema);
