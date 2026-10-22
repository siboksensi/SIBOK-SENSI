# SIBOK SENSI PRO — Separate portals

- `customer/index.html`: customer key-only page with backend verification hook and remaining-time countdown.
- `admin/index.html`: separate admin dashboard UI shell for key durations, device limits, profile files, customers, and settings.
- `supabase/schema.sql`: starter database schema.

GitHub Pages URLs after commit:
- Customer: `https://siboksensi.github.io/SIBOK-SENSI/customer/`
- Admin: `https://siboksensi.github.io/SIBOK-SENSI/admin/`

This is not yet a production key system. Add Supabase URL/anon key to the frontend and deploy protected Edge Functions for key validation, key generation/revocation, admin role checks, private file uploads/downloads, and settings. Do not put a service-role secret in browser code. Countdown is only a display; server must check expiry on every request.
