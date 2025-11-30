class SanskritUpaya < Formula
  desc "Cross-platform Sanskrit dictionary with full-text search across 36 dictionaries"
  homepage "https://github.com/licht1stein/sanskrit-upaya"
  url "https://github.com/licht1stein/sanskrit-upaya/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "e22ddc5a65db7ed1ddc77da6db0f9aa051528d2081bea752f794f149ad2b9dfe"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  def install
    # Install fyne CLI tool
    system "go", "install", "fyne.io/tools/cmd/fyne@latest"
    fyne = Pathname.new(ENV["GOPATH"] || "#{Dir.home}/go").join("bin/fyne")

    # Copy assets to cmd/desktop for fyne package
    cp "Icon.png", "cmd/desktop/"
    cp "FyneApp.toml", "cmd/desktop/"

    # Build the .app bundle
    ENV["CGO_ENABLED"] = "1"
    cd "cmd/desktop" do
      system fyne, "package", "-os", "darwin", "-release", "--app-version", version.to_s
    end

    # Install the .app bundle to the prefix
    prefix.install "cmd/desktop/Sanskrit Upāya.app"

    # Create a symlink in bin for CLI access
    (bin/"sanskrit-upaya").write <<~EOS
      #!/bin/bash
      open "#{prefix}/Sanskrit Upāya.app"
    EOS
  end

  def post_install
    # Link the app to ~/Applications (user-writable, Spotlight-indexed)
    user_apps = Pathname.new(Dir.home)/"Applications"
    user_apps.mkpath
    app_path = prefix/"Sanskrit Upāya.app"
    target = user_apps/"Sanskrit Upāya.app"
    target.unlink if target.symlink? || target.exist?
    target.make_symlink(app_path)
  end

  def caveats
    <<~EOS
      Sanskrit Upāya has been linked to ~/Applications.
      You can find it in Spotlight or Launchpad.

      On first run, the app will download the dictionary database (~670MB).
      The database will be stored in:
        ~/Library/Application Support/sanskrit-dictionary/sanskrit.db
    EOS
  end

  test do
    assert_predicate prefix/"Sanskrit Upāya.app", :exist?
    assert_predicate prefix/"Sanskrit Upāya.app/Contents/MacOS/sanskrit-upaya", :executable?
  end
end
