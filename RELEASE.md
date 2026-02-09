# How to Create a Release with DMG

The GitHub Actions workflow automatically builds and creates a DMG file on every push.

## Automatic DMG Creation

Every time you push to `main`:
1. GitHub Actions builds the app
2. Creates an app bundle
3. Packages it as a DMG
4. Uploads the DMG as a build artifact

You can download the DMG from the Actions tab → Click on the workflow run → Scroll to Artifacts section.

## Creating an Official Release

To create a tagged release with an attached DMG:

### Step 1: Create and push a tag

```bash
cd /Users/mac/Code/SlatePDF

# Create a new version tag
git tag -a v1.0.0 -m "Release v1.0.0: Initial public release

Features:
- Merge PDFs
- Delete and reorder pages
- Add text and image annotations
- 100% offline operation"

# Push the tag
git push origin v1.0.0
```

### Step 2: GitHub Actions automatically:
- Builds the app
- Creates the DMG
- Creates a GitHub Release
- Attaches the DMG to the release

### Step 3: View your release
Go to: https://github.com/kipmyk/SlatePDF/releases

The DMG will be available for download!

## Future Releases

When you're ready to release a new version:

```bash
# Make your changes and commit
git add .
git commit -m "Add new features"
git push

# Create new version tag
git tag -a v1.1.0 -m "Release v1.1.0: Bug fixes and improvements"
git push origin v1.1.0
```

GitHub Actions will automatically build and release the new version!

## Updating Homebrew Cask

Once you have a stable release, you can submit the cask to Homebrew:

```bash
# Test the cask locally first
brew install --cask ./Cask/slatepdf.rb

# Then submit to homebrew-cask
# Follow instructions at: https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap
```

Or keep it in your own tap:
```bash
# Users can install with:
brew install kipmyk/tap/slatepdf
```
