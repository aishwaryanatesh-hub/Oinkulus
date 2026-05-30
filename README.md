# Oinkulus 🐷

A calm, distraction-light **macOS menu-bar overlay** with a focus object that glides
smoothly back and forth across your screen — a gentle left/right (bilateral) visual rhythm
to rest your eyes on. The default focus object is a small pixel pig that flies side to side
(yes, *pigs fly bilaterally*), flipping to face whichever way it's heading.

> Oinkulus is a simple visual-focus / bilateral-movement tool for relaxation and focus.
> It is **not a medical device** and makes no clinical or therapeutic claims. If you are
> seeking treatment, please consult a qualified professional.

## Features

- Menu-bar app (no Dock icon) — toggle with **⌘⇧E**
- Smooth figure-8 motion across all spaces, click-through (never steals focus)
- Shapes: **Pig** (default), Triangle, Circle, Diamond
- Speeds: Slow / Medium / Fast
- Optional side letters that refresh at each edge (themed `P I G S F L Y` for the pig)

## Install

1. Download **`Oinkulus.dmg`** from the [latest release](../../releases/latest).
2. Open the DMG and drag **Oinkulus** into **Applications**.
3. **First launch** (unsigned build): macOS will say it "can't be checked for malicious
   software." This is expected — Oinkulus isn't notarized yet.
   - Open **System Settings → Privacy & Security**, scroll to the Oinkulus notice, and
     click **Open Anyway**. (You only need to do this once.)
4. Oinkulus lives in the menu bar (look for the eye icon). Click it → **Start Oinkulus**.

## Build from source

Requires Xcode and macOS 14+.

```bash
xcodebuild -project Overlay.xcodeproj -scheme Overlay -configuration Release build
```

Or produce a distributable DMG:

```bash
./scripts/release.sh
# → build/Oinkulus.dmg
```

## Maintainer notes — signing & notarization (optional)

The default build is **unsigned** (free, no Apple account). To ship a warning-free,
notarized DMG you need the **Apple Developer Program ($99/yr)**:

1. Create a *Developer ID Application* certificate (Xcode → Settings → Accounts).
2. Store notary credentials once:
   ```bash
   xcrun notarytool store-credentials oinkulus-notary \
     --apple-id "you@example.com" --team-id "TEAMID" --password "app-specific-password"
   ```
3. In `Overlay.xcodeproj`, set `DEVELOPMENT_TEAM` and `ENABLE_HARDENED_RUNTIME = YES`,
   then run `NOTARIZE=1 ./scripts/release.sh` (the script's notarize block uses an
   archive + Developer ID export, then `notarytool submit … --wait` and `stapler staple`).

## License

[MIT](LICENSE)
