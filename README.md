# anyllm-cli

Multi-backend CLI for calling LLMs from the terminal: Google Gemini and OpenAI ChatGPT.

Features
- Send prompts to Google Gemini or OpenAI ChatGPT via `gemini` or `chatgpt` commands.
- Switch between models with ease or use `--model` flag to override.
- Persist provider API keys and model preferences securely in your XDG config directory.

Installation (via Homebrew tap):

```bash
brew tap user/tap https://github.com/<your-username>/homebrew-anyllm-cli
brew install user/tap/anyllm-cli
```

This installs two commands: `gemini` and `chatgpt` (both point to the same executable).

API key setup

- Set the Gemini key:

```bash
gemini --set-key YOUR_GEMINI_KEY
```

- Set the OpenAI key:

```bash
gemini --set-key openai YOUR_OPENAI_KEY
```

- Remove a key:

```bash
gemini --unset-key openai
```

Model configuration

- Set your default Gemini model interactively:

```bash
gemini --set-model
```

- Set your default OpenAI model interactively:

```bash
gemini --set-model openai
```

- Reset model preference:

```bash
gemini --unset-model
```

Usage examples

```bash
# Use Gemini (default)
gemini Tell me a joke

# Use ChatGPT
chatgpt Tell me a joke

# Override with a specific model for one call
gemini --model gemini-1.5-pro Tell me a joke
chatgpt --model gpt-4 Tell me a joke

# Use your saved defaults
gemini What is 2+2?
```

Configuration storage

Settings are stored in `$XDG_CONFIG_HOME/anyllm-cli/` (fallback `~/.config/anyllm-cli/`):
- `gemini_api_key` — Your Gemini API key
- `openai_api_key` — Your OpenAI API key
- `gemini_model` — Your saved default Gemini model
- `openai_model` — Your saved default OpenAI model

