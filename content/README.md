# Lets Stretch static content

JSON + images for the app.

## Hosting (optional refresh)

- JSON: https://raw.githubusercontent.com/cburnham4/LetsStretch/master/content/data/content.json
- Images: https://raw.githubusercontent.com/cburnham4/LetsStretch/master/content/images/...

## App bundle (offline-first)

This `content/` folder is copied into the iOS app as a **folder reference**. At runtime the app:

1. Seeds routines/stretches from bundled `content/data/content.json` (or UserDefaults archive).
2. Loads stretch/routine PNGs from `content/images/…` in the bundle when the remote `downloadURL` path matches.
3. Treats the GitHub raw URLs as an optional refresh when online; missing art falls back to a placeholder.
