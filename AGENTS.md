<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to Lovable. Avoid rewriting published git history.
<!-- LOVABLE:END -->

- Use TanStack file routes with a public `/` and named customer pages under the authenticated layout, because marketing and workspace surfaces have different access needs.
- Store customer templates, jobs, profiles, and billing summaries in Lovable Cloud with owner-only access, because certificate data is private.
- Keep certificate files in the private `certificate-files` bucket under a user-ID folder, because uploads and generated files must remain isolated.
