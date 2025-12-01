cask "sanskrit-upaya" do
  version "1.0.5"
  sha256 "77741ffd5a4cff25b40252b135d3f171537c88138a71e707d1c833716e68190f"

  url "https://github.com/licht1stein/sanskrit-upaya/releases/download/v#{version}/sanskrit-upaya-v#{version}-macos.dmg"
  name "Sanskrit Upaya"
  desc "Cross-platform Sanskrit dictionary with full-text search across 36 dictionaries"
  homepage "https://github.com/licht1stein/sanskrit-upaya"

  depends_on formula: "go"

  app "Sanskrit Upāya.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-rd", "com.apple.quarantine", "#{appdir}/Sanskrit Upāya.app"]
    system_command "/usr/bin/codesign",
                   args: ["--force", "--deep", "-s", "-", "#{appdir}/Sanskrit Upāya.app"]

    # Build MCP server from source
    Dir.mktmpdir do |tmpdir|
      system_command "git",
                     args: ["clone", "--depth", "1", "--branch", "v#{version}",
                            "https://github.com/licht1stein/sanskrit-upaya.git", tmpdir]
      system_command "#{HOMEBREW_PREFIX}/bin/go",
                     args: ["build", "-ldflags", "-s -w -X main.Version=#{version}",
                            "-o", "#{HOMEBREW_PREFIX}/bin/sanskrit-upaya-mcp", "./cmd/mcp"],
                     chdir: tmpdir
    end
  end

  uninstall delete: "#{HOMEBREW_PREFIX}/bin/sanskrit-upaya-mcp"

  caveats <<~EOS
    #{token} is not notarized by Apple.
    On first run, the app will download the dictionary database (~670MB).

    MCP server installed at: #{HOMEBREW_PREFIX}/bin/sanskrit-upaya-mcp
    Add to Claude Code config:
      {
        "mcpServers": {
          "sanskrit": {
            "command": "#{HOMEBREW_PREFIX}/bin/sanskrit-upaya-mcp"
          }
        }
      }
  EOS
end
