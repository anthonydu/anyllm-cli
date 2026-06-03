# anyllm-cli

Multi-backend CLI for calling LLMs from the terminal: Google Gemini and OpenAI ChatGPT.

Features
- Send prompts to Google Gemini or OpenAI ChatGPT via simple commands.
- Switch between models with `gemini`, `chatgpt`, or `--model` flag.
- Persist provider API keys and model preferences securely in your XDG config directory.

Installation (via Homebrew tap):

```bash
brew tap user/tap https://github.com/<your-username>/homebrew-anyllm-cli
brew install user/tap/anyllm-cli
```

This installs `anyllm` (main) and `gemini`, `chatgpt` (symlinks) for easy access.

API key setup

- Set the Gemini key:

```bash
anyllm --set-key YOUR_GEMINI_KEY
```

- Set the OpenAI key:

```bash
anyllm --set-key openai YOUR_OPENAI_KEY
```

- Remove a key:

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

- Reset model preference:

```bash
anyllm --unset-model
```

Usage examples

```bash
# Use Gemini (default)
anyllm Tell me a joke

# Use ChatGPT via alias
chatgpt Tell me a joke
gemini Tell me a joke

# Override with a specific model for one call
anyllm --model gemini-1.5-pro Tell me a joke
anyllm --model gpt-4 Tell me a joke

# Use your saved defaults
anyllm What is 2+2?
```

Configuration storage

Settings are stored in `$XDG_CONFIG_HOME/gemini-cli/` (fallback `~/.config/gemini-cli/`):
- `gemini_api_key` — Your Gemini API key
- `openai_api_key` — Your OpenAI API key
- `gemini_model` — Your saved default Gemini model
- `openai_model` — Your saved default OpenAI model

