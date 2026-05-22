class Claudekit < Formula
  desc "Quality-of-life hooks for Claude Code: memory, notifications, quality guards, and TUI"
  homepage "https://github.com/rezaiyan/claudekit"
  url "https://github.com/rezaiyan/claudekit/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "3df5117a555d6223aa7d0c0f64ab8090c0040e1e5a71abd208b384afbbb125c8"
  version "0.3.0"
  license "MIT"

  head "https://github.com/rezaiyan/claudekit.git", branch: "main"

  depends_on "bun"

  def install
    libexec.install Dir["*"]

    # Install deps — non-fatal if it fails (bin wrapper self-heals on first run)
    cd libexec do
      quiet_system "bun", "install"
    end

    # Bin wrapper: installs deps if missing, then launches TUI
    (bin/"claudekit").write <<~SH
      #!/bin/sh
      LIBEXEC="#{libexec}"
      if [ ! -d "$LIBEXEC/node_modules" ]; then
        echo "Installing claudekit dependencies..." >&2
        cd "$LIBEXEC" && bun install --silent
      fi
      exec bun "$LIBEXEC/bin/tui.js" "$@"
    SH
  end

  def caveats
    <<~EOS
      Run the TUI to manage tools:
        claudekit

      To use the Claude Code plugin (hooks + memory), install via Claude Code:
        /plugin marketplace add rezaiyan/claude-plugins
        /plugin install claudekit@rezaiyan

    EOS
  end

  test do
    assert_predicate bin/"claudekit", :exist?
  end
end
