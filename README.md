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

Model configuration

- Set your default Gemini model interactively:

```bash
anyllm --set-model
```

- Set your default OpenAI model interactively:

```bash
anyllm --set-model openai
```

- Reset model preference to hardcoded default:

```bash
anyllm --unset-model
anyllm --unset-model openai
```

Usage examples

```bash
# Use Gemini (default or your saved preference)
anyllm Tell me a joke

# Use ChatGPT by invocation name (create symlink) or alias
anyllm chatgpt Tell me a joke

# Override saved model for a single call
anyllm --model gemini-1.5-pro Tell me a joke
anyllm --model gpt-4 Tell me a joke
```

Configuration storage

The CLI stores settings in `$XDG_CONFIG_HOME/gemini-cli/` (fallback `~/.config/gemini-cli/`):
- `gemini_api_key` — Your Gemini API key
- `openai_api_key` — Your OpenAI API key
- `gemini_model` — Your saved default Gemini model
- `openai_model` — Your saved default OpenAI model

