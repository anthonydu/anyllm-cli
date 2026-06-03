_anyllm() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="--model -m --style -s --key -k --set-key --unset-key --set-model --unset-model --set-style --unset-style --help -h"

    case "${prev}" in
        --model|-m)
            local models
            if [[ "${COMP_WORDS[0]}" == *chatgpt* || "${COMP_WORDS[0]}" == *chat* || "${COMP_WORDS[0]}" == *gpt* ]]; then
                models="gpt-4o gpt-4-turbo gpt-4 gpt-3.5-turbo"
            else
                models="gemini-2.5-flash gemini-2.0-flash gemini-1.5-pro gemini-1.5-flash"
            fi
            COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
            return 0
            ;;
        --style|-s|--set-style)
            COMPREPLY=( $(compgen -W "default minimal code" -- ${cur}) )
            return 0
            ;;
        --set-key|--unset-key|--set-model|--unset-model)
            COMPREPLY=( $(compgen -W "gemini openai" -- ${cur}) )
            return 0
            ;;
    esac

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _anyllm gemini chatgpt anyllm
