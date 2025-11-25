cask "my-app" do
  version "1.0.0"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"

  url "https://example.com/downloads/MyApp-#{version}.dmg"
  name "My Application"
  desc "Short description of what this application does"
  homepage "https://example.com"

  # For GUI applications
  app "MyApp.app"

  # Optional: Uninstall instructions
  # uninstall quit: "com.example.MyApp"

  # Optional: User instructions
  # caveats <<~EOS
  #   Additional setup required:
  #   1. Open System Preferences → Security & Privacy
  #   2. Allow MyApp to run
  # EOS
end
