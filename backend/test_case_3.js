require('dotenv').config();
const ai = require('./src/services/aiService');

async function main() {
    console.log('Testing Test Case 3 with Gemini API...');
    const result = await ai.processChatMessage(
        null,
        "I have had a fever of around 39°C for the last 3 days. I also have a persistent cough, feel very weak, and today I started experiencing some difficulty breathing when I walk. I don't have any chest pain. What should I do?"
    );
    console.log('\n=== RESULT FOR TEST CASE 3 ===');
    console.log('IS_EMERGENCY:', result.isEmergency);
    console.log('\nRESPONSE:\n', result.message);
}

main().catch(console.error);
