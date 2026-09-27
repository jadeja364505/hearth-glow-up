# Certibulk Homepage and Customer Portal

## Goal
Replace the blank starting page with a newly designed Certibulk website and a complete customer workspace. Use the uploaded CertificateFlow project as the functional reference—bulk certificate creation, templates, history, plans, and account management—without copying its existing homepage design.

## Experience structure

### Public website
- Build a distinctive new Certibulk homepage focused on the core promise: turning spreadsheet data into polished certificate batches.
- Include clear product demonstration, workflow overview, template examples, trust/proof, pricing preview, and strong registration calls to action.
- Add dedicated, shareable pages for pricing and template browsing where the content benefits from its own URL.
- Create responsive navigation, mobile menu, footer, light/dark treatment if it suits the selected direction, restrained motion, and accessible reduced-motion behavior.
- Give every public page unique search and social metadata.

### Authentication
- Enable Lovable Cloud for secure customer accounts, data, and file storage.
- Support email/password and Google sign-in by default.
- Add registration, sign-in, email confirmation, forgot-password, and reset-password flows.
- Store a basic customer profile because the workspace needs company/account settings; users can only access their own profile and content.
- Keep the public homepage available at `/` and place the signed-in workspace behind protected pages.

### Customer workspace
- **Dashboard:** recent templates, recent generation runs, usage summary, plan status, and direct next actions.
- **Templates:** browse starter templates, upload a design, create a template, edit field placement, preview it, duplicate it, and archive/delete it.
- **Generate:** select a template, upload spreadsheet data, map/validate columns, show row-level errors, preview output, then create the batch.
- **History:** list generation jobs with status, counts, date, and downloadable output when complete.
- **Billing:** display plan, usage allowance, upgrade options, invoices/payment history, and activation or redemption entry points. Payment processing itself will remain disconnected unless the user chooses a provider during implementation.
- **Settings:** edit company/profile details, theme/preferences, password, and sign out safely.
- Use clear loading, empty, validation, success, and failure states across each workflow.

## Data and security
- Add user-owned records for profiles, templates, template fields, generation jobs, generated files, and billing/subscription summaries.
- Use private file storage for templates, spreadsheets, and generated certificate archives.
- Enforce ownership rules on every customer record and file; no customer can read or modify another customer’s data.
- Validate file type, size, spreadsheet columns, and generation inputs before processing.
- Keep all protected operations authenticated on the server as well as in the interface.

## Implementation approach
- Rebuild the uploaded React/Vite concepts in the project’s existing TanStack Start structure rather than importing its router or backend directly.
- Establish one semantic design system for color, typography, spacing, controls, document previews, and status states.
- Split the experience into focused reusable pieces: public site shell, authenticated workspace shell, certificate preview/editor, spreadsheet mapper, job status, and account/billing surfaces.
- Use the uploaded project’s product wording and pricing only as draft reference; avoid presenting unverified claims or payment behavior as live.
- Record the resulting architecture decisions and keep source imports limited to reviewed, necessary files without copying repository metadata.

## Verification
- Check the homepage, auth screens, and every workspace page at desktop and mobile sizes.
- Verify registration, confirmation messaging, sign-in, password recovery, protected-page redirects, and sign-out.
- Run an end-to-end customer flow: create account → create/upload template → upload spreadsheet → validate rows → generate → see history → download output.
- Confirm ownership isolation, invalid-file handling, empty states, keyboard navigation, reduced motion, metadata, and a clean production build.

## Delivery sequence
1. Establish the chosen visual direction and public-site design system.
2. Build the public homepage and supporting public pages.
3. Enable accounts, profiles, protected navigation, and recovery flows.
4. Build the dashboard, template library, and editor.
5. Build spreadsheet validation, generation workflow, history, and downloads.
6. Add billing presentation and account settings.
7. Complete responsive, accessibility, security, and end-to-end verification.
