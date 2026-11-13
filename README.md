# MASSAGE AI

Flutter Web demo for a massage-service chat and booking flow.

## Deploy to Vercel

1. Push this repository to GitHub and import it as a project in Vercel.
2. In **Project Settings > Environment Variables**, add `GEMINI_API_KEY` with
   the Gemini API key. Enable it for the deployment environments you will use.
   Do not upload or commit the local `.env` file.
3. Keep the project root as the Root Directory. Vercel uses `vercel.json` to
   install Flutter when it is not already available, build the web app, and
   publish `build/web`.
4. Deploy or redeploy the project after adding the environment variable.

If `GEMINI_API_KEY` is not set in Vercel's Environment Variables, the build
will automatically fallback to the configured default key. For a
local web build, you can also provide a custom key through `--dart-define` or
`--dart-define-from-file=.env`:

```bash
flutter build web --release --dart-define=GEMINI_API_KEY=your-key
```

**Demo security note:** Flutter Web includes the Gemini key in browser-delivered
code. Anyone can inspect it after deployment. This setup is suitable only for a
temporary presentation demo; use a backend proxy for a public/production app,
and rotate the key after presenting.

Bookings are stored in local memory only and are cleared when the page is
reloaded. They are demo bookings, not real appointments.
