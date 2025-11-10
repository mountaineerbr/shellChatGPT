# chatgpt.sh(1) completion                                 -*- shell-script -*-
# v0.117

# System Wide: /usr/share/bash-completion/completions/         #pkg manager
#              /usr/local/share/bash-completion/completions/   #manually
# User-Specific: ~/.local/share/bash-completion/completions/

#list session names
__session_listf()
{
  local REPLY

  chatgpt.sh -EE /list 2>/dev/null | while read -r
    do
      printf '%s\n'  "${1}${REPLY%%.[Tt][Ss][Vv]}";
    done
}

#list custom prompts
__pr_listf()
{
  local REPLY

  chatgpt.sh -EE -S .list 2>/dev/null | while read -r
    do
      printf '%s\n' "${1}${REPLY%%.[Pp][Rr]}";
    done
}

#list models
__model_listf()
{
  chatgpt.sh -EE -lll 2>/dev/null
}

#list awesome-prompts
__awesome_listf()
{
  local var
  var=${2:-${1:-/}}

  set -- "${1:0:1}"
  chatgpt.sh -EE -S ${1:-/}list 2>&1 \
    | sed -n '/^ *[0-9][0-9]*/,$ p' \
    | sed "s/[0-9][0-9]*:/${var//\//\\\/}/g"
}

