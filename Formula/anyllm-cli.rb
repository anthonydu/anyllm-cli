class AnyllmCli < Formula
  desc "Multi-backend CLI for LLMs (Google Gemini, OpenAI ChatGPT)"
  homepage "https://github.com/anthonydu/anyllm-cli"
  url "https://github.com/anthonydu/anyllm-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  depends_on "jq"

  def install
    bin.install "bin/anyllm"
    # Create convenience symlinks
    bin.install_symlink "anyllm" => "gemini"
    bin.install_symlink "anyllm" => "chatgpt"
  end

  test do
    output = shell_output("#{bin}/gemini", 1)
    assert_match "Usage:", output
  end
end
