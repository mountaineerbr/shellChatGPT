#compdef chatgpt.sh

# Zsh Completion Script for ``chatgpt.sh''

# System Wide:  /usr/share/zsh/site-functions/
#               /usr/local/share/zsh/site-functions/
# User-Specific: under $fpath

local script operator
script="chatgpt.sh"
operator=""


#list session names
__session_listf()
{
  case "${words[CURRENT]}" in
    [!/]|[!/][!/]*|*/*[!/]*/*|\~*|.*)
      _files
      ;;
    *)
      local REPLY options ifs
      ifs=$IFS IFS=$'\t\n'
      options=( $("${script}" -EE /list 2>/dev/null | while read -r
        do
          printf '%s\n' "/${REPLY%%.[Tt][Ss][Vv]}"
        done) )
      IFS=$ifs
      compadd -a options "$@"  #pass args from _arguments to compadd!
      ((${#options[@]})) || _files
      ;;
  esac
}
__session_or_pr_listf()
{
  case "${words[CURRENT]}" in
    [.,]|[.,][.,])
      __pr_list2f
      ;;
    *)
      __session_listf
      ;;
  esac
}

#list prompt names
__pr_listf()
{
  local REPLY options ifs
  ifs=$IFS IFS=$'\t\n'
  options=( $("${script}" -EE -S .list 2>/dev/null | while read -r
    do
      printf '%s\n' "${operator}${REPLY%%.[Pp][Rr]}"
    done) )
  IFS=$ifs
  ((${#options[@]})) || options=( 'prompt_name' )
  compadd -a options "$@"
  ((${#options[@]})) || _files
}
#list prompt names plus operators
__pr_list2f() { 	operator="." __pr_listf ;}
__pr_list3f()
{
  local options
  __pr_list2f
  case "${words[CURRENT]}" in /*) __awesome_list1f "$@";; %*) __awesome_list3f "$@";; esac
  options=( "." ".." "," "/" "%" "/awesome_prompt_act" "%awesome_prompt_act_ch" "text_file" "text_prompt" "pdf_file" )
  compadd -a options "$@"
}

#list models from cache
__mod_listf()
{
  local options
  options=( $("${script}" -EE -lll 2>/dev/null) )
  ((${#options[@]})) || options=( 'davinci-002'  'gpt-3.5-turbo'  'gpt-3.5-turbo-instruct' 
    'gpt-4o'  'gpt-4-turbo'  'text-moderation-latest'
    'mistral-large-latest'  'codestral-latest'  'open-mixtral-8x22b'
    'llama3'  'gemini-1.5-flash-latest'  'gemini-1.5-pro-latest' )
  compadd -a options "$@"
}

#list awesome-prompts
__awesome_listf()
{
  local options
  options=( $( "${script}" -EE -S ${operator:-/}list 2>&1 \
      | sed -n '/^ *[0-9][0-9]*/,$ p' \
      | sed "s/[0-9][0-9]*:/${operator2//\//\\/}/g" ) )
  compadd -a options "$@"
}
__awesome_list1f() { 	operator="/" operator2="/" __awesome_listf "$@" ;}
__awesome_list2f() { 	operator="/" operator2=""  __awesome_listf "$@" ;}
__awesome_list3f() { 	operator="%" operator2="%" __awesome_listf "$@" ;}
__awesome_list4f() { 	operator="%" operator2=""  __awesome_listf "$@" ;}

#main fun
_chatgpt.sh()
{
  local options ifs

  _arguments -s -S : \
    {-@,--alpha}'[Mask transparent colour]:alpha -- [[percent%%]colour]' \
    '-Nill[Unset model max response]' \
    {-M,--max}'[Maximum response tokens]:max response -- [integer[-integer]]' \
    {-N,--modmax}'[Model capacity tokens]:model capacity -- [integer]' \
    {-a,--presence-penalty}'[Presence penalty]:presence-penalty -- [float]' \
    {-A,--frequency-penalty}'[Frequency penalty]:frequency-penalty -- [float]' \
    {-b,--best-of}'[Best-of]:best-of -- [integer]' \
    {-B,--logprobs}'[Log probabilities]:log-probs -- [integer]' \
    {-K,--top-k}'[Top_k value]:top_k -- [integer]' \
    {--keep-alive,--ka}'[Keep-alive seconds]:keep-alive -- [integer]' \
    {-m+,--model}'[Set language model]:model name:__mod_listf' \
    '--multimodal[Enable multimodal mode]' \
    {-n,--results}'[Number of results]:results -- [integer]' \
    {-p,--top-p}'[Top_p value]:top_p -- [float]' \
    {-r,--restart}'[Restart sequence]:restart-sequence:(sequence \\nQ\:\ )' \
    {-R,--start}'[Start sequence]:start-sequence:(sequence \\nA\:)' \
    {-s,--stop}'[Stop sequences]:stop-sequence:(sequence \\nQ\:\  \\nA\:)' \
    {-t,--temperature}'[Temperature]:temperature -- [float]' \
    {-c,-cc,--chat}'[Text or native chat completions]' \
    {-C,--continue}'[Continue from last session]' \
    {-d,--text}'[Text completions]' \
    {-e,--edit}'[Edit first prompt]' \
    {-E,-EE,--exit}'[Exit on first run]' \
    {-g,--stream}'[Stream response on]' \
    {-G,--no-stream}'[Stream response off]' \
    {-i,--image}'[Image generation, variation or edit]' \
    {-q,-qq,--insert}'[Insert text mode (two for multiturn)]' \
    {-S,--instruction}'[Instruction prompt]:instruction:__pr_list3f' \
    {-S.-,-S..-,-S\,-}'[Custom prompt]:name:__pr_listf' \
    {-.+,-\,+,-..-}'[Load custom prompt]:name:__pr_listf' \
    -S/-'[Awesome-prompts]:act:__awesome_list2f' \
    -S%-'[Awesome-prompts]:act:__awesome_list4f' \
    {-T,--tiktoken}'[Count input tokens]' \
    '-TT[Print input tokens]' \
    '-TTT[List available encodings]' \
    {-w,--transcribe}'[Transcribe audio]' \
    '-ww[Transcribe audio (timestamps)]' \
    {-W,--translate}'[Translate audio to English]' \
    '-WW[Translate audio to English (timestamps)]' \
    '--api-key[API key]:key' \
    {-f,--no-conf}'[Ignore configuration file]' \
    {-F,-FF}'[Edit configuration or dump template]' \
    {--fold,--no-fold}'[Response folding on/off]' \
    {-h,--help}'[Print help page]' \
    {-H,--hist}'[Edit history file]' \
    {-HH,-HHH}'[Print last session from history]' \
    {-k,--no-colour}'[Disable color output]' \
    {-l,--list-models}'[List models]:model name (optional)' \
    {-L,--log}'[Log file]:log filepath:_files' \
    '(--localai --mistral --google)'{-O,--ollama}'[Ollama integration]' \
    '(-O --ollama --mistral --google)--localai[LocalAI integration]' \
    '(-O --ollama --localai --google)--mistral[Mistral AI integration]' \
    '(-O --ollama --mistral --localai)--google[GoogleAI integration]' \
    {--md,--markdown}'[Enable markdown rendering]' \
    {--md=-,--markdown=-}'[Set markdown software (=cmd)]:markdown command:(bat pygmentize glow mdcat mdless)' \
    {--no-md,--no-markdown}'[Disable markdown rendering]' \
    {-o,--clipboard}'[Copy to clipboard]' \
    {-u,--multi}'[Multiline prompter (ctrl-d)]' \
    {-U,--cat}'[Cat prompter (ctrl-d)]' \
    {-v,-vv,--verbose}'[Less verbose mode]' \
    '-V[Pretty-print context]' \
    '-VV[Dump raw request (debug)]' \
    {-x,--editor}'[Edit prompt in text editor]' \
    {-y,--tik}'[Set tiktoken]' \
    {-Y,--no-tik}'[Unset tiktoken]' \
    {-z,--tts}'[Synthesize speech]' \
    {-Z,--last}'[Dump last response JSON]' \
    '1:session/file:__session_or_pr_listf' '*:file:_files'
    #-{0..9}'[Maximum response tokens]:max response -- integer [0-9]' \
}


command -v "${script}" >/dev/null 2>&1 || script="false";

_chatgpt.sh "$@"

# ex: filetype=zsh