# Termux WoL APT repository

Public APT repository for Termux WoL, intended for **TLester23/termux-wol** and GitHub Pages.

Repository URL: <https://TLester23.github.io/termux-wol/>

## One-time GitHub setup

1. Create a **public** repository named `termux-wol` under the `TLester23` account.
2. Push the contents of this directory to the repository's `main` branch.
3. Create a dedicated GPG signing key (instructions below).
4. In **Settings → Secrets and variables → Actions**, add these repository secrets:
   - `APT_GPG_PRIVATE_KEY`: complete ASCII-armored output of `gpg --armor --export-secret-keys KEY_ID`.
   - `APT_GPG_PASSPHRASE`: the signing key's passphrase.
5. In **Settings → Pages**, set the build/deployment source to **GitHub Actions**.
6. Run **Actions → Build and publish APT repository → Run workflow**. The workflow also runs on pushes that change `packages/*.deb` and on published GitHub Releases.

The workflow creates `Packages` and `Packages.gz`, creates `Release`, signs it as `InRelease` and `Release.gpg`, exports only the public key, and deploys the `public/` directory to GitHub Pages. It intentionally fails if signing secrets are absent.

## Create a dedicated signing key

Do this on a trusted computer. Do not commit the private key or paste it into an issue, chat, or workflow file.

```bash
gpg --full-generate-key
# Select RSA and RSA, 4096 bits, and set a strong passphrase.
gpg --list-secret-keys --keyid-format LONG
KEY_ID=YOUR_LONG_KEY_ID
gpg --armor --export-secret-keys "$KEY_ID" > apt-signing-private.asc
```

Copy the full contents of `apt-signing-private.asc` into the GitHub Actions secret `APT_GPG_PRIVATE_KEY`; put the passphrase in `APT_GPG_PASSPHRASE`. Keep a secure offline backup, then securely remove the exported file from any shared machine. The public key is published by Actions as `termux-wol-archive-keyring.gpg`.

## Install on Termux

Run only after the first successful GitHub Pages deployment:

```bash
pkg update
pkg install curl
mkdir -p "$PREFIX/etc/apt/keyrings"
curl -fsSL https://TLester23.github.io/termux-wol/termux-wol-archive-keyring.gpg \
  -o "$PREFIX/etc/apt/keyrings/termux-wol.gpg"
echo "deb [arch=all signed-by=$PREFIX/etc/apt/keyrings/termux-wol.gpg] https://TLester23.github.io/termux-wol stable main" \
  > "$PREFIX/etc/apt/sources.list.d/termux-wol.list"
pkg update
pkg install termux-wol
```

Or use the helper script after the repository has been deployed:

```bash
bash scripts/install-repo.sh
```

Upgrade later with `pkg update && pkg upgrade termux-wol`.

## Publish a new package version

Build a Termux-compatible `.deb` with package name `termux-wol`, architecture `all`, and a strictly higher Debian version. Add it to `packages/` and push to `main`; Actions regenerates the repository. Keep previous versions in `packages/` if you want APT downgrade options. Do not overwrite an existing version with different contents.

## Security and compatibility notes

- The private signing key is stored only in GitHub Actions Secrets; never put it in this repository.
- Client configuration uses `signed-by`, not `trusted=yes`.
- This repository targets Termux's Debian/apt environment and is not intended for desktop Debian/Ubuntu.
- The supplied 1.0.0 `.deb` is included as received. Its control metadata currently says `Maintainer: Local Termux package`; correct that field when building the next version rather than silently changing the published artifact.
- GitHub Pages is static hosting; package uploads and index generation happen in GitHub Actions.
