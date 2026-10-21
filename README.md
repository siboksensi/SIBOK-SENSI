SIBOK SENSI V2 — starter prototype
==================================

Files:
- index.html: customer key-entry + device-based sensitivity profile demo
- admin.html: admin dashboard prototype (key generation, Local Config URL, feature toggles, maintenance, device list, backup/restore)

IMPORTANT LIMITATIONS
- This is a FRONTEND PROTOTYPE. It saves data in localStorage in the current browser only.
- Admin and customer pages will share demo data only when opened in the same browser profile and same origin. For local file:// pages, browser behavior may isolate storage; host both pages on the same origin for a reliable demo.
- This is NOT secure for real customers. Do not use real paid keys or private admin credentials yet.
- For production, connect a backend/database and enforce key validity, expiry, device authorization, feature permissions, and maintenance server-side.
- The Sensi values are sample recommendations generated deterministically from the selected device/style. They do not change Free Fire settings automatically and are not guaranteed to improve aim.
- Local Config stores an external URL only; it does not upload or modify the remote server's files.
- Device model catalog is only a starter sample; verify models and tune profiles with real testing.

Suggested free deployment path:
1. Keep the customer page as index.html and admin page as admin.html on one frontend host.
2. Add a backend service and database before sharing publicly.
3. Never place admin passwords or server secrets in frontend JavaScript.
