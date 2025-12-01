cask "sanskrit-upaya" do
  version "1.0.5"
  sha256 "77741ffd5a4cff25b40252b135d3f171537c88138a71e707d1c833716e68190f"

  url "https://github.com/licht1stein/sanskrit-upaya/releases/download/v#{version}/sanskrit-upaya-v#{version}-macos.dmg"
  name "Sanskrit Upaya"
  desc "Cross-platform Sanskrit dictionary with full-text search across 36 dictionaries"
  homepage "https://github.com/licht1stein/sanskrit-upaya"

  app "Sanskrit Upāya.app"

  preflight do
    # Auto-uninstall the old formula if present
    system_command "#{HOMEBREW_PREFIX}/bin/brew",
                   args: ["uninstall", "--formula", "sanskrit-upaya"],
                   sudo: false,
                   print_stderr: false
  end

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-rd", "com.apple.quarantine", "#{appdir}/Sanskrit Upāya.app"]
    system_command "/usr/bin/codesign",
                   args: ["--force", "--deep", "-s", "-", "#{appdir}/Sanskrit Upāya.app"]
  end

  caveats <<~EOS
    #{token} is not notarized by Apple.
    On first run, the app will download the dictionary database (~670MB).
  EOS
end
