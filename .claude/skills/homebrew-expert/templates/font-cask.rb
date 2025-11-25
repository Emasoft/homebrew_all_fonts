cask "font-my-font" do
  version "2.1.0"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"

  url "https://github.com/user/my-font/releases/download/v#{version}/MyFont.zip"
  name "My Font"
  desc "Beautiful custom font family"
  homepage "https://github.com/user/my-font"

  # Install individual font files
  font "MyFont-Regular.ttf"
  font "MyFont-Bold.ttf"
  font "MyFont-Italic.ttf"
  font "MyFont-BoldItalic.ttf"

  # Optional: Version detection
  # livecheck do
  #   url "https://api.github.com/repos/user/my-font/releases/latest"
  #   strategy :github_latest
  # end
end
