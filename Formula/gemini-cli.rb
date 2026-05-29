class GeminiCli < Formula
  desc "Small CLI wrapper for Google Gemini"
  homepage "https://github.com/<your-username>/gemini-cli"
  url "https://github.com/<your-username>/gemini-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  def install
    bin.install "bin/gemini"
  end

  test do
    # The script exits with usage error when no args are provided; assert that.
    output = shell_output("#{bin}/gemini", 1)
    assert_match "Usage:", output
  end
end
