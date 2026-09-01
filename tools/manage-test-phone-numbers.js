#!/usr/bin/env node
/**
 * manage-test-phone-numbers.js
 *
 * Adds, lists, or removes phone numbers configured for Firebase Authentication
 * via the Google Identity Toolkit Admin REST API.
 *
 * Usage:
 *   # List all registered test phone numbers
 *   node tools/manage-test-phone-numbers.js list
 *
 *   # Add a phone number (e.g. +919876543210 with code 123456)
 *   node tools/manage-test-phone-numbers.js add +919876543210 123456
 *
 *   # Remove a phone number
 *   node tools/manage-test-phone-numbers.js remove +919876543210
 */

const fs = require('fs');
const path = require('path');

let JWT;
try {
  JWT = require('google-auth-library').JWT;
} catch (_) {
  JWT = require(path.join(__dirname, '..', 'backend', 'node_modules', 'google-auth-library')).JWT;
}

const DEFAULT_KEY_FILE = 'C:\\secrets\\ruralcare-firebase-admin.json';
const PROJECT_ID = 'luciferai-3b049';

async function getClient(keyFile) {
  if (!fs.existsSync(keyFile)) {
    throw new Error(`Service account key not found at: ${keyFile}`);
  }
  const creds = JSON.parse(fs.readFileSync(keyFile, 'utf8'));
  return new JWT({
    email: creds.client_email,
    key: creds.private_key,
    scopes: [
      'https://www.googleapis.com/auth/firebase',
      'https://www.googleapis.com/auth/cloud-platform',
    ],
  });
}

function normalizePhone(raw) {
  let cleaned = raw.trim().replace(/[\s-]/g, '');
  if (!cleaned.startsWith('+')) {
    if (cleaned.length === 10) {
      cleaned = '+91' + cleaned;
    } else {
      cleaned = '+' + cleaned;
    }
  }
  return cleaned;
}

async function main() {
  const args = process.argv.slice(2);
  const action = args[0] || 'list';
  const keyFile = process.env.GOOGLE_APPLICATION_CREDENTIALS || DEFAULT_KEY_FILE;

  const client = await getClient(keyFile);
  const { token } = await client.getAccessToken();

  const configUrl = `https://identitytoolkit.googleapis.com/admin/v2/projects/${encodeURIComponent(PROJECT_ID)}/config`;
  const headers = {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // Fetch current config
  const getRes = await fetch(configUrl, { headers });
  if (!getRes.ok) {
    const text = await getRes.text();
    throw new Error(`Failed to fetch config (${getRes.status}): ${text}`);
  }
  const currentConfig = await getRes.json();
  const currentNumbers = (currentConfig.signIn && currentConfig.signIn.phoneNumber && currentConfig.signIn.phoneNumber.testPhoneNumbers) || {};

  if (action === 'list') {
    console.log('\n--- Registered Firebase Phone Numbers ---');
    const keys = Object.keys(currentNumbers);
    if (keys.length === 0) {
      console.log('No test phone numbers configured.');
    } else {
      for (const phone of keys) {
        console.log(`Phone: ${phone}  →  Code: ${currentNumbers[phone]}`);
      }
    }
    console.log('-----------------------------------------\n');
    return;
  }

  if (action === 'add') {
    const rawPhone = args[1];
    const code = args[2] || '123456';
    if (!rawPhone) {
      console.error('Usage: node tools/manage-test-phone-numbers.js add <phoneNumber> [otpCode]');
      process.exit(1);
    }
    const phone = normalizePhone(rawPhone);
    currentNumbers[phone] = code;

    const patchUrl = `${configUrl}?updateMask=signIn.phoneNumber.testPhoneNumbers,signIn.phoneNumber.enabled`;
    const patchBody = {
      signIn: {
        phoneNumber: {
          enabled: true,
          testPhoneNumbers: currentNumbers,
        },
      },
    };

    const patchRes = await fetch(patchUrl, {
      method: 'PATCH',
      headers,
      body: JSON.stringify(patchBody),
    });

    if (!patchRes.ok) {
      const text = await patchRes.text();
      throw new Error(`Failed to add phone number (${patchRes.status}): ${text}`);
    }

    console.log(`\n✓ Successfully registered ${phone} with OTP code [${code}] on Firebase!`);
    console.log('You can now type this number in the app, click "Send OTP", and enter this code.\n');
    return;
  }

  if (action === 'remove') {
    const rawPhone = args[1];
    if (!rawPhone) {
      console.error('Usage: node tools/manage-test-phone-numbers.js remove <phoneNumber>');
      process.exit(1);
    }
    const phone = normalizePhone(rawPhone);
    delete currentNumbers[phone];

    const patchUrl = `${configUrl}?updateMask=signIn.phoneNumber.testPhoneNumbers`;
    const patchBody = {
      signIn: {
        phoneNumber: {
          testPhoneNumbers: currentNumbers,
        },
      },
    };

    const patchRes = await fetch(patchUrl, {
      method: 'PATCH',
      headers,
      body: JSON.stringify(patchBody),
    });

    if (!patchRes.ok) {
      const text = await patchRes.text();
      throw new Error(`Failed to remove phone number (${patchRes.status}): ${text}`);
    }

    console.log(`\n✓ Removed ${phone} from Firebase.\n`);
    return;
  }

  console.log(`Unknown action: "${action}". Supported: list, add, remove`);
}

main().catch((err) => {
  console.error('\nERROR:', err.message);
  process.exit(1);
});
