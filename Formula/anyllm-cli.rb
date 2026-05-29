class AnyllmCli < Formula
  desc "Command-line client for multiple LLM backends (Google Gemini, OpenAI)"
  homepage "https://github.com/<your-username>/anyllm-cli"
  url "https://github.com/<your-username>/anyllm-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  def install
    bin.install "bin/anyllm"
    # Optional: install a compatibility symlink 'gemini' to the same executable
    bin.install_symlink "anyllm" => "gemini"
  end

  test do
    output = shell_output("#{bin}/anyllm", 1)
    assert_match "Usage:", output
  end
end
