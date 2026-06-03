#compdef gemini chatgpt anyllm

_anyllm() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a common_args=(
        '--model[Specify LLM model override]:model:->models'
        '--mode[Specify response mode override]:mode:(default minimal code)'
        '--key[Specify API key override]:key:'
        '--set-key[Save API key for a provider]:provider:->providers_with_key'
        '--unset-key[Remove API key for a provider]:provider:(gemini openai)'
        '--set-model[Interactively set default model]:provider:(gemini openai)'
        '--unset-model[Reset default model preference]:provider:(gemini openai)'
        '--set-mode[Set default response mode preference]:mode:(default minimal code)'
        '--unset-mode[Reset default response mode preference]'
        '(-h --help)'{-h,--help}'[Show usage instructions]'
        '*:prompt:_files'
    )

    _arguments -s -S $common_args

    case $state in
        models)
            local -a available_models
            if [[ "$words[1]" == *chatgpt* || "$words[1]" == *chat* || "$words[1]" == *gpt* ]]; then
                available_models=(gpt-4o gpt-4-turbo gpt-4 gpt-3.5-turbo)
            else
                available_models=(gemini-2.5-flash gemini-2.0-flash gemini-1.5-pro gemini-1.5-flash)
            fi
            _describe -t models 'models' available_models
            ;;
        providers_with_key)
            local -a providers=(
                'gemini:Google Gemini API key'
                'openai:OpenAI ChatGPT API key'
            )
            _describe -t providers 'providers' providers
            ;;
    esac
}

_anyllm "$@"
