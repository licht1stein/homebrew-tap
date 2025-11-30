class SanskritUpaya < Formula
  desc "Cross-platform Sanskrit dictionary with full-text search across 36 dictionaries"
  homepage "https://github.com/licht1stein/sanskrit-upaya"
  url "https://github.com/licht1stein/sanskrit-upaya/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "2ee09eaa94ed23d572e8fde3ef9362a65ddd32652113a07d4c5d4b5063cea75f"
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

    # Build the binary first with version ldflags
    ENV["CGO_ENABLED"] = "1"
    ldflags = %W[
      -s -w
      -X main.Version=v#{version}
    ]
    system "go", "build", *std_go_args(ldflags:, output: "cmd/desktop/sanskrit-upaya"), "./cmd/desktop"

    # Package the pre-built binary into .app bundle
    cd "cmd/desktop" do
      system fyne, "package", "-os", "darwin", "-release", "--app-version", version.to_s, "-exe", "sanskrit-upaya"
    end

    # Install the .app bundle to the prefix
    prefix.install "cmd/desktop/Sanskrit Upāya.app"

    # Create a launcher script in bin
    # Uses opt_prefix which is a stable symlink to the current version
    (bin/"sanskrit-upaya").write <<~EOS
      #!/bin/bash
      open "#{opt_prefix}/Sanskrit Upāya.app"
    EOS
  end

  def caveats
    <<~EOS
      To launch the app, run:
        sanskrit-upaya

      Tip: Right-click the dock icon → Options → Keep in Dock

      On first run, the app will download the dictionary database (~670MB).
    EOS
  end

  test do
    assert_predicate prefix/"Sanskrit Upāya.app", :exist?
    assert_predicate prefix/"Sanskrit Upāya.app/Contents/MacOS/sanskrit-upaya", :executable?
  end
end
