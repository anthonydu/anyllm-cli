# anyllm-cli

Multi-backend CLI for calling LLMs from the terminal.

Features
- Send prompts to Google Gemini or OpenAI ChatGPT via a single CLI.
- Persist provider API keys securely in your XDG config directory with `--set-key`.

Installation (recommended via Homebrew tap):

- Create a GitHub release tarball containing the `bin/` directory.
- Add the Homebrew formula (see `Formula/anyllm-cli.rb`) to a tap or submit to homebrew-core.
- Users can then install with `brew install user/tap/anyllm-cli`.

API key usage

- Set the Gemini key (legacy):

```bash
anyllm --set-key YOUR_GEMINI_KEY
```

- Set the OpenAI key:

```bash
anyllm --set-key openai YOUR_OPENAI_KEY
```

- Remove the stored key:

```bash
anyllm --unset-key openai
```

Usage examples

```bash
# Use Gemini (default)
anyllm Tell me a joke

# Use ChatGPT by invocation name (create symlink) or alias
anyllm chatgpt Tell me a joke
```

When running, the CLI checks for provider-specific keys in `$XDG_CONFIG_HOME/gemini-cli/` (fallback `~/.config/gemini-cli/`).

