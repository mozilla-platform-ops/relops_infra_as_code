# macOS Package Blueprints for MDM Deployment

This repo contains source blueprints for building and signing macOS `.pkg` installers using [munkipkg](https://github.com/munki/munki-pkg), intended for deployment via MDM (e.g., SimpleMDM, Jamf).

## 📁 Project Layout

```
osx_pkg_blueprints/
├── p_role_gecko_t_osx_1400_r8/      # Example package blueprint
│   ├── build-info.plist
│   └── payload/
│       └── etc/
│           └── puppet_role          # Contains "gecko_t_osx_1400_r8"
├── scripts/
│   └── sign.sh                      # Interactive signing tool
├── .gitignore
└── README.md
```

## 🚀 Building a Package

1. Make sure you have munkipkg installed:

   ```bash
   brew install munkipkg
   ```

2. Build the unsigned package:

   ```bash
   munkipkg p_role_gecko_t_osx_1400_r8
   ```

   This creates:
   ```
   p_role_gecko_t_osx_1400_r8/build/p_role_gecko_t_osx_1400_r8-1.0.pkg
   ```

## 🔐 Signing the Package

Run the interactive signing script:

```bash
./scripts/sign.sh p_role_gecko_t_osx_1400_r8/build/p_role_gecko_t_osx_1400_r8-1.0.pkg
```

- If you have multiple Developer ID Installer certs, you'll be prompted to pick one.
- The script signs and verifies the package.
- Output:
  ```
  p_role_gecko_t_osx_1400_r8/build/p_role_gecko_t_osx_1400_r8-1.0-signed.pkg
  ```

> ⚠️ macOS may report "Unnotarized Developer ID" when verifying locally. This is expected for MDM use — notarization is not required for trusted `.pkg` delivery via MDM.

## ☁️ Hosting & Deployment

Upload the signed `.pkg` to a public or pre-signed URL (e.g., S3 or GitHub Releases), and provide that URL to your MDM system’s custom software configuration.

---

## ✏️ Creating New Blueprints

To create a new package blueprint:

```bash
munkipkg --create my-new-pkg
```

Then populate the `payload/` folder with your desired files.

---

## 🧼 .gitignore

We recommend ignoring the `build/` and signed `.pkg` files:

```
**/build/
*.pkg
```

---

## 🔧 Requirements

- macOS with Xcode command line tools
- `munkipkg` installed
- A Developer ID Installer certificate in your keychain

