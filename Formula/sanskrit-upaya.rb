class SanskritUpaya < Formula
  desc "Cross-platform Sanskrit dictionary with full-text search across 36 dictionaries"
  homepage "https://github.com/licht1stein/sanskrit-upaya"
  url "https://github.com/licht1stein/sanskrit-upaya/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "fc7640dd75c38c4f4b974dd3821c3bcbe8bf02ec3de2172eb5fb90e282f5d135"
  license "MIT"

  depends_on "go" => :build

  def install
    # Set version in binary
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/desktop"
  end

  def caveats
    <<~EOS
      On first run, Sanskrit Upaya will download the dictionary database (~670MB)
      from the internet. This is a one-time download.

      The database will be stored in:
        ~/Library/Application Support/sanskrit-dictionary/sanskrit.db

      To run the application:
        sanskrit-upaya
    EOS
  end

  test do
    # GUI app - just verify the binary exists and is executable
    assert_predicate bin/"sanskrit-upaya", :exist?
    assert_predicate bin/"sanskrit-upaya", :executable?
  end
end
