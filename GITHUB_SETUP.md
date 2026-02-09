# Publishing SlatePDF to GitHub

## Step 1: Initialize Git Repository (if not already done)

```bash
cd /Users/mac/Code/SlatePDF

# Check if git is already initialized
git status

# If not initialized, run:
git init
```

## Step 2: Add All Files

```bash
# Add all files to git
git add .

# Check what will be committed
git status
```

## Step 3: Create Initial Commit

```bash
git commit -m "Initial commit: SlatePDF - Native macOS PDF utility

Features:
- Merge PDFs
- Reorder pages
- Delete pages
- Add text annotations
- Add image annotations
- 100% offline operation
- Safe atomic file operations with backups

Built with SwiftUI and PDFKit as an AI-assisted development experiment."
```

## Step 4: Create GitHub Repository

**Option A: Using GitHub CLI (gh)**
```bash
# Install if you don't have it
brew install gh

# Login to GitHub
gh auth login

# Create the repo
gh repo create SlatePDF --public --source=. --remote=origin --push
```

**Option B: Manual (via GitHub website)**

1. Go to https://github.com/new
2. Repository name: `SlatePDF`
3. Description: `Native macOS PDF utility - Merge, edit, and annotate PDFs offline`
4. Make it **Public**
5. **DON'T** initialize with README (we already have one)
6. Click "Create repository"

Then run:
```bash
git remote add origin https://github.com/kipmyk/SlatePDF.git
git branch -M main
git push -u origin main
```

## Step 5: Verify Upload

```bash
# Check remote
git remote -v

# Check branch
git branch -a

# View on GitHub
open https://github.com/kipmyk/SlatePDF
```

## Step 6: Add Topics/Tags on GitHub

Go to your repo page and add these topics:
- `macos`
- `pdf`
- `swift`
- `swiftui`
- `pdf-manipulation`
- `ai-assisted`
- `offline-first`

## Future Updates

When you make changes:
```bash
# Check what changed
git status

# Add changes
git add .

# Commit
git commit -m "Your commit message"

# Push
git push
```

## Optional: Create a Release

```bash
# Tag the current version
git tag -a v1.0.0 -m "Release v1.0.0: Initial public release"

# Push the tag
git push origin v1.0.0
```

Then on GitHub, go to Releases → Draft a new release → Select the tag → Publish

---

**Your repo will be at: https://github.com/kipmyk/SlatePDF**
