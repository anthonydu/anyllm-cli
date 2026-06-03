class AnyllmCli < Formula
  desc "Multi-backend CLI for LLMs (Google Gemini, OpenAI ChatGPT)"
  homepage "https://github.com/<your-username>/anyllm-cli"
  url "https://github.com/<your-username>/anyllm-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  def install
    bin.install "bin/anyllm"
    # Create convenience symlinks
    bin.install_symlink "anyllm" => "gemini"
    bin.install_symlink "anyllm" => "chatgpt"
  end

  test do
    output = shell_output("#{bin}/anyllm", 1)
    assert_match "Usage:", output
  end
end
