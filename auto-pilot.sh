#!/bin/bash
# =============================================================
# 🤖 Auto-Pilot Script — Project Generator
# =============================================================
# This script generates a random project, creates repo, and pushes
# Run manually or via cron on your local machine:
#   0 6 * * 1 bash /path/to/auto-pilot.sh
# =============================================================

set -e

TOKEN="${GITHUB_TOKEN:-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}"
USERNAME="mamadiezad"

# ---- Project Ideas Pool ----
IDEA_INDEX=$((RANDOM % 10))

case $IDEA_INDEX in
  0)
    NAME="persian-url-shortener"
    DESC="سرویس کوتاه‌کننده لینک فارسی با Next.js و MongoDB"
    TOPICS='["url-shortener","nextjs","mongodb","persian","link-shortener"]'
    LANG="ts"
    ;;
  1)
    NAME="persian-ocr-service"
    DESC="سرویس OCR تشخیص متن فارسی از تصویر با Python"
    TOPICS='["ocr","python","persian-ocr","tesseract","image-processing"]'
    LANG="py"
    ;;
  2)
    NAME="telegram-job-finder-bot"
    DESC="ربات کاریابی تلگرام — آگهی‌های شغلی رو بر اساس مهارتت پیدا کن"
    TOPICS='["telegram-bot","job-finder","persian","nodejs","employment"]'
    LANG="ts"
    ;;
  3)
    NAME="persian-password-manager"
    DESC="مدیریت رمز عبور با رمزنگاری AES-256 نسخه تحت وب"
    TOPICS='["password-manager","security","encryption","aes256","persian"]'
    LANG="ts"
    ;;
  4)
    NAME="mistral-persian-chat"
    DESC="چت هوش مصنوعی فارسی با Mistral AI بدون نیاز به OpenAI"
    TOPICS='["mistral-ai","chatbot","persian","nodejs","llm"]'
    LANG="ts"
    ;;
  5)
    NAME="vpn-account-manager"
    DESC="پنل مدیریت اکانت VPN با داکر مناسب برای فروشنده ها"
    TOPICS='["vpn","account-manager","docker","panel","persian"]'
    LANG="ts"
    ;;
  6)
    NAME="persian-qrcode-generator"
    DESC="تولید QR Code با لوگوی شخصی API + Web UI"
    TOPICS='["qrcode","python","api","persian","generator"]'
    LANG="py"
    ;;
  7)
    NAME="persian-forms-builder"
    DESC="ساخت فرم و نظر سنجی آنلاین مثل Google Forms فارسی"
    TOPICS='["forms","survey","nextjs","mongodb","persian"]'
    LANG="ts"
    ;;
  8)
    NAME="persian-proxy-checker"
    DESC="چکر پروکسی و وی پی ان تست سرعت و سلامت"
    TOPICS='["proxy","checker","python","vpn","network"]'
    LANG="py"
    ;;
  9)
    NAME="telegram-report-bot"
    DESC="ربات گزارش ساز تلگرام دریافت بازخورد و نظرات کاربران"
    TOPICS='["telegram-bot","report","feedback","persian","nodejs"]'
    LANG="ts"
    ;;
esac

echo "═══════════════════════════════════════"
echo "  🤖 Auto-Pilot Generator"
echo "═══════════════════════════════════════"
echo ""
echo "📦 Project: $NAME"
echo "📝 Desc: $DESC"
echo "🔧 Lang: $LANG"
echo ""

# ---- Create repo via API ----
echo "🔧 Creating repository..."
REPO_DATA=$(curl -s -X POST -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$NAME\",\"description\":\"$DESC\",\"auto_init\":true,\"private\":false}" \
  "https://api.github.com/user/repos")

CLONE_URL=$(echo "$REPO_DATA" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('clone_url','ERROR'))" 2>/dev/null || echo "ERROR")

if [ "$CLONE_URL" = "ERROR" ]; then
  echo "❌ Failed to create repo!"
  echo "$REPO_DATA"
  exit 1
fi

echo "✅ Repo created: $CLONE_URL"

# ---- Clone and generate code ----
WORKDIR="/tmp/autopilot_$NAME"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/src"
cd "$WORKDIR"

# Write .gitignore
cat > .gitignore << 'GITIGNORE'
node_modules/
dist/
.env
*.log
__pycache__/
.DS_Store
GITIGNORE

# Write README
cat > README.md << READMEOF
# $NAME

> $DESC

## 🚀 Quick Start

\`\`\`bash
git clone https://github.com/$USERNAME/$NAME.git
cd $NAME
\`\`\`

## 📜 License

MIT

---

<p align="center">Built with ❤️ by <a href="https://github.com/$USERNAME">Mohammad</a></p>
READMEOF

# Write code based on language
if [ "$LANG" = "py" ]; then
  cat > src/main.py << PYEOF
# $NAME
# $DESC

import os
import sys

def main():
    print("Welcome to $NAME!")
    print("$DESC")

if __name__ == "__main__":
    main()
PYEOF
  cat > requirements.txt << 'REQTXT'
# pip install -r requirements.txt
# Add your dependencies
REQTXT
else
  cat > package.json << PKGJSON
{
  "name": "$NAME",
  "version": "1.0.0",
  "description": "$DESC",
  "main": "src/index.ts",
  "scripts": {
    "dev": "echo 'Add dev script'",
    "build": "echo 'Add build script'"
  }
}
PKGJSON
  cat > src/index.ts << TSEOF
// $NAME
// $DESC

console.log("Welcome to $NAME!");
TSEOF
fi

# ---- Push ----
git init
git config user.name "mamadiezad"
git config user.email "mamadiezad@github.com"
git add -A
git commit -m "🎯 Initial release: $DESC"
git remote add origin "https://mamadiezad:${TOKEN}@github.com/${USERNAME}/${NAME}.git"
git push -u origin main 2>&1 | tail -3

echo ""

# ---- Update topics ----
curl -s -X PUT -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"names\": $TOPICS}" \
  "https://api.github.com/repos/${USERNAME}/${NAME}/topics" > /dev/null

echo "═══════════════════════════════════════"
echo "  ✅ Done!"
echo "  📦 https://github.com/$USERNAME/$NAME"
echo "═══════════════════════════════════════"
