cask "slatepdf" do
  version "1.0.0"
  sha256 :no_check  # Will be updated by release workflow
  
  url "https://github.com/kipmyk/SlatePDF/releases/download/v#{version}/SlatePDF.dmg"
  name "SlatePDF"
  desc "Native macOS PDF utility - Merge, edit, and annotate PDFs offline"
  homepage "https://github.com/kipmyk/SlatePDF"
  
  depends_on macos: ">= :ventura"
  
  app "SlatePDF.app"
  
  zap trash: [
    "~/Library/Preferences/com.kipmyk.slatepdf.plist",
    "~/Library/Saved Application State/com.kipmyk.slatepdf.savedState",
  ]
end
