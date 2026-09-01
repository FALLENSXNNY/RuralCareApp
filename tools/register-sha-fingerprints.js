#!/usr/bin/env node
/**
 * register-sha-fingerprints.js
 *
 * Registers the SHA-1 / SHA-256 fingerprints of an Android signing keystore on
 * the Firebase project's Android app via the Firebase Management REST API.
 *
 * WHY: Firebase Phone Authentication on Android will NOT send an SMS OTP until
 * the SHA-1 and SHA-256 fingerprints of the signing keystore are registered on
 * the Firebase Android app. This script does that step programmatically, so you
 * do NOT need to visit the Firebase console.
 *
 * Requirements:
 *   - A service account JSON that has the "Firebase Admin" (or Owner/Editor)
 *     role on the project. Default path: C:\secrets\ruralcare-firebase-admin.json
 *     (override with GOOGLE_APPLICATION_CREDENTIALS or --keyFile).
 *   - Run from the project root so `require('google-auth-library')` resolves
 *     (the backend already bundles it), or `npm i -D google-auth-library`.
 *
 * Usage:
 *   node tools/register-sha-fingerprints.js
 *   node tools/register-sha-fingerprints.js \
 *       --sha1 07:25:E7:C2:1E:16:EC:2F:B1:8D:1D:BC:0B:49:42:67:08:60:66:B4 \
 *       --sha256 CA:B3:55:73:3E:25:D3:56:25:35:B0:F3:1E:17:F0:DD:F7:6E:BF:7E:AB:45:DE:F8:03:9E:38:F2:81:23:E7:BB
 *
 * Wait ~10s for the change to propagate, then uninstall & re-install the app.
 */

const fs = require('fs');
const path = require('path');

// ── Config (override via CLI flags) ─────────────────────────────────────────
const DEFAULT_KEY_FILE = 'C:\\secrets\\ruralcare-firebase-admin.json';

// The Firebase Android app resource. mobilesdk_app_id from google-services.json:
//   "1:<PROJECT_NUMBER>:android:<HASH>"  →  projects/<PROJECT_ID>/androidApps/<APP_RESOURCE>
const APP = '1:1045232562713:android:6c7fecab6b3c0a1c1ff088';

// Default = this machine's debug keystore fingerprints (see tools/android_sha.ps1).
const DEFAULT_SHA1 = '07:25:E7:C2:1E:16:EC:2F:B1:8D:1D:BC:0B:49:42:67:08:60:66:B4';
const DEFAULT_SHA256 =
  'CA:B3:55:73:3E:25:D3:56:25:35:B0:F3:1E:17:F0:DD:F7:6E:BF:7E:AB:45:DE:F8:03:9E:38:F2:81:23:E7:BB';

function parseArgs() {
  const argv = process.argv.slice(2);
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--sha1') args.sha1 = argv[++i];
    else if (argv[i] === '--sha256') args.sha256 = argv[++i];
    else if (argv[i] === '--keyFile') args.keyFile = argv[++i];
  }
  return args;
}

/** Strips colons and uppercases; validates it looks like a hex digest. */
function normalize(hash) {
  const clean = (hash || '').replace(/:/g, '').trim().toUpperCase();
  if (!/^[0-9A-F]{20,64}$/.test(clean)) {
    throw new Error(`Invalid fingerprint: "${hash}". Expected a hex SHA-1/SHA-256 digest.`);
  }
  return clean;
}

async function main() {
  const args = parseArgs();
  const keyFile = args.keyFile || process.env.GOOGLE_APPLICATION_CREDENTIALS || DEFAULT_KEY_FILE;
  const sha1 = normalize(args.sha1 || DEFAULT_SHA1);
  const sha256 = normalize(args.sha256 || DEFAULT_SHA256);

  if (!fs.existsSync(keyFile)) {
    throw new Error(
      `Service account key not found at: ${keyFile}\n` +
        'Download it from Firebase Console → Project settings → Service accounts → ' +
        'Generate new private key, then pass --keyFile <path>.'
    );
  }

  const { JWT } = require('google-auth-library');
  const creds = JSON.parse(fs.readFileSync(keyFile, 'utf8'));
  const projectId = creds.project_id;

  const client = new JWT({
    email: creds.client_email,
    key: creds.private_key,
    scopes: [
      'https://www.googleapis.com/auth/firebase',
      'https://www.googleapis.com/auth/cloud-platform',
    ],
  });

  console.log('Minting access token from service account…');
  const { token } = await client.getAccessToken();

  const base = `https://firebase.googleapis.com/v1beta1/projects/${encodeURIComponent(
    projectId
  )}/androidApps/${encodeURIComponent(APP)}/sha`;

  const headers = {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // 1) List what is already registered.
  const listRes = await fetch(base, { headers });
  if (!listRes.ok) {
    const text = await listRes.text();
    throw new Error(`LIST /sha failed (${listRes.status}): ${text}`);
  }
  const listBody = await listRes.json();
  const existingCertTypes = new Set(
    (listBody.certificates || []).map((c) => c.certType)
  );
  console.log(`Existing SHA certs on ${projectId}/${APP}:`, [...existingCertTypes].join(', ') || '(none)');

  // 2) Register each missing certificate:
  //    POST /sha  body = { certType: "SHA_1" | "SHA_256", shaHash: "<hex without colons>" }
  const wanted = [
    { certType: 'SHA_1', shaHash: sha1 },
    { certType: 'SHA_256', shaHash: sha256 },
  ];

  for (const cert of wanted) {
    const existing = (listBody.certificates || []).find(
      (c) => c.certType === cert.certType
    );
    if (existing) {
      console.log(`✓ ${cert.certType} already registered — skipping.`);
      continue;
    }
    const res = await fetch(base, {
      method: 'POST',
      headers,
      body: JSON.stringify(cert),
    });
    if (res.status === 200 || res.status === 201) {
      console.log(`✓ Registered ${cert.certType}: ${cert.shaHash}`);
    } else {
      const text = await res.text();
      console.error(
        `✗ Failed to register ${cert.certType} (${res.status}): ${text}`
      );
      // Do NOT fail the run for a single cert — report and continue.
    }
  }

  console.log('\nDone. Give it ~10 seconds, then UNINSTALL the app and re-run fresh.');
  console.log('If Firebase still blocks OTP, check console permissions on the service');
  console.log('account (needs "Firebase Admin" or Owner/Editor) and re-run this script.');
}

main().catch((err) => {
  console.error('\nERROR:', err.message);
  process.exit(1);
});