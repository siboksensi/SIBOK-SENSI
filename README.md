# SIBOK SENSI PRO — Starter Kit

A starter architecture for a key-gated sensitivity-profile website with an admin dashboard.

## Included
- Responsive customer website and admin-dashboard UI preview.
- Key activation flow clearly marked as demo until backend is configured.
- Supabase SQL schema for keys, activations, profiles, roles, feature catalog, maintenance settings, and audit logs.
- Edge Function example for server-side key activation.
- SQL seed for 500 catalog entries (catalog entries are not 500 implemented capabilities).

## Important
This is a starter kit, not a deployed production service. GitHub Pages can host the frontend, but secure key
validation, admin controls, private file downloads, and global maintenance mode need a configured backend.
Never put a Supabase service-role key in browser code. The sample sensitivity profiles are editable examples,
not guaranteed optimal settings. Do not enable features until they have real implementations and tests.

## Setup overview
1. Create a Supabase project.
2. Run `supabase/schema.sql` in its SQL Editor.
3. Deploy `supabase/functions/activate-key/index.ts` as an Edge Function.
4. Set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` as Edge Function secrets.
5. Configure frontend Supabase URL/anon key and wire activation to the deployed function.
6. Create your first admin Auth user, then insert their UUID into `public.user_roles` as `super_admin`.
7. Implement authenticated server-side admin functions for key creation/revocation, private file downloads,
   profile management, feature flags, maintenance settings, and audit logs before production use.
