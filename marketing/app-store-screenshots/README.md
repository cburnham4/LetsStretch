# Let's Stretch — App Store screenshot generator

Same workflow as Sunrise & Sunset / Truth Finder: Next.js frames + Puppeteer export.

## Run locally

```bash
cd marketing/app-store-screenshots
npm install
npm run dev
```

### Generate on disk

```bash
npm run generate:screenshots
```

Writes frames + universal creative into `exported-store-screenshots/`.

## Capture source screenshots

UITest: `LetsStretchUITests/testCaptureAppStoreScreens` → `/tmp/asc-captures/letsstretch/`.

Copy RGB PNGs into `public/screenshots/` as `home.png`, `stretch.png`, `stretch-active.png`, `settings.png`.

## Brand

- Coral accent `#E86B33` (`AppTheme.accent`)
- Warm background `#FAF7F2`
