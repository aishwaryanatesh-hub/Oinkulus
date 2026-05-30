<div align="center">

# 🐷 Oinkulus

### *when pigs fly… sideways, across your screen, very calmly.*

A tiny **macOS menu-bar** companion: a pixel pig that glides gently left ↔ right,
giving your eyes a soft, hypnotic rhythm to follow. Look up. Breathe. Watch the pig fly.

**No windows. No clutter. No Dock icon. Just vibes.** ✨

<br/>

<img src="docs/hero.png" alt="Oinkulus flying across the screen" width="720"/>

<br/>

`🐷 flies bilaterally` · `🅿️🅸🅶🆂🅵🅻🆈 letters` · `🌙 dims your screen` · `🖱️ click-through` · `⌘⇧E to toggle`

</div>

---

## ✨ Why you'll love it

- 🐽 **It's a flying pig.** Pixel-perfect, faces the way it flies, never upside down.
- 🌊 **Smooth bilateral motion** — a calm side-to-side glide to rest your eyes on.
- 🔤 **Floating letters** that spell out `P · I · G · S · F · L · Y` and refresh at the edges.
- 🪶 **Featherweight & invisible-until-wanted** — lives in your menu bar, clicks pass right through it.
- 🐢 **Three speeds** — Slow, Medium, Fast. (Default is nice and slow.)

> 💛 Oinkulus is a gentle visual-focus / relaxation toy. It is **not a medical device** and
> makes no clinical claims. If you're seeking treatment, please talk to a professional.

---

## 📥 Install (60 seconds)

1. **[⬇️ Download the latest `Oinkulus.dmg`](../../releases/latest)**
2. Open the DMG and **drag 🐷 Oinkulus into Applications**.
3. **First launch only** — because this build isn't signed by Apple yet, macOS will say it
   *"can't be checked for malicious software."* That's expected. To let your pig fly:
   - Go to **System Settings → Privacy & Security**
   - Scroll down to the **Oinkulus** notice → click **Open Anyway**
   - Confirm once more. ✅ Done forever.

---

## ▶️ Start flying

Oinkulus has **no window** — it lives up in your **menu bar** (top-right of your screen).

1. Look for the **👁️ eye icon** in the menu bar.
2. Click it → **▶ Start Oinkulus** (or just press **⌘⇧E** anywhere).
3. Your pig takes off. Press **⌘⇧E** again to land it.

From that same menu you can tweak everything:

| Menu item | What it does |
|---|---|
| **▶ / ⏸ Start / Pause Oinkulus** | Launch or land the pig (⌘⇧E) |
| **Speed** | Slow · Medium · Fast |
| **Shape** | 🐷 Pig · Triangle · Circle · Diamond |
| **Side Letters** | Toggle the floating letters on/off |
| **Quit** | Send the pig home |

---

## 🛠️ Build it yourself

Requires Xcode + macOS 14 or later.

```bash
# Just build
xcodebuild -project Overlay.xcodeproj -scheme Overlay -configuration Release build

# …or build a shareable DMG
./scripts/release.sh        # → build/Oinkulus.dmg
```

<details>
<summary>🔏 Maintainer notes — signing &amp; notarization (optional)</summary>

The default build is **unsigned** (free, no Apple account). For a warning-free, notarized DMG
you need the **Apple Developer Program ($99/yr)**:

1. Create a *Developer ID Application* certificate (Xcode → Settings → Accounts).
2. Store notary credentials once:
   ```bash
   xcrun notarytool store-credentials oinkulus-notary \
     --apple-id "you@example.com" --team-id "TEAMID" --password "app-specific-password"
   ```
3. Set `DEVELOPMENT_TEAM` + `ENABLE_HARDENED_RUNTIME = YES` in `Overlay.xcodeproj` and the
   `teamID` in `ExportOptions.plist`, then run:
   ```bash
   NOTARIZE=1 ./scripts/release.sh
   ```
</details>

---

<div align="center">

Made with 🩷 and a flying pig · [MIT License](LICENSE)

</div>
