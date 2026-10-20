# Edge Function deployment notes

`activate-key` is a minimal server-side key check, not a complete production authorization layer.
Before production, add:
- Rate limiting and abuse monitoring.
- Authenticated admin Edge Functions for key generation/revocation, profile management, maintenance,
  feature flags, and audit logs; verify the caller's role in every function.
- Account authentication tied to a verified user.
- Private Storage buckets and short-lived signed URLs after key validation.
- A trusted device-registration approach if device limits matter; browser fingerprints can be spoofed.
Never ship `SUPABASE_SERVICE_ROLE_KEY` to browser code.