#main fun
_chatgptsh()
{
  local cur prev opts ifs models op var
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  models=( 'davinci-002'  'gpt-3.5-turbo'  'gpt-3.5-turbo-instruct' 
    'gpt-4o'  'gpt-4-turbo'  'text-moderation-latest'
    'mistral-large-latest'  'codestral-latest'  'open-mixtral-8x22b'
    'llama3'  'gemini-1.5-flash-latest'  'gemini-1.5-pro-latest' )

  opts="-@ --alpha
        -Nill -M --max --max-tokens
        -N --modmax --mod-max
        -a --presence-penalty --presence --pre
        -A --frequency-penalty --frequency --freq
        -b --responses --resp
        --best-of --best
        -j --seed
        -K --top-k --topk
        --keep-alive --ka
        -m --model --mod
        --multimodal
        --vision
        --audio
        -n --results
        -p --top-p --topp
        -r --restart --restart-seq --restart-sequence
        -R --start --start-seq --start-sequence
        -s --stop
        -S --instruction
        -. -, -,,
        -t --temperature --temp
        --time --date --no-time --no-date
        -c --chat -cc
        -C --continue --resume
        -d --text
        --effort --budget
        -e --edit
        -E --exit -EE
        -g --stream
        -G --no-stream
        --think
        -i --image
        -X --media
        -q -qq --insert
        --awesome --awesome-zh
        -T --tiktoken -TT -TTT
        -w --transcribe --stt -ww -www
        -W --translate -WW -WWW
        --api-key
        -f --no-conf
        -F -FF
        --fold --wrap --no-fold --no-wrap
        --google --goo --groq --anthropic --ant --github --git --openai
        --xai --grok --deepseek --deep --novita --nov
        -h --help
        -H --hist -HH -P -PP --print
        -k --no-colour --no-color
        -l --list-models
        -L --log
        --source
        --tmp
        --localai --local-ai --local
        --mistral
        --md --markdown --md= --markdown=
        --no-md --no-markdown
        -o --clipboard --clip
        -O --ollama
        -u --multi --multiline
        -U --cat
        -v -vv
        -V -VV
        -x --editor
        -y --tik
        -Y --no-tik
        -z --tts --speech
        --format
        --no-truncation
        --verb --verbosity --no-verbosity
        --voice
        -Z --last
        --info
        --version
  "


  #main
  [[ $prev = "=" ]] && prev=${PREV_PREV:-$prev}; PREV_PREV=$prev;  #--foo=bar hack

  case "${prev}" in
    -@|-[!-]*@|--alpha)
      ((${#cur})) || COMPREPLY=( '[[percent%]colour]' '"10%white"' )
      ;;
    -[aApt]|-[!-]*[aApt]|--presence*|--pre|--frequency*|--freq|--top-p|--topp|--temperature|--temp)
      ((${#cur})) || COMPREPLY=( '[float]' )
      ;;
    -[NbBKn]|-[!-]*[NbBKn]|--modmax*|--best-of*|--best|--top-k|--topk|--keep-alive|--ka|--results|--seed)
      ((${#cur})) || COMPREPLY=( '[integer]' )
      ;;
    -M|-[!-]*M|--max|--max-tokens)
      ((${#cur})) || COMPREPLY=( '[integer]' '[integer-integer]' )
      ;;
    -r|-[!-]*r|--restart*)
      ((${#cur})) || COMPREPLY=( '[restart-sequence]' '"\\nQ: "' )
      ;;
    -R|-[!-]*R|--start*)
      ((${#cur})) || COMPREPLY=( '[start-sequence]' '"\\nA:"' )
      ;;
    -s|-[!-]*s|--stop*)
      ((${#cur})) || COMPREPLY=( '[stop-sequence]' '"\\nQ: "' '"\\nA:"' )
      ;;
    --effort|--budget)
      ((${#cur})) || COMPREPLY=( 'minimal' 'low' 'medium' 'high' )
      ;;
    --think)
      ((${#cur})) || COMPREPLY=( 'TOKEN_NUM' '16000' )
      ;;
    --md|--markdown)
      COMPREPLY=( $(compgen -W "bat pygmentize glow mdcat mdless" -- "${cur##*=}") )
      ;;
    -m|-[!-]*m|--model|--mod)
      COMPREPLY=( $(compgen -W "$(chatgpt.sh -EE -lll 2>/dev/null)" -- "${cur}") )
      ((${#COMPREPLY[@]})) || COMPREPLY=( "${models[@]}" )
      ;;
    --format)
      COMPREPLY=( mp3 opus aac flac wav pcm16  mulaw ogg )
      ;;
    --verb|--verbosity)
      ((${#cur})) || COMPREPLY=( 'low' 'medium' 'high' )
      ;;
    --voice)
      COMPREPLY=( alloy echo fable onyx nova shimmer  ash ballad coral sage verse  Aaliyah-PlayAI Basil-PlayAI Calum-PlayAI Deedee-PlayAI Eleanor-PlayAI Fritz-PlayAI Gail-PlayAI Indigo-PlayAI Jennifer-PlayAI Mamaw-PlayAI Nia-PlayAI Quinn-PlayAI Ruby-PlayAI Thunder-PlayAI )
      ;;
    -[.,]|-[.,][.,]|\
    -[!S.,-][.,]|-[!S.,-][.,][.,]|\
    -[!-]*[!S.,][.,]|\
    -S|-[!-]*S|--instruction)
      if [[ ${cur} = [/%]* ]]
      then
          COMPREPLY=( $(compgen -W "$(__awesome_listf "${cur:0:1}")
            ${cur:0:1}list /[awesome_prompt_act] %[awesome_prompt_act_ch]" -- "${cur}") )
      else
          ifs=$IFS IFS=$'\t\n'
          COMPREPLY=( $(compgen -W "$(
            [[ ${prev} = *[.,]* ]] || op=${cur%%[!.,]*} op=${op:0:2} op=${op:-.}
            __pr_listf "${op}")" -- "${cur}") )
          IFS=$ifs
      fi
      ((${#cur})) || COMPREPLY=( "${COMPREPLY[@]}" $(compgen -W "[text_file] [pdf_file] [text_prompt] .[prompt_name] ,[prompt_name] /[awesome_prompt_act] %[awesome_prompt_act_ch]" -- "${cur}") )
      ;;
    *)
      case "${cur}" in
        -S[/%]*|-[!-]*S[/%]*)
          COMPREPLY=( $(compgen -W "$(var=${cur##*[/%]}
            __awesome_listf "${cur//[!\/%]}" "${cur%%"${var}"}")
            ${cur:0:1}list /[awesome_prompt_act] %[awesome_prompt_act_ch]" -- "${cur}") )
          ;;
        #options -S. and -. hacks (custom prompt files)
        -S[.,]*|\
        -S[.,][.,]*|\
        -[.,]*|-[!-]*[.,]*|\
        [.,] | [.,][.,] | [.,][!/.,]* | [.,][.,][!/]*)  #first positional argument
          ifs=$IFS IFS=$'\t\n'
	  var=${cur%[.,][a-zA-Z0-9]*}
	  var=${cur:0:${#var}+1}
          COMPREPLY=( $(compgen -W "$(__pr_listf "${var}") .[prompt_name]" -- "${cur}") )
          IFS=$ifs
          ;;
        -m*|-[!-]*m*)
          COMPREPLY=( $(compgen -W "$(printf -- "${cur%%m*}m%s\n" $(__model_listf) )" -- "${cur}") )
          ((${#COMPREPLY[@]})) || COMPREPLY=( "${models[@]}" )
          ;;
        [/!]*)  #user history files
          ifs=$IFS IFS=$'\t\n'
          COMPREPLY=( $(compgen -W "$(__session_listf "${cur:0:1}") ${cur:0:1}[history_file]" -- "${cur}") )
          IFS=$ifs
          ;;
        -[1-9]*|-[!-][0-9]*)  #max response tokens (e.g. -4000)
          COMPREPLY=( "${cur}" "${cur}1" "${cur}2" "${cur}3" "${cur}4" "${cur}5" "${cur}6" "${cur}7" "${cur}8" "${cur}9" "${cur}0" )
          ;;
        -|-[!-]*)  #agglutinated short options (e.g. -vcc)
          COMPREPLY=( $(compgen -W "$(sed -e 's/--[^ ]*//g' <<<"${opts}")" -- "${cur}") )  #sed -e "s/-/${cur}/g"
          ((${#COMPREPLY[@]})) || COMPREPLY=( "${cur}" )
          ;;
        -*)  #short and long options
          COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
          ;;
        '')  #first suggestion when no input + list files
          ((${#COMP_WORDS[@]}==2)) && COMPREPLY=( '-cc' )
          ((${#COMP_WORDS[@]}<5)) && COMPREPLY=( '/[session_name]' '.[prompt_name]' "${COMPREPLY[@]}" )
          ;&
        *)  #filetype filter
          COMPREPLY=( $(compgen -f -X '!*.@([Jj][Pp][Gg]|[Jj][Pp][Ee][Gg]|[Pp][Nn][Gg]|[Ww][Ee][Bb][Pp]|[Gg][Ii][Ff]|[Mm][Pp][34]|[Oo][Pp][Uu][Ss]|[Aa][Aa][Cc]|[Ff][Ll][Aa][Cc]|[Ww][Aa][Vv]|[Mm][Oo][Vv]|[Mm][Pp][Ee][Gg]|[Mm][Pp][Gg]|[Aa][Vv][Ii]|[Ww][Mm][Vv]|[Ff][Ll][Vv]|[Tt][Xx][Tt]|[Hh][Tt][Mm][Ll]|[Pp][Rr]|[Tt][Ss][Vv]|[Pp][Dd][Ff])' -- "${cur}") "${COMPREPLY[@]}")
          #https://www.linux.org/threads/custom-autocomplete-in-bash-zsh-functions.45561/
          ;;
      esac
      ;;
    esac
} &&
    complete -o default -F _chatgptsh chatgpt.sh

# ex: filetype=sh
