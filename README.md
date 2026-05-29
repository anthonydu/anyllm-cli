# gemini-cli

Simple CLI wrapper for Google Gemini.

Features
- Send prompts to the Gemini API via the `gemini` command.
- Persist the API key securely in your XDG config directory with `--set-key`.

Installation (recommended via Homebrew tap):

- Create a GitHub release tarball containing the `bin/` directory.
- Add the Homebrew formula (see `Formula/gemini-cli.rb`) to a tap or submit to homebrew-core.
- Users can then install with `brew install user/tap/gemini-cli`.

API key usage

- Set the key once (saves to `~/.config/gemini-cli/api_key` or `$XDG_CONFIG_HOME/gemini-cli/api_key`):

```bash
gemini --set-key YOUR_API_KEY
```

- Remove the stored key:

```bash
gemini --unset-key
```

When running normally, `gemini` will use `GEMINI_API_KEY` if set, otherwise it will read the stored key.

See the project files for a formula template and packaging instructions.
