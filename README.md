# Homelab Test Store

Umbrel community app store with **Yuvomi Test** (`homelab-yuvomi-test`, port 8181):
a copy of Yuvomi used to try updates before applying them to the real app.

Add in Umbrel: App Store → ⋯ → Community App Stores → paste this repo's URL.

## Testing a Yuvomi update

1. When Umbrel shows an update for the real Yuvomi, copy the new `image:` line from
   https://github.com/getumbrel/umbrel-apps/blob/master/yuvomi/docker-compose.yml
   into `homelab-yuvomi-test/docker-compose.yml`, and the new `version:` / `releaseNotes:`
   into `homelab-yuvomi-test/umbrel-app.yml`. Commit and push.
2. In Umbrel, update **Yuvomi Test** and check it at http://umbrel.local:8181.
3. If everything works, update the real Yuvomi.

Settings kept only on the Umbrel (custom environment of Yuvomi Test, never in this repo):
`DB_ENCRYPTION_KEY` (the real Yuvomi's key, so the copied database opens),
`SYNC_INTERVAL_MINUTES=30000` (keep it under 35791: larger values overflow Node's timer
and make the sync loop), and a dead SMTP server so the test copy sends no email.

Note: the test `version:` may carry a `-test.N` suffix (e.g. `2.89.1-test.1`) when only the
store files changed (icon, texts); bump N to make Umbrel offer the change as an update.

## Automatic updates

A GitHub Actions workflow (`.github/workflows/sync-yuvomi.yml`) runs every hour,
copies the official Yuvomi app with `scripts/sync-yuvomi.sh` and pushes when a new
version is out. Umbrel then offers the update for **Yuvomi Test** on its own
(within a few minutes); the real Yuvomi is never touched by this repo.
Run it by hand from the repo's **Actions** tab → *Sync Yuvomi Test* → *Run workflow*.
