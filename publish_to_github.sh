#!/usr/bin/env bash
set -e
cd /sdcard/Delta/DeltaAssetStorage
if ! gh auth status >/dev/null 2>&1; then
  echo "Please log in to GitHub first: gh auth login"
  exit 1
fi
GH_USER=$(gh api user -q .login)
REPO_NAME="DeltaAssetStorage"
git config --global --add safe.directory /sdcard/Delta/DeltaAssetStorage || true
if [ ! -d .git ]; then
  git init -b main
fi
git config user.name "$GH_USER"
git config user.email "${GH_USER}@users.noreply.github.com"
git add -A
git commit -m "Add DeltaIsland and DeltaSidebar PNG assets" || true
if ! gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
else
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
  gh auth setup-git
  git push -u origin main --force
fi
RAW_BASE="https://raw.githubusercontent.com/$GH_USER/$REPO_NAME/refs/heads/main/DeltaIsland/"
cat << JSON > /sdcard/Delta/Workspace/DeltaCustom/DeltaIsland/AssetLinks.json
{
  "Run": "${RAW_BASE}Run.png",
  "Save": "${RAW_BASE}Save.png",
  "Float": "${RAW_BASE}Float.png",
  "Hub": "${RAW_BASE}Hub.png",
  "Collapse": "${RAW_BASE}Collapse.png",
  "Pulse": "${RAW_BASE}Pulse.png"
}
JSON
python3 -c "
for p in ['/sdcard/Delta/Autoexecute/Delta Modded (1).txt', '/sdcard/Delta/Delta Modded (1).txt']:
    with open(p, 'r', encoding='utf-8') as f:
        s = f.read()
    import re
    s = re.sub(r'https://raw\.githubusercontent\.com/[^\"\\x27]+/DeltaAssetStorage/refs/heads/main/DeltaIsland/', '$RAW_BASE', s)
    with open(p, 'w', encoding='utf-8') as f:
        f.write(s)
"
echo "Published to https://github.com/$GH_USER/$REPO_NAME and updated raw links to $RAW_BASE"
