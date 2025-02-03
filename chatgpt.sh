#!/usr/bin/env bash
# chatgpt.sh -- Shell Wrapper for ChatGPT/DALL-E/Whisper/TTS
# v0.92.7  feb/2025  by mountaineerbr  GPL+3
set -o pipefail; shopt -s extglob checkwinsize cmdhist lithist histappend;
export COLUMNS LINES; ((COLUMNS>2)) || COLUMNS=80; ((LINES>2)) || LINES=24;

# API keys
#OPENAI_API_KEY=
#GOOGLE_API_KEY=
#MISTRAL_API_KEY=
#GROQ_API_KEY=
#ANTHROPIC_API_KEY=
#GITHUB_TOKEN=
#NOVITA_API_KEY=
#XAI_API_KEY=

# DEFAULTS
# Text cmpls model
MOD="gpt-3.5-turbo-instruct"
# Chat cmpls model
MOD_CHAT="${MOD_CHAT:-gpt-4o}"  #"chatgpt-4o-latest"
# Image model (generations)
MOD_IMAGE="${MOD_IMAGE:-dall-e-3}"
# Whisper model (STT)
MOD_AUDIO="${MOD_AUDIO:-whisper-1}"
# Speech model (TTS)
MOD_SPEECH="${MOD_SPEECH:-tts-1}"
# LocalAI model
MOD_LOCALAI="${MOD_LOCALAI:-phi-2}"
# Ollama model
MOD_OLLAMA="${MOD_OLLAMA:-llama3.2}"
# Google AI model
MOD_GOOGLE="${MOD_GOOGLE:-gemini-2.0-flash-exp}"
# Mistral AI model
MOD_MISTRAL="${MOD_MISTRAL:-mistral-large-latest}"
# Groq models
MOD_GROQ="${MOD_GROQ:-llama-3.1-70b-versatile}"
MOD_AUDIO_GROQ="${MOD_AUDIO_GROQ:-whisper-large-v3}"
# Prefer Groq Whisper (chat mode)
#WHISPER_GROQ=
# Anthropic model
MOD_ANTHROPIC="${MOD_ANTHROPIC:-claude-3-5-sonnet-latest}"
# Github Azure model
MOD_GITHUB="${MOD_GITHUB:-Phi-3-medium-128k-instruct}"
# Novita AI model
MOD_NOVITA="${MOD_NOVITA:-sao10k/l3-70b-euryale-v2.1}"
# xAI model
MOD_XAI="${MOD_XAI:-grok-2-latest}"
# DeepSeek model
MOD_DEEPSEEK="${MOD_DEEPSEEK:-deepseek-reasoner}"
# Bash readline mode
READLINEOPT="emacs"  #"vi"
# Stream response
STREAM=1
# Prompter flush with <CTRL-D>
#OPTCTRD=
# Temperature
#OPTT=
# Whisper temperature
OPTTW=0
# Top_p probability mass (nucleus sampling)
#OPTP=1
# Maximum response tokens
OPTMAX=1024
# Model capacity (auto)
#MODMAX=
# Presence penalty
#OPTA=
# Frequency penalty
#OPTAA=
# N responses of Best_of
#OPTB=
# Number of responses
OPTN=1
# Keep Alive (seconds, Ollama)
#OPT_KEEPALIVE=
# Seed (integer)
#OPTSEED=
# Set python tiktoken
#OPTTIK=
# Image size
#OPTS=1024x1024  #hd
#Image style
#OPTI_STYLE=natural  #vivid
# Image out format
OPTI_FMT=b64_json  #url
# TTS voice
OPTZ_VOICE=echo  #alloy, echo, fable, onyx, nova, and shimmer
# TTS voice speed
#OPTZ_SPEED=   #0.25 - 4.0
# TTS out file format
#OPTZ_FMT=opus   #mp3, opus, aac, flac, wav, pcm16
# Recorder command, e.g. "sox -d"
#REC_CMD=""
# Media player command, e.g. "cvlc"
#PLAY_CMD=""
# Clipboard set command, e.g. "xsel -b", "pbcopy"
#CLIP_CMD=""
# Markdown renderer, e.g. "pygmentize -s -lmd", "glow", "mdless", "mdcat"
#MD_CMD="bat"
# Fold response (wrap at white spaces)
OPTFOLD=1
# Avoid using dialog
#NO_DIALOG=
# Inject restart text
#RESTART=""
# Inject   start text
#START=""
#  Chat mode of text cmpls sets "\nQ: " and "\nA:"
# Reasoning effort
#REASON_EFFORT=  #low, medium, or high
# Reasoning interactive
#REASON_INTERACTIVE=  #true or false
# Input and output prices (dollars per million tokens)
#MOD_PRICE="0 0"
# Currency rate against USD
# e.g. BRL is 5.66 USD, JPY is 0.006665 USD
#CURRENCY_RATE="1"

# INSTRUCTION
# Chat completions, chat mode only
# INSTRUCTION=""
INSTRUCTION_CHAT_EN="The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and friendly."
INSTRUCTION_CHAT_PT="A seguinte é uma conversa com um assistente de IA. O assistente é prestativo, criativo, sagaz e amigável." 
INSTRUCTION_CHAT_ES="Lo siguiente es una conversación con un asistente de IA. El asistente es servicial, creativo, listo y amigable." 
INSTRUCTION_CHAT_IT="La seguente è una conversazione con un assistente AI. L'assistente è utile, creativo, sveglio e amichevole."
INSTRUCTION_CHAT_FR="Ce qui suit est une conversation avec un assistant d'IA. L'assistant est prévenant, créatif, astucieux et amical." 
INSTRUCTION_CHAT_DE="Das Folgende ist ein Gespräch mit einem KI-Assistenten. Der Assistent ist hilfsbereit, kreativ, klug und freundlich."
INSTRUCTION_CHAT_RU="Далее приводится разговор с ИИ-ассистентом. Ассистент полезный, креативный, сообразительный и дружелюбный."
INSTRUCTION_CHAT_JA="以下は、AIアシスタントとの会話です。アシスタントは、親切で、創造的で、賢く、そしてフレンドリーです。"
INSTRUCTION_CHAT_ZH="以下是对话内容与一位人工智能助手之间的对话。该助手乐于助人、富有创造力、聪明且友好。"
INSTRUCTION_CHAT_ZH_TW="以下是对话內容與一位人工智慧助手之間的對話。該助手樂於助人、富有創造力、聰明且友善。"
INSTRUCTION_CHAT_HI="निम्न एक एआई सहायक के साथ एक वार्तालाप है। सहायक मददगार, रचनात्मक, चतुर और मित्रवत है।"
INSTRUCTION_CHAT="${INSTRUCTION_CHAT-$INSTRUCTION_CHAT_EN}"
# Insert timestamp in instruction prompt
#INST_TIME=0

# Awesome-chatgpt-prompts URL
AWEURL="https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv"
AWEURLZH="https://raw.githubusercontent.com/PlexPt/awesome-chatgpt-prompts-zh/main/prompts-zh.json"  #prompts-zh-TW.json

# CACHE AND OUTPUT DIRECTORIES
CACHEDIR="${CACHEDIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/chatgptsh"
OUTDIR="${OUTDIR:-${XDG_DOWNLOAD_DIR:-$HOME/Downloads}}"

# Colour palette
# Normal Colours       # Bold                  # Background
Black='\u001b[0;30m'   BBlack='\u001b[1;30m'   On_Black='\u001b[40m'  \
Red='\u001b[0;31m'     BRed='\u001b[1;31m'     On_Red='\u001b[41m'    \
Green='\u001b[0;32m'   BGreen='\u001b[1;32m'   On_Green='\u001b[42m'  \
Yellow='\u001b[0;33m'  BYellow='\u001b[1;33m'  On_Yellow='\u001b[43m' \
Blue='\u001b[0;34m'    BBlue='\u001b[1;34m'    On_Blue='\u001b[44m'   \
Purple='\u001b[0;35m'  BPurple='\u001b[1;35m'  On_Purple='\u001b[45m' \
Cyan='\u001b[0;36m'    BCyan='\u001b[1;36m'    On_Cyan='\u001b[46m'   \
White='\u001b[0;37m'   BWhite='\u001b[1;37m'   On_White='\u001b[47m'  \
Inv='\u001b[0;7m'      Nc='\u001b[m'           Alert=$BWhite$On_Red   \
Bold='\u001b[0;1m';
HISTSIZE=256;

# Load user defaults
((${#CHATGPTRC})) || CHATGPTRC="$HOME/.chatgpt.conf"
[[ -f "${OPTF}${CHATGPTRC}" ]] && . "$CHATGPTRC";

# Set file paths
FILE="${CACHEDIR%/}/chatgpt.json"
FILESTREAM="${CACHEDIR%/}/chatgpt_stream.json"
FILECHAT="${FILECHAT:-${CACHEDIR%/}/chatgpt.tsv}"
FILEWHISPER="${FILECHAT%/*}/whisper.json"
FILEWHISPERLOG="${OUTDIR%/*}/whisper_log.txt"
FILETXT="${CACHEDIR%/}/chatgpt.txt"
FILEOUT="${OUTDIR%/}/dalle_out.png"
FILEOUT_TTS="${OUTDIR%/}/tts.${OPTZ_FMT:=opus}"
FILEIN="${CACHEDIR%/}/dalle_in.png"
FILEINW="${CACHEDIR%/}/whisper_in.${REC_FMT:=mp3}"
FILEAWE="${CACHEDIR%/}/awesome-prompts.csv"
FILEFIFO="${CACHEDIR%/}/fifo.buff"
FILEMODEL="${CACHEDIR%/}/models.txt"
USRLOG="${OUTDIR%/}/${FILETXT##*/}"
HISTFILE="${CACHEDIR%/}/history_bash"
HISTCONTROL=erasedups:ignoredups
SAVEHIST=$HISTSIZE HISTTIMEFORMAT='%F %T '

# API URL / endpoint
OPENAI_BASE_URL_DEF="https://api.openai.com/v1";
OLLAMA_BASE_URL_DEF="http://localhost:11434";
LOCALAI_BASE_URL_DEF="http://127.0.0.1:8080/v1";
MISTRAL_BASE_URL_DEF="https://api.mistral.ai/v1";
GOOGLE_BASE_URL_DEF="https://generativelanguage.googleapis.com/v1beta";
GROQ_BASE_URL_DEF="https://api.groq.com/openai/v1";
ANTHROPIC_BASE_URL_DEF="https://api.anthropic.com/v1";
GITHUB_BASE_URL_DEF="https://models.inference.ai.azure.com";
NOVITA_BASE_URL_DEF="https://api.novita.ai/v3/openai";
XAI_BASE_URL_DEF="https://api.x.ai/v1";
DEEPSEEK_BASE_URL_DEF="https://api.deepseek.com/beta";
OPENAI_API_KEY_DEF=$OPENAI_API_KEY;
BASE_URL=$OPENAI_BASE_URL_DEF;

# Def hist, txt chat types
Q_TYPE="\\nQ: "
A_TYPE="\\nA:"
S_TYPE="\\n\\nSYSTEM: "
I_TYPE_STR="[insert]"
I_TYPE="\\[[Ii][Nn][Ss][Ee][Rr][Tt]\\]"

# Globs
SPC="*([$IFS])"
SPC1="*(\\\\[ntrvf]|[$IFS])"
NL=$'\n' BS=$'\b'

UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'  #chrome on win10
PLACEHOLDER='sk-CbCCb0CC0bbbCbb0CCCbC0CbbbCC00bC00bbCbbCbbbCbb0C'

TIME_ISO8601_FMT='%Y-%m-%dT%H:%M:%S%z'
TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'

HELP="Name
	${0##*/} -- Wrapper for ChatGPT / DALL-E / Whisper / TTS


Synopsis
	${0##*/} [-cc|-dd|-qq] [opt..] [PROMPT|TEXT_FILE|PDF_FILE]
	${0##*/} -i [opt..] [X|L|P][hd] [PROMPT]  #dall-e-3
	${0##*/} -i [opt..] [S|M|L] [PROMPT]
	${0##*/} -i [opt..] [S|M|L] [PNG_FILE]
	${0##*/} -i [opt..] [S|M|L] [PNG_FILE] [MASK_FILE] [PROMPT]
	${0##*/} -w [opt..] [AUDIO_FILE|.] [LANG] [PROMPT]
	${0##*/} -W [opt..] [AUDIO_FILE|.] [PROMPT-EN]
	${0##*/} -z [OUTFILE|FORMAT|-] [VOICE] [SPEED] [PROMPT]
	${0##*/} -ccWwz [opt..] -- [PROMPT] -- [whisper_arg..] -- [tts_arg..]
	${0##*/} -l [MODEL]
	${0##*/} -TTT [-v] [-m[MODEL|ENCODING]] [INPUT|TEXT_FILE|PDF_FILE]
	${0##*/} -HPP [/HIST_NAME|.]
	${0##*/} -HPw


Description
	Wraps ChatGPT, DALL-E, Whisper, and TTS endpoints from various
	providers.
	
	Defaults to single-turn native chat completions. Handles multi-turn
	chat, text completions, image generation/editing, speech-to-text,
	and text-to-speech models.

	Positional arguments are read as a single PROMPT. Some functions
	such as Whisper and TTS may handle optional positional parameters
	before the prompt itself.


Chat Completion Mode
	Set option -c to start multi-turn chat mode via text completions
	(instruct models) or -cc for native chat completions (gpt-3.5+
	models) with interactive history support.

	In chat mode, some options are automatically set to un-lobotomise
	the bot.

	Option -C resumes last history session. To exit on first response,
	set option -E.


Text Completion Mode
	Option -d initiates a single-turn session of plain text completions.
	Further options (e.g., instructions, temperature, stop sequences)
	must be set explicitly at the command line.

	Text completions in multi-turn mode with history support is set
	with options -dd. Use models as gpt-3.5-turbo-instruct.


Insert Mode (FIM)
	Set option -qq for multi turn insert mode, and add tag \`[insert]'
	to the prompt at the location to be filled in (instruct	models).


Instruction Prompts
	The SYSTEM INSTRUCTION prompt may be set with option -S or via
	envars \`\$INSTRUCTION' and \`\$INSTRUCTION_CHAT'.

	If a plain text or PDF file path is set as the argument to \`-S',
	the text of the file is loaded as the INSTRUCTION.

	To create and reuse a custom prompt, set the prompt name you wish
	as the option argument preceded by dot or comma, such as
	\`-S .[prompt_name]' or \`-S ,[prompt_name]'.

	Alternatively, set the first positional argument with the operator
	dot \`.' and the prompt name, such as \`${0##*/} -cc .[prompt]'.

	To insert the current date and time to the instruction prompt, set
	command line option \`--time'.


Image Generations and Edits (Dall-E)
	Option -i generates or edits images. A text prompt is required for
	generations. An image file is required for variations. Edits need
	an image file, a mask (or the image must have a transparent layer),
	and a text prompt to direct the editing.

	Size of output image may be set as the first positional parameter,
	options are: \`256x256' (S), \`512x512' (M), \`1024x1024' (L),
	\`1792x1024' (X), and \`1024x1792' (P). The parameter \`hd' may also
	be set for quality (Dall-E-3), such as \`Xhd', or \`1792x1024hd'.
	
	For Dalle-3, optionally set the generation style as either \"natural\"
	or \"vivid\" as a positional parameter.


Speech-To-Text (Whisper)
	Option -w transcribes audio to any language, and option -W translates
	audio to English text. Set these options twice to have phrasal-
	level timestamps, options -ww, and -WW. Set thrice for word-level
	timestamps.


Text-To-Voice (TTS)
	Option -z synthesises voice from text (TTS models). Set a voice as
	the first positional parameter (\`alloy', \`echo', \`fable', \`onyx',
	\`nova', or \`shimmer'). Set the second positional parameter as the
	speed (0.25 - 4.0), and, finally the output file name or the format,
	such as \`./new_audio.mp3' (\`mp3', \`opus', \`aac', and \`flac'),
	or \`-' for stdout. Set options -vz to not play received output.


Environment
	BLOCK_USR
	BLOCK_USR_TTS 	Extra options for the request JSON block
			(e.g. \`\"seed\": 33, \"dimensions\": 1024').

	CACHEDIR 	Script cache directory base.
	
	CHATGPTRC 	Path to the user configuration file.
			Defaults=${CHATGPTRC/"$HOME"/"~"}

	FILECHAT 	Path to a history / session TSV file.

	INSTRUCTION 	Initial instruction message.

	INSTRUCTION_CHAT
			Initial instruction or system message (chat mode).

	LC_ALL
	LANG 		Default instruction language (chat mode).

	MOD_CHAT        MOD_IMAGE      MOD_AUDIO
	MOD_SPEECH      MOD_LOCALAI    MOD_OLLAMA
	MOD_MISTRAL     MOD_GOOGLE     MOD_GROQ
	MOD_AUDIO_GROQ  MOD_ANTHROPIC  MOD_GITHUB
	MOD_NOVITA      MOD_XAI
			Set default model for each endpoint / provider.
	
	OPENAI_BASE_URL
	OPENAI_URL_PATH Main Base URL setting. Alternatively, provide the
			URL_PATH parameter to disable endpoint auto-selection.

	[PROVIDER]_BASE_URL
			Base URLs for providers: LOCALAI, OLLAMA,
			MISTRAL, GOOGLE, GROQ, ANTHROPIC, and GITHUB.

	OPENAI_API_KEY  [PROVIDER]_API_KEY
	GITHUB_TOKEN 	Keys for OpenAI, Gemini, Mistral, Groq,
			Anthropic, GitHub Models, Novita, and xAI APIs.

	OUTDIR 		Output directory for received image and audio.

	RESTART
	START           Restart and start sequences. May be set to null.

	VISUAL
	EDITOR 		Text editor for external prompt editing.
			Defaults=\"${VISUAL:-${EDITOR:-vim}}\"

	CLIP_CMD 	Clipboard set command, e.g. \`xsel -b', \`pbcopy'.

	PLAY_CMD 	Audio player command, e.g. \`mpv --no-video --vo=null'.

	REC_CMD 	Audio recorder command, e.g. \`sox -d'.


Notes
	Input sequences \`\\n' and \`\\t' are only treated specially in
	restart, start and stop sequences in chat mode!

	Online documentation and usage examples:
	<https://gitlab.com/fenixdragao/shellchatgpt>.


Command Interface
	When the first positional argument starts with the command operator
	\`/' on script invocation, the command \`/session [HIST_NAME]' is
	assumed. This changes to or creates a history file (with -ccCdPP).

	To append image and audio file paths at the end of the prompt with
	multimodal and reasoning models. All models work with PDF, DOC, and
	URL text dump, provided required software is installed. Make sure
	file paths containing spaces are backslash-escaped.

	In multi-turn interactions, prompts starting with a colon \`:' are
	appended as user messages to the request block, while double colons
	\`::' append the prompt as instruction / system without initiating
	a new API request.


Command List
	In chat mode, commands are invoked with either \`!' or \`/' as
	operators. The following modify settings and manage sessions.

   -------    ----------    -----------------------------------------
   --- Misc Commands ------------------------------------------------
      -S      :, ::   [PROMPT]  Append user/system prompt to request.
      -S.     -.       [NAME]   Load and edit custom prompt.
      -S/    !awe      [NAME]   Load and edit awesome prompt (en).
      -S%    !awe-zh   [NAME]   Load and edit awesome prompt (zh).
      -Z      !last             Print last response JSON.
      !#      !save   [PROMPT]  Save current prompt to shell history. ‡
       !      !r, !regen        Regenerate last response.
      !!      !rr               Regenerate response, edit prompt first.
      !g:    !!g:     [PROMPT]  Ground prompt, insert search results. ‡
      !i      !info             Info on model and session settings.
     !!i     !!info             Monthly usage stats (OpenAI).
      !j      !jump             Jump to request, append response primer.
     !!j     !!jump             Jump to request, no response priming.
     !cat     -                 Cat prompter (one-shot, ctrl-d).
     !cat     !cat: [TXT|URL|PDF] Cat text or PDF file, dump URL.
     !dialog  -                 Toggle the \`dialog' interface.
     !img     !media [FILE|URL] Append image, media, or URL to prompt.
     !md      !markdown [SOFTW] Toggle markdown support in response.
    !!md     !!markdown [SOFTW] Render last response in markdown.
     !rep     !replay           Replay last TTS audio response.
     !res     !resubmit         Resubmit last STT recorded audio input.
     !p       !pick  [PROMPT]   File picker, appends filepath to prompt. ‡
     !pdf     !pdf:    [FILE]   Dump PDF text.
    !photo   !!photo   [INDEX]  Take a photo, camera index (Termux). ‡
     !sh      !shell    [CMD]   Run shell or command, and edit output. ‡
     !sh:     !shell:   [CMD]   Same as !sh but apppend output as user.
    !!sh     !!shell    [CMD]   Run interactive shell (w/ cmd) and exit.
     !url     !url:     [URL]   Dump URL text or YouTube transcript.
   --- Script Settings and UX ---------------------------------------
    !fold     !wrap             Toggle response wrapping.
      -g      !stream           Toggle response streaming.
      -h      !help   [REGEX]   Print help, optionally set regex.
      -l      !models  [NAME]   List language models or model details.
      -o      !clip             Copy responses to clipboard.
      -u      !multi            Toggle multiline, ctrl-d flush.
      -uu    !!multi            Multiline, one-shot, ctrl-d flush.
      -U      -UU               Toggle cat prompter or set one-shot.
      -V      !debug            Dump raw request block and confirm.
      -v      !ver              Toggle verbose modes.
      -x      !ed               Toggle text editor interface.
      -xx    !!ed               Single-shot text editor.
      -y      !tik              Toggle python tiktoken use.
      !q      !quit             Exit. Bye.
   --- Model Settings -----------------------------------------------
     !Nill    -Nill             Unset max response tkns (chat cmpls).
      !NUM    -M        [NUM]   Max response tokens.
     !!NUM    -N        [NUM]   Model token capacity.
      -a      !pre      [VAL]   Presence penalty.
      -A      !freq     [VAL]   Frequency penalty.
      -b      !best     [NUM]   Best-of n results.
      -j      !seed     [NUM]   Seed number (integer).
      -K      !topk     [NUM]   Top_k.
      -m      !mod      [MOD]   Model by name or pick from list.
      -n      !results  [NUM]   Number of results.
      -p      !topp     [VAL]   Top_p.
      -r      !restart  [SEQ]   Restart sequence.
      -R      !start    [SEQ]   Start sequence.
      -s      !stop     [SEQ]   One stop sequence.
      -t      !temp     [VAL]   Temperature.
      -w      !rec     [ARGS]   Toggle voice chat mode (Whisper).
      -z      !tts     [ARGS]   Toggle TTS chat mode (speech out).
     !blk     !block   [ARGS]   Set and add options to JSON request.
    !effort   -        [MODE]   Reasoning effort: high, medium, or low.
!interactive  -                 Toggle reasoning interactive mode.
     !ka      !keep-alive [NUM] Set duration of model load in memory
   !vision    !audio            Toggle model multimodality type.
   --- Session Management -------------------------------------------
      -H      !hist             Edit raw history file in editor.
      -P      -HH, !print       Print session history.
      -L      !log  [FILEPATH]  Save to log file (pretty-print).
     !br      !break, !new      Start new session (session break).
     !ls      !list    [GLOB]   List Hist files with glob in name. All: \`.'.
                                Instruction prompts: \`pr'. Awesome: \`awe'.
     !grep    !sub    [REGEX]   Search sessions and copy to tail.
      !c      !copy [SRC_HIST] [DEST_HIST]
                                Copy session from source to destination.
      !f      !fork [DEST_HIST] Fork current session to destination.
      !k      !kill     [NUM]   Comment out n last entries in hist file.
     !!k     !!kill  [[0]NUM]   Dry-run of command !kill.
      !s      !session [HIST_NAME]
                                Change to, search for, or create hist file.
     !!s     !!session [HIST_NAME]
                                 Same as !session, break session.
   -------    ----------    -----------------------------------------

      : Commands with a colon have their output appended to the prompt.

      ‡ Commands with double dagger may be invoked at the very end of
        the prompt.

      Examples
        \`/temp 0.7',  \`!modgpt-4',  \`-p 0.2',
	\`[PROMPT] /pick',  \`[PROMPT] /sh'.

      Notes
        To change to a specific history file, run \`/session [HIST_NAME]',
	or simply \`/[HIST_NAME]' at script invocation.

	In order to resume an old session, execute command \`sub' or the
	alias \`/.'. On script invocation, resuming is aliased to \`.'
	when a dot is set as the first positional parameter.

        To regenerate a response, type in the command \`!regen' or a single
        exclamation mark or forward slash in the new empty prompt. In order
        to edit the prompt before the request, try \`!!' (or \`//').

        Press <CTRL-X CTRL-E> to edit command line in text editor (readline).
        Press <CTRL-J> or <CTRL-V CTRL-J> for newline (readline).
        Press <CTRL-L> to redraw readline buffer (user input) on screen.
        Press <CTRL-C> during cURL requests to interrupt the call.
        Press <CTRL-\\> to terminate the script at any time (QUIT signal),
        or \`Q' in user confirmation prompts.


Options
	Service Providers
	--anthropic
		Anthropic integration (cmpls/chat).
	--github
		GitHub Models integration (chat).
	--google
		Google Gemini integration (cmpls/chat).
	--groq  Groq AI integration (chat).
	--localai
		LocalAI integration (cmpls/chat).
	--mistral
		Mistral AI integration (chat).
	--novita
		Novita AI integration (cmpls/chat).
	--openai
		Reset service integrations.
	-O, --ollama
		Ollama server integration (cmpls/chat).
	--xai 	xAI's Grok integration (cmpls/chat).

	Configuration File
	-f, --no-conf
		Ignore user configuration file.
	-F 	Edit configuration file, if it exists.
		\$CHATGPTRC=${CHATGPTRC/"$HOME"/"~"}.
	-FF 	Dump template configuration file to stdout.

	Sessions and History Files
	-H, --hist  [/HIST_NAME]
		Edit history file with text editor or pipe to stdout.
		A hist file name can be optionally set as argument.
	-P, -PP, --print  [/HIST_NAME]    (aliases to -HH and -HHH)
		Print out last history session. Set twice to print
		commented out entries, too. Heeds -ccdrR.

	Input Modes
	-u, --multiline
		Toggle multiline prompter, <CTRL-D> flush.
	-U, --cat
		Cat prompter, <CTRL-D> flush.
	-x, -xx, --editor
		Edit prompt in text editor. Set twice for single-shot.
		Options -eex to edit last text buffer from cache.

	Interface Modes
	-c, --chat
		Chat mode in text completions (used with -wzvv).
	-cc 	Chat mode in chat completions (used with -wzvv).
	-C, --continue, --resume
		Continue from (resume) last session (cmpls/chat).
	-d, --text
		Single-turn session of plain text completions.
	-dd 	Same as -d, multi-turn and history support.
	-e, --edit
		Edit the first input before request. (cmpls/chat).
		With options -eex, edit the last text editor buffer.
	-E, -EE, --exit
		Exit on first run (even with -cc).
	-g, --stream  (defaults)
		Response streaming.
	-G, --no-stream
		Unset response streaming.
	-i, --image   [PROMPT]
		Generate images given a prompt.
	-i  [PNG]
		Create variations of a given image.
	-i  [PNG] [MASK] [PROMPT]
		Edit image with mask, and prompt (required).
	-q, -qq, --insert
		Insert text mode. Use \`[insert]' tag within the prompt.
		Set twice for multi-turn (\`instruct', Mistral \`code' models).
	-S .[PROMPT_NAME],  -.[PROMPT_NAME]
	-S ,[PROMPT_NAME],  -,[PROMPT_NAME]
		Load, search for, or create custom prompt.
		Set \`.[prompt]' to load prompt silently.
		Set \`,[prompt]' to single-shot edit prompt.
		Set \`,,[prompt]' to edit the prompt template.
		Set \`.?' to list all prompt template files.
	-S, --awesome  /[AWESOME_PROMPT_NAME]
	-S, --awesome-zh  %[AWESOME_PROMPT_NAME_ZH]
		Set or search an awesome-chatgpt-prompt(-zh).
		Set \`//' or \`%%' to refresh cache.
	-T, -TT, -TTT, --tiktoken
		Count input tokens with Tiktoken. Set twice to print
		tokens, thrice to available encodings. Set the model
		or encoding with option -m. It heeds options -ccm.
	-w, --transcribe  [AUD] [LANG] [PROMPT]
		Transcribe audio file into text (whisper models).
		LANG is optional. A prompt that matches the audio language
		is optional. Set twice to phrase or thrice for word-level
		timestamps (-www). With -vv, stop voice recorder on silence.
	-W, --translate   [AUD] [PROMPT-EN]
		Translate audio file into English text (whisper models).
		Set twice to phrase or thrice for word-level timestamps (-WWW). 
	-z, --tts   [OUTFILE|FORMAT|-] [VOICE] [SPEED] [PROMPT]
		Synthesise speech from text prompt, set -v to not play.

	Model Settings
	-@, --alpha  [[VAL%]COLOUR]
		Transparent colour of image mask. Def=black.
		Fuzz intensity can be set with [VAL%]. Def=0%.
	-Nill
		Unset model max response tokens (chat cmpls only).
	-NUM
	-M, --max  [NUM[-NUM]]
		Maximum number of \`response tokens'. Def=$OPTMAX.
		A second number in the argument sets model capacity.
	-N, --modmax    [NUM]
		Model capacity token value. Def=_auto_, Fallback=8000.
	-a, --presence-penalty   [VAL]
		Presence penalty  (cmpls/chat, -2.0 - 2.0).
	-A, --frequency-penalty  [VAL]
		Frequency penalty (cmpls/chat, -2.0 - 2.0).
	-b, --best-of   [NUM]
		Best of, must be greater than opt -n (cmpls). Def=1.
	-B, --logprobs  [NUM]
		Request log probabilities, see -Z (cmpls, 0 - 5),
	--effort  [ high | medium | low ]
		Amount of effort in reasoning models (OpenAI).
	--interactive, --no-interactive
		Reasoning model output style.
	-j, --seed  [NUM]
		Seed for deterministic sampling (integer).
	-K, --top-k     [NUM]
		Top_k value (local-ai, ollama, google).
	--keep-alive, --ka [NUM]
		How long the model will stay loaded into memory (Ollama).
	-m, --model     [MOD]
		Language MODEL name or set it as \`.' to pick
		from the list. Def=$MOD, $MOD_CHAT.
	--multimodal, --vision, --audio
 		Model multimodal mode.
	-n, --results   [NUM]
		Number of results. Def=$OPTN.
	-p, --top-p     [VAL]
		Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).
	-r, --restart   [SEQ]
		Restart sequence string (cmpls).
	-R, --start     [SEQ]
		Start sequence string (cmpls).
	-s, --stop      [SEQ]
		Stop sequences, up to 4. Def=\"<|endoftext|>\".
	-S, --instruction  [INSTRUCTION|FILE]
		Set an instruction prompt. It may be a text file.
	--time, --no-time
		Insert the current date and time to the instruction prompt.
	-t, --temperature  [VAL]
		Temperature value (cmpls/chat/whisper),
		Def=${OPTT:-0} (0.0 - 2.0), Whisper=${OPTTW:-0} (0.0 - 1.0).

	Miscellanous Settings
	--api-key  [KEY]
		The API key to use.
	--fold (defaults), --no-fold
		Set or unset response folding (wrap at white spaces).
	-h, --help
		Print this help page.
	--info  Print OpenAI usage status (envar \`\$OPENAI_ADMIN_KEY\`).
	-k, --no-colour
		Disable colour output. Def=auto.
	-l, --list-models  [MOD]
		List models or print details of MODEL.
	-L, --log   [FILEPATH]
		Log file. FILEPATH is required.
	--md, --markdown, --markdown=[SOFTWARE]
		Enable markdown rendering in response. Software is optional:
		\`bat', \`pygmentize', \`glow', \`mdcat', or \`mdless'.
	--no-md, --no-markdown
		Disable markdown rendering.
	-o, --clipboard
		Copy response to clipboard.
	-v, --verbose
		Less verbose. With -ccwv, sleep after response. With
		-ccwzvv, stop recording voice input on silence and play
		TTS response right away. May be set multiple times.
	-V  	Dump raw request block to stderr (debug).
	--version
		Print script version.
	-y, --tik
		Tiktoken for token count (cmpls/chat).
	-Y, --no-tik  (defaults)
		Unset tiktoken use (cmpls/chat).
	-Z, -ZZ, -ZZZ, --last
		Print data from the last JSON responses."

ENDPOINTS=(
	/completions               #0
	/moderations               #1
	/edits                     #2  -> chat/completions
	/images/generations        #3
	/images/variations         #4
	/embeddings                #5
	/chat/completions          #6
	/audio/transcriptions      #7
	/audio/translations        #8
	/images/edits              #9
	/audio/speech              #10
	/models                    #11
	/organization              #12
	#/realtime                 #
)
#https://platform.openai.com/docs/{deprecations/,models/,model-index-for-researchers/}
#https://help.openai.com/en/articles/{6779149,6643408}

#set model endpoint based on its name
function set_model_epnf
{
	unset OPTEMBED TKN_ADJ EPN6 MULTIMODAL
	typeset -l model; model=${1##*/};
	set -- "${model##ft:}";

	if is_amodelf "$1"
	then 	set -- "audio";
	elif is_visionf "$1"
	then 	set -- "vision";
	fi;

	case "${1##ft:}" in
		*dalle-e*|*stable*diffusion*)
				# 3 generations  4 variations  9 edits  
				((OPTII)) && EPN=4 || EPN=3;
				((OPTII_EDITS)) && EPN=9;;
		tts-*|*-tts-*) 	EPN=10;;
		*whisper*) 	((OPTWW)) && EPN=8 || EPN=7;;
		code-*) 	case "$1" in
					*search*) 	EPN=5 OPTEMBED=1;;
					*) 		EPN=0;;
				esac;;
		text-*|*turbo-instruct*|*davinci*|*babbage*|ada|*moderation*|*embed*|*similarity*|*search*)
				case "$1" in
					*embed*|*similarity*|*search*) 	EPN=5 OPTEMBED=1;;
					*moderation*) 	EPN=1 OPTEMBED=1;;
					*) 		EPN=0;;
				esac;;
		o[1-9]*|chatgpt-*|gpt-[4-9]*|gpt-3.5*|gpt-*|*turbo*|*vision*|*audio*)
				EPN=6 EPN6=6  OPTB= OPTBB=
				((OPTC)) && OPTC=2
				#set token adjustment per message
				case "$MOD" in
					gpt-3.5-turbo-0301) 	((TKN_ADJ=4+1));;
					gpt-3.5-turbo*|gpt-4*|*) 	((TKN_ADJ=3+1));;
				esac #https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb
				#also: <https://tiktokenizer.vercel.app/>
				;;
		*) 		#fallback
				case "$1" in
					*embed*|*similarity*|*search*)
						EPN=5 OPTEMBED=1;;
					*)
						if ((OPTZ && !(MTURN+CHAT_ENV) ))
						then 	OPTCMPL= OPTC= EPN=10;
						elif ((OPTW && !(MTURN+CHAT_ENV) ))
						then 	OPTCMPL= OPTC= EPN=7;
						elif ((OPTI && !(MTURN+CHAT_ENV) ))
						then 	# 3 generations  4 variations  9 edits  
							((OPTII)) && EPN=4 || EPN=3;
							((OPTII_EDITS)) && EPN=9;
						elif ((OPTEMBED))
						then 	OPTCMPL= OPTC= EPN=1;
						elif ((OPTCMPL || OPTSUFFIX))
						then 	OPTC= EPN=0;
						elif ((OPTC>1 || GROQAI || MISTRALAI || GOOGLEAI || GITHUBAI))
						then 	OPTCMPL= EPN=6;
						elif ((OPTC))
						then 	OPTCMPL= EPN=0;
						else 	EPN=0;  #defaults
						fi;;
				esac
				return 1;;
	esac
}

#set ``model capacity''
function model_capf
{
	typeset -l model; model=${1##*/};
	case "${model##ft:}" in  #ft: fine-tune models
		open-codestral-mamba*|codestral-mamba*|ai21-jamba-1.5*|ai21-jamba-instruct)
			MODMAX=256000;;
		deepseek-reasoner|deepseek-chat|open-mixtral-8x22b|text-davinci-002-render-sha)
			MODMAX=64000;;
		claude-[3-9]*|claude-2.1*)
			MODMAX=200000;;
		claude-2.0*|claude-instant*)
			MODMAX=100000;;
		meta-llama-3-70b-instruct|meta-llama-3-8b-instruct|\
		code-davinci-00[2-9]*|mistral-embed*|-8k*)
			MODMAX=8001;;
		*llama-3-8b-instruct|*llama-3-70b-instruct|*gemma-2-9b-it|\
		*hermes-2-pro-llama-3-8b|llama3*|gemma-*|text-embedding-ada-002|\
		*embedding*-002|*search*-002|grok-2-vision-1212|grok-vision-beta)
			MODMAX=8191;;  #8192
		davinci|curie|babbage|ada)
			MODMAX=2049;;
		gemini*-thinking*-exp*)
			MODMAX=32768;;
		gemini*-flash*)
			MODMAX=1048576;;  #std: 128000
		gemini*-1.[5-9]*|gemini*-[2-9].[0-9]*|gemini-exp*)
			MODMAX=2097152;;  #std: 128000
		*qwen-2.5-72b-instruct|learnlm-1.5-pro*)
			MODMAX=32000;;
		*l3-70b-euryale-v2.1|*l31-70b-euryale-v2.2|*dolphin-mixtral-8x22b)
			MODMAX=16000;;
		*llama-3.1-8b-instruct|davinci-00[2-9]|babbage-00[2-9]|gpt-3.5*16k*|\
		*turbo*16k*|gpt-3.5-turbo-1106|gemini*-vision*|*-16k*)
			MODMAX=16384;;
		*llama-3.1-70b-instruct|*mistral-7b-instruct|*wizardlm-2-7b|*qwen-2-7*b-instruct*|\
		gpt-4*32k*|*32k|*mi[sx]tral*|*codestral*|mistral-small|*mathstral*|*moderation*)
			MODMAX=32768;;
		o[1-9]*|gpt-4o*|chatgpt-*|gpt-[5-9]*|gpt-4-1106*|\
		gpt-4-*preview*|gpt-4-vision*|gpt-4-turbo|gpt-4-turbo-202[4-9]-*|\
		mistral-3b*|open-mistral-nemo*|*mistral-nemo*|*mistral-large*|\
		phi-3.5-mini-instruct|phi-3.5-moe-instruct|phi-3.5-vision-instruct|\
		*llama-[3-9].[1-9]*|*llama[4-9]-*|\
		*llama[4-9]*|*ministral*|*pixtral*|*-128k*)
			MODMAX=128000;;
		*turbo*|*davinci*|teknium/openhermes-2.5-mistral-7b|openchat/openchat-7b) 	MODMAX=4096;;
		grok*|*llama-3.1-405b-instruct|cohere-command-r*|grok-beta|grok-2-1212|grok-2*)
			MODMAX=131072;;
		*openchat-7b|*mythomax-l2-13b|*airoboros-l2-70b|*lzlv_70b|*nous-hermes-llama2-13b|\
		*openhermes-2.5-mistral-7b|*midnight-rose-70b|\
		gpt-4*|*-bison*|*-unicorn|*wizardlm-2-8x22b)
			MODMAX=65535;;
		gemini*-pro*) 	MODMAX=32760;;
		cohere-embed-v3-*) 	MODMAX=1000;;
		*embedding-gecko*) 	MODMAX=3072;;
		*embed*|*search*) 	MODMAX=2046;;
		aqa) 	MODMAX=7168;;
		*-4k*) 	MODMAX=4000;;
		*) 	MODMAX=8192;;
	esac
}
#novita: model names: [provider]/[model]
#groq: 3.1 models to max_tokens of 8k and 405b to 16k input tokens.
#pixtral: maximum number images per request is 8.
#https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/

#make cmpls request
function __promptf
{
	if curl "$@" ${FAIL} -L "${BASE_URL}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer ${MISTRAL_API_KEY:-$OPENAI_API_KEY}" \
		-d "$BLOCK"  $CURLTIMEOUT
	then 	[[ \ $*\  = *\ -s\ * ]] || _clr_lineupf;
	else 	return $?;  #E#
	fi
}

function _promptf
{
	typeset str
	json_minif;
	
	if ((STREAM))
	then 	set -- -s "$@" -S --no-buffer;
		[[ -s $FILE ]] && mv -f -- "$FILE" "${FILE%.*}.2.${FILE##*.}"; : >"$FILE"  #clear buffer asap

		if ((OPTC))
		then 	str='"text"'; ((GOOGLEAI)) ||
			if ((EPN==0)) && ((OLLAMA))
			then 	str='"response"';
			elif ((EPN==6))
			then 	str='"content"';
			fi;
		fi
		
		if ((GOOGLEAI))
		then 	__promptf "$@" | { tee -- "$FILESTREAM" "$FILE" || cat ;}
		else
			__promptf "$@" | { tee -- "$FILESTREAM" || cat ;} |
			if ((ANTHROPICAI))
			then 	sed -n -e 's/^[[:space:]]*//' \
				-e 's/^[[:space:]]*[Dd][Aa][Tt][Aa]:[[:space:]]*//p' \
				-e '/^[[:space:]]*\[[A-Za-z_][A-Za-z_]*\]/d' \
				-e '/^[[:space:]]*$/d';
			else 	sed -e 's/^[[:space:]]*//' \
				-e 's/^[[:space:]]*[Dd][Aa][Tt][Aa]:[[:space:]]*//' \
				-e '/^[[:space:]]*[A-Za-z_][A-Za-z_]*:/d' \
				-e '/^[[:space:]]*\[[A-Za-z_][A-Za-z_]*\]/d' \
				-e '/^[[:space:]]*$/d';
			fi |
			if ((OPTC))
			then 	sed -e "1s/${str}:[[:space:]]*\"[[:space:]]*/${str}: \"/" | tee -- "$FILE";
			else 	tee -- "$FILE";
			fi;

		fi
	else
		{ test_cmplsf || ((OPTV>1)) ;} && set -- -s "$@"
		set -- -\# "$@" -o "$FILE"
		__promptf "$@"
	fi
}

function promptf
{
	typeset pid ret

	if ((OPTVV)) && ((!OPTII))
	then 	block_printf || {
		  REPLY=${REPLY_CMD:-$REPLY} REGEN= JUMP= PSKIP=;
		  REPLY_CMD_DUMP= REPLY_CMD_BLOCK= SKIP_SH_HIST= WSKIP= SKIP=;  #E#
		  return 200 ;}
	fi

	if ((STREAM))
	then 	: >"$FILETXT"; RET_APRF=;
		test_cmplsf || ((OPTV>1)) || printf "${BYELLOW}%s\\b${NC}" "C" >&2;
		{ _promptf || exit ;} |  #!#
		{ prompt_printf; ret=$?; printf '%s' "${RET_APRF##0}" >"$FILETXT"; exit $ret ;}
	else
		test_cmplsf || ((OPTV>1)) || printf "${BYELLOW}%*s\\r${YELLOW}" "$COLUMNS" "C" >&2;
		COLUMNS=$((COLUMNS-1)) _promptf || exit;  #!#
		printf "${NC}" >&2;
		if ((OPTI))
		then 	prompt_imgprintf
		else 	prompt_printf
		fi
	fi & pid=$! PIDS+=($!)  #catch <CTRL-C>
	
	trap "trap 'exit' INT; kill -- $pid 2>/dev/null; echo >&2;" INT;
	wait $pid; echo >&2;
	trap 'exit' INT; RET_APRF=;
	[[ -s $FILETXT ]] && { 	RET_APRF=$(<$FILETXT); : >"$FILETXT" ;}

	if ((OPTCLIP)) || [[ ! -t 1 ]]
	then 	typeset out; out=$(
			((STREAM)) && set -- -j "$@"
			prompt_pf -r "$@" "$FILE"
		)
		((!OPTCLIP)) || (${CLIP_CMD:-false} <<<"$out" &)  #clipboard
		[[ -t 1 ]] || printf '%s\n' "$out" >&2  #pipe + stderr
	fi
	wait $pid;  #curl exit code
}

#print tokens from response
function response_tknf
{
	jq -r '(.usage.prompt_tokens)//"0",
		(.usage.completion_tokens)//"0",
		(.usage.completion_tokens_details|(.reasoning_tokens//.audio_tokens))//"0",
		(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$@";
}
#https://community.openai.com/t/usage-stats-now-available-when-using-streaming-with-the-chat-completions-api-or-completions-api/738156

#position cursor at end of screen
function _clr_dialogf
{
	printf "${NC}\\n\\n\\033[${LINES};1H" >&2;
}
function __clr_dialogf { 	((DIALOG_CLR)) && _clr_dialogf ;}

#clear impending stream (tty)
function _clr_ttystf
{
	typeset REPLY n;
	while IFS= read -r -n 1 -t 0.002;
	do 	((++n)); ((n<8192)) || break;
	done </dev/tty;
}

#clear n lines up as needed (assumes one `new line').
function _clr_lineupf
{
	typeset chars n
	chars="${1:-1}" ;((COLUMNS))||COLUMNS=80
	for ((n=0;n<((chars+(COLUMNS-1))/COLUMNS);++n))
	do 	printf '\e[A\e[K' >&2
	done
} 
#https://www.zsh.org/mla/workers//1999/msg01550.html
#https://superchlorine.com/2013/08/kill-winch-to-fix-bash-prompt-wrapping-to-the-same-line/

# spin.bash -- provide a `spinning wheel' to show progress
#  Copyright 1997 Chester Ramey (adapted)
SPIN_CHARS8=(⣟ ⣯ ⣷ ⣾ ⣽ ⣻ ⢿ ⡿)
SPIN_CHARS0=(. o O @ \*)
SPIN_CHARS=(\| \\ - /)
function _spinf
{
	((++SPIN_INDEX)); ((SPIN_INDEX%=${#SPIN_CHARS[@]}));
	printf "%s\\b" "${SPIN_CHARS[SPIN_INDEX]}" >&2;
}
#avoid animations on pipelines
[[ -t 1 ]] || function _spinf { : ;}

#print input and backspaces for all chars
function _printbf { 	printf "%s${1//?/\\b}" "${1}" >&2; };

#trim leading glob
#usage: trim_leadf [string] [glob]
function trim_leadf
{
	typeset var ind sub
	var="$1" ind=${INDEX:-320}
	sub="${var:0:$ind}"
	((SMALLEST)) && sub="${sub#$2}" || sub="${sub##$2}"
	var="${sub}${var:$ind}"
	printf '%s\n' "$var"
}
#trim trailing glob
#usage: trim_trailf [string] [glob]
function trim_trailf
{
	typeset var ind sub
	var="$1" ind=${INDEX:-320}
	if ((${#var}>ind))
	then 	sub="${var:$((${#var}-${ind}))}"
		((SMALLEST)) && sub="${sub%$2}" || sub="${sub%%$2}"
		var="${var:0:$((${#var}-${ind}))}${sub}"
	else 	((SMALLEST)) && var="${var%$2}" || var="${var%%$2}"
	fi; printf '%s\n' "$var"
}
#fast shell glob trimmer
#usage: trimf [string] [glob]
function trimf
{
	trim_leadf "$(trim_trailf "$1" "$2")" "$2"
}

#pretty print request body or dump and exit
function block_printf
{
	typeset REPLY; OPTAWE= SKIP= ;
	[[ ${BLOCK:0:32} = @* ]] && cat -- "${BLOCK##@}" | less >&2
	printf '\n%s\n%s\n' "${ENDPOINTS[EPN]}" "$BLOCK" >&2
	printf '\n%s\n' '<Enter> continue, <Ctrl-D> redo, <Ctrl-C> exit' >&2
	_clr_ttystf; read </dev/tty || return 200;
}

#prompt confirmation prompter
function new_prompt_confirmf
{
	typeset REPLY extra
	case \ $*\  in 	*\ ed\ *) extra=", te[x]t editor, m[u]ltiline";; esac;
	case \ $*\  in 	*\ whisper\ *) 	((OPTW)) && extra="${extra}, [W]hsp_append, [w]hsp_off, w[h]sp_retry";; esac;

	_sysmsgf 'Confirm?' "[Y]es, [n]o, [e]dit${extra}, [r]edo, or [a]bort " ''
	REPLY=$(read_charf); _clr_lineupf $((8+1+40+${#extra}))  #!#
	case "$REPLY" in
		[Q]) 	return 202;;  #exit
		[aq]) 	return 201;;  #abort
		[Rr]) 	return 200;;  #redo
		[Ee]|$'\e') 	return 199;;  #edit
		[VvXx]) return 198;;  #text editor
		[UuMm]) return 197;;  #multiline
		[w]) 	return 196;;  #whisper off
		[WAPp]) return 195;;  #whisper append
		[HhTt]) return 194;;  #whisper retry request
		[NnOo]) REC_OUT=; return 1;;  #no
		[-/!]) 	echo >&2; read_mainf -i "$REPLY" REPLY; echo >&2;
			BLOCK_USR= BREAK_SET= OPTRESUME= EDIT= ENDPOINTS= \
			HERR= JUMP= MAIN_LOOP= REGEN= REPLAY_FILES= REPLY= \
			REPLY_CMD_BLOCK= REPLY_CMD_DUMP= REPLY_OLD= RESTART= START= \
			RESUBW= RET= SKIP= SKIP_SH_HIST=  BCYAN= CYAN= ON_CYAN= \
			cmd_runf "$REPLY";
			new_prompt_confirmf "$@";;
	esac  #yes
}

#read one char from user
function read_charf
{
	typeset REPLY ret
	((NO_CLR)) || _clr_ttystf;
	IFS=$'\n' read -r -n 1 "$@" </dev/tty; ret=$?;
	printf '%.1s\n' "$REPLY";
	[[ -n $REPLY ]] && echo >&2;
	return $ret
}

#main user input read
#usage: read_mainf [read_opt].. VARIABLE_NAME
function read_mainf
{
	IFS= read -r -e -d $'\r' ${OPTCTRD:+-d $'\04'} "$@"
}
#https://www.reddit.com/r/bash/comments/ppp6a2/is_there_a_way_to_paste_multiple_lines_where_read/

#audio-model player
#play from an appending pcm16 audio file
function splayerf
(
	trap 'exit' INT TERM;
	: > "${1}" || exit;
	
	((${#TERMUX_VERSION})) && sleep 0.8;
	for ((n=0;n<12;n++))  #wait for buffer
	do 	sleep 0.6; [[ -s "${1}" ]] &&
		(( $(wc -c <${1}) > 64000)) && break;
	done
	
	if command -v ffplay
	then 	ffplay -autoexit -nodisp -hide_banner -f s16le -ar 24000 -i "${1}";
	elif command -v sox
	then 	sox -t raw -b 16 -e signed-integer -L -r 24000 -c 1 "${1}" -d;
	elif command -v mpv
	then 	mpv --demuxer=rawaudio --demuxer-rawaudio-format=s16le --demuxer-rawaudio-rate=24000 --demuxer-rawaudio-channels=1 "${1}";
	elif command -v cvlc
	then 	cvlc --play-and-exit --no-loop --no-repeat -I dummy --demux rawaud --rawaud-channels 1 --rawaud-samplerate 24000 --rawaud-fourcc s16l "${1}";
	else 	false;
	fi >/dev/null 2>&1;
)

#print response
function prompt_printf
{
	typeset pid ret

	if ((STREAM))
	then 	typeset OPTC OPTV;
	else 	set -- "$FILE"; unset STREAM;
		((OPTBB)) && jq -r '(.choices[].logprobs)?' "$@" >&2
	fi
	if ((OPTEMBED))
	then 	jq -r '(.data),
		(.model//"'"$MOD"'"//"?")+" ("+(.object//"?")+") ["
		+(.usage.prompt_tokens//"?"|tostring)+" / "
		+(.usage.total_tokens//"?"|tostring)+" tkns]"' "$@" >&2
		return
	fi

	if ((OPTMD)) && ((MD_CMD_UNBUFF))
	then
		JQCOL= prompt_prettyf "$@" | mdf;
	else
		#audio-models
		if ((MULTIMODAL>1)) && ((OPTZ)) && ((STREAM)) && if [[ -n $TERMUX_VERSION ]]
			then 	OPTV=2 set_termuxpulsef;
			else 	:; fi;
		then
			splayerf "$FILEFIFO" & pid=$! PIDS+=($!);
			tee >(
				jq -r '(.choices|.[]?|.delta.audio.data)//empty' |
				{ 	base64 -d || base64 -D ;} >"$FILEFIFO";
				) | prompt_prettyf "$@" | foldf; ret=$?;

			wait $pid;
			kill -0 $pid >/dev/null 2>&1 && kill -9 -- $pid >/dev/null 2>&1;
		else
			prompt_prettyf "$@" | foldf; ret=$?;
		fi
		if ((OPTMD))
		then 	printf "${NC}\\n" >&2;
			prompt_pf -r ${STREAM:+-j --unbuffered} "$@" "$FILE" 2>/dev/null | mdf >&2 2>/dev/null;
		fi; ((!ret));
	fi || prompt_pf -r ${STREAM:+-j --unbuffered} "$@" "$FILE" 2>/dev/null;
	return $ret;
}
function prompt_prettyf
{
	((STREAM)) || unset STREAM;

	jq -r ${STREAM:+-j --unbuffered} "${JQCOLNULL} ${JQCOL}
	  byellow
	  + ( ((.choices?|.[1].index)//null) as \$sep | if ((.choices?)//null) != null then .choices[] else (if (${GOOGLEAI:+1}0>0) then .[] else . end) end |
	  ( ((.delta.content)//(.delta.text)//(.delta.audio.transcript)
	    //.text//.response//.completion//.reasoning//(.content[]?|.text?)
	    //(if (.message.reasoning_content?) then (.message.reasoning_content,\"---\",(.message.content//empty)) else null end)
	    //(.message.content${ANTHROPICAI:+skip})//(.message.audio.transcript)
	    //(.candidates[]?|.content | if ((${MOD_THINK:+1}0>0) and (.parts?|.[1]?|.text?)) then (.parts[0].text?,\"\\n\\nANSWER:\\n\",.parts[1].text?) else (.parts[]?|.text?) end)
	    //\"\" ) |
	  if ( (${OPTC:-0}>0) and (${STREAM:-0}==0) ) then (gsub(\"^[\\\\n\\\\t ]\"; \"\") |  gsub(\"[\\\\n\\\\t ]+$\"; \"\")) else . end)
	  + if any( (.finish_reason//.stop_reason//\"\")?; . != \"stop\" and . != \"stop_sequence\" and . != \"end_turn\" and . != \"\") then
	      red+\"(\"+(.finish_reason//.stop_reason)+\")\"+byellow else null end,
	  if \$sep then \"---\" else empty end) + reset" "$@" && _p_suffixf;
}  #finish_reason: length, max_tokens
function prompt_pf
{
	typeset var
	typeset -a opt; opt=();
	for var
	do 	[[ -f $var ]] || { 	opt=("${opt[@]}" "$var"); shift ;}
	done
	set -- "(if ((.choices?)//null) != null then (.choices[$INDEX]) else (if (${GOOGLEAI:+1}0>0) then .[] else . end) end |
		(.delta.content)//(.delta.text)//(.delta.audio.transcript)//.text//.response//.completion//(.content[]?|.text?)//(.message.content${ANTHROPICAI:+skip})//(.message.audio.transcript)//(.candidates[]?|.content.parts[]?|.text?)//(.data?))//empty" "$@"
	jq "${opt[@]}" "$@" && _p_suffixf || ! _warmsgf 'Err';
}
#https://stackoverflow.com/questions/57298373/print-colored-raw-output-with-jq-on-terminal
#https://stackoverflow.com/questions/40321035/

#print suffix string
function _p_suffixf { 	((!${#SUFFIX} )) || printf '%s' "${SUFFIX}" ;}

#print last line of input that is within $columns range
#usage: _p_linerf [string]
function _p_linerf
{
	typeset var
	var=$(sed -n '$p' <<<$1);
	var=$((${#var} % COLUMNS));
	((var)) && printf '\n%s' "${1: ${#1}-${var}}" >&2;
}

#open image with sys defaults
function _openf
{
	if command -v xdg-open >/dev/null 2>&1
	then 	xdg-open "$1"
	elif command -v open >/dev/null 2>&1
	then 	open "$1"
	elif command -v feh >/dev/null 2>&1
	then 	feh "$1"
	elif command -v sxiv >/dev/null 2>&1
	then 	sxiv "$1"
	elif command -v firefox >/dev/null 2>&1
	then 	firefox "$1"
	elif command -v google-chrome-stable >/dev/null 2>&1
	then 	google-chrome-stable "$1"
	elif command -v google-chrome >/dev/null 2>&1
	then 	google-chrome "$1"
	else 	false
	fi
}
#https://budts.be/weblog/2011/07/xdf-open-vs-exo-open/

#print image endpoint response
function prompt_imgprintf
{
	typeset n m fname fout
	if [[ $OPTI_FMT = b64_json ]]
	then 	[[ -d "${FILEOUT%/*}" ]] || FILEOUT="${FILEIN}"
		n=0 m=0
		for fname in "${FILEOUT%.*}"*
		do 	fname="${fname%.*}" fname="${fname##*[!0-9]}"
			((m>fname)) || ((m=fname+1)) 
		done
		while jq -e ".data[${n}]" "$FILE" >/dev/null 2>&1
		do 	fout="${FILEOUT%.*}${m}.png"
			jq -r ".data[${n}].b64_json" "$FILE" | { 	base64 -d || base64 -D ;} > "$fout"
			_sysmsgf 'File Out:' "${fout/"$HOME"/"~"}";
			((OPTV)) ||  _openf "$fout" || function _openf { : ;}
			((++n, ++m)); ((n<50)) || break;
		done
		((n)) || ! _warmsgf 'Err';
	else 	jq -r '.data[].url' "$FILE" || ! _warmsgf 'Err';
	fi &&
	jq -r 'if .data[].revised_prompt then "\nREVISED PROMPT: "+.data[].revised_prompt else empty end' "$FILE" >&2
}

function prompt_audiof
{
	((OPTVV)) && _warmsgf "Whisper:" "Model: ${MOD_AUDIO:-unset},  Temperature: ${OPTTW:-${OPTT:-unset}}${*:+,  }${*}" >&2

	curl -\# ${OPTV:+-Ss} ${FAIL} -L "${BASE_URL}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H 'Content-Type: multipart/form-data' \
		-F file="@$1" \
		-F model="${MOD_AUDIO}" \
		-F temperature="${OPTTW:-$OPTT}" \
		-o "$FILE" \
		"${@:2}" && {
	  [[ -d $CACHEDIR ]] && printf '%s\n\n' "$(<"$FILE")" >> "$FILEWHISPER";
	  ((OPTV)) || _clr_lineupf; ((CHAT_ENV)) || echo >&2;
	}
}

function list_modelsf
{
	curl -\# ${FAIL} -L "${BASE_URL}${ENDPOINTS[11]}${1:+/}${1}" \
		-H "Authorization: Bearer $OPENAI_API_KEY" -o "$FILE" &&

	if [[ -n $1 ]]
	then  	jq . "$FILE" || ! _warmsgf 'Err';
	else 	{   jq -r '.data[].id' "$FILE" | sort && {
		    {    ((LOCALAI+OLLAMA+MISTRALAI+GOOGLEAI+GROQAI+ANTHROPICAI+GITHUBAI+NOVITAAI)) || [[ $BASE_URL != "$OPENAI_BASE_URL_DEF" ]] ||
		    printf '%s\n' text-moderation-latest text-moderation-stable ;}
		    ((!MISTRALAI)) || printf '%s\n' mistral-moderation-latest;
		  }
		} | tee -- "$FILEMODEL" || ! _warmsgf 'Err';
	fi || ! _warmsgf 'Err:' 'Model list'
}

function pick_modelf
{
	typeset REPLY mod options
	set -- "${1// }"; set -- "${1##*(0)}";
	((${#1}<2)) || return  #mind o1 models
	((${#MOD_LIST[@]})) || MOD_LIST=($(list_modelsf))
	if [[ ${REPLY:=$1} = +([0-9]) ]] && ((REPLY && REPLY <= ${#MOD_LIST[@]}))
	then 	mod=${MOD_LIST[REPLY-1]}  #pick model by number from the model list
	else 	_clr_ttystf; REPLY=${REPLY//[!0-9]};
		while ! ((REPLY && REPLY <= ${#MOD_LIST[@]}))
		do
			if test_dialogf
			then 	options=( $(_dialog_optf ${MOD_LIST[@]:-err}) )
				REPLY=$(
				  dialog --backtitle "Model Picker" --title "Selection Menu" \
				    --menu "Choose a model:" 0 40 0 \
				    -- "${options[@]}"  2>&1 >/dev/tty;
				) || typeset NO_DIALOG=1;
				_clr_dialogf;
			else
				echo $'\nPick model:' >&2;
				select mod in ${MOD_LIST[@]:-err}
				do 	break;
				done </dev/tty; REPLY=${REPLY//[$' \t\b\r']};
			fi;
			[[ \ ${MOD_LIST[*]:-err}\  = *\ "$REPLY"\ * ]] && mod=$REPLY && break;
		done;  #pick model by number or name
	fi; MOD=${mod:-$MOD};
}

#get usage stats from *start of month* to *now*
function get_infof
{
	typeset unix
	
	# 1:Y 2:m 3:d 4:h 5:min 6:s  7:Y 8:m 9:d 10:h 11:min 12:s  # now  month_start
	set -- $(printf '%(%Y %m %d %H %M %S)T' -1) $(printf '%(%Y %m 01 00 00 00)T' -1);
	set -- $(( ( (10#${3}-10#${9}) * 24*60*60) + ( (10#${4}-10#${10}) * 60*60) + ( (10#${5}-10#${11}) * 60) + 10#${6}));
	set -- $(printf '%(%s)T' -1) "$@";
	unix=$(printf '%(%s)T' $((${1} - ${2})) );

	[[ -s $FILE ]] && mv -f -- "$FILE" "${FILE%.*}.2.${FILE##*.}"; : >"$FILE"

	curl ${FAIL} -\# -L "${BASE_URL}${ENDPOINTS[12]}/costs?start_time=${unix}&limit=31" \
	  -H "Authorization: Bearer ${OPENAI_ADMIN_KEY:?required}" -H "Content-Type: application/json" -o "$FILE" &&

	  jq -r '.data | map({start_time: (.start_time | strftime("%Y-%m-%d")), value: (.results[0].amount.value // 0)}) | reduce .[] as $item ({sum: 0, results: []}; .sum += $item.value | .results += [{start_time: $item.start_time, value: $item.value, sum: .sum}]) | .results[] | [.start_time, .value, .sum] | @tsv' "$FILE" |
	  column -t -Ndate,price,subtotal;

	curl ${FAIL} -\# -L "${BASE_URL}${ENDPOINTS[12]}/usage/completions?start_time=${unix}&limit=31" \
	  -H "Authorization: Bearer ${OPENAI_ADMIN_KEY:?required}" -H "Content-Type: application/json" -o "$FILE" &&

	  jq -r '"date    \treqs\tinput\toutput\tsubtotal",(.data | map({start_time: (.start_time | strftime("%Y-%m-%d")), num_model_requests: (.results[0].num_model_requests // 0), input_tokens: (.results[0].input_tokens // 0), output_tokens: (.results[0].output_tokens // 0)}) | reduce .[] as $item ({sum: 0, results: []}; .sum += $item.input_tokens + $item.output_tokens | .results += [{start_time: $item.start_time, num_model_requests: $item.num_model_requests, input_tokens: $item.input_tokens, output_tokens: $item.output_tokens, sum: .sum}]) | .results[] | [.start_time, .num_model_requests, .input_tokens, .output_tokens, .sum] | @tsv)' "$FILE" ||
	  jq . "$FILE" >&2 || cat -- "$FILE" >&2;
}

function lastjsonf
{
	if ((OPTZZ>2)) && [[ -s $FILE_PRE ]]  #google response
	then 	jq . "$FILE_PRE" 2>/dev/null || cat -- "$FILE_PRE";
		[[ -t 1 ]] && printf "${BWHITE}%s${NC}\\n" "$FILE_PRE" >&2;
	elif ((OPTZZ>1)) && [[ -s ${FILE%.*}.2.${FILE##*.} ]]  #old response
	then 	jq . "${FILE%.*}.2.${FILE##*.}" 2>/dev/null || cat -- "${FILE%.*}.2.${FILE##*.}";
		[[ -t 1 ]] && printf "${BWHITE}%s${NC}\\n" "${FILE%.*}.2.${FILE##*.}" >&2;
	elif [[ -s $FILE ]]  #last response
	then 	jq . "$FILE" 2>/dev/null || cat -- "$FILE";
		[[ -t 1 ]] && printf "${BWHITE}%s${NC}\\n" "$FILE" >&2;
	elif [[ -s $FILESTREAM ]]
	then 	jq . "$FILESTREAM" 2>/dev/null || cat -- "$FILESTREAM";
		[[ -t 1 ]] && printf "${BWHITE}%s${NC}\\n" "$FILESTREAM" >&2;
	fi;
}

#set up context from history file ($HIST and $HIST_C)
function set_histf
{
	typeset time token string stringc stringd max_prev q_type a_type role role_last rest com sub ind herr nl x r n;
	time= token= string= stringc= stringd= max_prev= role= role_last= rest= sub= ind= nl=;
	typeset -a MEDIA MEDIA_CMD; MEDIA=(); MEDIA_CMD=(); HIST_LOOP=0;
	[[ -s $FILECHAT ]] || return; HIST= HIST_C=;
	((BREAK_SET)) && return;
	((OPTTIK)) && HERR_DEF=1 || HERR_DEF=4
	((herr = HERR_DEF + HERR))  #context limit error
	q_type=${Q_TYPE##$SPC1} a_type=${A_TYPE##$SPC1}
	((OPTC>1 || EPN==6)) && typeset A_TYPE="${A_TYPE} "  #pretty-print seq "\\nA: " ($rest)
	((${#})) && token_prevf "${*}"

	while _spinf
		IFS=$'\t' read -r time token string
	do
		[[ ${time}${token} = *([$IFS])\#* ]] && { ((OPTHH>2)) && com=1 || continue ;}
		[[ ${time}${token} = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
		[[ -z ${time}${token}${string} ]] && continue
		if [[ -z $string ]]
		then 	[[ -n $token ]] && string=$token token=$time time=
			[[ -n $time  ]] && string=$time  token=  time=
		fi

		((${#string}>1)) && string=${string:1:${#string}-2}  #del lead and trail ""
		#improve bash globbing speed with substring manipulation
		sub="${string:0:32}" sub="${sub##@("${q_type}"|"${a_type}"|":")}"
		stringc="${sub}${string:32}"  #del lead seqs `\nQ: ' and `\nA:'

		((MOD_REASON)) && case "$MOD" in o1-mini*|o1-mini-2024-09-12|o1-preview*|o1-preview-2024-09-12)
			case "${string}" in :*) 	continue;; esac;;
		esac;

		if ((OPTTIK || token<1))
		then 	((token<1 && OPTVV)) && _warmsgf "Warning:" "Zero/Neg token in history"
			start_tiktokenf
			if ((EPN==6))
			then 	token=$(__tiktokenf "$(INDEX=32 trim_leadf "$stringc" :)" )
			else 	token=$(__tiktokenf "\\n$(INDEX=32 trim_leadf "$stringc" :)" )
			fi; ((token+=TKN_ADJ))
		fi # every message follows <|start|>{role/name}\n{content}<|end|>\n (gpt-3.5-turbo-0301)
		#trail nls are rm in (text) chat modes, so actual request prompt token count may be *less*
		#we currently ignore (re)start seq tkns, always consider +3 tkns from $[QA]_TYPE

		if (( ( ( (max_prev+token+TKN_PREV)*(100+herr) )/100 ) < MODMAX-OPTMAX)) || {
			#truncate input to fit most of the model capacity
			if 	(( x = ( (MODMAX-OPTMAX-max_prev-TKN_PREV)*(100-(herr*2) ) )/100 )); ((x>20));
			then 	(( r = ( ( ( ( ( (x*100)/token) * x) / 100) ) * ${#stringc}) / token ));
				(( token = ( ( ( (x*100)/token) * x) / 100) + 1 ));
				stringc=${stringc:${#stringc}-r};
			fi
		   (( ( ( (max_prev+token+TKN_PREV)*(100+herr) )/100 ) < MODMAX-OPTMAX))
		}
		then 	((++HIST_LOOP))
			((max_prev+=token)); ((MAIN_LOOP)) || ((TOTAL_OLD+=token))
			MAX_PREV=$((max_prev+TKN_PREV))  HIST_TIME="${time##\#}"

			if ((OPTC))
			then 	stringc=$(trim_leadf  "$stringc" "*(\\\\[ntr]| )")
				stringc=$(trim_trailf "$stringc" "*(\\\\[ntr])")
			fi

			role_last=$role role= rest= nl=
			case "${string}" in
				::*) 	role=system rest=  #[DEPRECATED]
					((MOD_REASON)) && role=developer;
					stringc=$(INDEX=32 trim_leadf "$stringc" :)  #append (txt cmpls)
					;;
				:*) 	role=system;
					((MOD_REASON)) && role=developer;
					((OPTC)) && rest="$S_TYPE" nl="\\n"  #system message
					;;
				"${a_type:-%#}"*|"${START:-%#}"*)
					role=assistant
					if ((OPTC)) || [[ -n "${START}" ]]
					then 	rest="${START-${A_TYPE}}"
					fi
					;;
				*) #q_type, RESTART
					role=user
					if ((OPTC)) || [[ -n "${RESTART}" ]]
					then 	rest="${RESTART-${Q_TYPE}}"
					fi
					;;
			esac

			#vision
			if ((!OPTHH)) && { is_visionf "$MOD" || is_amodelf "$MOD" ;}
			then 	MEDIA=(); OPTV=100 media_pathf "$stringc"
			fi

			#print commented out lines ( $OPTHH > 2 )
			((com)) && stringc=$(sed 's/\\n/\\n# /g' <<<"${rest}${stringc}") rest= com=
			
			HIST="${rest}${stringc}${nl}${HIST}"
			stringd=$(fmt_ccf "${stringc}" "${role}") && ((${#HIST_C}&&${#stringc})) && stringd=${stringd},${NL};
			
			((GOOGLEAI)) && {
			  case "$role" in system)
			    ((${#GINSTRUCTION_PERM})) ||
			    GINSTRUCTION_PERM=$(unescapef "${stringc:-$GINSTRUCTION}");
			    continue;;
			  esac;
			  case "$role" in system|user)  #[UNNEEDED]
			    case "$role_last" in system|user)
			      HIST_C=$(SMALLEST=1 trim_leadf "$HIST_C" $'*"text":?( )"')
			      stringd=$(SMALLEST=1 trim_trailf "$stringd" $'"}*')"\\n\\n";;
			    esac;;
			  esac;
			}
			
			((EPN==6)) && HIST_C="${stringd}${HIST_C}"
		else 	break
		fi
	done < <(tac -- "$FILECHAT")
	_printbf ' ' #_spinf() end
	((MAX_PREV+=3)) # chat cmpls, every reply is primed with <|start|>assistant<|message|>
	# in text chat cmpls, prompt is primed with A_TYPE = 3 tkns 
	
	#first system/instruction: add extra newlines and delete $S_TYPE  (txt cmpls) 
	case "$role" in system|developer)
		if ((OLLAMA))
		then 	((OPTC && EPN==0)) && [[ $rest = \\n* ]] && rest="xx${rest}"  #!#del \n at start of string
			HIST="${HIST:${#rest}+${#stringc}}"  #delete first system message for ollama
		else 	HIST="${HIST:${#rest}:${#stringc}}\\n${HIST:${#rest}+${#stringc}}"
		fi;;
	esac;

	((!OPTC)) || [[ $HIST = "$stringc"*(\\n) ]] ||  #hist contains only one/system prompt?
	HIST=$(trim_trailf "$HIST" "*(\\\\[ntrvf])")  #del multiple trailing nl
	HIST=$(trim_leadf "$HIST" "?(\\\\[ntrvf]|$NL)?( )")  #del one leading nl+sp
}
#https://thoughtblogger.com/continuing-a-conversation-with-a-chatbot-using-gpt/

#print the last line of tsv history file
function hist_lastlinef
{
	sed -n -e 's/\t"/\t/; s/"$//;' -e '$s/^[^\t]*\t[^\t]*\t//p' "$@" \
	| sed -e "s/^://; s/^${Q_TYPE//\\n}//; s/^${A_TYPE//\\n}//;"
}

#grep the last line of a history file that contains a REGEX '\t"Q:'
#little slow with big tsv files
function grep_usr_lastlinef
{
	unescapef "$(grep -F -e $'\t"'${Q_TYPE//$SPC1} "$FILECHAT" | hist_lastlinef)"
}

#print to history file
#usage: push_tohistf [string] [tokens] [time]
function push_tohistf
{
	typeset string token time
	string=$1; ((${#string})) || ((OPTCMPL)) || return; CKSUM_OLD=;
	token=$2; ((token>0)) || {
		start_tiktokenf;    ((OPTTIK)) && _printbf '(tiktoken)';
		token=$(__tiktokenf "${string}");
		((token+=TKN_ADJ)); ((OPTTIK)) && _printbf '          '; };
	time=${3:-$(datef)}
	printf '%s%.22s\t%d\t"%s"\n' "$INT_RES" "$time" "$token" "${string:-${Q_TYPE##$SPC1}}" >> "$FILECHAT"
}

function datef
{
	printf "%(${TIME_ISO8601_FMT})T\\n" -1 || date +"${TIME_ISO8601_FMT}";
}

function date2f
{
	printf "%(${TIME_RFC5322_FMT})T\\n" -1 || date +"${TIME_RFC5322_FMT}";
}

#record preview query input and response to hist file
#usage: prev_tohistf [input]
function prev_tohistf
{
	typeset input answer
	input="$*"
	((BREAK_SET)) && { _break_sessionf; BREAK_SET= ;}
	if ((STREAM))
	then 	answer=$(escapef "$(prompt_pf -r -j "$FILE")")
	else 	answer=$(prompt_pf "$FILE")
		((${#answer}>1)) && answer=${answer:1:${#answer}-2}  #del lead and trail ""
	fi
	push_tohistf "$input" '' '#1970-01-01'  #(dummy dates)
	push_tohistf "$answer" '' '#1970-01-01'  #(as comments)
}

#calculate token preview
#usage: token_prevf [string]
function token_prevf
{
	((OPTTIK)) && _printbf '(tiktoken)'
	start_tiktokenf
	TKN_PREV=$(__tiktokenf "${*}")
	((TKN_PREV+=TKN_ADJ))
	((OPTTIK)) && _printbf '          '
}

#send to tiktoken coproc
function send_tiktokenf
{
	kill -0 $COPROC_PID 2>/dev/null || return
	printf '%s\n' "${1//$NL/\\n}" >&"${COPROC[1]}"
}

#get from tiktoken coproc
function get_tiktokenf
{
	typeset REPLY m
	kill -0 $COPROC_PID 2>/dev/null || return
	while IFS= read -r
		((!${#REPLY}))
	do 	((++m)); ((m>128)) && break
		((m%32)) || sleep 0.1
	done <&"${COPROC[0]}"
	if ((!${#REPLY}))
	then  	! _warmsgf 'Err:' 'get_tiktokenf()'
	else 	printf '%s\n' "$REPLY"
	fi
}

#start tiktoken coproc
function start_tiktokenf
{
	if ((OPTTIK)) && ! kill -0 $COPROC_PID 2>/dev/null
	then 	coproc { trap '' INT; PYTHONUNBUFFERED=1 HOPTTIK=1 tiktokenf ;}
		PIDS+=($COPROC_PID)
	fi
}

#defaults tiktoken fun
function __tiktokenf
{
	if ((OPTTIK)) && kill -0 $COPROC_PID 2>/dev/null
	then 	send_tiktokenf "${*}" && get_tiktokenf
	else 	false
	fi; ((!$?)) || _tiktokenf "$@"
}

#poor man's tiktoken
#usage: _tiktokenf [string] [divide_by]
# divide_by  ^:less tokens  v:more tokens
function _tiktokenf
{
	typeset str tkn var by wc
	var="$1" by="$2"

	# 1 TOKEN ~= 4 CHARS IN ENGLISH
	#str="${1// }" str="${str//[$'\t\n']/xxxx}" str="${str//\\[ntrvf]/xxxx}" tkn=$((${#str}/${by:-4}))
	
	# 1 TOKEN ~= ¾ WORDS
	var=$(sed 's/\\[ntrvf]/ x /g' <<<"$var")  #escaped special chars
	var=$(sed 's/[^[:alnum:] \t\n]/ x/g' <<<"$var")
	wc=$(wc -w <<<"$var")
	tkn=$(( (wc * 4) / ${by:-3}))

	printf '%d\n' "${tkn:-0}" ;((tkn>0))
}

#use openai python tiktoken lib
#input should be `unescaped'
#usage: tiktokenf [model|encoding] [text|-]
function tiktokenf
{
	python -c "import sys

try:
    import tiktoken
except ImportError as e:
    print(\"Err: Python -- \", e)
    exit()

opttiktoken, opttik = ${OPTTIKTOKEN:-0}, ${HOPTTIK:-0}
optv, optl = ${OPTV:-0}, ${OPTL:-0}
mod, text = sys.argv[1], \"\"

if opttik <= 0:
    if opttiktoken+optl > 2:
        for enc_name in tiktoken.list_encoding_names():
            print(enc_name)
        sys.exit()
    elif (len(sys.argv) > 2) and (sys.argv[2] == \"-\"):
        text = sys.stdin.read()
    else:
        text = sys.argv[2]

try:
    enc = tiktoken.encoding_for_model(mod)
except:
    try:
        try:
            enc = tiktoken.get_encoding(mod)
        except:
            enc = tiktoken.get_encoding(\"${MODEL_ENCODING}\")
    except:
        enc = tiktoken.get_encoding(\"r50k_base\")  #davinci
        print(\"Warning: Tiktoken -- unknown model/encoding, fallback \", str(enc), file=sys.stderr)

if opttik <= 0:
    encoded_text = enc.encode_ordinary(text)
    if opttiktoken > 1:
        print(encoded_text)
    if optv:
        print(len(encoded_text))
    else:
        print(len(encoded_text),str(enc))
else:
    try:
        while text != \"/END_TIKTOKEN/\":
            text = sys.stdin.readline().rstrip(\"\\n\")
            text = text.replace(\"\\\\\\\\\", \"&\\f\\f&\").replace(\"\\\\n\", \"\\n\").replace(\"\\\\t\", \"\\t\").replace(\"\\\\\\\"\", \"\\\"\").replace(\"&\\f\\f&\", \"\\\\\")
            encoded_text = enc.encode_ordinary(text)
            print(len(encoded_text), flush=True)
    except (KeyboardInterrupt, BrokenPipeError, SystemExit):  #BaseException:
        exit()" "${MOD:-davinci}" "${@:-}"
}
#cl100k_base gpt-3.5-turbo
#json specials \" \\ b f n r t \uHEX

#convert markdown to plain text
function unmarkdownf
{
	python -c "import sys
try:
    import markdown
    from bs4 import BeautifulSoup
except:
    sys.exit(2)

def remove_markdown(text):
    html = markdown.markdown(text)
    soup = BeautifulSoup(html, 'html.parser')
    return soup.get_text()

markdown_text = sys.stdin.read()
stripped_text = remove_markdown(markdown_text)
print(stripped_text)"
}

#set output image size
function set_imgsizef
{
	typeset opts_hd
	case "$1" in
		[Hh][Dd] | [Hh][Dd]* | *[Hh][Dd] )
			OPTS_HD="hd" opts_hd=1;
			set -- "${1/[Hh][Dd]}";;
	esac
	case "$1" in  #width x height, dall-e-3
		1024*1792 | [Pp] | [Pp][Oo][Rr][Tt][Rr][Aa][Ii][Tt] )  #portrait
			OPTS=1024x1792;;
		1792* | [Xx] | [Ll][Aa][Nn][Dd][Ss][Cc][Aa][Pp][Ee] )  #landscape
			OPTS=1792x1024;;
		1024* | [Ll] | [Ll][Aa][Rr][Gg][Ee] )  #large
			OPTS=1024x1024;;
		512*  |  [Mm]  | [Mm][Ee][Dd][Ii][Uu][Mm] ) OPTS=512x512;;  #medium
		256*  |  [Ss]  | [Ss][Mm][Aa][Ll][Ll] )     OPTS=256x256;;  #small
		*)  #fallbacks
			[[ -z $OPTS ]] || return 1;
			if [[ $MOD_IMAGE = *dall-e*[3-9] ]] || [[ opts_hd -gt 0 ]]
			then 	OPTS=1024x1024; 
			else 	OPTS=512x512;
			fi; ((opts_hd));;
	esac;
}

# Nill, null, none, inf; Nil, nul; -N---, --- (chat);
GLOB_NILL='?([Nn])[OoIiUu][NnLl][EeLlFf]' GLOB_NILL2='?([Nn])[IiUu][Ll]' GLOB_NILL3='?([Nn])-*(-)'
function set_maxtknf
{
	typeset buff
	set -- "${*:-$OPTMAX}"
	set -- "${*##[+-]}"; set -- "${*%%[+-]}"; set -- "${*// }";

	case "$*" in
		$GLOB_NILL|$GLOB_NILL2|$GLOB_NILL3)
			((OPTMAX_NILL)) && unset OPTMAX_NILL || OPTMAX_NILL=1;;
		*[0-9][!0-9][0-9]*)
			OPTMAX="${*##${*%[!0-9]*}}" MODMAX="${*%%"$OPTMAX"}"
			OPTMAX="${OPTMAX##[!0-9]}" OPTMAX_NILL= ;;
		*[0-9]*)
			OPTMAX="${*//[!0-9]}" OPTMAX_NILL= ;;
	esac
	if ((OPTMAX>MODMAX))
	then 	buff="$MODMAX" MODMAX="$OPTMAX" OPTMAX="$buff" 
	fi
}

#set the markdown command
function set_mdcmdf
{
	typeset cmd;
	unset MD_CMD_UNBUFF;
	((STREAM)) || unset STREAM;
	set -- "$(trimf "${*:-$MD_CMD}" "$SPC")";

	if ! command -v "${1%% *}" &>/dev/null
	then 	for cmd in "bat" "pygmentize" "glow" "mdcat" "mdless"
		do 	command -v $cmd &>/dev/null || continue;
			set -- $cmd; break;
		done;
	fi

	case "$1" in
		bat) 	MD_CMD_UNBUFF=1  #line-buffer support
			function mdf {
			  [[ -t 1 || OPTMD -gt 1 ]] && set -- --color always "$@";
			  bat --paging never --language md --style plain "$@" | foldf;
			}
			;;
		bat*) 	eval "function mdf { 	$* \"\$@\" ;}"
			MD_CMD_UNBUFF=1
			;;
		pygmentize)
			function mdf { 	pygmentize ${STREAM:+-s} -l md "$@" | foldf ;}
			MD_CMD_UNBUFF=1
			;;
		pygmentize*)
			eval "function mdf { 	$* \"\$@\" | foldf ;}"
			[[ $* = *-s* ]] && MD_CMD_UNBUFF=1
			;;
		glow*|mdcat*|mdless*|*)
			command -v "${1%% *}" &>/dev/null || return 1;
			eval "function mdf { 	$* \"\$@\" ;}";
			;;
	esac; MD_CMD="${1%% *}";
	#turn off folding for some software
	case "$1" in mdless*|less*|bat?*|cat*) OPTFOLD=1; cmd_runf /fold;; esac;
}
function mdf { 	cat ;}

#set a terminal web browser
function set_browsercmdf
{
	typeset cmd;
	if ((${#BROWSER})) && command -v "${BROWSER%% *}" &>/dev/null
	then 	_set_browsercmdf "$BROWSER";
	else 	for cmd in "w3m" "elinks" "links" "lynx" "curl"
		do 	command -v $cmd &>/dev/null || continue;
			_set_browsercmdf $cmd && return;
		done; false;
	fi;
}
function set_jbrowsercmdf
{
	typeset cmd;
	for cmd in "google-chrome-stable" "google-chrome" "chromium" "chromium-browser" "ungoogled-chromium" "brave"
	do 	command -v $cmd &>/dev/null || continue;
		_set_browsercmdf $cmd && return;
	done; false;
}
function _set_browsercmdf
{
	case "$1" in
		w3m*) 	printf '%s' "w3m -T text/html -dump";;
		lynx*) 	printf '%s' "lynx -force_html -nolist -dump -stdin";;
		elinks*) printf '%s' "elinks -force-html -no-references -dump";;
		links*) printf '%s' "links -force-html -dump";;
		google-chrome*|chromium*|ungoogled-chromium*|brave*)
			printf '%s' "${1%% *} --disable-gpu --headless --dump-dom";;
		*) 	printf '%s' "curl -f -L --compressed --insecure --cookie non-existing --header \"$UAG\"";;
	esac;
}

#calculate cost of query (dollars per million tokens)
#usage: costf [input_tokens] [output_tokens] [input_price] [output_price] [scale]
function costf  #[TO BE REMOVED]
{
	bc <<<"scale=${5:-8};
( ( (${1:-0} / 1000000) * ${3:-0}) + ( (${2:-0} / 1000000) * ${4:-0}) ) * ${CURRENCY_RATE:-1}"
}
function _model_costf
{
	case "${MOD_PRICE[*]}" in
	*[0-9]*[$IFS]*[0-9]*) 	echo ${MOD_PRICE[@]:0:2}; return;;
	esac;
	typeset model; model=${1};
	case "${model##ft:}" in
		claude-3-opus*) 	echo 15 75;;
		claude-3-sonnet*|claude-3-5-sonnet*) echo 3 15;;
		claude-3-haiku*) 	echo 0.25 1.25;;
		claude-3.5-haiku*) 	echo 1 5;;
		claude-2.1*|claude-2*) 	echo 8 24;;
		claude-instant-1.2*) 	echo 0.8 2.4;;
		open-mistral-nemo*) 	echo 0.3 0.3;;
		mistral-large*) 	echo 2 6;;
		codestral*|mistral-small*) echo 0.2 0.6;;
		open-mistral-7b*) 	echo 0.25 0.25;;
		open-mixtral-8x7b*) 	echo 0.7 0.7;;
		open-mixtral-8x22b*|pixtral-large*) 	echo 2 6;;
		pixtral-12b*) 	echo 0.15 0.15;;
		mistral-medium*) 	echo 2.75 8.1;;
		ministral-8b*) 	echo 0.1 0.1;;
		ministral-3b*) 	echo 0.04 0.04;;
		gpt-4o-audio-preview*|gpt-4o-audio-preview-2024-10-01) echo 2.5 10;;  #text only
		o3-mini*|o3-mini-2025-01-31) echo 1.10 4.40;;
		o1-mini*|o1-mini-2024-09-12) echo 1.10 4.40;;
		o1*|o1-preview-2024-09-12) echo 15 60;;
		gpt-4o-mini-audio-preview*|gpt-4o-mini-audio-preview-2024-12-17) echo 0.15 0.60;;  #text only
		gpt-4o-mini*) 	echo 0.15 0.6;;
		gpt-4o-2024-05-13|chatgpt-4o*) 	echo 5 15;;
		gpt-4o-2024-08-06|gpt-4o*) echo 2.5 10;;
		text-embedding-3-small) 	echo 0.02 0;;
		text-embedding-3-large) 	echo 0.13 0;;
		text-embedding-ada-002|mistral-embed*|mistral-moderation*) 	echo 0.1 0;;
		gpt-4) 	echo 30 60;;
		gpt-4-32k) 	echo 60 120;;
		gpt-4-turbo*|gpt-4-*preview) 	echo 10 30;;
		gpt-3.5-turbo-0125) 	echo 0.5 1.5;;
		gpt-3.5-turbo-0613|gpt-3.5-turbo-0301|gpt-3.5-turbo-instruct) echo 1.5 2;;
		gpt-3.5-turbo-1106) 	echo 1 2;;
		gpt-3.5-turbo-16k-0613) echo 3 4;;
		davinci-002) 	echo 2 2;;
		babbage-002) 	echo 0.4 0.4;;
		gemini-1.0-pro*) 	echo 0.5 1.5;;
		gemini-1.5-flash*) ((MAX_PREV>128000||TOTAL_OLD>128000)) && echo 0.15 0.6 || echo 0.075 0.3;;
		gemini-1.5*) ((MAX_PREV>128000||TOTAL_OLD>128000)) && echo 7 21 || echo 3.5 10.5;;
		deepseek-chat) echo 0.14 0.55;;
		deepseek-reasoner) echo 0.28 2.19;;
		# Novita Models
		deepseek/deepseek-r1) echo 4 4;;
		deepseek/deepseek-r1-distill-llama-70b) echo 0.8 0.8;;
		deepseek/deepseek_v3) echo 0.89 0.89;;
		meta-llama/llama-3.1-8b-instruct|qwen/qwen-2-7b-instruct|Sao10K/L3-8B-Stheno-v3.2) 	echo 0.05 0.05;;
		meta-llama/llama-3.1-70b-instruct) 	echo 0.34 0.39;;
		meta-llama/llama-3.1-405b-instruct) 	echo 2.75 2.75;;
		mistralai/mistral-7b-instruct|microsoft/wizardlm-2-7b|openchat/openchat-7b) 	echo 0.06 0.06;;
		qwen/qwen-2-72b-instruct) 	echo 0.34 0.39;;
		meta-llama/llama-3-8b-instruct) 	echo 0.04 0.04;;
		meta-llama/llama-3-70b-instruct) 	echo 0.51 0.74;;
		google/gemma-2-9b-it) 	echo 0.08 0.08;;
		nousresearch/hermes-2-pro-llama-3-8b) 	echo 0.14 0.14;;
		mistralai/mistral-nemo) 	echo 0.15 0.15;;
		microsoft/wizardlm-2-8x22b) 	echo 0.62 0.62;;
		gryphe/mythomax-l2-13b) 	echo 0.09 0.09;;
		jondurbin/airoboros-l2-70b) 	echo 0.50 0.50;;
		lzlv_70b) 	echo 0.58 0.78;;
		nousresearch/nous-hermes-llama2-13b|teknium/openhermes-2.5-mistral-7b) 	echo 0.17 0.17;;
		sophosympatheia/midnight-rose-70b) 	echo 0.80 0.80;;
		qwen/qwen-2.5-72b-instruct) 	echo 0.38 0.40;;
		sao10k/l3*-70b-euryale-v2.[1-9]) 	echo 1.48 1.48;;
		cognitivecomputations/dolphin-mixtral-8x22b) 	echo 0.90 0.90;;
		grok-beta|grok-vision-beta) 	echo 5 15;;
		grok-2-*-1212|grok-*) 	echo 2 10;;
		*) 	echo 0 0; false;;
	esac;
}
#prices updated on aug/24
#https://openai.com/api/pricing/
#https://cloud.google.com/vertex-ai/generative-ai/pricing
#https://ai.google.dev/pricing

#check input and run a chat command  #tags: cmdrunf, runcmdf, run_cmdf
function cmd_runf
{
	typeset append filein fileinq onutdir out var wc xskip pid n
	typeset -a args arr;
	((${#HARGS})) || typeset HARGS;
	[[ ${1:0:128}${2:0:128} = *([$IFS:])[/!-]* ]] || return;
	((${#1}+${#2}<1024)) || return;
	printf "${NC}" >&2;

	set -- "${1##*([$IFS:])?([/!])}" "${@:2}";
	args=("$@"); set -- "$*";

	case "$*" in
		$GLOB_NILL|$GLOB_NILL2|$GLOB_NILL3)
			set_maxtknf nill
			cmdmsgf 'Response' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} tkns"
			;;
		-[0-9]*|[0-9]*|-M*|[Mm]ax*|\
		-N*|[Mm]odmax*|[/!][0-9]*|--[0-9]*)
			case "$*" in -N*|-[Mm]odmax*|[/!]*|--*)
				#model capacity
				set -- "${*##@([Mm]odmax|-N|[/!]|--)*([$IFS])}";
				[[ $* = *[!0-9]* ]] && set_maxtknf "$*" || MODMAX="$*";
				;;
			*) 	#response max
				set_maxtknf "${*##?([Mm]ax|-M)*([$IFS])}";
				;;
			esac;
			if ((HERR))
			then 	unset HERR
				_sysmsgf 'Context Length:' 'error reset'
			fi ;cmdmsgf 'Response / Capacity' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
			;;
		-a*|presence*|pre*)
			set -- "${*//[!0-9.]}"
			OPTA="${*:-$OPTA}"
			fix_dotf OPTA
			cmdmsgf 'Presence Penalty' "$OPTA"
			;;
		-A*|frequency*|freq*)
			set -- "${*//[!0-9.]}"
			OPTAA="${*:-$OPTAA}"
			fix_dotf OPTAA
			cmdmsgf 'Frequency Penalty' "$OPTAA"
			;;
		-b*|best[_-]of*)
			set -- "${*//[!0-9.]}" ;set -- "${*%%.*}"
			OPTB="${*:-$OPTB}"
			cmdmsgf 'Best_Of' "$OPTB"
			;;
		-C)
			if ((BREAK_SET))
			then 	BREAK_SET= OPTRESUME=1 INSTRUCTION_OLD=${INSTRUCTION:-$INSTRUCTION_OLD} INSTRUCTION= GINSTRUCTION=;
				cmdmsgf "Session Continue:" $(_onoff ${OPTRESUME:-0});
			else 	BREAK_SET=1 OPTRESUME= INSTRUCTION=${INSTRUCTION_OLD:-$INSTRUCTION};
				((GOOGLEAI)) && GINSTRUCTION=${INSTRUCTION:-$GINSTRUCTION} INSTRUCTION=;
				cmd_runf /break;
			fi
			;;
		-c)
			((OPTC)) && { 	cmd_runf -cc; return ;}
			OPTC=1 EPN=0 OPTCMPL= ;
			cmdmsgf "Endpoint[$EPN]:" "Text Chat Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$BASE_URL}]";
			;;
		-cc)
			((OPTC>1)) && { 	cmd_runf -d; return ;}
			OPTC=2 EPN=6 OPTCMPL= ;
			cmdmsgf "Endpoint[$EPN]:" "Chat Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$BASE_URL}]";
			;;
		-[dD]|-[dD][dD])
			((!OPTC)) && { 	cmd_runf -c; return ;}
			OPTC= EPN=0 OPTCMPL=1 ;
			cmdmsgf "Endpoint[$EPN]:" "Text Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$BASE_URL}]";
			;;
		break|br|new)
			if ((OPTV>99))
			then 	BREAK_SET=1;
			else 	break_sessionf;
			fi;
			[[ -n ${INSTRUCTION_OLD:-$INSTRUCTION} ]] && {
			  ((OPTV>99)) || _sysmsgf 'INSTRUCTION:' "${INSTRUCTION_OLD:-$INSTRUCTION}" 2>&1 | foldf >&2
			  ((GOOGLEAI)) && GINSTRUCTION=${INSTRUCTION_OLD:-${INSTRUCTION:-$GINSTRUCTION}} GINSTRUCTION_PERM=$GINSTRUCTION INSTRUCTION= ||
			  INSTRUCTION=${INSTRUCTION_OLD:-$INSTRUCTION};
			}; CKSUM_OLD= MAX_PREV= WCHAT_C= MAIN_LOOP= HIST_LOOP= TOTAL_OLD= xskip=1;
			;;
		currency[_-]rate*|currency*)  #currency rate
			set -- "${*##@(currency[_-]rate|currency)$SPC}"
			set -- "${*//[!0-9.,]}"
			CURRENCY_RATE=${*:-$CURRENCY_RATE}
			cmdmsgf 'Currency Rate:' "${*:-$CURRENCY_RATE} (vs Dollar)"
			;;
		prices*|price*)
			set -- "${*##@(prices|price)$SPC}"
			set -- "${*//[!0-9.,\ ]}"
			MOD_PRICE=( ${*//,/.} )
			cmdmsgf 'Price / 1M tkns:' "input: \$ ${MOD_PRICE[0]}  output: \$ ${MOD_PRICE[1]}"
			;;
		block*|blk*)
			set -- "${*##@(block|blk)$SPC}"
			_printbf '>';
			read_mainf -i "${BLOCK_USR}${1:+ }${1}" BLOCK_USR;
			cmdmsgf $'\nUser Block:' "${BLOCK_USR:-unset}";
			;;
		effort*)
			set -- "${*##effort$SPC}"
			if [[ $REASON_EFFORT != *[!$IFS]* ]]
			then 	REASON_EFFORT="${*:-medium}";
			else 	REASON_EFFORT="${*}";
			fi;
			cmdmsgf 'Reasoning Effort:' "${REASON_EFFORT:-unset}";
			;;
		fold|wrap|no-fold|no-wrap)
			((++OPTFOLD)) ;((OPTFOLD%=2))
			cmdmsgf 'Folding' $(_onoff $OPTFOLD)
			;;
		-g|-G|stream|no-stream)
			((++STREAM)) ;((STREAM%=2))
			((STREAM)) || unset STREAM;
			cmdmsgf 'Streaming' $(_onoff ${STREAM:-0})
			;;
		interactive|no-interactive)
			case "$REASON_INTERACTIVE" in
				false|'') if [[ $REASON_INTERACTIVE != *[!$IFS]* ]]
					then 	REASON_INTERACTIVE=true;
					else 	REASON_INTERACTIVE=;
					fi;;
				true|*) REASON_INTERACTIVE=false;;

			esac;
			cmdmsgf 'Reasoning Interactive' "$REASON_INTERACTIVE";
			;;
		-h|h|help|-\?|\?)
			var=$(sed -n -e 's/^   //' -e '/^[[:space:]]*-----* /,/^[[:space:]]*Notes/p' <<<"$HELP");
			less -S <<<"${var}"; xskip=1;
			;;
		-h\ *|h\ *|[/!]h*|help?*|-\?*|\?*)
			set -- "${*##@(-h|h|[/!]h|help|\?)$SPC}";
			if ((${#1}<2)) ||
				! grep --color=always -i -e "${1%%${NL}*}" <<<"$(cmd_runf -h)" >&2;
			then 	cmd_runf -h; return;
			fi; xskip=1
			;;
		-H|H|history|hist)
			_edf "$FILECHAT"
			CKSUM_OLD= xskip=1
			;;
		-HH|-HHH*|HH|HHH*|request|print)
			[[ $* = ?(-)HHH* ]] && typeset OPTHH=3
			Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" \
			  MOD= OLLAMA= HERR= TKN_PREV= MAX_PREV= set_histf
			var=$( usr_logf "$(unescapef "$HIST")" )
			if ((OPTMD))
			then 	set_mdcmdf "$MD_CMD";
				mdf <<<"$var" >&2 2>/dev/null;
			else 	printf "\\n---\\n%s\\n---\\n" "$var" >&2;
			fi
			((OPTCLIP)) && ${CLIP_CMD:-false} <<<"$var" && echo 'Clipboard set!' >&2
			;;
		-P|P) 	cmd_runf -HH; return;; -PP*|PP*) 	cmd_runf -HHH; return;;
		-j|seed)
			OPTSEED="${*##@(-j|seed)*([$IFS])}"
			cmdmsgf 'Seed:' "$OPTSEED"
			;;
		j|jump)
			cmdmsgf 'Jump:' 'append response primer'
			JUMP=1 REPLY=
			return 179
			;;
		[/!]j|[/!]jump|J|Jump)
			cmdmsgf 'Jump:' 'no response primer'
			JUMP=2 REPLY=
			return 180
			;;
		-K*|top[Kk]*|top[_-][Kk]*)
			set -- "${*//[!0-9.]}"
			OPTKK="${*:-$OPTKK}"
			cmdmsgf 'Top_K' "$OPTKK"
			;;
		keep-alive*|ka*)
			set -- "${*//[!0-9.]}"
			OPT_KEEPALIVE="${*:-$OPT_KEEPALIVE}"
			cmdmsgf 'Keep_alive' "$OPT_KEEPALIVE"
			;;
		-L*|log*)
			((OPTLOG)) && [[ -n $* ]] && OPTLOG= ;
			((++OPTLOG)); ((OPTLOG%=2));
			cmdmsgf 'Logging' $(_onoff $OPTLOG);
			((OPTLOG)) && {
			  set -- "${*##@(-L|log)$SPC}"
			  if [[ -d "$*" ]]
			  then 	USRLOG="${*%%/}/${USRLOG##*/}"
			  else 	USRLOG="${*:-${USRLOG}}"
			  fi
			  [[ "$USRLOG" = '~'* ]] && USRLOG="${HOME}${USRLOG##\~}"
			  _cmdmsgf 'Log file' "<${USRLOG/"$HOME"/"~"}>";
			};
			;;
		-l*|models|list-models)
			set -- "${*##@(-l|models|list-models)*([$IFS])}";
			list_modelsf "$*" | less >&2;
			;;
		-m*|model*|mod*)
			set -- "${*##@(-m|model|mod)}"; set -- "${1//[$IFS]}"
			if ((${#1}<3))
			then 	pick_modelf "$1"
			else 	MOD=${1:-$MOD};
			fi; MULTIMODAL=;
			case "${MOD}" in o[1-9]*) 	:;; *) 	((MOD_REASON));; esac && set_optsf
			set_model_epnf "$MOD"; model_capf "$MOD";
			is_amodelf "$MOD" && MULTIMODAL=2;
			is_visionf "$MOD" && MULTIMODAL=1;
			send_tiktokenf '/END_TIKTOKEN/'
			cmdmsgf 'Model Name' "$MOD$( ((MULTIMODAL)) && printf ' / %s' 'multimodal')"
			cmdmsgf 'Response / Capacity:' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
			;;
		markdown*|md*)
			((OPTMD)) || (OPTMD=1 cmd_runf //"${args[@]}");
			set -- "${*##@(markdown|md)$SPC}"
			((OPTMD)) && [[ -n $1 ]] && OPTMD= ;
			if ((++OPTMD)); ((OPTMD%=2))
			then 	MD_CMD=${1:-$MD_CMD} xskip=1;
				set_mdcmdf "$MD_CMD";
				((${MD_AUTO:+1})) ||
				  sysmsgf 'MD Cmd:' "$MD_CMD"
			fi;
			cmdmsgf 'Markdown' "$(_onoff $OPTMD)${MD_AUTO:+ (AUTO)}";
			((OPTMD)) || unset OPTMD; NO_OPTMD_AUTO=1;
			;;
		[/!]markdown*|[/!]md*)
			set -- "${*##[/!]@(markdown|md)$SPC}"
			set_mdcmdf "${1:-$MD_CMD}"; xskip=1;
			printf "${NC}\\n" >&2;
			((BREAK_SET)) ||
			prompt_pf -r ${STREAM:+-j --unbuffered} "$FILE" 2>/dev/null | mdf >&2 2>/dev/null;
			printf "${NC}\\n\\n" >&2;
			;;
		url*|[/!]url*)
			HARGS=${HARGS:-$*} xskip=1;
			case "$*" in [/!]url:*|url:*) 	append=1;; esac;  #append as user
			set -- "$(trimf "$(trim_leadf "$*" '@(url|[/!]url)*(:)')" "$SPC")";

			case "$*" in
			*youtube.com/watch*|*youtube.com/live*|*youtube.com/shorts*|*youtu.be/*)
				{ yt_descf "$*" || _warmsgf 'YouTube:' 'Description unavailable';
				  yt_transf "$*" || _warmsgf 'YouTube:' 'Transcript dump fail / unavailable';
				} >"$FILEFIFO";
				[[ -s "$FILEFIFO" ]] && cmd_runf /cat "$FILEFIFO";
				return 0;
				;;
			*vimeo.com/[0-9][0-9]*|*vimeo.com/video*|*vimeo.com/channel*|*vimeo.com/group*|*vimeo.com/album*)
				{ vimeo_descf "$*" || _warmsgf 'Vimeo:' 'Description unavailable';
				  vimeo_transf "$*" || _warmsgf 'Vimeo:' 'Transcript dump fail / unavailable';
				} >"$FILEFIFO";
				[[ -s "$FILEFIFO" ]] && cmd_runf /cat "$FILEFIFO";
				return 0;
				;;
			*)
				if ((${#1}))
				then 	var=$(set_browsercmdf);
					((OPTV)) || _printbf "${var%% *}";
					case "$var" in
					  google-chrome*|chromium*|ungoogled-chromium*|brave*)  #html filter hack
					    cmd_runf /sh${append:+:} "${var} \"${1// /%20}\" | $(BROWSER= set_browsercmdf)";
					    ;;
					  *)  cmd_runf /sh${append:+:} "${var}" "\"${1// /%20}\"";
					    ;;
					esac;
					return 0;
				fi;
				;;
			esac;
			;;
		[/!]g*|g*)  #ground context (on-line)
			HARGS=${HARGS:-$*};
			case "$*" in [/!]g:*|g:*) 	append=1;; esac;  #append as user
			set -- "${*##?([/!])g*(:)$SPC}";

			case "${args[*]:-$*}" in
			  [/!]*)
			    n=50; var=$(
			      printf 'Search Engine:\n' >&2;
			      select var in google duckduckgo brave abort
			      do 	break;
			      done </dev/tty;
			      echo "${var:-$REPLY}")

			    case "$var" in
			      abort|[AaQq]*|[$'\e\t ']*) EDIT=1; return 0;;
			      brave|b*) out=Brave;
			        var="https://search.brave.com/search?q=${*//[&?]/+}&source=web";;
			      duckduckgo|d*) out=DuckDuckGo;
			        var="https://html.duckduckgo.com/html/?q=${*//[&?]/+}&kl=wt-wt&kj=wt-wt&k1=-1&kv=${n}";;
			      google|g*|*)
			        var="https://www.google.com/search?q=${*//[&?]/+}&num=${n}";;
			    esac;
			    ;;
			    *)
			    n=50;
			    var="https://www.google.com/search?num=${n}&q=${*//[&?]/+}";
			    ;;
			esac;
			
			((OPTV)) || printf "${BWHITE}%s\\n${NC}" "${out:-Google}" >&2;
			cmd_runf /url${append:+:} "${var:-err}";
			REPLY="$REPLY"$'\n\n'"$*";
			return 0;
			;;
		media*|img*|audio*|aud*)
			set -- "${*##@(media|img|audio|aud)*([$IFS])}";
			set -- "$(trim_trailf "$*" $'*([ \t\n])')";
			CMD_CHAT=1 media_pathf "$1" && {
			  [[ -f $1 ]] && set -- "$(duf "$1")";
			  var=$((MEDIA_IND_LAST+${#MEDIA_IND[@]}+${#MEDIA_CMD_IND[@]}))
			  out=$(is_audiof "$1" && echo aud || echo img)
			  _sysmsgf "$out ?$var" "${1:0: COLUMNS-6-${#var}}$([[ -n ${1: COLUMNS-6-${#var}} ]] && printf '\b\b\b%s' ...)";
			};
			;;
		multimodal|[/!-]multimodal|--multimodal|\
		vision|[/!-]vision|--vision|\
		audio|[/!-]audio|--audio)
			((++MULTIMODAL)); ((MULTIMODAL%=3))
			case "${MULTIMODAL}" in 2) 	var=audio;; 1) 	var=vision;; *) 	var=text;; esac;
			cmdmsgf "Multimodal Model [${var}]" $(_onoff $MULTIMODAL)
			;;
		-n*|results*)
			[[ $* = -n*[!0-9\ ]* ]] && { 	cmd_runf "-N${*##-n}"; return ;}  #compat with -Nill option
			set -- "${*//[!0-9.]}" ;set -- "${*%%.*}"
			OPTN="${*:-$OPTN}"
			cmdmsgf 'Results' "$OPTN"
			;;
		-p*|top[Pp]*|top[_-][Pp]*)
			set -- "${*//[!0-9.]}"
			OPTP="${*:-$OPTP}"
			fix_dotf OPTP
			cmdmsgf 'Top_P' "$OPTP"
			;;
		-r*|restart*)
			set -- "${*##@(-r|restart)?( )}"
			restart_compf "$*"
			cmdmsgf 'Restart Sequence' "\"${RESTART-unset}\""
			;;
		-R*|start*)
			set -- "${*##@(-R|start)?( )}"
			start_compf "$*"
			cmdmsgf 'Start Sequence' "\"${START-unset}\""
			;;
		-s*|stop*)
			set -- "${*##@(-s|stop)?( )}"
			((${#1})) && STOPS=("$(unescapef "${*}")" "${STOPS[@]}")
			cmdmsgf 'Stop Sequences' "[$(unset s v; for s in "${STOPS[@]}"; do v=${v}\"$(escapef "$s")\",; done; printf '%s' "${v%%,}")]"
			;;
		-?(S)*([$' \t'])[.,]*)
			set -- "${*##-?(S)*([$' \t.,'])}"; PSKIP= SKIP=1 EDIT=1
			var=$(INSTRUCTION=$* OPTRESUME=1 CMD_CHAT=1; custom_prf "$@" && echo "$INSTRUCTION")
			case $? in [1-9]*|201|[!0]*) 	REPLY=${args[*]};; 	*) REPLY="-S $var";; esac
			;;
		-?(S)*([$' \t'])[/%]*)
			set -- "${*##-?(S)*([$' \t'])}"; PSKIP= SKIP=1 EDIT=1 
			var=$(INSTRUCTION=$* CMD_CHAT=1; awesomef && echo "$INSTRUCTION") && REPLY="-S $var"
			;;
		-S*|-:*)
			set -- "${*##-[S:]*([$': \t'])}"
			SKIP=1 PSKIP=1 REPLY="::${*}"
			unset INSTRUCTION GINSTRUCTION
			;;
		-t*|temperature*|temp*)  #randomness
			set -- "${*//[!0-9.]}"
			OPTT="${*:-$OPTT}"
			fix_dotf OPTT
			cmdmsgf 'Temperature' "$OPTT"
			;;
		-o|clipboard|clip)
			((++OPTCLIP)); ((OPTCLIP%=2))
			cmdmsgf 'Clipboard' $(_onoff $OPTCLIP)
			if ((OPTCLIP))  #set clipboard
			then 	set_clipcmdf;
				set -- "$(hist_lastlinef "$FILECHAT")";
				[[ $* = *[!$IFS]* ]] &&
				  unescapef "$*" | ${CLIP_CMD:-false} &&
				  printf "${NC}Clipboard Set -- %.*s..${CYAN}\\n" $((COLUMNS-20>20?COLUMNS-20:20)) "$*" >&2;
			fi
			;;
		-q|insert)
			((++OPTSUFFIX)) ;((OPTSUFFIX%=2))
			cmdmsgf 'Insert Mode' $(_onoff $OPTSUFFIX)
			;;
		-v|-vv|-vv*|verbose)
			set --  ${*//[!v]}; set -- ${*//v/ v};
			for var
			do 	((++OPTV)); ((OPTV%=3));
			done;
			case "${OPTV:-0}" in
				1) var='Less';;  2) var='Much less';;
				0) var='ON'; unset OPTV;;
			esac ;_cmdmsgf 'Verbose' "$var"
			;;
		-V|-VV|debug)  #debug
			((++OPTVV)) ;((OPTVV%=2));
			cmdmsgf 'Debug Request' $(_onoff $OPTVV)
			;;
		-xx|[/!]editor|[/!]ed|[/!]vim|[/!]vi)
			((!OPTX)) && cmdmsgf 'Text Editor' 'one-shot'
			((OPTX)) || OPTX=2; REPLY= xskip=1
			;;
		-x|editor|ed|vim|vi)
			((++OPTX)) ;((OPTX%=2)); REPLY= xskip=1
			;;
		-y|-Y|tiktoken|tik|no-tik)
			send_tiktokenf '/END_TIKTOKEN/'
			((++OPTTIK)) ;((OPTTIK%=2))
			cmdmsgf 'Tiktoken' $(_onoff $OPTTIK)
			;;
		-[Ww]*|[Ww]*|rec*|whisper*)
			set -- "${*##@(-[wW][wW]|-[wW]|[wW][wW]|[wW]|rec|whisper)$SPC}";
			((OPTW+OPTWW)) && [[ -n $* ]] && OPTW= OPTWW=; OPTX=;
			case "${args[*]}" in
				-W*|W*) OPTWW=1; OPTW= ;;
				*)      OPTW=1; OPTWW= ;;
			esac;

			((OPTW%=2)); ((OPTWW%=2));
			case "${args[*]}" in 	-[Ww][Ww]*|[Ww][Ww]*) OPTW=2;; esac;
			
			if ((OPTW+OPTWW))
			then
			  set_reccmdf

			  var="${*##$SPC}"
			  [[ $var = [a-z][a-z][$IFS]*[[:graph:]]* ]] \
			  && set -- "${var:0:2}" "${var:3}"
			  for var
			  do 	((${#var})) || shift; break;
			  done

			  [[ -z $* ]] || WARGS=("$@"); xskip=1;
			  cmdmsgf "Whisper Args #${#WARGS[@]}" "${WARGS[*]:-(auto)}"
			fi; cmdmsgf 'Whisper Chat' $(_onoff $((OPTW+OPTWW)) );
			((OPTW)) || unset OPTW WSKIP SKIP;
			;;
		-z*|tts*|speech*)
			set -- "${*##@(-z*([zZ])|tts|speech)$SPC}"
			((OPTZ)) && [[ -n $* ]] && OPTZ= ;
			if ((++OPTZ)); ((OPTZ%=2))
			then 	set_playcmdf;
				[[ -z $* ]] || ZARGS=("$@"); xskip=1;
				cmdmsgf 'TTS Args' "${ZARGS[*]:-unset}";
			fi; cmdmsgf 'TTS Chat' $(_onoff $OPTZ);
			((OPTZ)) || unset OPTZ SKIP;
			;;
		-Z|last)
			lastjsonf >&2
			;;
		-ZZ) 	OPTZZ=2 lastjsonf >&2
			;;
		-ZZZ*) 	OPTZZ=3 lastjsonf >&2
			;;
		[/!]k*|k*)  #kill num hist entries
			typeset IFS dry; IFS=$'\n';
			[[ ${n:=${*//[!0-9]}} = 0* || $* = [/!]* ]] \
			&& n=${n##*([/!0])} dry=4; ((n>0)) || n=1
			if arr=( $(
				grep -n -e '^[[:space:]]*[^#]' "$FILECHAT" \
				| tail -n $n | cut -c 1-160 | sed -e 's/[[:space:]]/ /g') )
			then
				((n<${#arr[@]})) || n=${#arr[@]}
				wc=$((COLUMNS>50 ? COLUMNS-6+dry : 60))
				printf "kill${dry:+\\b\\b\\b\\b}:%.${wc}s\\n" "${arr[@]}" >&2
				if ((!dry))
				then
					set --
					for ((n=n;n>0;n--))
					do 	set -- -e "${arr[${#arr[@]}-n]%%:*} s/^/#/" "$@"
					done
					sed -i "$@" "$FILECHAT";
				fi
			fi
			;;
		[/!]i|[/!]info) 	get_infof;;
		i|info)
			(  unset blku hurl hurlv modmodal rseq sseq stop
			((OLLAMA)) && hurl='ollama-url' hurlv=${OLLAMA_BASE_URL}${ENDPOINTS[EPN]};
			((GOOGLEAI)) && hurl='google-url' hurlv=${GOOGLE_BASE_URL}${ENDPOINTS[EPN]};
			((ANTHROPICAI)) && hurl='anthropic-url' hurlv=${ANTHROPIC_BASE_URL}${ENDPOINTS[EPN]};

			set_optsf 2>/dev/null
			stop=${OPTSTOP#*:} stop=${stop%%,} stop=${stop:-\"unset\"}
			{ is_visionf "$MOD" || is_amodelf "$MOD" ;} && modmodal=' / multimodal'
			((MTURN+OPTRESUME)) &&
			OPTC= OLLAMA= GOOGLEAI= OPTHH=1 EPN=0 set_histf >/dev/null;

			((${#BLOCK_USR})) && blku="user-json ${BLOCK_USR:+set}";

			if ((EPN==6))
			then 	rseq='unavailable'
				sseq='unavailable'
			elif ((OPTC))
			then 	rseq=\"${RESTART-$Q_TYPE}\"
				sseq=\"${START-$A_TYPE}\"
			else 	rseq=\"${RESTART-unset}\"
				sseq=\"${START-unset}\"
			fi

			printf "${NC}${BWHITE}%-13s:${NC} %-5s\\n" \
			$hurl          $hurlv \
			api-path      "${BASE_URL}${ENDPOINTS[EPN]}" \
			model-name    "${MOD:-?}${modmodal}" \
			model-cap     "${MODMAX:-?}" \
			response-max  "${OPTMAX:-?}${OPTMAX_NILL:+${EPN6:+ - inf.}}" \
			context-prev  "${MAX_PREV:-${TKN_PREV:-?}}  (${HIST_LOOP:-0} turns)" \
			token-rate    "${TKN_RATE[2]:-?} tkns/sec  (${TKN_RATE[0]:-?} tkns, ${TKN_RATE[1]:-?} secs)" \
			session-cost  "${SESSION_COST:-0} \$" \
			turn-cost-max "$(costf ${MAX_PREV:-0} ${OPTMAX:-0} $(_model_costf "$MOD") 6 ) \$" \
			browser-cli   "${BROWSER:-auto}" \
			seed          "${OPTSEED:-unset}" \
			tiktoken      "${OPTTIK:-0}" \
			keep-alive    "${OPT_KEEPALIVE:-unset}" \
			temperature   "${OPTT:-0}" \
			pres-penalty  "${OPTA:-unset}" \
			freq-penalty  "${OPTAA:-unset}" \
			top-k         "${OPTKK:-unset}" \
			top-p         "${OPTP:-unset}" \
			results       "${OPTN:-1}" \
			best-of       "${OPTB:-unset}" \
			logprobs      "${OPTBB:-unset}" \
			insert-mode   "${OPTSUFFIX:-unset}" \
			streaming     "${STREAM:-unset}" \
			clipboard     "${OPTCLIP:-unset}" \
			ctrld-prpter  "${OPTCTRD:-unset}" \
			cat-prompter  "${CATPR:-unset}" \
			restart-seq   "${rseq}" \
			start-seq     "${sseq}" \
			stop-seqs     "${stop}" \
			$blku \
			history-file  "${FILECHAT/"$HOME"/"~"}"  >&2;
			
			((!NOVITAAI)) || {  _printbf 'wait';  #credit_balance
			curl -L -s "https://api.novita.ai/v3/user" --header "Authorization: Bearer ${NOVITA_API_KEY}"; echo >&2 ;}  )
			;;
		-u|multi|multiline|-uu*(u)|[/!]multi|[/!]multiline)
			case "$*" in
				-uu*|[/!]multi|[/!]multiline)
					((OPTCTRD)) || OPTCTRD=2;
					((OPTCTRD==2)) && cmdmsgf 'Prompter <Ctrl-D>' 'one-shot';;
				*) 	((OPTCTRD)) && unset OPTCTRD || OPTCTRD=1
					cmdmsgf 'Prompter <Ctrl-D>' $(_onoff $OPTCTRD)
					((OPTCTRD)) && _warmsgf '*' '<Ctrl-V Ctrl-J> for newline * ';;
			esac
			;;
		-U|-UU*(U))
			case "$*" in
				-UU*) 	((CATPR)) || CATPR=2;
					((CATPR==2)) && _cmdmsgf 'Cat Prompter' "one-shot";;
				*) 	((++CATPR)) ;((CATPR%=2))
					cmdmsgf 'Cat Prompter' $(_onoff $CATPR);;
			esac
			;;
		cat*|file*)
			set -- "${*}"; HARGS=${HARGS:-$*};
			filein=$(trimf "${1##@(cat|file)*(:)}" "$SPC");
			if [[ $filein = *\\* ]]
			then 	filein=${filein//\\};
			else 	fileinq=$(printf '%q' "${filein}");
			fi  #paths with spaces must be backslash-escaped

			if is_imagef "$filein" || is_audiof "$filein"
			then 	cmd_runf /media"${filein}";
			elif is_pdff "$filein"
			then 	cmd_runf /pdf"${filein}";
			elif is_docf "$filein"
			then 	cmd_runf /doc"${filein}";
			elif _is_linkf "$filein"
			then 	cmd_runf /url"${filein}";
			else
				case "$*" in
					cat:*[!$IFS]*)
						cmd_runf /sh: "cat ${fileinq:-$filein}";;
					cat*[!$IFS]*)
						cmd_runf /sh "cat ${fileinq:-$filein}";;
					*)
						_warmsgf '*' 'Press <Ctrl-D> to flush * '
						STDERR=/dev/null  cmd_runf /sh cat </dev/tty;;
				esac;
			fi; return;
			;;
		pdf*)
			set -- "${*}"; HARGS=${HARGS:-$*};
			filein=$(trimf "${1##pdf*(:)}" "$SPC");
			[[ $filein = *\\* ]] || filein=$(printf '%q' "${filein}");
			
			if command -v pdftotext
			then 	var="pdftotext -layout -nopgbrk ${filein} -";
			elif command -v gs
			then 	var="gs -sDEVICE=txtwrite -o - ${filein}"
			elif command -v abiword
			then 	var="abiword --to=txt --to-name='$FILEFIFO' ${filein}; cat -- '$FILEFIFO'"
			elif command -v ebook-convert
			then 	var="ebook-convert ${filein} '$FILEFIFO'; cat -- '$FILEFIFO'"
			else 	set --; RET=1;  #auto-disable
				function _is_pdff { 	false ;};
			fi 2>/dev/null >&2

			case "$*" in
				pdf:*[!$IFS]*)
					cmd_runf /sh: "$var";;
				pdf*[!$IFS]*)
					cmd_runf /sh "$var";;
				*) 	_warmsgf 'Err:' 'Input or PDF-to-Text software missing';;
			esac; return;
			;;
		doc*)
			set -- "${*}"; HARGS=${HARGS:-$*};
			filein=$(trimf "${1##doc*(:)}" "$SPC");
			[[ $filein = *\\* ]] || filein=$(printf '%q' "${filein}");
			outdir=$(printf '%q' "${OUTDIR}");
			out=${outdir}/${filein##*/} out=${out%.*}.txt;

			if command -v libreoffice
			then 	var="libreoffice --headless --convert-to txt --outdir ${outdir} ${filein} && cat -- ${out}";
			elif command -v abiword
			then 	var="abiword --to=txt --to-name=${out} ${filein}; cat -- ${out}";
			else 	set --; RET=1;  #auto-disable
				function _is_docf { 	false ;};
			fi 2>/dev/null >&2

			case "$*" in
				doc:*[!$IFS]*)
					cmd_runf /sh: "$var";;
				doc*[!$IFS]*)
					cmd_runf /sh "$var";;
				*) 	_warmsgf 'Err:' 'Input or LibreOffice missing';;
			esac; return;
			;;
		save*|\#*)
			shell_histf "${*##@(save|\#)*([$IFS])}"; history -a;
			((${#1})) && cmdmsgf 'Shell:' 'Prompt added to history!';
			REPLY= EDIT= SKIP_SH_HIST=;
			;;
		[/!]sh*)
			set -- "${*##[/!]@(shell|sh)*([:$IFS])}"
			if [[ -n $1 ]]
			then 	bash -i -c "${1%%;}; exit"
			else 	bash -i
			fi  </dev/tty  >&2;  #>/dev/tty
			;;
		shell*|sh*)
			case "$*" in shell:*|sh:*) 	append=1;; esac;  #append as user
			set -- "${*##@(shell|sh)*([:$IFS])}";
			[[ -n $* ]] || set --; xskip=1;
			while :
			do 	trap 'trap "-" INT' INT;  #disable trap for one <CRTL-C>#
				var=$(trap "-" INT; bash --norc --noprofile ${@:+-c} "${@}" </dev/tty | tee $STDERR);
				RET=$?; ((RET)) && _warmsgf "ret code:" "$RET";
				trap "exit" INT;

				#return on empty or signal
				if ((!${#var} || RET))
				then 	((RET)) || RET=1; SKIP=1 EDIT=1;
					_warmsgf "cmd dump:" "(empty)"; return 0;
				else 	REPLY=$var var=;
				fi; printf '\n---\n\n' >&2;

				_sysmsgf 'Edit buffer?' '[N]o, [y]es, te[x]t editor, [s]hell, or [r]edo ' ''
				((OPTV>2)) && { 	printf '%s\n' 'n' >&2; break ;}
				case "$(NO_CLR=1 read_charf)" in
					[Q]) 	RET=202; exit 202;;  #exit
					[AaqRr]) 	SKIP=1 EDIT=1 RET=200 REPLY="!${args[*]}";
		  					REPLY_CMD_DUMP= REPLY_CMD_BLOCK= SKIP_SH_HIST= WSKIP= SKIP=;  #E#
							break;;  #abort, redo
					[EeYy]|$'\e') 	SKIP=1 EDIT=1 RET=199; break;; #yes, bash `read`
					[VvXx]|$'\t'|' ') 	SKIP=1 EDIT=1 RET=198; ((OPTX)) || OPTX=2; break;; #yes, text editor
					[NnOo]|[!Ss]|'') 	SKIP=1 PSKIP=1; break;;  #no need to edit
				esac; set --;
			done; _clr_lineupf $((12+1+47));  #!#

			((append)) && [[ $REPLY != [/!]* ]] && REPLY=:$REPLY;
			shell_histf "!${HARGS[*]:-${args[*]}}"; SKIP_SH_HIST=1 HARGS=;
			((RET==200)) || REPLY_CMD_BLOCK=1;
			;;
		[/!]session*|session*|list*|copy*|cp\ *|fork*|sub*|grep*|[/!][Ss]*|[Ss]*|[/!][cf]\ *|[cf]\ *|ls*|.)
			echo Session and History >&2; [[ $* = . ]] && args=('fork current');
			session_mainf /"${args[@]}"
			;;
		photo*)
			set -- "$(trim_leadf "$*" "photo$SPC")";
			if [[ -n $TERMUX_VERSION ]]
			then
				case "${1:0:2}" in [0-9]|[0-9][!0-9]) 	typeset INDEX=${1:0:1}; set -- "${1:1}";; esac;

				while var=${OUTDIR%/}/camera_photo${n:+_}${n}.jpg
					[[ -e "$var" ]]
				do 	((++n));
				done

				if termux-camera-photo ${INDEX:+-c ${INDEX:-0}} "$var"
				then
					# Resize and rotate image if necessary
					if command -v "magick" >/dev/null 2>&1;
					then
					  typeset var2 size
					  #var2=${var%.*}s.${var##*.}  #shrink
					  size=($(magick identify -format "%w %h" "$var"))
					  _sysmsgf "Camera Raw:" "$(printf '%dx%d' "${size[@]}")  $(duf "$var")";
					  
					  #((size[0]>2048 || size[1]>2048)) && ((size[0]!=size[1])) && 
					  #magick "$var" -auto-orient -resize '2048x2048>' "$var2" >&2;
					  #
					  #[[ -s $var2 ]] && var=$var2 size=($(magick identify -format "%w %h" "$var2"));
					  #
					  #((size[0]<size[1] ? size[0]>768 : size[1]>768)) &&
					  #magick "$var" -auto-orient -resize '768x768^' "$var2" >&2;

					  #[[ -s $var2 ]] && var=$var2 ||
					  magick mogrify -auto-orient "$var" >&2;
					  #https://platform.openai.com/docs/guides/vision/calculating-costs
					elif command -v "exiftran" >/dev/null 2>&1;
					then
					  exiftran -ai "$var" >&2;
					fi
					REPLY="${1}${1:+ }${var}";
					_sysmsgf "$(duf "$var")" >&2; :;
				else
					false;
				fi || _warmsgf 'Err:' 'Photo camera';
			else 	cmd_runf /pick "$*"; return;
			fi;
			SKIP=1 EDIT=1 xskip=1;
			;;
		[/!]photo*)
			INDEX=1 cmd_runf "$*"; return;
			;;
		pick*|p*)
			set -- "$(trim_leadf "$*" "@(pick|p)$SPC")";
			trap "trap 'exit' INT; echo >&2;" INT;

			if [[ -d $1 ]]
			then 	var=$(trap '-' INT; _file_pickf "$1");
				((${#var})) && REPLY="$var";
			else 	var=$(trap '-' INT; _file_pickf "$PWD");
				((${#var})) && REPLY="${1}${1:+ }${var}";
			fi && unset TIPS_DIALOG || _warmsgf 'Err:' 'Filepicker';
			
			trap 'exit' INT;
			SKIP=1 EDIT=1 xskip=1;
			;;
		r|rr|''|[/!]|regen|[/!]regen|[$IFS])  #regenerate last response / retry
			SKIP=1 EDIT=1 SKIP_SH_HIST=1;
			case "$*" in
				rr|[/!]*) REGEN=2;;  #edit prompt
				*)
				    if test_cmplsf
				    then  _p_linerf "$REPLY_OLD";
				    elif ((REGEN==1)) && ((!OPTV))
				    then  printf '\n%s\n' '--- regenerate ---' >&2;
				    fi;
				    REGEN=1 REPLY= ;;
			esac
			if ((!BAD_RES)) && [[ -s "$FILECHAT" ]] &&
			[[ "$(tail -n 2 "$FILECHAT")"$'\n' != *[Bb][Rr][Ee][Aa][Kk]*([$' \t'])$'\n'* ]]
			then 	# comment out two lines from tail
				wc=$(wc -l <"$FILECHAT") && ((wc>2)) \
				&& sed -i -e "$((wc-1)),${wc} s/^/#/" "$FILECHAT";
				CKSUM_OLD=;
			fi
			;;
		replay|rep)
			if ((${#REPLAY_FILES[@]})) || [[ -f $FILEOUT_TTS ]]
			then 	for var in "${REPLAY_FILES[@]:-$FILEOUT_TTS}"
				do 	[[ -f $var ]] || continue
					du -h "$var" >&2 2>/dev/null;
					[[ -n $TERMUX_VERSION ]] && set_termuxpulsef;
					${PLAY_CMD} "$var" >&2 & pid=$! PIDS+=($!);
					trap "trap 'exit' INT; kill -- $pid 2>/dev/null;" INT;
					wait $pid;
				done;
				trap 'exit' INT;
			else 	_warmsgf 'Err:' 'No TTS audio file to play'
			fi
			;;
		res|resub|resubmit)
			RESUBW=1 SKIP=1 WSKIP=1;
			;;
		dialog|no-dialog)
			((++NO_DIALOG)) ;((NO_DIALOG%=2))
			cmdmsgf 'Dialog' $(_onoff $( ((NO_DIALOG)) && echo 0 || echo 1) )
			;;
		q|quit|exit|bye)
			send_tiktokenf '/END_TIKTOKEN/' && wait
			echo '[bye]' >&2; exit 0
			;;
		*) 	return 181;  #illegal command
			;;
	esac;
	((OPTEXIT>1)) && exit;
	{ ((OPTCMPL)) && typeset Q_TYPE; [[ ${RESTART-$Q_TYPE} != @($'\n'|\\n)* ]] && echo >&2 ;}  #newline
	if ((OPTX && REGEN<1 && !xskip)) 
	then 	printf "\\r${BWHITE}${ON_CYAN}%s\\a${NC}" ' * Press Enter to Continue * ' >&2;
		read_charf >/dev/null;
	fi;
       	return 0;
}

#print msg to stderr
#usage: _sysmsgf [string_one] [string_two] ['']
function _sysmsgf
{
	printf "${BWHITE}%s${NC}${Color200}${2:+ }%s${NC}${3-\\n}" "$1" "$2" >&2
}
function sysmsgf
{
	((OPTV>1)) && return
	_sysmsgf "$@"
}

function _warmsgf
{
	BWHITE="${RED}" Color200="${Color200:-${RED}}" \
	_sysmsgf "$@"
}

#command feedback
function _cmdmsgf
{
	BWHITE="${WHITE}" Color200="${CYAN}" \
	_sysmsgf "$(printf '%-14s' "$1")" "=> ${2:-unset}"
}
function cmdmsgf
{
	((OPTV>1)) && return
	_cmdmsgf "$@"
}
function _onoff
{
	((${1:-0})) && echo ON || echo OFF
}

#check if buffer file is open and set another one
function set_filetxtf
{
	typeset n;
	while [[ $(ps a) = *"${VISUAL:-${EDITOR:-vim}}"[\ ]"$FILETXT"* ]] && ((n<32))
	do 	((++n)); FILETXT=${FILETXT%%[0-9]}${n};
	done;
}

#main plain text editor
function _edf
{
	${VISUAL:-${EDITOR:-vim}} "$1" </dev/tty >/dev/tty
}

#text editor stdout wrapper
function ed_outf
{
	set_filetxtf
	printf "%s${*:+\\n}" "${*}" > "$FILETXT"
	_edf "$FILETXT" &&
	cat -- "$FILETXT"
}

#text editor chat wrapper
function edf
{
	typeset ed_msg pre rest pos ind sub inst instruction prev reply
	ed_msg=",,,,,,(edit below this line),,,,,,"
	((OPTC)) && rest="${RESTART-$Q_TYPE}" || rest="${RESTART}"
	rest="$(_unescapef "$rest")"
	instruction=${GINSTRUCTION:-${INSTRUCTION:-${ANTHROPICAI:+$INSTRUCTION_OLD}}};

	if ((CHAT_ENV)) && ((MTURN+OPTRESUME))  #G#
	then 	MAIN_LOOP=1 Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" MOD= \
		  OLLAMA= TKN_PREV= MAX_PREV= set_histf "${rest}${*}"
	fi

	set_filetxtf
	pre="${instruction}${instruction:+$'\n\n'}""$(unescapef "$HIST")"

	if ((${#instruction}==${#pre}-2)) || ((${#INSTRUCTION_OLD}==${#pre}-2)) ||
	   ((CHAT_ENV && MTURN+OPTRESUME && HIST_LOOP==1))  #G#
	then 	inst=1 &&  #instruction editing on
		ed_msg=",,,,,,(edit ABOVE AND BELOW this line),,,,,,"
	fi

	((OPTCMPL)) || [[ $pre != *[!$IFS]* ]] || pre="${pre}"$'\n\n'"${ed_msg}"
	if ((OPTE>1))
	then 	printf "%s\\n" "${1:+${NL}${NL}}${*}" >> "$FILETXT"; OPTE= pre= ;  #dont clear buffer
	else 	printf "%s\\n" "${pre}${pre:+${NL}${NL}}${rest}${*}" > "$FILETXT";
	fi

	_edf "$FILETXT"

	while [[ -f $FILETXT ]] && pos="$(<"$FILETXT")"
		
		if ((inst)) && [[ "$pos" != "${pre}"* ]]
		then 	inst= ;  #instruction editing
			prev=$(sed -n "1,/${ed_msg}/ p" <<<"${pos}");
			instruction=$(sed "/${ed_msg}/ d" <<<"${prev}");
		    ((${#prev}==${#instruction})) || {  #skip?

			pre=$prev instruction=$(trimf "$instruction" "$SPC");
			if ((${#instruction}))
			then 	if ((GOOGLEAI))
				then 	GINSTRUCTION="$instruction" INSTRUCTION=;
				else 	INSTRUCTION="$instruction";
				fi; INSTRUCTION_OLD="$instruction"
			fi
 			((HIST_LOOP==1)) && OPTX= cmd_runf /break
		    }
		fi
		[[ "$pos" != "${pre}"* ]] || [[ "$pos" = *"${rest:-%#%#}" ]]
	do 	_warmsgf "Bad edit:" "[E]dit, [c]ontinue, [/]cmd, [r]edo or [a]bort? " ''
		reply=$(read_charf)
		case "$reply" in
			[-/!]) read_mainf -i "$reply" reply;
				cmd_runf "$reply"; _edf "$FILETXT";;  #cmd
			[AQ]) echo '[bye]' >&2; return 202;;  #exit
			[aq]) echo '[abort]' >&2; return 201;;  #abort
			[CcNn]) break;;      #continue
			[Rr])  return 200;;  #redo
			[Ee]|$'\e'|*) _edf "$FILETXT";;  #edit
		esac
	done; printf '\n---\n\n' >&2;

	ind=320 sub="${pos:${#pre}:${ind}}"
	if ((OPTCMPL))
	then 	((${#rest})) &&
		sub="${sub##$SPC"${rest}"}"
	else 	sub="${sub##?($SPC"${rest%%$SPC}")$SPC}"
	fi
	pos="${sub}${pos:$((${#pre}+${ind}))}"

	printf "%s\\n" "$pos" > "$FILETXT"

	if ((CHAT_ENV)) && cmd_runf "$pos"
	then 	return 200;
	fi
}

#readline edit command line in text editor without executing it
function _edit_no_execf
{
	set_filetxtf;
	printf '%s\n' "$READLINE_LINE" >"$FILETXT";
	if _edf "$FILETXT" && [[ -s $FILETXT ]]
	then 	READLINE_LINE=$(<"$FILETXT");
		READLINE_POINT=${#READLINE_LINE};
		printf "${BCYAN}" >&2;
	fi;
}
#https://superuser.com/questions/1601543/ctrl-x-e-without-executing-command-immediately

#(un)escape from/to json (bash truncates input on \000)
function _escapef
{
	sed -e 's/\\/\\\\/g; s/$/\\n/' -e '$s/\\n$//'  \
	    -e 's/\r/\\r/g; s/\t/\\t/g; s/"/\\"/g;'  \
	    -e $'s/\a/\\\\a/g; s/\f/\\\\f/g; s/\b/\\\\b/g;'  \
	    -e $'s/\v/\\\\v/g; s/\e/\\\\u001b/g; s/[\03\04]//g;' <<<"$*" \
	| tr -d '\n\000'
}  #fallback
function _unescapef { 	printf -- '%b' "$*" ;}  #fallback

function unescapef {
	((${#1})) || return
	jq -Rr '"\"" + . + "\"" | fromjson' <<<"$*" || ! _unescapef "$*"
}
function escapef {
	((${#1})) || return
	printf '%s' "$*" | jq -Rrs 'tojson[1:-1]' || ! _escapef "$*"
}
# json special chars: \" \/ b f n r t \\uHEX
# characters from U+0000 through U+001F must be escaped

function _break_sessionf
{
	[[ -f "$FILECHAT" ]] || return; typeset tail;
	
	tail=$(tail -n 20 -- "$FILECHAT") || return;
	((${#tail}>2048)) && tail=${tail:${#tail} -2048};
	
	[[ BREAK${tail} = *[Bb][Rr][Ee][Aa][Kk]*([$IFS]) ]] \
	|| printf '%s%s\n' "$1" 'SESSION BREAK' >> "$FILECHAT";
}
function break_sessionf
{
	BREAK_SET=1;
	_sysmsgf 'SESSION BREAK';
}

#fix: remove session break
function fix_breakf
{
	[[ $(tail -n 1 "$1" 2>/dev/null) = *[Bb][Rr][Ee][Aa][Kk]*([$' \t']) ]] &&
	  sed -i -e '$d' "$1" && _sysmsgf 'Session Break Removed';
}

#fix variable value, add zero before/after dot.
function fix_dotf
{
	eval "[[ \$$1 = [0-9.] ]] || return"
	eval "[[ \$$1 = .[0-9]* ]] && $1=0\$${1}"
	eval "[[ \$$1 = *[0-9]. ]] && $1=\${${1}}0"
}

#minify json
function json_minif
{
	typeset blk;
	if [[ ${BLOCK:0:32} = @* ]]
	then 	blk=$(jq -c . "${BLOCK##@}") || return
		printf '%s\n' "$blk" >"${BLOCK##@}"
	else 	blk=$(jq -c . <<<"$BLOCK") || return
		BLOCK="${blk:-$BLOCK}"
	fi
}

#format for chat completions endpoint
#usage: fmt_ccf [prompt] [role]
function fmt_ccf
{
	typeset var
	typeset -l ext
	typeset -a settings
	settings=();
	[[ ${1} = *[!$IFS]* ]] || ((${#MEDIA[@]}+${#MEDIA_CMD[@]})) || return

	if ! ((${#MEDIA[@]}+${#MEDIA_CMD[@]}))
	then
		((ANTHROPICAI)) && [[ $2 = system ]] && return 1;

		case "$MOD" in o[1-9]*)
			_fmt_cc_reasonf;;  #settings[]
		esac;
		if ((${#settings[@]}))
		then
			printf '{"role": "%s", "content": "%s", "settings": { %s } }\n' "${2:-user}" "$1" "${settings[*]}";
		else
			printf '{"role": "%s", "content": "%s"}\n' "${2:-user}" "$1";
		fi;
	elif ((OLLAMA))
	then
		printf '{"role": "%s", "content": "%s",\n' "${2:-user}" "$1";
		ollama_mediaf && printf '%s' ' }'
	elif is_visionf "$MOD" || is_amodelf "$MOD"
	then
		case "$MOD" in o[1-9]*)
			_fmt_cc_reasonf;;  #settings[]
		esac;
		if ((${#settings[@]}))
		then
			printf '{ "role": "%s", "settings": { %s }, "content": [ ' "${2:-user}" "${settings[*]}";
		else
			printf '{ "role": "%s", "content": [ ' "${2:-user}";
		fi;

		((${#1})) &&
		printf '{ "type": "text", "text": "%s" }' "$1";
		for var in "${MEDIA[@]}" "${MEDIA_CMD[@]}"
		do
			case "$var" in \~\/*) 	var="$HOME/${var:2}";; esac;
			if [[ $var != *[!$IFS]* ]]
			then 	continue;
			elif [[ -s $var ]] && is_audiof "$var"
			then 	ext=${var##*.};
				((${#ext}<7)) || ext=;
				case "$ext" in mp3|opus|aac|flac|wav|pcm16) :;;
					*)  _warmsgf 'Warning:' "Filetype may be unsupported -- ${ext:-extension_err}" ;;
				esac
				((${#1})) && printf ',';
				printf '\n{ "type": "input_audio", "input_audio": { "data": "%s", "format": "%s" } }' "$(base64 "$var" | tr -d $'\n')" "${ext:-mp3}" ;
			elif [[ -s $var ]]
			then 	ext=${var##*.} ext=${ext/[Jj][Pp][Gg]/jpeg};
				((${#ext}<7)) || ext=;
				case "$ext" in jpeg|png|gif|webp) :;;  #20MB per image
					*)  _warmsgf 'Warning:' "Filetype may be unsupported -- ${ext:-extension_err}" ;;
				esac
				((${#1})) && printf ',';
				if ((ANTHROPICAI))
				then
				  printf '\n{ "type": "image", "source": { "type": "base64", "media_type": "image/%s", "data": "%s" } }' "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
				else
				  printf '\n{ "type": "image_url", "image_url": { "url": "data:image/%s;base64,%s" } }' "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
				  #groq: detail  string  Optional  #groq: image URL or base64
				fi
			else  #img url
				((ANTHROPICAI)) || {  #mistral groq
				  ((${#1})) && printf ',';
				  printf '\n{ "type": "image_url", "image_url": { "url": "%s" } }' "$var";
				};
			fi
		done;
		printf '%s\n' ' ] }';
	fi
}
#prepare the settings array (reasoning models, possibly gpt-5).
function _fmt_cc_reasonf
{
	typeset var;
	settings=();

	((${REASON_INTERACTIVE:+1})) && settings=("${settings[@]}" '"interactive": '"${REASON_INTERACTIVE:-true}");

	if ((${#settings[@]}>1))
	then
		for var in "${settings[@]}"
		do
			set -- "$@" "${var},";
		done;

		settings=("${@:1:${#} -1}" "${var}");
	fi
}

#remove implicit refs .. and .
#ex: a/b/../img.gif -> a/img.gif
function rmimpf
{
	sed -E  -e 's|[^/]+/\.\./|| ;s|^\./|| ;s|/\./|/|' \
		-e 's|[^/]+/\.\./|| ;s|^\./|| ;s|/\./|/|' \
		-e 's|[^/]+/\.\./|| ;s|^\./|| ;s|/\./|/|' #3x
}

# file picker
function _file_pickf
{
	typeset file
	file=${1:-${PWD:-$HOME}}/
	
	__set_fpick;

	case "$file" in
		\~\/*) 	file="$HOME/${file:2}";
		;;
		[!/]*) 	[[ -e $PWD/$file ]] && file="$PWD/$file";
		;;
	esac;

	while file=$(__fpick "$file")
		case $? in
		2) 	typeset TIPS_DIALOG;
			continue;
			;;
		1) 	__clr_dialogf;
			_sysmsgf "No file selected";
			return 1;
			;;
		-1|5|128|130|255) __clr_dialogf;
			_warmsgf "An unexpected error has occurred";
			return 1;
			;;
		esac;
	do 	typeset TIPS_DIALOG;
		[[ -d ${file:-$PWD} ]] || [[ ! -f $file ]] || break;
	done;
	__clr_dialogf;

	printf '%q' "$file";
}
function __set_fpick
{
	typeset cmd
	declare -f "__fpick" >/dev/null 2>&1 && return;

	((NO_DIALOG)) || {
	  ((${#DISPLAY})) && set -- "$@" kdialog zenity osascript;
	  ((${#TERMUX_VERSION})) && set -- "$@" termux-dialog  ;}
	for cmd in "$@" vifm ranger nnn dialog
	do 	command -v "$cmd" >/dev/null 2>&1 && break;
	done;
	case "$cmd" in 	dialog) DIALOG_CLR=1;; esac;

	eval "function __fpick { _${cmd}_pickf \"\$@\" ;}"  #_dialog_pickf
}

function _dialog_pickf
{
	((${#TIPS_DIALOG})) && dialog --colors --timeout 3 --backtitle "File Picker Tips" --begin 3 2 --msgbox "$TIPS_DIALOG" 14 40  >/dev/tty;
	dialog --help-button --backtitle "File Picker" --title "File Select" --fselect "$1" 24 80  2>&1 >/dev/tty;
	case $? in
		2) 	dialog --colors --backtitle "File Picker" --title "File Picker Help" --msgbox "$HELP_DIALOG" 24 56  2>&1 >/dev/tty;
			return 2;;
		*) 	return;;
	esac
	#-1:error, 1:cancel, 2:help, 3:extra, 5:timeout, 255:ESC
}
#whiptail warp
function whiptailf
{
	typeset arg args; args=();
	for arg  #option check
	do 	case "$arg" in
		    [!-]*|-1|--backtitle|-button|--checklist|--clear|\
		    --defaultno|--fb|--gauge|-height|--infobox|\
		    --inputbox|-key|--menu|--msgbox|--nocancel|\
		    --noitem|-options|--passwordbox|--radiolist|\
		    --scrolltext|-string|--title|--topleft|--yesno)
		        args=("${args[@]}" "${arg//\\Z[[:alnum:]]}");;
		    #*) echo "whiptail: ignore option -- $arg" >&2;;
		esac;
	done;
	whiptail "${args[@]}";
}
function test_dialogf
{
	((!NO_DIALOG)) || return; ((OK_DIALOG)) && return;
	if command -v dialog
	then 	OK_DIALOG=1;
	elif command -v whiptail
	then 	function dialog { 	whiptailf "$@" ;};
		OK_DIALOG=1;
	else 	false;
	fi >/dev/null 2>&1;
}

function _termux-dialog_pickf
{
	printf '%s/%s' "${1%%/}" "$(
		termux-dialog sheet -v"$(IFS=$'\t\n'; printf '%q,' .. $(_ls_pickf "$1") ..)." | jq -r .text;
	)" | rmimpf;
}
#{ termux-storage-get || am start -a android.intent.action.OPEN_DOCUMENT -d /storage/emulated/0 -t '*/*' ;}
#https://wiki.termux.com/wiki/Internal_and_external_storage
function _ls_pickf
{
	shopt -s nullglob; 
	cd "$1" || return;
	printf '%s\n' */;
	printf '%s\n' * |  __ls_pickf
	printf '%s\n' .*/;
	printf '%s\n' .* | __ls_pickf
}
function __ls_pickf
{
	typeset file
	while IFS= read -r file; do
	[[ -d $file ]] || [[ -L $file ]] || printf '%s\n' "$file"; done;
}
function _nnn_pickf { nnn -p - "$1" ;}
function _vifm_pickf { vifm --no-configs -c "set nosave" -c "only" -c "set mouse=a" --choose-files - "$1" ;}
function _ranger_pickf { : >"$FILEFIFO"; ranger -c --cmd="set mouse_enabled true" --choosefile="$FILEFIFO" "$1" >/dev/tty; cat -- "$FILEFIFO" ;}
function _kdialog_pickf { kdialog --getopenfilename "$1" 2>/dev/null ;}
function _zenity_pickf { zenity --file-selection --filename="$1" --title="Select a File" 2>/dev/null ;}
function _osascript_pickf { osascript -l JavaScript -e 'a=Application.currentApplication();a.includeStandardAdditions=true;a.chooseFile({withPrompt:"Please select a file:"}).toString()' ;}

TIPS_DIALOG='\n- \ZbNavigation:\ZB Use \ZbTAB\ZB, \ZbSHIFT-TAB\ZB and \ZbARROW KEYS\ZB.\n\n- \ZbSelect:\ZB Press \ZbSPACE-BAR\ZB.\n\n- \ZbMouse:\ZB \ZbCLICK\ZB to select and \ZbSPACE\ZB to complete.'
HELP_DIALOG='\n- \ZbMove:\ZB Use \ZbTAB\ZB, \ZbSHIFT+TAB\ZB, or \ZbARROW KEYS\ZB.\n\n- \ZbScroll:\ZB Use \ZbUP and DOWN\ZB arrow keys in lists.\n\n- \ZbSelect:\ZB Press \ZbSPACE\ZB to copy to text box.\n\n- \ZbAutocomplete:\ZB Type \ZbSPACE\ZB to complete names.\n\n- \ZbConfirm:\ZB Press \ZbENTER\ZB or click "\ZbOK\ZB".\n\n\n\ZuHappy browsing!\ZU'

#print entries with 1-9 indexes or '.' for dialog
function _dialog_optf 
{
	typeset i
	for ((i=0;i<${#};i++))
	do  printf "%q %s " "${@: i+1: 1}" "$( ((i<9)) && echo $((i + 1)) || echo .)";
	done
}

#check for pure text completions conditions, or insert mode with null suffix
function test_cmplsf
{
	((OPTCMPL && !OPTSUFFIX)) || ((OPTSUFFIX)) ||
	((!OPTCMPL && !OPTC && !MTURN && !OPTSUFFIX && EPN==0))
}

#set media for ollama *generation endpoint*
function ollama_mediaf
{
	typeset var n
	set -- "${MEDIA[@]}" "${MEDIA_CMD[@]}";
	[[ -n $* ]] || return;
	printf '\n"images": ['
	for var
	do 	((++n))
		if [[ $var != *[!$IFS]* ]]
		then 	continue;
		elif [[ -f $var ]] && [[ -s $var ]]
		then 	printf '"%s"' "$(base64 "$var" | tr -d $'\n')";
			((n < ${#})) && printf '%s' ',';
		fi
	done;
       	printf '%s' ']'
}

#process files and urls from input
#filenames with spaces must be blackslash-quoted
function media_pathf
{
	typeset var ind m n
	#process only the last line of input
	set -- "$(sed -e 's/\\n/\n/g; s/\\\\ /\\ /g; s/^[[:space:]|]*//; s/[[:space:]|]*$//; /^[[:space:]]*$/d' <<<"$*" | sed -n -e '$ p')";
	
	while [[ $1 = *[[:alnum:]]* ]] && ((m<128))
	do
		((++m)); var=;
		set -- "$(trim_leadf "$1" $'*([ \n\t\r|]|\\\\[ntr])')";
		if [[ -f $1 ]]
		then 	var=$1;
		else 	[[ $1 = *[\|]* ]]   && var=$(sed 's/^.*[|][[:space:]|]*//' <<<"$1");
			[[ -f ${var//\\} ]] || var=$(sed 's/^.*[^\\][[:space:]]//; s/^[[:space:]|]*//' <<<"$1");
		fi; ind=${#var};
		[[ $var = *\\* ]] && var=${var//\\};
		case "$var" in \~\/*) 	var="$HOME/${var:2}";; esac;

		#check if file or url and add to array (max 20MB)
		if is_imagef "$var" || { is_amodelf "$MOD" && is_audiof "$var" ;} ||
			{ ((!GOOGLEAI)) && is_linkf "$var" ;}
		then
			((++n));
			if ((CMD_CHAT))
			then 	MEDIA_CMD=("${MEDIA_CMD[@]}" "$var");
				MEDIA_CMD_IND=("${MEDIA_CMD_IND[@]}" "$var");
			else 	MEDIA=("$var" "${MEDIA[@]}");  #read by fmt_ccf()
				MEDIA_IND=("$var" "${MEDIA_IND[@]}");
			fi;
			
			((${#1}-ind < 0)) && { 	_warmsgf 'Err: media_pathf():' "negative index -- $((${#1}-ind))"; break ;}
			set -- "$(trim_trailf "${1: 0: ${#1}-ind}" $'*(\\[tnr]|[ \t\n\r|])')";
		else
			((OPTV>99)) || [[ $var = *[[\]\<\>{}\(\)*?=%\&^\$\#\ ]* ]] ||
			  [[ $var != *[[:alnum:]].[[:alnum:]]* ]] || [[ ${1:0:128} = "${var:0:128}" ]] || {
			  var="${var:0: COLUMNS-25}$([[ -n ${var: COLUMNS-25} ]] && printf '\b\b\b%s' ...)";
			  _warmsgf 'multimodal: invalid --' "\`\`${var//$'\t'/ }''";
			}

			break;
			#set -- "${1: 0: ${#1}-ind}";
		fi  #https://stackoverflow.com/questions/12199059/
	done; ((n));
}

function _is_linkf
{
	[[ ! -f $1 ]] || return;
	case "$1" in
		[Hh][Tt][Tt][Pp][Ss]://* | [Hh][Tt][Tt][Pp]://* | [Ff][Tt][Pp]://* | [Ff][Ii][Ll][Ee]://* | telnet://* | gopher://* | about://* | wais://* ) :;;
		*?.[Hh][Tt][Mm] | *?.[Hh][Tt][Mm][Ll] | *?.[A-Za-z][Hh][Tt][Mm][Ll] | *?.[Hh][Tt][Mm][Ll]? | *?.[Xx][Mm][Ll] | *?.com | *?.com/ | *?.com.[a-z][a-z] | *?.com.[a-z][a-z]/ ) :;;
		[Ww][Ww][Ww].?* ) :;;
		*) false;;
	esac
}
function is_linkf
{
	[[ ! -f $1 ]] || return;
	
	_is_linkf "$1" || [[ \ $LINK_CACHE\  = *\ "${1:-empty}"\ * ]] ||
	  case "$1" in
	  *[$IFS]*) false;;
	  *[[:alnum:]][-[:alnum:]]*.[[:alnum:]][-[:alnum:]]*|[0-9]*.[0-9]*.[0-9]*.[0-9]*)
	      [[ \ $LINK_CACHE_BAD\  != *\ "${1:-empty}"\ * ]] &&
	      if curl --output /dev/null --max-time 4 --silent --head --fail --location -H "$UAG" -- "$1" 2>/dev/null
	      then  LINK_CACHE="$LINK_CACHE $1";
	      else  ! LINK_CACHE_BAD="$LINK_CACHE_BAD $1";
	      fi;;
	  *) false;;
	  esac
}

function is_txtfilef
{
	[[ -f $1 ]] || return
	case "$1" in
        	*?.[Tt][Xx][Tt] | *?.[Mm][Dd] | *?.[Cc][Ff][Gg] | *?.[Ii][Nn][Ii] | *?.[Ll][Oo][Gg] | *?.[TtCc][Ss][Vv] | *?.[Jj][Ss][Oo][Nn] | *?.[Xx][Mm][Ll] | *?.[Cc][Oo][Nn][Ff] | *?.[Rr][Cc] | *?.[Yy][Aa][Mm][Ll] | *?.[Yy][Mm][Ll] | *?.[Hh][Tt][Mm][Ll] | *?.[Hh][Tt][Mm] | *?.[Ss][Hh] | *?.[CcZz][Ss][Hh] | *?.[Bb][Aa][Ss][Hh] | *?.[Pp][Yy] | *?.[Jj][Ss] | *?.[Cc][Ss][Ss] | *?.[Jj][Aa][Vv][Aa] | *?.[Rr][Bb] | *?.[Pp][Hh][Pp] | *?.[Tt][Cc][Ll] | *?.[Pp][LlSs] | *?.[Rr][Ss][Tt] | *?.[Tt][Ee][Xx] | *?.[Ss][Qq][Ll] | *?.[Ll][Oo][Gg] | *?.c | *.bashrc | *.bash_profile | *.profile | *.zshrc | *.zshenv ) return;;
	esac
	! _is_imagef "$@" && ! _is_videof "$@" &&
	! _is_audiof "$@" && ! (__set_outfmtf "$@") &&
	[[ "$(file -- "$1")" = *[Tt][Ee][Xx][Tt]* ]]
}

function _is_pdff
{
	case "$1" in
		*?.[Pp][Dd][Ff] | *?.[Pp][Dd][Ff]? ) :;;
		*) false;
	esac;
}
function is_pdff { 	[[ -f $1 ]] && _is_pdff "$1" ;}

function _is_imagef
{
	case "$1" in
		*?.[Pp][Nn][Gg] | *?.[Jj][Pp][Gg] | *?.[Jj][Pp][Ee][Gg] | *?.[Ww][Ee][Bb][Pp] | *?.[Gg][Ii][Ff] | *?.[Hh][Ee][Ii][CcFf] | *?.[Gg][Ii][Ff] ) :;;
		*) false;;
	esac;
}
function is_imagef { 	[[ -f $1 ]] && _is_imagef "$1" ;}

function _is_videof
{
	case "$1" in
		*?.[Mm][Oo][Vv] | *?.[Mm][Pp][Ee][Gg] | *?.[Mm][Pp][Gg4] | *?.[Aa][Vv][Ii] | *?.[Ww][Mm][Vv] | *?.[Ff][Ll][Vv] ) :;;
		*) false;;
	esac;
}
function is_videof { 	[[ -f $1 ]] && _is_videof "$1" ;}

function _is_audiof
{
	case "$1" in  #mp3..
		*?.[Mm][Pp][34] | *?.[Mm][Pp][Gg] | *?.[Mm][Pp][Ee][Gg] | *?.[Mm][Pp][Gg][Aa] | *?.[Mm]4[Aa] | *?.[Ww][Aa][Vv] | *?.[Ww][Ee][Bb][Mm] | *?.[Oo][Oo][Gg] | *?.[Ff][Ll][Aa][Cc] ) :;;
		*?.[Oo][Pp][Uu][Ss] | *?.[Aa][Aa][Cc] | *?.[Pp][Cc][Mm]16 | *?.[Pp][Cc][Mm] ) :;;
		*) false;;
	esac
}
function is_audiof { 	[[ -f $1 ]] && _is_audiof "$1" ;}

#test whether file is text, pdf file, or url and print out filepath
function is_txturl
{
	((${#1}>320)) && set -- "${1: ${#1}-320}"
	
	set -- "$1" "$(INDEX=64 trimf "$1" "$SPC")";
	if [[ -f ${2:-$1} ]]
	then 	set -- "${2:-$1}";
	else 	set -- "$(trim_leadf "$(trim_trailf "$1" "$SPC")" $'*[!\\\\][ \t\n]')";
		[[ ${1:0:1} = [$IFS] ]] && set -- "${1:1}";
	fi  #C#
	case "$1" in \~\/*) 	set -- "$HOME/${1:2}";; esac;

	[[ $1 = *\\* ]] && set -- "${1//\\}";  #path with spaces must be backslash-quoted
	is_txtfilef "$1" || is_pdff "$1" || is_docf "$1" ||
	{ _is_linkf "$1" && ! _is_imagef "$1" && ! _is_videof "$1" ;}
	((!${?})) && printf '%s' "$1";
}

#check for multimodal (vision) model
function is_visionf
{
	typeset -l model; model=${1##*/};
	case "${model##ft:}" in 
	*vision*|*pixtral*|*llava*|*cogvlm*|*cogagent*|*qwen*|*detic*|*codet*|*kosmos-2*|*fuyu*|*instructir*|*idefics*|*unival*|*glamm*|\
	gpt-4o*|gpt-[5-9]*|gpt-4-turbo|gpt-4-turbo-202[4-9]-[0-1][0-9]-[0-3][0-9]|\
	gemini*-1.[5-9]*|gemini*-[2-9].[0-9]*|*multimodal*|\
	claude-[3-9]*|llama[3-9][.-]*|llama-[3-9][.-]*|*mistral-7b*) :;;
	*) 	((MULTIMODAL));;
	esac;
}

#check for audio-model
function is_amodelf
{
	typeset -l model; model=${1##*/};
	case "${model##ft:}" in 
	*audio*|*speech*|*speaker*|*bark*|*lalm*|*music*|*yi-vl*) :;;
	*) 	((MULTIMODAL>1));;
	esac;
}

function is_mdf
{
	[[ "\\n$1" =~ (\
[*_][*_][[:alnum:]]|\
\\n\ *\`\`\`|\
\\n\#\#*\ |\
\\n\ \ *[*-]\ |\
\\n\ \ *[0-9IiVvXx][0-9IiVvXx]*\.\ |\
\[[^\]]*\]\([^\)]*\)) ]]
}

function _is_docf
{
	typeset -l ext=$1
	case "$ext" in
	*.doc|*.docx|*.odt|*.ott|*.rtf) :;; 
	*) false;;
	esac;
}
function is_docf { 	[[ -f $1 ]] && _is_docf "$1" ;}

# Filtro HTML
#https://ascii.cl/htmlcodes.htm
#https://www.freeformatter.com/html-entities.html
function sedhtmlf
{
	sed -E -e 's/\xc2\xa0/ /g ; s/&mdash;/--/g' -e 's/&quot;/"/g' -e "s/&apos;/'/g" \
	-e 's/&#32;/ /g ;s/&#33;/!/g ;s/&#34;/"/g ;s/&#35;/#/g ;s/&#36;/$/g' \
	-e 's/&#37;/%/g' -e "s/&#39;/'/g" -e 's/&#40;/(/g ;s/&#41;/)/g ;s/&#42;/*/g' \
	-e 's/&#43;/+/g ;s/&#44;/,/g ;s/&#45;/-/g ;s/&#46;/./g ;s/&#47;/\//g' \
	-e 's/&#58;/:/g ;s/&#59;/;/g ;s/&#61;/=/g ;s/&#63;/?/g ;s/&#64;/@/g' \
	-e 's/&#91;/[/g ;s/&#92;/\\/g ;s/&#93;/]/g ;s/&#94;/^/g ;s/&#95;/_/g' \
	-e 's/&#96;/`/g ;s/&#123;/{/g ;s/&#124;/|/g ;s/&#125;/}/g ;s/&#126;/~/g' \
	-e 's/(&amp;|&#38;)/\&/g ;s/(&lt;|&#60;)/</g ;s/(&gt;|&#62;)/>/g ;s/(&Agrave;|&#192;)/À/g' \
	-e 's/(&Aacute;|&#193;)/Á/g ;s/(&Acirc;|&#194;)/Â/g ;s/(&Atilde;|&#195;)/Ã/g ;s/(&Auml;|&#196;)/Ä/g' \
	-e 's/(&Aring;|&#197;)/Å/g ;s/(&AElig;|&#198;)/Æ/g ;s/(&Ccedil;|&#199;)/Ç/g ;s/(&Egrave;|&#200;)/È/g' \
	-e 's/(&Eacute;|&#201;)/É/g ;s/(&Ecirc;|&#202;)/Ê/g ;s/(&Euml;|&#203;)/Ë/g ;s/(&Igrave;|&#204;)/Ì/g' \
	-e 's/(&Iacute;|&#205;)/Í/g ;s/(&Icirc;|&#206;)/Î/g ;s/(&Iuml;|&#207;)/Ï/g ;s/(&ETH;|&#208;)/Ð/g' \
	-e 's/(&Ntilde;|&#209;)/Ñ/g ;s/(&Ograve;|&#210;)/Ò/g ;s/(&Oacute;|&#211;)/Ó/g ;s/(&Ocirc;|&#212;)/Ô/g' \
	-e 's/(&Otilde;|&#213;)/Õ/g ;s/(&Ouml;|&#214;)/Ö/g ;s/(&Oslash;|&#216;)/Ø/g ;s/(&Ugrave;|&#217;)/Ù/g' \
	-e 's/(&Uacute;|&#218;)/Ú/g ;s/(&Ucirc;|&#219;)/Û/g ;s/(&Uuml;|&#220;)/Ü/g ;s/(&Yacute;|&#221;)/Ý/g' \
	-e 's/(&THORN;|&#222;)/Þ/g ;s/(&szlig;|&#223;)/ß/g ;s/(&agrave;|&#224;)/à/g ;s/(&aacute;|&#225;)/á/g' \
	-e 's/(&acirc;|&#226;)/â/g ;s/(&atilde;|&#227;)/ã/g ;s/(&auml;|&#228;)/ä/g ;s/(&aring;|&#229;)/å/g' \
	-e 's/(&aelig;|&#230;)/æ/g ;s/(&ccedil;|&#231;)/ç/g ;s/(&egrave;|&#232;)/è/g ;s/(&eacute;|&#233;)/é/g' \
	-e 's/(&ecirc;|&#234;)/ê/g ;s/(&euml;|&#235;)/ë/g ;s/(&igrave;|&#236;)/ì/g ;s/(&iacute;|&#237;)/í/g' \
	-e 's/(&icirc;|&#238;)/î/g ;s/(&iuml;|&#239;)/ï/g ;s/(&eth;|&#240;)/ð/g ;s/(&ntilde;|&#241;)/ñ/g' \
	-e 's/(&ograve;|&#242;)/ò/g ;s/(&oacute;|&#243;)/ó/g ;s/(&ocirc;|&#244;)/ô/g ;s/(&otilde;|&#245;)/õ/g' \
	-e 's/(&ouml;|&#246;)/ö/g ;s/(&oslash;|&#248;)/ø/g ;s/(&ugrave;|&#249;)/ù/g ;s/(&uacute;|&#250;)/ú/g' \
	-e 's/(&ucirc;|&#251;)/û/g ;s/(&uuml;|&#252;)/ü/g ;s/(&yacute;|&#253;)/ý/g ;s/(&thorn;|&#254;)/þ/g' \
	-e 's/(&yuml;|&#255;)/ÿ/g ;s/(&#160;|&nbsp;)/ /g ;s/(&iexcl;|&#161;)/¡/g ;s/(&cent;|&#162;)/¢/g' \
	-e 's/(&pound;|&#163;)/£/g ;s/(&curren;|&#164;)/¤/g ;s/(&yen;|&#165;)/¥/g ;s/(&brvbar;|&#166;)/¦/g' \
	-e 's/(&sect;|&#167;)/§/g ;s/(&uml;|&#168;)/¨/g ;s/(&copy;|&#169;)/©/g ;s/(&ordf;|&#170;)/ª/g' \
	-e 's/(&laquo;|&#171;)/«/g ;s/(&not;|&#172;)/¬/g ;s/(&shy;|&#173;)/­/g ;s/(&reg;|&#174;)/®/g' \
	-e 's/(&macr;|&#175;)/¯/g ;s/(&deg;|&#176;)/°/g ;s/(&plusmn;|&#177;)/±/g ;s/(&sup2;|&#178;)/²/g' \
	-e 's/(&sup3;|&#179;)/³/g ;s/(&acute;|&#180;)/´/g ;s/(&micro;|&#181;)/µ/g ;s/(&para;|&#182;)/¶/g' \
	-e 's/(&cedil;|&#184;)/¸/g ;s/(&sup1;|&#185;)/¹/g ;s/(&ordm;|&#186;)/º/g ;s/(&raquo;|&#187;)/»/g' \
	-e 's/(&frac14;|&#188;)/¼/g ;s/(&frac12;|&#189;)/½/g ;s/(&frac34;|&#190;)/¾/g ;s/(&iquest;|&#191;)/¿/g' \
	-e 's/(&times;|&#215;)/×/g ;s/(&divide;|&#247;)/÷/g ;s/(&circ;|&#710;)/ˆ/g ;s/(&tilde;|&#732;)/˜/g' \
	-e 's/(&ensp;|&#8194;)/ /g ;s/(&emsp;|&#8195;)/ /g ;s/(&thinsp;|&#8201;)/ /g ;s/(&ndash;|&#8211;)/–/g' \
	-e 's/(&mdash;|&#8212;)/—/g ;s/(&lsquo;|&#8216;)/‘/g ;s/(&rsquo;|&#8217;)/’/g ;s/(&sbquo;|&#8218;)/‚/g' \
	-e 's/(&ldquo;|&#8220;)/“/g ;s/(&rdquo;|&#8221;)/”/g ;s/(&bdquo;|&#8222;)/„/g ;s/(&dagger;|&#8224;)/†/g' \
	-e 's/(&Dagger;|&#8225;)/‡/g ;s/(&bull;|&#8226;)/•/g ;s/(&hellip;|&#8230;)/…/g ;s/(&permil;|&#8240;)/‰/g' \
	-e 's/(&prime;|&#8242;)/′/g ;s/(&Prime;|&#8243;)/″/g ;s/(&lsaquo;|&#8249;)/‹/g ;s/(&rsaquo;|&#8250;)/›/g' \
	-e 's/(&oline;|&#8254;)/‾/g ;s/(&euro;|&#8364;)/€/g ;s/(&trade;|&#8482;)/™/g ;s/(&larr;|&#8592;)/←/g' \
	-e 's/(&uarr;|&#8593;)/↑/g ;s/(&rarr;|&#8594;)/→/g ;s/(&darr;|&#8595;)/↓/g ;s/(&harr;|&#8596;)/↔/g' \
	-e 's/(&crarr;|&#8629;)/↵/g';
}

#dump youtube video transcription
function yt_transf
{
	curl -Ls "$1" |
	grep -o '"baseUrl":"https://www.youtube.com/api/timedtext[^"]*' |
	cut -d \" -f4 |
	sed 's/\\u0026/\&/g' |
	xargs curl -Ls |
	grep -o '<text[^<]*</text>' |
	sed -E 's/<text start="([^"]*)".*>(.*)<.*/\1 \2/' |
	sed 's/\xc2\xa0/ /g;s/&amp;/\&/g' |
	{ sedhtmlf || cat ;} |
	awk '{$1=sprintf("%02d:%02d:%02d",$1/3600,$1%3600/60,$1%60)}1' |
	awk 'NR%n==1{printf"%s ",$1}{sub(/^[^ ]* /,"");printf"%s"(NR%n?FS:RS),$0}' n=2 |
	awk 1 | sed 's/^00://';
}
#https://stackoverflow.com/questions/9611397

#dump youtube video description
function yt_descf
{
	curl -Ls "$1" | grep -o -e '"videoDetails":{[^}]*}' | grep -oe '":"[^"]*"' | { sedhtmlf || cat ;};
}
#"shortDescription",'eow-description'
#https://stackoverflow.com/questions/72354649/
#https://stackoverflow.com/questions/76876281/

function vimeo_transf
{
	typeset browser url
	
	if browser=$(set_jbrowsercmdf)
	then
		url=$( ${browser} "${*}" |
		  grep -o -e 'src="/texttrack[^"]*.[sv][rt][t][^"]*"' | sed 's/^[^"]*"//; s/"$//' );

		((${#url})) && curl -Ls "https://player.vimeo.com${url%%${IFS}*}";
	else
		! _warmsgf 'Err:' 'Transcription dump requires JavaScript-capable cli-browser';
	fi;
}
#https://developer.vimeo.com/api/reference/videos#get_transcript_metadata

function vimeo_descf
{
	curl -Ls -H "$UAG" -H 'x-requested-with: XMLHttpRequest' "https://vimeo.com/api/oembed.json?url=${*}" | jq .;
}

#alternative to du
function duf
{
	typeset s x u y
	wc -c -- "$@" | while read x y
	  do  if ((x>1024*1224))
	      then 	x=$(bc <<<"scale=3; $x/1024/1024") s=2 u=MB;
	      elif ((x>1024*5))
	      then 	x=$(bc <<<"scale=2; $x/1024") s=1 u=KB;
	      else 	s=0 u=B;
	      fi
	      printf "%'.*f %s  %s\\n" "$s" "$x" "$u" "$y";
	  done;
}

#create user log
function usr_logf
{
	printf '%s  Tokens: %s\n\n%s\n' \
	"${HIST_TIME:-$(date -R 2>/dev/null||date)}" "${MAX_PREV:-?}" "$*"
}

#wrap text at spaces rather than mid-word
function foldf
{
	if ((!OPTFOLD)) || ((COLUMNS<18)) || [[ ! -t 1 ]]
	then 	cat
	else 	typeset REPLY r x n text result

		while IFS= read -r -d ' ' && REPLY=$REPLY' ' || ((${#REPLY}))
		do
			r=$REPLY;
			r=${r//$'\t'/        };  #fix for tabs

			((OPTK)) || {  #delete ansi codes
			  text="$r" result=""
			  while [[ "$text" = *$'\e'*[mG]* ]]
			  do
			    result="${result}${text%%$'\e'*}"
			    text="${text#*$'\e'*[mGa-zA-Z]}"
			  done
			  r="${result}${text}"
			}
			
			[[ $r = *$'\n'* ]] && x=${r##*$'\n'} r=${r%%$'\n'*};

			if (( ${#r}>COLUMNS ))  #REPLY alone is bigger than COLUMNS
			then
				((n = ( (n+${#r})%COLUMNS + COLUMNS)%COLUMNS )); r= ;
				#modulus as (a%b + b)%b to avoid negative remainder.
				printf '%s' "$REPLY";
			elif (( n+${#r}>COLUMNS ))
			then
				n= ;
				printf '\n%s' "$REPLY";
			else
				(( n+${#r}==COLUMNS )) && r= n= ;
				printf '%s' "$REPLY";
			fi
			((n += ${#r}));
			((${#x})) && n=${#x} x= ;
		done
	fi; return 0;
}

#check if a value is within a fp range
#usage: check_optrangef [val] [min] [max]
function check_optrangef
{
	typeset val min max prop ret
	val="${1:-0}" min="${2:-0}" max="${3:-0}" prop="${4:-property}"

	ret=$(bc <<<"($val < $min) || ($val > $max)") || function check_optrangef { : ;}  #no-`bc' systems
	if [[ $val = *[!0-9.,+-]* ]] || ((ret))
	then 	printf "${RED}Warning: Bad %s${NC}${BRED} -- %s  ${NC}${YELLOW}(%s - %s)${NC}\\n" "$prop" "$val" "$min" "$max" >&2
		return 1
	fi ;return ${ret:-0}
}

#check and set settings
function set_optsf
{
	typeset s n p stop
	typeset -a pids

	case "$MOD" in
		gemini-2*-thinking*)
		((MOD_THINK)) || {
			((OPTMM<1024*4 && OPTMAX<1024*5)) && {
				_warmsgf 'Warning:' 'Thinking may require large numbers of output tokens';
				OPTMAX=6000;
			}
			MOD_THINK=1;
			#32k input, 8k output limits; Text and image in, Text out only
			#For .thought parameter, set "v1alpha version"
			#stream the thinking, use generate_content_stream method
			#https://ai.google.dev/gemini-api/docs/thinking-mode
		}
		;;
		o[1-9]*|o1-mini*|o1-mini-2024-09-12|o1-preview*|o1-preview-2024-09-12)
		((MOD_REASON)) || {
			((OPTMM<1024*4 && OPTMAX<1024*5)) && {
				_warmsgf 'Warning:' 'Reasoning requires large numbers of output tokens';
				OPTMAX_REASON=$OPTMAX OPTMAX=25000;
			}
			case "$MOD" in o1-mini*|o1-mini-2024-09-12|o1-preview*|o1-preview-2024-09-12)
			  ((${#INSTRUCTION_CHAT}+${#INSTRUCTION})) && _warmsgf 'Warning:' 'Reasoning models do not support system messages yet';
			  INSTRUCTION_CHAT_REASON=$INSTRUCTION_CHAT INSTRUCTION_REASON=$INSTRUCTION;;
			esac;
			[[ -n $OPTA || -n $OPTAA ]] && _warmsgf 'Warning:' 'Resetting frequency and presence penalties';
			OPTA_REASON=$OPTA OPTAA_REASON=$OPTAA OPTT_REASON=$OPTT;
			OPTA= OPTAA= OPTT=1 MOD_REASON=1 CURLTIMEOUT="--max-time 900" INSTRUCTION_CHAT= INSTRUCTION=;
			#https://platform.openai.com/docs/guides/reasoning#beta-limitations
		}
		case "$REASON_INTERACTIVE" in
			true|[1-9]*) 	REASON_INTERACTIVE=true;;
			false|[00]*) 	REASON_INTERACTIVE=false;;
		esac;
		case "$REASON_EFFORT" in
			high|medium|low|'') 	:;;
			*) 	_warmsgf 'Warning:' "reason_effort must be high, medium or low -- $REASON_EFFORT";
			;;
		esac;
		;;
		llama-3.2*-vision-preview|llava-v1.5-7b-4096-preview)  #groq vision
		INSTRUCTION_CHAT= INSTRUCTION=;
		;;
		*) ((MOD_REASON)) && {
			case "$MOD" in o1-mini*|o1-mini-2024-09-12|o1-preview*|o1-preview-2024-09-12)
			  INSTRUCTION_CHAT=$INSTRUCTION_CHAT_REASON INSTRUCTION=$INSTRUCTION_REASON;;
			esac;
			OPTA=$OPTA_REASON OPTAA=$OPTAA_REASON OPTT=$OPTT_REASON OPTMAX=${OPTMAX_REASON:-$OPTMAX} MOD_REASON= CURLTIMEOUT=;
		}
		((MOD_THINK)) && {
			MOD_THINK=;
		}
		;;
	esac
	((GITHUBAI)) && [[ $OPTA$OPTAA = *[1-9]* ]] &&
	case "$MOD" in
		Mistral-*|AI21-Jamba*)
		_warmsgf 'Warning:' 'model may not support frequency_ and/or presence_penalty';
		OPTA= OPTAA=;
		;;
	esac;

	((OPTI+OPTEMBED)) || {
	  ((OPTW+OPTZ && !CHAT_ENV)) || {
	    check_optrangef "$OPTA"   -2.0 2.0 'Presence-penalty'
	    check_optrangef "$OPTAA"  -2.0 2.0 'Frequency-penalty'
	    ((OPTB)) && check_optrangef "${OPTB:-$OPTN}"  "$OPTN" 50 'Best_of'
	    check_optrangef "$OPTBB" 0   5 'Logprobs'

	    check_optrangef "$OPTP"  0.0 1.0 'Top_p'
	    ((!OPTMAX && OPTBB)) ||
	    check_optrangef "$OPTMAX"  1 "$MODMAX" 'Response Max Tokens'
	  }
	  check_optrangef "$OPTT"  0.0 $( ((MISTRALAI+ANTHROPICAI)) && echo 1.0 || echo 2.0) 'Temperature'  #whisper 0.0 - 1.0
	  #change temp or top_p but not both
	}
	((OPTI)) && check_optrangef "$OPTN"  1 10 'Number of Results'
	case "$OPTSEED" in *[!0-9]*)
	  printf "${RED}Warning: Bad %s${NC}${BRED} -- %s  ${NC}${YELLOW}(integer)${NC}\\n" "seed" "$OPTSEED" >&2;;
	esac

	[[ -n $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA," || unset OPTA_OPT
	[[ -n $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA," || unset OPTAA_OPT
	{ ((OPTB)) && OPTB_OPT="\"best_of\": $OPTB," || unset OPTB OPTB_OPT;
	  ((OPTBB)) && OPTBB_OPT="\"logprobs\": $OPTBB," || unset OPTBB OPTBB_OPT; } 2>/dev/null
	[[ -n $OPTP ]] && OPTP_OPT="\"top_p\": $OPTP," || unset OPTP_OPT
	[[ -n $OPTKK ]] && OPTKK_OPT="\"top_k\": $OPTKK," || unset OPTKK_OPT
	if ((OPTSUFFIX+${#SUFFIX})); then 	OPTSUFFIX_OPT="\"suffix\": \"$(escapef "$SUFFIX")\","; else 	unset OPTSUFFIX_OPT; fi;
	if [[ -n $OPTSEED ]]
	then #seed  integer or null: openai, groq, ollama.
	  OPTSEED_OPT="\"${MISTRALAI:+random_}seed\": $OPTSEED," || unset OPTSEED
	fi
	if ((STREAM))
	then 	STREAM_OPT="\"stream\": true,";
	else 	STREAM_OPT="\"stream\": false,"; unset STREAM;
	fi
	#((BREAK_SET && OPTRESUME)) && BREAK_SET=1 OPTRESUME=;  #inconsistent config
	((OPT_KEEPALIVE)) && OPT_KEEPALIVE_OPT="\"keep_alive\": $OPT_KEEPALIVE," || unset OPT_KEEPALIVE_OPT
	((OPTV<1)) && unset OPTV  #IPC#
	
	if ((${#STOPS[@]})) && [[ "${STOPS[*]}" != "${STOPS_OLD[*]:-%#}" ]]
	then  #compile stop sequences  #def: <|endoftext|>
		OPTSTOP=;
		for s in "${STOPS[@]}"
		do 	[[ -n $s ]] || continue
			((++n)) ;((n>4)) && break
			OPTSTOP="${OPTSTOP}${OPTSTOP:+,}\"$(escapef "$s")\""
		done
		((ANTHROPICAI)) && stop="stop_sequences" || stop="stop";
		if ((n==1))
		then 	OPTSTOP="\"${stop}\":${OPTSTOP},"
		elif ((n))
		then 	OPTSTOP="\"${stop}\":[${OPTSTOP}],"
		fi; STOPS_OLD=("${STOPS[@]}");
	fi #https://help.openai.com/en/articles/5072263-how-do-i-use-stop-sequences
	((EPN==6)) || {
	  [[ "$RESTART" = "$RESTART_OLD" ]] || restart_compf
	  [[ "$START" = "$START_OLD" ]] || start_compf
	}

	case "${MOD_PRICE[*]}" in
	*[0-9]*[$IFS]*[0-9]*) 	:;;
	*[0-9]*|*[a-zA-Z]*) 	_warmsgf "err:" "bad model prices -- ${MOD_PRICE[*]}";
			MOD_PRICE=();;
	esac;

	#update pid array
	for p in ${PIDS[@]}
	do 	kill -0 -- $p 2>/dev/null && pids+=($p);
	done; PIDS=(${pids[@]});
}

function restart_compf { ((${#1}+${#RESTART})) && RESTART=$(escapef "$(unescapef "${1:-$RESTART}")") RESTART_OLD="$RESTART" ;}
function start_compf { ((${#1}+${#START})) && START=$(escapef "$(unescapef "${1:-$START}")") START_OLD="$START" ;}

function record_confirmf
{
	typeset var
	if ((OPTV<1)) && { 	((!WSKIP)) || [[ ! -t 1 ]] ;}
	then 	printf "\\n${NC}${BWHITE}${ON_PURPLE}%s${NC}" ' * [e]dit_text,  [w]hisper_off * ' \
							      ' * Press ENTER to START record * ' >&2;
		var=$(read_charf)
		case "$var" in
			[Q]) 	return 202;;
			[AaOoqWw]) 	return 196;;
			[Ee]|$'\e') 	return 199;;
			[/!-]) 	((${#REPLY})) || REPLY="$var";
 					return 193;;
		esac;
		_clr_lineupf 33; _clr_lineupf 33;  #!#
	fi
	printf "\\n${NC}${BWHITE}${ON_PURPLE}%s\\a${NC}\\n" ' * [e]dit, [r]edo, [w]hspr_off * ' >&2
	printf "\\r${NC}${BWHITE}${ON_PURPLE}%s\\a${NC}\\n" ' * Press ENTER to  STOP record * ' >&2
}

#record mic
#usage: recordf [filename]
function recordf
{
	typeset termux pid ret
	case "$REC_CMD" in
		termux*) termux=1;;
		false) 	return 196;;
	esac
	
	#move out file before writing
	[[ -s $1 ]] && mv -f -- "$1" "${1%.*}.2.${1##*.}";
	
	[[ -n $TERMUX_VERSION ]] &&
	if is_amodelf "$MOD"
	then 	OPTV=2 set_termuxpulsef;
		case "$REC_CMD" in *termux*) 	_warmsgf 'Warning:' 'Audio-models require SoX or FFmpeg';; esac;
	else 	set_termuxpulsef;
	fi

	$REC_CMD "$1" >&2 & pid=$! PIDS+=($!);
	trap "trap 'exit' INT; ret=199;" INT;
	
	#see record_confirmf()
	case "$(read_charrecf "$@")" in
		[Q]) 	ret=202  #exit
			;;
		[AaOoqWw])   ret=196  #whisper off
			;;
		[Ee]|$'\e') ret=199  #text edit (single-shot)
			;;
		[RrSs]) rec_killf $pid $termux;  #redo, quit
			trap 'exit' INT;
			wait $pid;
			OPTV=4 WSKIP= record_confirmf;
			recordf "$@"; return;
			;;
	esac

	rec_killf $pid $termux;
       	trap 'exit' INT;
	wait $pid 
	[[ -n $TERMUX_VERSION ]] && sleep 0.6;  #termux on slow-cpu bug workaround

	#if command -v ffmpeg >/dev/null 2>&1
	#then 	trim_silencef "$FILEINW";
	#fi
	return ${ret:-0};
}
#avfoundation for macos: <https://apple.stackexchange.com/questions/326388/>
function rec_killf
{
	typeset pid termux
	pid=$1 termux=$2
	((termux)) && termux-microphone-record -q >&2 || kill -INT -- $pid 2>/dev/null >&2;
}

#whisper silence detection (hands-free, options -Wwvv)
function read_charrecf
{
	typeset atrim min_len tmout rms threshold init var
	tmout=0.3    #read timeout
	atrim=0.26   #audio trim
	min_len=1.66 #seconds (float)
	rms=0.0157   #rms amplitude (0.001 to 0.1)
	threshold="-26dB"  #noise tolerance (-32dbFS to -26dBFS)

	if ((OPTV>1)) &&
	    { case "$REC_CMD" in termux-microphone-record*)  false;; *)  :;; esac ;} &&
	    command -v ffmpeg >/dev/null 2>&1
	then
	  _cmdmsgf "Silence Detection:" "tolerance: ${threshold}  min_length: ${min_len}s";
	  _clr_ttystf; sleep ${min_len};
	  while var=$(
	      ffmpeg -fflags +nobuffer+discardcorrupt \
	        -i "$1" -af silencedetect=n=${threshold}:d=${min_len} -f null - 2>&1 </dev/null |
	        sed -n 's/^.*silence_start:[[:space:]]*//p' | sed -n '$ p'
	    )  #!# ignore start silence until speech
	    (( $(bc <<<"${var:-0} < (${min_len} * 1.6)") ))
	  do
	    NO_CLR=1 read_charf -t ${tmout} && break 1;
	  done;
	elif ((OPTV>1)) &&
	    { case "$REC_CMD" in termux-microphone-record*)  false;; *)  :;; esac ;} &&
	    command -v sox >/dev/null 2>&1
	then
	  _cmdmsgf "Silence Detection:" "rms_amplitude: ${rms}  min_length: ${min_len}s";
	  _clr_ttystf; sleep ${min_len};
	  while var=$(
	      sox "$1" -n trim -${min_len} stat 2>&1 </dev/null |
	        sed -n 's/RMS .*amplitude:[[:space:]]*//p'
	    )
	    if ((!init))  #!# enable detection after first rms peak
	    then  (( $(bc <<<"${var:-0} > (${rms} * 2.0)") )) && init=1 || var=100;
	    fi
	    (( $(bc <<<"${var:-100} > ${rms}") ))
	  do
	    NO_CLR=1 read_charf -t ${tmout} && break 1;
	  done;
	else  #defaults
	    read_charf;
	fi
}
#https://www.izotope.com/en/learn/what-is-crest-factor.html

#remove silence from both ends of audio file
function trim_silencef
{
	typeset out atrim start_periods start_silence threshold
	out=${1%.*}.2.${1##*.}
	atrim=0.26
	start_periods=1
	start_silence=0.2
	threshold="-38dB"

	ffmpeg -fflags +discardcorrupt -y -i "${1}" -af \
atrim=start=${atrim},areverse,atrim=start=${atrim},asetpts=PTS-STARTPTS,\
silenceremove=start_periods=${start_periods}:start_threshold=${threshold}:start_silence=${start_silence}:detection=peak,\
areverse,asetpts=PTS-STARTPTS,\
silenceremove=start_periods=${start_periods}:start_threshold=${threshold}:start_silence=${start_silence}:detection=peak \
	"${out}" >/dev/null 2>&1 &&
	mv -f "${out}" "${1}";
}
#https://ffmpeg.org/ffmpeg-filters.html#toc-Examples-23
#https://lists.ffmpeg.org/pipermail/ffmpeg-user/2021-August/053415.html
#https://github.com/openai/openai-cookbook/blob/main/examples/Whisper_processing_guide.ipynb
#tip: set threshold to "mean_vol", or "max_vol minus -3dB to -6dB"  #ffmpeg mailing
#voice-gate: lowpass=200,highpass=100  #man ffmpeg-filters
#lowpass=5000,highpass=200  #fast filtering not perfect
#-af lowpass=3000,highpass=200,afftdn=nf=-25
#-af arnndn=m=cb.rnnn  #voice filters

#extract mean and max volume from audio stream
#ffmpeg -i "${1}" -af "atrim=start=0.2,areverse,atrim=start=0.2,volumedetect" -f null - 2>&1 | sed -n -e 's/[[:space:]]*dB//' -e 's/.*mean_volume:[[:space:]]*//p' -e 's/.*max_volume:[[:space:]]*//p'

#amplitude ratio <-> decibel FS converter
#bc -l <<<"scale=4; 20 * l( ${rms} ) / l(10)"
#bc -l <<<"scale=6; e((${dbfs} / 20) * l(10))"

#set whisper language
function _set_langf
{
	if [[ $1 = [a-z][a-z] ]]
	then 	if ((!OPTWW))
		then 	LANGW="-F language=$1"
			((OPTV)) || sysmsgf 'Language:' "$1"
		fi ;return 0
	fi ;return 1
}

#whisper
function whisperf
{
	typeset file rec var max pid granule scale;
	typeset -a args; args=(); WHISPER_OUT=;
	
	if ((!(CHAT_ENV+MTURN) ))
	then 	sysmsgf 'Whisper Model:' "$MOD_AUDIO";
		sysmsgf 'Temperature:' "${OPTTW:-$OPTT}";
	fi;
	check_optrangef "${OPTTW:-$OPTT}" 0 1.0 Temperature
	set_model_epnf "$MOD_AUDIO"
	
	((${#})) || [[ -z ${WARGS[*]} ]] || set -- "${WARGS[@]}" "$@";
	for var
	do    [[ $var != *[!$IFS]* ]] && shift || break;
	done; var= ; args=("$@");

	#set language ISO-639-1 (two letters)
	if _set_langf "$1"
	then 	shift
	elif _set_langf "$2"
	then 	set -- "${@:1:1}" "${@:3}"
	fi
	
	if { 	((!$#)) || [[ ! -e $1 && ! -e ${@:${#}} ]] ;} && ((!CHAT_ENV))
	then 	printf "${PURPLE}%s ${NC}" 'Record mic input? [Y/n]' >&2
		[[ -t 1 ]] && echo >&2 || var=$(read_charf)
		case "$var" in
			[Q]) 	return 202;;  #exit
			[AaNnq]|$'\e') 	:;;
			*) 	((CHAT_ENV)) || sysmsgf 'Rec Cmd:' "\"${REC_CMD%% *}\"";
				OPTV=4 record_confirmf || return
				WSKIP=1 recordf "$FILEINW"
				set -- "$FILEINW" "$@"; rec=1;;
		esac
	fi
	
	if is_audiof "$1"
	then 	file="$1"; shift;
	elif ((${#} >1)) && is_audiof "${@:${#}}"
	then 	file="${@:${#}}"; set -- "${@:1:$((${#}-1))}";
	else 	printf "${BRED}Err: %s --${NC} %s\\n" 'Unknown audio format' "${1:-nill}" >&2
		return 1
	fi ;[[ -f $1 ]] && shift  #get rid of eventual second filename
	if var=$(wc -c <"$file"); ((var > 25000000));
	then 	du -h "$file" >&2;
		_warmsgf 'Warning:' "Whisper input exceeds API limit of 25 MB";
	fi
	
	#set a prompt (224 tokens, GPT2 encoding)
	max=490  #2-3 chars/tkn code and foreign languages, 4 chars/tkn english
	if var=$*; [[ $var = *[!$IFS]* ]]
	then
		((${#var}>max)) && var=${var: ${#var}-max};
		set -- -F prompt="$var";
		((CHAT_ENV+MTURN)) || sysmsgf 'Text Prompt:' "${var:0: COLUMNS-17}$([[ -n ${var: COLUMNS-17} ]] && echo ...)";
	fi

	((OPTW>2||OPTWW>2)) && granule=word || granule=segment;
	
	if [[ $granule = segment ]] || ((GROQAI))
	then 	scale=2;
	else  #word level
		scale=${OPTW:-3};
		set -- -F "timestamp_granularities[]=${granule}" "$@";
	fi

	[[ -s $FILE ]] && mv -f -- "$FILE" "${FILE%.*}.2.${FILE##*.}";

	#response_format (timestamps)
	if ((OPTW>1 || OPTWW>1)) && ((!CHAT_ENV))
	then
		OPTW_FMT=verbose_json   #json, text, srt, verbose_json, or vtt.
		set -- -F "response_format=${OPTW_FMT}" "$@";

		prompt_audiof "$file" $LANGW "$@" && {
		jq -r "def scale: ${scale}; ${JQCOLNULL} ${JQCOL} ${JQDATE}
			\"Task: \(.task)\" +
			\"    \" + \"Gran: ${granule}\" +
			\"    \" + \"Lang: \(.language)\" +
			\"    \" + \"Dur: \(.duration|seconds_to_time_string)\" +
			\"\\n\", (.text//empty) +
			\"\\n\", (.${granule}s[]| \"[\" + yellow + \"\(.start|seconds_to_time_string)\" + reset + \"]\" +
			\" \" + bpurple + (.text//.${granule}) + reset)" "$FILE" | foldf \
		|| jq -r "if .${granule}s then (.${granule}s[] | (.start|tostring) + (.text//.${granule}//empty)) else (.text//.${granule}//empty) end" "$FILE" || ! _warmsgf 'Err' ;}
	else
		prompt_audiof "$file" $LANGW "$@" && {
		jq -r "def scale: 1; ${JQCOLNULL} ${JQCOL} ${JQDATE}
		bpurple + (.text//.${granule}//empty) + reset" "$FILE" | foldf \
		|| jq -r ".text//.${granule}//empty" "$FILE" || ! _warmsgf 'Err' ;}
	fi & pid=$! PIDS+=($!);
	trap "trap 'exit' INT; kill -- $pid 2>/dev/null; BAD_RES=1" INT;

	wait $pid; trap 'exit' INT; wait $pid &&  #check exit code
	if WHISPER_OUT=$(jq -r "def scale: ${scale}; ${JQDATE} if .${granule}s then (.${granule}s[] | \"[\(.start|seconds_to_time_string)]\" + (.text//.${granule}//empty)) else (.text//.${granule}//empty) end" "$FILE" 2>/dev/null) &&
		((${#WHISPER_OUT}))
	then
		((!CHAT_ENV)) && [[ -d ${FILEWHISPERLOG%/*} ]] &&  #log output
		printf '\n====\n%s\n\n%s\n' "$(date -R 2>/dev/null||date)" "$WHISPER_OUT" >>"$FILEWHISPERLOG" &&
		_sysmsgf 'Whisper Log:' "$FILEWHISPERLOG";

		((OPTCLIP && !CHAT_ENV)) && (${CLIP_CMD:-false} <<<"$WHISPER_OUT" &);  #clipboard
		:;
	else 	false;
	fi || {
		#[[ -s $FILE ]] && jq . "$FILE" >&2 2>/dev/null;
		_warmsgf $'\nerr:' 'whisper response';
		printf 'Retry request? Y/n ' >&2;
		var=$(if ((!BAD_RES)) && [[ -s $FILEINW ]]; then  _printbf 'wait'; sleep 0.6; _printbf '    '; else    read_charf; fi)
		case "$var" in
			[Q]) 	return 202;;
			[AaNnq]) false;;  #no
			*) 	((rec)) && args+=("$FILEINW")
				BAD_RES=1 whisperf "${args[@]}";;
		esac
	}
}
#JQ function: seconds to compound time
JQDATE="def yscale: 2;
def pad(x): tostring | (length | if . >= x then \"\" else \"0\" * (x - .) end) as \$padding | \"\(\$padding)\(.)\";
def pade(x): tostring | (length | if . >= x then \"\" else \"0\" * (x - .) end) as \$padding | \"\(.)\(\$padding)\";
def padf(x;y): tostring | split(\".\") |  ( (first | pad(x)) + \".\" + (last | pade(y)));
def seconds_to_time_string:
  def nonzero: floor | if . > 0 then . else empty end;
  def decimal_places:
    . as \$in | (\$in * pow(10;scale) | floor) as \$rounded | (\$rounded / pow(10;scale) | tostring) | split(\".\") | (\"0.\" + last) ;
  if . == 0 then \"00\"
  else
    [(./60/60         | nonzero),
     (./60       % 60 | pad(2)),
     ( (. % 60) + ( (. - (. | tostring | split(\".\") | first | tonumber) ) | decimal_places | tonumber) | padf(2;scale))]
  | join(\":\")
  end;"
#https://rosettacode.org/wiki/Convert_seconds_to_compound_duration#jq
#https://stackoverflow.com/questions/64957982/how-to-pad-numbers-with-jq

#request tts prompt
function prompt_ttsf
{
	curl -N -Ss ${FAIL} -L "${BASE_URL}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H 'Content-Type: application/json' \
		-d "$BLOCK" \
		-o "$FOUT"
}
#disable curl progress-bar because of `chunk transfer encoding'

#speech synthesis (tts)
function _ttsf
{
	typeset FOUT VOICEZ SPEEDZ fname input max ret pid var secs ok n m i
	typeset -a SPIN_CHARS=("${SPIN_CHARS8[@]}");
	((${#OPTZ_VOICE})) && VOICEZ=$OPTZ_VOICE
	((${#OPTZ_SPEED})) && SPEEDZ=$OPTZ_SPEED
	
	((${#})) || [[ -z ${ZARGS[*]} ]] || set -- "${ZARGS[@]}" "$@";
	for var
	do    [[ $var != *[!$IFS]* ]] && shift || break;
	done; var= ;
	
	if ((!CHAT_ENV)) || ((${#ZARGS[@]}))
	then 	#set speech voice, out file format, and speed
		_set_ttsf "$3" && set -- "${@:1:2}" "${@:4}"
		_set_ttsf "$2" && set -- "${@:1:1}" "${@:3}"
		_set_ttsf "$1" && shift
	fi

	[[ $FOUT = "-" ]] || FOUT=$(set_fnamef "${FILEOUT_TTS%.*}.${OPTZ_FMT}");

	[[ ${MOD_SPEECH} = tts-1* ]] && max=4096 || max=40960;
	((${#} >1)) && set -- "$*";

	if ((!CHAT_ENV))
	then 	sysmsgf 'Speech Model:' "$MOD_SPEECH";
		sysmsgf 'Voice:' "$VOICEZ";
		sysmsgf 'Speed:' "${SPEEDZ:-1}";
	fi; ((${#SPEEDZ})) && check_optrangef "$SPEEDZ" 0.25 4 'TTS speed'
	[[ $1 = *[!$IFS]* ]] || ! echo '(empty)' >&2 || return 2

	if ((${#1}>max))
	then 	_warmsgf 'Warning:' "TTS input ${#1} chars / max ${max} chars"  #max ~5 minutes
		i=1 FOUT=${FOUT%.*}-${i}.${OPTZ_FMT};
	fi  #https://help.openai.com/en/articles/8555505-tts-api
	REPLAY_FILES=();

	while input=${1:0: max}; set -- "${1:max}"; [[ $input = *[!$IFS]* ]]
	do
		if ((!CHAT_ENV))
		then 	var=${input//\\\\[nt]/ };
			_sysmsgf $'\nFile Out:' "${FOUT/"$HOME"/"~"}";
			sysmsgf 'Text Prompt:' "${var:0: COLUMNS-17}$([[ -n ${input: COLUMNS-17} ]] && echo ...)";
		fi; REPLAY_FILES=("${REPLAY_FILES[@]}" "$FOUT"); var= ;
		
		BLOCK="{
\"model\": \"${MOD_SPEECH}\",
\"input\": \"${input:-$*}\",
\"voice\": \"${VOICEZ}\", ${SPEEDZ:+\"speed\": ${SPEEDZ},}
\"response_format\": \"${OPTZ_FMT}\"${BLOCK_USR_TTS:+,$NL}$BLOCK_USR_TTS
}"
		((OPTVV)) && _warmsgf "TTS:" "Model: ${MOD_SPEECH:-unset}, Voice: ${VOICEZ:-unset}, Speed: ${SPEEDZ:-unset}, Block: ${BLOCK}"
		_sysmsgf 'TTS:' '<ctr-c> [k]ill, <enter> play ' '';  #!#

		prompt_ttsf & pid=$! secs=$SECONDS;
		trap "trap 'exit' INT; kill -- $pid 2>/dev/null; return;" INT;
		while _spinf; ok=
			kill -0 -- $pid  >/dev/null 2>&1 || ! echo >&2
		do 	var=$(
			  if ((OPTV>0)) && ((!${#TERMUX_VERSION}))
			  then
			    printf '%s\n' 'p' >&2;
			  else
			    NO_CLR=1 read_charf -t 0.3;
			  fi
			) &&
			case "$var" in
				[Pp]|' '|''|$'\t')  ok=1;
					((SECONDS>secs+2)) ||  #buffer
					read_charf -t $((secs+2-SECONDS)) >/dev/null 2>&1;
					for ((n=0;n<10;n++))
					do 	[[ -s $FOUT ]] || sleep 0.2;
					done; n=;  #delay until unique file creation
					break 1;;
				[CcEeKkQqSs]|$'\e')  ok=1 ret=130;
					kill -s INT -- $pid 2>/dev/null;
					break 1;;
			esac
		done </dev/tty; _clr_lineupf $((4+1+29+${#var}));  #!#

		((ok)) || wait $pid || ((ret+=$?));
		trap 'exit' INT;
		jq . "$FOUT" >&2 2>/dev/null && ((ret+=$?));  #json response is an err

		case $ret in
			1[2-9][0-9]|2[0-5][0-9]) break 1;;
			[1-9]|[1-9][0-9])
				_warmsgf $'\rerr:' 'tts response';
				printf 'Retry request? Y/n ' >&2;
				case "$(read_charf)" in
					[Q]) 	return 202;;
					[AaNnQq]) break 1;;  #no
					*) 	continue;;
				esac;;
		esac

	[[ $FOUT = "-"* ]] || [[ ! -e $FOUT ]] || { 
		du -h "$FOUT" >&2 2>/dev/null || _sysmsgf 'TTS File:' "$FOUT"; 
		((OPTV && !CHAT_ENV)) || [[ ! -s $FOUT ]] || {
			((CHAT_ENV)) || sysmsgf 'Play Cmd:' "\"${PLAY_CMD}\"";
			case "$PLAY_CMD" in false) 	return $ret;; esac;
		while
			[[ -n $TERMUX_VERSION ]] && set_termuxpulsef;
			${PLAY_CMD} "$FOUT" >&2 & pid=$! PIDS+=($!);
		do
			trap "trap 'exit' INT; kill -- $pid 2>/dev/null; case \"\$PLAY_CMD\" in *termux-media-player*) termux-media-player stop;; esac;" INT;
			wait $pid;
			case $? in
				0) 	case "$PLAY_CMD" in *termux-media-player*) while sleep 1 ;[[ $(termux-media-player info 2>/dev/null) = *[Pp]laying* ]] ;do : ;done;; esac;  #termux fix
					var=3;  #3+1 secs
					((OPTV)) && var=2;;
				*) 	wait $pid;
					var=8;;  #8+1 secs
			esac;
			trap 'exit' INT;
			_warmsgf $'\nReplay?' 'N/y/[w]ait ' '';  #!# #F#
			for ((n=var;n>-1;n--))
			do 	printf '%s\b' "$n" >&2
				if var=$(NO_CLR=1 read_charf -t 1)
				then 	case "$var" in
					[Q]) 	return 202;;
					[RrYy]|$'\t') continue 2;;
					[PpWw]|[$' \e']) printf '%s' waiting.. >&2;
						read_charf >/dev/null;
						continue 2;;  #wait key press
					*) 	break;;
					esac;
				fi; ((n)) || echo >&2;
			done; _clr_lineupf 19;  #!#
			break;
		done
		}
		((++i)); FOUT=${FOUT%-*}-${i}.${OPTZ_FMT};
		((${#1})) && ((!ret)) || break 1;
	}
	done;
	return $ret
}
function ttsf
{
	if ((CHAT_ENV))
	then 	typeset BASE_URL OPENAI_API_KEY ENDPOINTS EPN MOD;
		ENDPOINTS=(); MOD=$MOD_SPEECH;
		EPN=10 ENDPOINTS[10]="/audio/speech";
		BASE_URL=$OPENAI_BASE_URL_DEF;
		OPENAI_API_KEY=$OPENAI_API_KEY_DEF;  #only OpenAI
	fi
	_ttsf "$@";
}
function _set_ttsf { 	__set_outfmtf "$1" || __set_voicef "$1" || __set_speedf "$1" ;}
function __set_voicef
{
	case "$1" in
		#alloy|echo|fable|onyx|nova|shimmer
		#alloy|ash|ballad|coral|echo|sage|shimmer|verse  #realtime
		[Aa][Ll][Ll][Oo][Yy]|[Ee][Cc][Hh][Oo]|[Ff][Aa][Bb][Ll][Ee]|[Oo][Nn][YyIi][Xx]|[Nn][Oo][Vv][Aa]|[Ss][Hh][Ii][Mm][Mm][Ee][Rr]|\
		[Ss][Kk][Yy]|[Aa][Ss][Hh]|[Bb][Aa][Ll][Ll][Aa][Dd]|[Cc][Oo][Rr][Aa][Ll]|[Ss][Aa][Gg][Ee]|[Vv][Ee][Rr][Ss][Ee]) 	VOICEZ=$1;;
		*) 	false;;
	esac
}
function __set_outfmtf
{
	case "$1" in  #mp3|opus|aac|flac
		[Mm][Pp]3|[Oo][Pp][Uu][Ss]|[Aa][Aa][Cc]|[Ff][Ll][Aa][Cc]) 	OPTZ_FMT=$1;;
		*?.[Mm][Pp]3|*?.[Oo][Pp][Uu][Ss]|*?.[Aa][Aa][Cc]|*?.[Ff][Ll][Aa][Cc]) 	OPTZ_FMT=${1##*.} FILEOUT_TTS=$1;;
		*?/) 	[[ -d $1 ]] && FILEOUT_TTS=${1%%/}/${FILEOUT_TTS##*/};;
		-) 	FOUT='-';;
		*) 	false;;
	esac
}
function __set_speedf
{
	case "$1" in
		[.,][0-9]*([0-9])) 	SPEEDZ=0${1//,/.};;
		[0-9]*([0-9.,])) 	SPEEDZ=${1//,/.};;
		*) 	false;;
	esac
}

#image generations
function imggenf
{
	typeset block_x;
	
	if ((LOCALAI))
	then 	block_x="\"model\": \"$MOD_IMAGE\",";
	elif [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	block_x="\"model\": \"$MOD_IMAGE\",
\"quality\": \"${OPTS_HD:-standard}\", ${OPTI_STYLE:+\"style\": \"$OPTI_STYLE\",}";
	fi
	
	BLOCK="{
\"prompt\": \"${*:?IMG PROMPT ERR}\",
\"size\": \"$OPTS\", $block_x
\"n\": ${OPTN:-1},
\"response_format\": \"$OPTI_FMT\"${BLOCK_USR:+,$NL}$BLOCK_USR
}"  #dall-e-2: n<=10, dall-e-3: n==1
	promptf
}

#image variations
function prompt_imgvarf
{
	curl -\# ${OPTV:+-Ss} ${FAIL} -L "${BASE_URL}${ENDPOINTS[EPN]}" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-F image="@$1" \
		-F response_format="$OPTI_FMT" \
		-F n="$OPTN" \
		-F size="$OPTS" \
		"${@:2}" \
		-o "$FILE"
}

#image edits+variations
function imgvarf
{
	typeset size prompt mask ;unset ARGS PNG32
	[[ -f ${1:?input PNG path required} ]]

	if command -v magick >/dev/null 2>&1
	then 	if ! _is_pngf "$1" || ! _is_squaref "$1" || ! _is_rgbf "$1" ||
			{ 	((${#} > 1)) && [[ ! -e $2 ]] ;} || [[ -n ${OPT_AT+force} ]]
		then  #not png or not square, or needs alpha
			if ((${#} > 1)) && [[ ! -e $2 ]]
			then  #needs alpha
				_set_alphaf "$1"
			else  #no need alpha
			      #resize and convert (to png32?)
				if _is_opaquef "$1"
				then  #is opaque
					ARGS="" PNG32="" ;((OPTV)) ||
					printf '%s\n' 'Alpha not needed, opaque image' >&2
				else  #is transparent
					ARGS="-alpha set" PNG32="png32:" ;((OPTV)) ||
					printf '%s\n' 'Alpha not needed, transparent image' >&2
				fi
			fi
			_is_rgbf "$1" || { 	PNG32="png32:" ;printf '%s\n' 'Image colour space is not RGB(A)' >&2 ;}
			img_convf "$1" $ARGS "${PNG32}${FILEIN}" &&
				set -- "${FILEIN}" "${@:2}"  #adjusted
		else 	((OPTV)) ||
			printf '%s\n' 'No adjustment needed in image file' >&2
		fi ;unset ARGS PNG32
						
		if [[ -f $2 ]]  #edits + mask file
		then 	size=$(print_imgsizef "$1") 
			if ! _is_pngf "$2" || ! _is_rgbf "$2" || {
				[[ $(print_imgsizef "$2") != "$size" ]] &&
				{ 	((OPTV)) || printf '%s\n' 'Mask size differs' >&2 ;}
			} || _is_opaquef "$2" || [[ -n ${OPT_AT+true} ]]
			then 	mask="${FILEIN%.*}_mask.png" PNG32="png32:" ARGS=""
				_set_alphaf "$2"
				img_convf "$2" -scale "$size" $ARGS "${PNG32}${mask}" &&
					set  -- "$1" "$mask" "${@:3}"  #adjusted
			else 	((OPTV)) ||
				printf '%s\n' 'No adjustment needed in mask file' >&2
			fi
		fi
	fi ;unset ARGS PNG32
	
	_chk_imgsizef "$1" || return 2

	## one prompt  --  generations
	## one file  --  variations
	## one file (alpha) and one prompt  --  edits
	## two files, (and one prompt)  --  edits
	if [[ -f $1 ]] && ((${#} > 1))  #img edits
	then 	OPTII=1 EPN=9  #MOD=image-ed
		if ((${#} > 2)) && [[ -f $2 ]]
		then 	prompt="${@:3}" ;set -- "${@:1:2}" 
		elif ((${#} > 1)) && [[ ! -e $2 ]]
		then 	prompt="${@:2}" ;set -- "${@:1:1}"
		fi
		[[ -f $2 ]] && set -- "${@:1:1}" -F mask="@$2"
	elif [[ -f $1 ]]  #img variations
	then 	OPTII=1 EPN=4  #MOD=image-var
	fi
	[[ -n $prompt ]] && set -- "$@" -F prompt="$prompt"

	prompt_imgvarf "$@" &&
	prompt_imgprintf
}
#https://legacy.imagemagick.org/Usage/resize/
#https://imagemagick.org/Usage/masking/#alpha
#https://stackoverflow.com/questions/41137794/
#https://stackoverflow.com/questions/2581469/
#https://superuser.com/questions/1491513/
#
#set alpha flags for IM
function _set_alphaf
{
	unset ARGS PNG32
	if _has_alphaf "$1"
	then  #has alpha
		if _is_opaquef "$1"
		then  #is opaque
			ARGS="-alpha set -fuzz ${OPT_AT_PC:-0}% -transparent ${OPT_AT:-black}" PNG32="png32:"
			((OPTV)) ||
			printf '%s\n' 'File has alpha but is opaque' >&2
		else  #is transparent
			ARGS="-alpha set" PNG32="png32:"
			((OPTV)) ||
			printf '%s\n' 'File has alpha and is transparent' >&2
		fi
	else  #no alpha, is opaque
		ARGS="-alpha set -fuzz ${OPT_AT_PC:-0}% -transparent ${OPT_AT:-black}" PNG32="png32:"
		((OPTV)) ||
		printf '%s\n' 'File has alpha but is opaque' >&2
	fi
}
#check if file ends with .png
function _is_pngf
{
	if [[ $1 != *.[Pp][Nn][Gg] ]]
	then 	((OPTV)) || printf '%s\n' 'Not a PNG image' >&2
		return 1
	fi ;return 0
}
#convert image
#usage: img_convf [in_file] [opt..] [out_file]
function img_convf
{
	if ((!OPTV))
	then 	[[ $ARGS = *-transparent* ]] &&
		printf "${BWHITE}%-12s --${NC} %s\\n" "Transparent colour" "${OPT_AT:-black}" "Fuzz" "${OPT_AT_PC:-2}%" >&2
		sysmsgf 'Edit with ImageMagick?' '[Y/n] ' ''
		case "$(read_charf)" in [AaNnQq]|$'\e') 	return 2;; esac
	fi

	if magick "$1" -background none -gravity center -extent 1:1 "${@:2}"
	then 	if ((!OPTV))
		then 	set -- "${@##png32:}" ;_openf "${@:${#}}"
			sysmsgf 'Confirm Edit?' '[Y/n] ' ''
			case "$(read_charf)" in [AaNnQq]|$'\e') 	return 2;; esac
		fi
	else 	false
	fi
}
#check for image alpha channel
function _has_alphaf
{
	typeset alpha
	alpha=$(magick identify -format '%A' "$1")
	[[ $alpha = [Tt][Rr][Uu][Ee] ]] || [[ $alpha = [Bb][Ll][Ee][Nn][Dd] ]]
}
#check if image is opaque
function _is_opaquef
{
	typeset opaque
	opaque=$(magick identify -format '%[opaque]' "$1")
	[[ $opaque = [Tt][Rr][Uu][Ee] ]]
}
#https://stackoverflow.com/questions/2581469/detect-alpha-channel-with-imagemagick
#check if image is square
function _is_squaref
{
	if (( $(magick identify -format '%[fx:(h != w)]' "$1") ))
	then 	((OPTV)) || printf '%s\n' 'Image is not square' >&2
		return 2
	fi
}
#print image size
function print_imgsizef
{
	magick identify -format "%wx%h\n" "$@"
}
#check file size of image
function _chk_imgsizef
{
	typeset chk_fsize
	if chk_fsize=$(wc -c <"$1" 2>/dev/null) ;(( (chk_fsize+500000)/1000000 >= 4))
	then 	_warmsgf "Warning:" "Max image size is 4MB [file:$((chk_fsize/1000))KB]"
		(( (chk_fsize+500000)/1000000 < 5))
	fi
}
#is image colour space rgb?
function _is_rgbf
{
	[[ " $(magick identify -format "%r" "$@") " = *[Rr][Gg][Bb]* ]]
}

#embeds
function embedf
{
	BLOCK="{
$( ((MISTRALAI)) || echo "\"temperature\": $OPTT, $OPTP_OPT
\"max_tokens\": $OPTMAX, \"n\": $OPTN," )
\"model\": \"$MOD\", ${BLOCK_USR:+$NL}$BLOCK_USR
\"input\": \"${*:?INPUT ERR}\"
}"
	promptf 2>&1
}

function moderationf
{
	BLOCK="{
\"model\": \"$MOD\",
\"input\": \"${*:?INPUT ERR}\"${BLOCK_USR:+,$NL}$BLOCK_USR
}"
	_promptf
}

# Awesome-chatgpt-prompts
function awesomef
{
	typeset REPLY act_keys act_keys_n options glob act zh a l n
	[[ "$INSTRUCTION" = %* ]] && FILEAWE="${FILEAWE%%.csv}-zh.csv" zh=1

	set -- "$(trimf "${INSTRUCTION##[/%]}" "*( )" )";
	set -- "${1// /_}";
	FILECHAT="${FILECHAT%/*}/awesome.tsv"
	_cmdmsgf 'Awesome Prompts' "$1"

	if [[ ! -s $FILEAWE ]] || [[ $1 = [/%]* ]]  #second slash
	then 	set -- "${1##[/%]}"
		if 	if ((zh))
			then 	! { curl -\# -L ${FAIL} "$AWEURLZH" \
				| jq '"act,prompt",(.[]|join(","))' \
				| sed 's/,/","/' >"$FILEAWE" ;}  #json to csv
			else 	! curl -\# -L ${FAIL} "$AWEURL" -o "$FILEAWE"
			fi
		then 	[[ -f $FILEAWE ]] && rm -- "$FILEAWE"
			return 1
		fi
	fi;

	#map prompts to indexes and get user selection
	act_keys=$(sed -e '1d; s/,.*//; s/^"//; s/"$//; s/""/\\"/g; s/[][()`*_]//g; s/ /_/g' "$FILEAWE")
	act_keys_n=$(wc -l <<<"$act_keys")
	case "$1" in
		list*|ls*|+([./%*?-]))  #list awesome keys
			{ 	pr -T -t -n:3 -W $COLUMNS -$(( (COLUMNS/80)+1)) || cat ;} <<<"$act_keys" >&2;
			return 210;;
	esac

	((${#1}==1)) && glob='^';
	if test_dialogf
	then
		if ((${#1})) && 
		options=( $(_dialog_optf $(grep -i -e "${glob}${1//[ _-]/[ _-]}" <<<"${act_keys}" | sort) ) )
			((!${#options[@]}))
		then  options=( $(_dialog_optf $(printf '%s\n' ${act_keys:-err} | sort) ) )
		fi
		REPLY=$(
		  dialog --backtitle "Awesome Picker" --title "Select an Act" \
		    --menu "The following acts are available:" 0 40 0 \
		    -- "${options[@]}"  2>&1 >/dev/tty;
		) || typeset NO_DIALOG=1;
		_clr_dialogf;

		for act in ${act_keys}
		do  ((++n))
		    case "$REPLY" in "$act")  act=${n:-1}; break;; esac;
		done
	else
	echo >&2;
	set -- "${1:-%#}";
	while ! { 	((act && act <= act_keys_n)) ;}
	do 	if ! act=$(grep -n -i -e "${glob}${1//[ _-]/[ _-]}" <<<"${act_keys}")
		then 	_clr_ttystf;
			select act in ${act_keys}
			do 	break
			done </dev/tty; act="$REPLY";
		elif act="$(cut -f1 -d: <<<"$act")"
			[[ ${act} = *$'\n'?* ]]
		then 	while read l;
			do 	((++n));
				for a in ${act};
				do 	((n==a)) && printf '%d) %s\n' "$n" "$l" >&2;
				done;
			done <<<"${act_keys}";
			printf '\n#? <enter> ' >&2
			_clr_ttystf; read -r -e act </dev/tty;
			printf '\n\n' >&2;
		fi ;set -- "$act"; glob= n= a= l=;
	done
	fi
	
	INSTRUCTION=$(sed -n -e 's/^[^,]*,//; s/^"//; s/"$//; s/""/"/g' -e "$((act+1))p" "$FILEAWE")
	((CMD_CHAT)) ||
	if _clr_ttystf; ((OPTX))  #edit chosen awesome prompt
	then 	INSTRUCTION=$(ed_outf "$INSTRUCTION") || exit
		printf '%s\n\n' "$INSTRUCTION" >&2 ;
	else 	read_mainf -i "$INSTRUCTION" INSTRUCTION
		((OPTCTRD)) && INSTRUCTION=$(trim_trailf "$INSTRUCTION" $'*([\r])')
	fi </dev/tty
	case "$INSTRUCTION" in ''|prompt|act)
		_warmsgf 'Err:' 'awesome-chatgpt-prompts fail'
		unset OPTAWE INSTRUCTION;return 1
	esac;
}

# Custom prompts
function custom_prf
{
	typeset file filechat name template list msg new skip ret
	filechat="$FILECHAT"
	FILECHAT="${FILECHAT%%.[Tt][SsXx][VvTt]}.pr"
	case "$INSTRUCTION" in  #lax syntax  -S.prompt.
		*[!.,][.]) 	INSTRUCTION=".${INSTRUCTION%%[.]}";;
		*[!.,][,]) 	INSTRUCTION=",${INSTRUCTION%%[,]}";;
	esac

	#options
	case "${INSTRUCTION:0:32}"  in
		+([.,])@(list|\?)|[.,]+([.,/*?-]))
			INSTRUCTION= list=1
			_cmdmsgf 'Prompt File' 'LIST'
			;;
		,,?*) #edit template prompt file
			INSTRUCTION="${INSTRUCTION##[.,]*( )}"
			template=1 skip=0 msg='EDIT TEMPLATE'
			;;
		,?*)  #single-shot edit
			INSTRUCTION="${INSTRUCTION##[.,]*( )}"
			skip=0 msg='LOAD (single-shot edit)'
			;;
		[.,]) #pick prompt file
			INSTRUCTION=
			;;
	esac
	
	#set skip confirmation (catch ./file)
	[[ $INSTRUCTION = .* ]] && [[ $INSTRUCTION != .?(.)/*([!/]) ]] \
	&& INSTRUCTION="${INSTRUCTION##[.,]}" skip=${skip:-1} 
	
	[[ ! -f $INSTRUCTION ]] && [[ $INSTRUCTION != ./*([!/]) ]] \
	&& INSTRUCTION="${INSTRUCTION##[.,]}"
	
	name=$(trim_leadf "$INSTRUCTION" '*( )')

	#set source prompt file
	if [[ -f $name ]]
	then 	file="$name"
	elif [[ $name = */* ]] ||
		! file=$(
		  SESSION_LIST=$list SGLOB='[Pp][Rr]' EXT='pr' \
		  session_globf "$name")
	then
		case "$name" in  #default translations
			en)  INSTRUCTION=$INSTRUCTION_CHAT_EN;;
			pt)  INSTRUCTION=$INSTRUCTION_CHAT_PT;;
			es)  INSTRUCTION=$INSTRUCTION_CHAT_ES;;
			it)  INSTRUCTION=$INSTRUCTION_CHAT_IT;;
			fr)  INSTRUCTION=$INSTRUCTION_CHAT_FR;;
			de)  INSTRUCTION=$INSTRUCTION_CHAT_DE;;
			ru)  INSTRUCTION=$INSTRUCTION_CHAT_RU;;
			ja)  INSTRUCTION=$INSTRUCTION_CHAT_JA;;
			hi)  INSTRUCTION=$INSTRUCTION_CHAT_HI;;
			zh[_-]TW|zh[_-][Hh][Aa][Nn][Tt])  INSTRUCTION=$INSTRUCTION_CHAT_ZH_TW;;
			zh[_-]CN|zh)  INSTRUCTION=$INSTRUCTION_CHAT_ZH;;
			*)   false;;
		esac && return;

		template=1;
		file=$(
		  SGLOB='[Pp][Rr]' EXT='pr' \
		  session_name_choosef "$name")

		[[ -f $file ]] && msg=${msg:-LOAD} || msg=CREATE
	fi
	((list)) && { 	printf '%s\n' "$file"; exit ;}

	case "$file" in
		[Cc]urrent|.) 	file="${FILECHAT}";;
		[Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit) 	return 201;;
	esac
	if [[ -f "$file" ]]
	then 	msg=${msg:-LOAD}    INSTRUCTION=$(<"$file")
	else 	msg=${msg:-CREATE}  INSTRUCTION=  template=1 new=1
	fi

	FILECHAT="${filechat%/*}/${file##*/}"
	FILECHAT="${FILECHAT%%.[Pp][Rr]}.tsv"
	if ((OPTHH>1 && OPTHH<=4))
	then 	session_sub_fifof "$FILECHAT"
		return
	fi
	((CMD_CHAT)) ||
	  _sysmsgf 'Hist   File:' "${FILECHAT/"$HOME"/"~"}"
	((OPTV>99)) || {
	  _sysmsgf 'Prompt File:' "${file/"$HOME"/"~"}"
	  _cmdmsgf "${new:+New }Prompt Cmd" " ${msg}"
	}

	if { 	[[ $msg = *[Cc][Rr][Ee][Aa][Tt][Ee]* ]] && INSTRUCTION="$*" ret=200 ;} ||
		[[ $msg = *[Ee][Dd][Ii][Tt]* ]] || (( (MTURN+CHAT_ENV) && OPTRESUME!=1 && skip==0))
	then
		_clr_ttystf;
		if ((OPTX))  #edit prompt
		then 	INSTRUCTION=$(ed_outf "$INSTRUCTION") || exit
			printf '%s\n\n' "$INSTRUCTION" >&2 ;
		else 	_printbf '>'; read_mainf -i "$INSTRUCTION" INSTRUCTION;
			((OPTCTRD)) && INSTRUCTION=$(trim_trailf "$INSTRUCTION" $'*([\r])')
		fi </dev/tty

		if ((template))  #push changes to file
		then 	printf '%s' "$INSTRUCTION"${INSTRUCTION:+$'\n'} >"$file"
			[[ -f "$file" && ! -s "$file" ]] && { rm -v -- "$file" || rm -- "$file" ;} >&2
		fi
		if [[ -z $INSTRUCTION ]]
		then 	_warmsgf 'Err:' 'Custom prompts fail'
			return 1
		fi
	fi
	return ${ret:-0}
} #exit codes: 1) err; 	200) create new pr; 	201) abort.

#set an empty output filename
function set_fnamef
{
	typeset f n m ext fname;
	ext=${1##*.} f=$1;

	if [[ -s $1 ]]
	then 	n=0 m=0  #set a filename for output
		for fname in "${1%.*}"*
		do 	fname=${fname##*/} fname=${fname%.*}
			fname=${fname%%-*([0-9])} fname=${fname##*[!0-9]}
			((m>fname)) || ((m=fname+1)) 
		done
		set -- "${1%.*}"; set -- "${1%%?(-)*([0-9])}";
		while [[ -s ${1}${m}.${ext} ]]; do 	((++m)); done;
		set -- "${1}${m}.${ext}";
	fi
	printf '%s\n' "${1:-${f}}"; ((${#1}));
}

# Set the clipboard command
function set_clipcmdf
{
	((${#CLIP_CMD})) ||
	if command -v termux-clipboard-set
	then 	CLIP_CMD='termux-clipboard-set'
	elif command -v pbcopy
	then 	CLIP_CMD='pbcopy'
	elif command -v xsel
	then 	CLIP_CMD='xsel -b'
	elif command -v xclip
	then 	CLIP_CMD='xclip -selection clipboard'
	else 	CLIP_CMD='false'
	fi >/dev/null 2>&1
}

# Set the audio play command
function set_playcmdf
{
	((${#PLAY_CMD})) && return;

	if [[ -n $TERMUX_VERSION ]]
	then 	is_amodelf "$MOD" && typeset OPTV=2;
		set_termuxpulsef ||
		if command -v play-audio
		then 	PLAY_CMD='play-audio';
			return 0;
		elif command -v termux-media-player
		then 	PLAY_CMD='termux-media-player play';
			return 0;
		fi >/dev/null 2>&1
	fi

	if command -v mpv
	then 	PLAY_CMD='mpv --no-video --vo=null'
	#--profile=low-latency  --vo=xv  #low latency
	elif command -v play  #sox
	then 	PLAY_CMD='play'
	#--input-buffer=40000
	#https://sourceforge.net/p/sox/patches/124/
	elif command -v cvlc
	then 	PLAY_CMD='cvlc --play-and-exit --no-loop --no-repeat'
	#--network-caching=150 --sout-mux-caching=50 --live-caching=100 --clock-jitter=0 --file-caching=0 --no-audio-time-stretch
	elif command -v ffplay
	then 	PLAY_CMD='ffplay -nodisp -hide_banner -autoexit'
	#-fflags +nobuffer -flags low_delay -framedrop 
	#-fflags discardcorrupt, too aggressive (breaks audio-video sync)
	elif command -v afplay  #macos
	then 	PLAY_CMD='afplay'
	else 	PLAY_CMD='false'
	fi >/dev/null 2>&1
}

#set audio recorder command
function set_reccmdf
{
	((${#REC_CMD})) && return;

	if [[ -n $TERMUX_VERSION ]]
	then 	is_amodelf "$MOD" && typeset OPTV=2;
		set_termuxpulsef ||
		if command -v termux-microphone-record
		then 	REC_CMD='termux-microphone-record -r 16000 -c 1 -l 0 -f';
			is_amodelf "$MOD" ||  #termux-mic encodes m4a only
			FILEINW="${FILEINW%.*}.m4a";  #encoder aac
			return 0;
		fi >/dev/null 2>&1
	fi

	if command -v sox
	then 	REC_CMD='sox -d -r 16000 -c 1'
	#--input-buffer=40000, silence 1 0.50 0.1%
	#https://sourceforge.net/p/sox/patches/124/
	elif command -v arecord  #alsa utils
	then 	REC_CMD='arecord -f S16_LE -r 16000 -c 1 -i'
	#-B --buffer-time=#, --buffer-size=#
	elif command -v ffmpeg
	then 	case "${OSTYPE:-$(uname -a)}" in
		    *[Dd]arwin*)
			REC_CMD='ffmpeg -hide_banner -f avfoundation -i ":1" -ar 16000 -ac 1 -y';;
		    *)  REC_CMD='ffmpeg -hide_banner -f alsa -i pulse -ar 16000 -ac 1 -y';;
		esac;
	else 	REC_CMD='false'
	fi >/dev/null 2>&1
}

#check and set termux pulseaudio configuration
function set_termuxpulsef
{
	((OPTV>1)) || return;
	if case "$OPT_SLES" in
		[Yy]) 	:;;
		[Nn]) 	return 1;;
		*) 	command -v pulseaudio >/dev/null 2>&1 &&
			command -v pactl >/dev/null 2>&1;;
	   esac;
	then
		case "$(pactl list modules 2>&1)" in
		  *module-sles-source*)  :;;
		  *module-sles-sink*|*)
		    _warmsgf 'Pulseaudio:' "\`module-sles-source' not active";
		    _warmsgf 'Pulseaudio:' "configure \`pulseaudio' with \`module-sles-source'";
		    _sysmsgf 'See' "<https://gitlab.com/fenixdragao/shellchatgpt#termux-users>";

		    ((${#OPT_SLES})) ||
		      printf '\n%s  [N/y] \a' "Enable \`module-sles-source'?" >&2;
		    case "${OPT_SLES:-$(read_charf -t 4||echo >&2)}" in
		      [YySs]|[$' \t'])
		        OPT_SLES=y;
		        _printbf "pulse";
		        pulseaudio -k; sleep 0.1;
		        pulseaudio -L "module-sles-source" -D &
		        disown $!; sleep 0.2;
		        _printbf "     ";
		        ;;
		      [NnAaQq]|$'\e'|*)
		        OPT_SLES=n;
		        false;
		        ;;
		    esac;
		    ;;
		esac;
	else
		  sysmsgf 'Tip:' "install \`pulseaudio', \`sox', and \`ffmpeg' for enhanced audio";
		  OPT_SLES=n;
		  false;
	fi
}
#https://madskjeldgaard.dk/posts/sox-tutorial-sox-on-android/

#append to shell hist list
function shell_histf
{
	[[ ${*} = *[!$IFS]* ]] || return
	history -s -- "$*"
}
#history file must start with a timestamp (# plus Unix timestamp) or else
#the history command will still split on each line of a multi-line command
#https://askubuntu.com/questions/1133015/
#https://lists.gnu.org/archive/html/bug-bash/2011-02/msg00025.html

#print checksum
function cksumf
{
	[[ -f "$1" ]] && wc -l -- "$@"
}

#list session files in cache dir
function session_listf
{
	SESSION_LIST=1 session_globf "$@"
}
#pick session files by globbing cache dir
function session_globf
{
	typeset REPLY file glob sglob ext ok options
	sglob="${SGLOB:-[Tt][Ss][Vv]}" ext="${EXT:-tsv}"

	[[ ! -f "$1" ]] || return
	case "$1" in
		[Nn]ew) 	return 2;;
		[Cc]urrent|.) 	printf '%s' "${FILECHAT:-$1}"; return;;
	esac

	cd -- "${CACHEDIR}"
	glob="${1%%.${sglob}}" glob="${glob##*/}"
	#input is exact filename, or ends with extension wo whitespaces?
	[[ -f "${glob}".${ext} ]] || [[ "$1" = *?.${sglob} && "$1" != *\ * ]] \
	|| set -- *${glob}*.${sglob}  #set the glob
	
	if ((SESSION_LIST))
	then 	ls -- "$@";
		return 0;
	fi

	if ((${#} >1)) && [[ "$glob" != *[$IFS]* ]]
	then 	_clr_ttystf;
		if test_dialogf
		then 	options=( $(_dialog_optf 'current' 'new' "${@%%.${sglob}}") )
			file=$(
			  dialog --backtitle "Selection Menu" --title "$([[ $ext = *[Tt][Ss][Vv] ]] && echo History File || echo Prompt) Selection" \
			    --menu "Choose one of the following:" 0 40 0 \
			    -- "${options[@]}"  2>&1 >/dev/tty;
			) || { file=abort; typeset NO_DIALOG=1 ;}
			_clr_dialogf;
		else
			printf '# Pick file [.%s]:\n' "${ext}" >&2
			select file in 'current' 'new' 'abort' "${@%%.${sglob}}"
			do 	break
			done </dev/tty
		fi
		file="${file:-$REPLY}"
	else 	file="${1}"
	fi

	case "$file" in
		[Cc]urrent|.|'')
			file="${FILECHAT##*/}"
			;;
		[Nn]ew) session_name_choosef
			return
			;;
		[Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit)
			echo abort; echo '[abort]' >&2
			return 201
			;;
		"$REPLY")
			ok=1
			;;
	esac

	file="${CACHEDIR%%/}/${file:-${*:${#}}}"
	file="${file%%.${sglob}}.${ext}"
	[[ -f $file || $ok -gt 0 ]] && printf '%s' "${file}"
}
#set tsv filename based on input
function session_name_choosef
{
	typeset fname new print_name sglob ext var item
	fname="$1" sglob="${SGLOB:-[Tt][Ss][Vv]}" ext="${EXT:-tsv}" 
	((OPTEXIT>1)) && return
	case "$fname" in [Nn]ew|*[N]ew.${sglob}) 	set --; fname= ;; esac
	while
		fname="${fname%%\/}"
		fname="${fname%%.${sglob}}"
		fname="${fname/\~\//"$HOME"\/}"
		case "pr" in ${sglob}) item="prompt";;
			*) item="session";;
		esac;
		
		if [[ -d "$fname" ]]
		then 	_warmsgf 'Err:' 'Is a directory'
			fname="${fname%%/}"
		( 	cd "$fname" &&
			ls -- "${fname}"/*.${sglob} ) >&2 2>/dev/null
			shell_histf "${fname}${fname:+/}"
			unset fname
		fi

		if [[ ${fname} != *[!$IFS]* ]]
		then
			if test_dialogf
			then 	fname=$(
				dialog --backtitle "${item} manager" \
				--title "new ${item} file" \
				--inputbox "enter new ${item} name" 8 32  2>&1 >/dev/tty )
				_clr_dialogf;
			else
				_sysmsgf "New ${item} name <enter/abort>:" \
				_clr_ttystf; read -r -e -i "$fname" fname </dev/tty;
			fi;
			case "${fname}" in \~\/*) 	fname="$HOME/${fname:2}";; esac;
			fname=${fname%%.${sglob}} fname=${fname//[ \<\>\*\;:,?!]/_} fname=${fname//__/_};
		fi

		if [[ -d "$fname" ]]
		then 	unset fname
			continue
		fi

		if [[ $fname != *?/?* ]] && [[ ! -e "$fname" ]]
		then 	fname="${CACHEDIR%%/}/${fname:-abort}"
		fi; fname="${fname:-abort}"
		if [[ ! -f "$fname" ]]
		then 	fname="${fname}.${ext}"
			new=" new"
		fi

		if [[ $fname = "$FILECHAT" ]]
		then 	print_name=current
		else 	print_name="${fname/"$HOME"/"~"}"
		fi
		if [[ ! -e $fname ]]
		then 	case "$fname" in *[N]ew.${sglob}) 	:;; *[Aa]bort.${sglob}|*[Cc]ancel.${sglob}|*[Ee]xit.${sglob}|*[Qq]uit.${sglob}) 	echo abort; echo '[abort]' >&2; return 201;; esac
			if test_dialogf
			then 	dialog --colors --backtitle "${item} manager" \
				--title "confirm${new} ${item} file?" \
				--yesno " \\Zb${new:+\\Z1}${print_name}\\Zn" 8 $((${#print_name}+6))  >/dev/tty
				case $? in
					-1|1|5|255) var=abort;;
				esac;
				_clr_dialogf;
			else
				_sysmsgf "Confirm${new}? [Y]es/[n]o/[a]bort:" "${print_name} " '' ''
				var=$(read_charf)
			fi
			case "$var" in [AaQq]|$'\e'|*[Aa]bort|*[Aa]bort.${sglob}) 	echo abort; echo '[abort]' >&2; return 201;; [NnOo]) 	:;; *) 	false;; esac
		else 	false
		fi
	do 	unset fname new print_name
	done
	
	if [[ ! -e ${fname} ]]
	then 	[[ ${fname} = *.[Pp][Rr] ]] \
		&& printf '(new prompt file)\n' >&2 \
		|| printf '(new hist file)\n' >&2
	fi
	[[ ${fname} = *[!$IFS]* ]] && printf '%s\n' "$fname"
}
#pick and print a session from hist file
function session_sub_printf
{
	typeset REPLY reply file time token string buff buff_end index regex skip sopt copt ok m n
	typeset -a SPIN_CHARS=("${SPIN_CHARS0[@]}");
	sopt= copt= ok= buff= buff_end=;
	[[ -s ${file:=$1} ]] || return; [[ $file = */* ]] || [[ ! -e "./$file" ]] || file="./$file";
	FILECHAT_OLD="$file" regex="${REGEX%%${NL}*}";
 
	while ((skip)) || IFS= read -r
	do 	_spinf; skip= ;
		if [[ ${REPLY} = *([$IFS])\#* ]] && ((OPTHH<3))
		then 	continue
		elif [[ ${REPLY} = *[Bb][Rr][Ee][Aa][Kk]*([$IFS]) ]]
		then
for ((m=1;m<2;++m))
do 	_spinf 	#grep session with user regex
			((skip)) && skip= ||
			if ((${regex:+1}))
			then 	if ((!ok))
				then 	[[ $regex = -?* ]] && sopt="${regex%% *}" regex="${regex#* }"
					grep $sopt "${regex}" <<<" " >/dev/null  #test user syntax
					(($?<2)) || return 1; ((OPTK)) || copt='--color=always';
					
					_sysmsgf 'Regex': "\`${regex}'";
					if ! grep -q $copt $sopt "${regex}" "$file" 1>&2 2>/dev/null;  #grep regex match in current file
					then 	grep -n -o $copt $sopt "${regex}" "${file%/*}"/*"${file##*.}" 1>&2 2>/dev/null  #grep other files
						_warmsgf 'Err:' "No match at \`${file/"$HOME"/"~"}'";
						buff= ; break 2;
					fi; ok=1;
				fi;
				grep $copt $sopt "${regex}" < <(_unescapef "$(cut -f1,3- -d$'\t' <<<"$buff")") >&2 &&
				  printf '%s\n' '---' >&2 || buff= ;
			else
				for ((n=0;n<12;++n))
				do 	_spinf
					IFS=$'\t' read -r time token string || break
					buff_end="${buff_end}${buff_end:+$NL}${string:1: ${#string}-2}"
				done <<<"${buff}"
			fi
			
			((OPTHH && OPTV)) && break 2;  #IPC#
			((${#buff})) && {
			  if ((${#buff_end}))
			  then 	((${#buff_end}>640)) && ((index=${#buff_end}-640)) || index= ;
				printf -- '===\n%s%s\n---\n' "${index:+[..]}" "$(_unescapef "${buff_end:${index:-0}}")" | foldf >&2;
			  fi
			  ((OPTPRINT)) && break 2;

			  if ((${regex:+1}))
			  then 	_sysmsgf "Correct session?" '[Y/n/p/r/a] ' ''
			  else 	_sysmsgf "Tail of the correct session?" '[Y]es, [n]o, [p]rint, [r]egex, [a]bort ' ''
			  fi;
			  reply=$(read_charf);
			  case "$reply" in
				[]GgSsRr/?:\;-]|[$' \t']) _sysmsgf 'grep:' '<-opt> <regex> <enter>';
					_clr_ttystf;
					read -r -e -i "${regex:-${reply//[!-]}}" regex </dev/tty;
					skip=1 ok= ;
					continue 2;
					;;
				[Pp]) 	_unescapef "\\n\\n$(sed -e $'s/^.*\t//' -e 's/^"//; s/"$/\n/' <<<"${buff:-err}")\\n---\\n" >&2;
					skip=1 m=0 buff_end= ;
					continue 1;
					;;
				[NnOo]|$'\e') ((${regex:+1})) && printf '%s\n\n' '---' >&2;
					false;
					;;
				[AaQq]) echo '[abort]' >&2;
					return 201;
					;;
				*) 	((${regex:+1})) && printf '%s\n' '---' >&2;
					break 2;
					;;
			esac
			}
done
			REPLY= reply= time= token= string= buff= buff_end= index= m= n=
			continue
		fi
		buff="${REPLY}"${buff:+$'\n'}"${buff}"
	done < <( 	tac -- "$file" && {
			((OPTPRINT+OPTHH)) || _warmsgf '(end of hist file)' ;}
			echo BREAK;
		); _printbf ' '
	[[ -n ${buff} ]] && printf '%s\n' "$buff"
}
#copy session to another session file, print destination filename
function session_copyf
{
	typeset src dest buff
	
	((${#}==1)) && [[ "$1" = +([!\ ])[\ ]+([!\ ]) ]] && set -- $@  #filename with spaces

	_sysmsgf 'Source hist file: ' '' ''
	if ((${#}==1)) && [[ "$1" != [Cc]urrent && "$1" != . ]]
	then 	src=${FILECHAT}; echo "${src:-err}" >&2
	else 	src="$(session_globf "${@:1:1}" || session_name_choosef "${@:1:1}")"; echo "${src:-err}" >&2
		set -- "${@:2:1}"
	fi; case "$src" in [Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit) 	echo '[abort]' >&2; return 201;; esac
	_sysmsgf 'Destination hist file: ' '' ''
	dest="$(session_globf "$@" || session_name_choosef "$@")"; echo "${dest:-err}" >&2
	dest="${dest:-$FILECHAT}"; case "$dest" in [Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit) 	echo '[abort]' >&2; return 201;; esac

	buff=$(session_sub_printf "$src") && {
		[[ -f "$dest" ]] && { 	[[ $(tail -- "$dest") != *"$buff" ]] || return 0 ;}
		FILECHAT="${dest}" INSTRUCTION_OLD= INSTRUCTION= OPTRESUME= BREAK_SET= cmd_runf /break 2>/dev/null;
		FILECHAT="${dest}" _break_sessionf; OLD_DEST="${dest}";
		#check if dest is the same as current
		[[ "$dest" != "$FILECHAT" ]] || OPTRESUME=1 BREAK_SET= MAIN_LOOP= HIST_LOOP= TOTAL_OLD= MAX_PREV=;
		_sysmsgf 'SESSION FORK';
		printf '%s\n' "$buff" >> "$dest" &&
		printf '%s\n' "$dest";
	}
}
#create or copy a session, search for and change to a session file.
function session_mainf
{
	typeset name file optsession arg break msg
	typeset -a args
	name="${*}"               ;((${#name}<512)) || return
	name=$(trimf "${name}" "*([$IFS])") ;[[ $name = [/!]* ]] || return
	name="${name##?([/!])*([$IFS])}"

	case "${name}" in
		#list files: /list [awe|pr|all|session]
		list*|ls*)
			name="${name##@(list|ls)*([$IFS])}"
			case "$name" in
				[Aa]wesome|[Aa]we)
					INSTRUCTION=/list awesomef;
					return 0;;  #e:210
				[Pp][Rr]|[Pp]rompt|[Pp]rompts)
					typeset SGLOB='[Pp][Rr]' EXT='pr' name= msg=Prompt;;  #duplicates opt `-S .list` fun
				[Aa]ll|[Ee]verything|[Aa]nything|+([./*?-]))
					typeset SGLOB='*' EXT='*' name= msg=All;;
				[Tt][Ss][Vv]|[Ss]ession|[Ss]essions|*)
					name= msg=Session;;
			esac
			_cmdmsgf "$msg Files" $'list\n'
			session_listf "$name"; ((OPTEXIT>1)) && exit;
			return 0;
			;;
		#fork current session to [dest_hist]: /fork
		fork*|f\ *)
			_cmdmsgf 'Session' 'fork'
			optsession=4 ;set -- "$*"
			set -- "${1##*([/!])@(fork|f)*([$IFS])}"
			set -- current "${1/\~\//"$HOME"\/}"
			;;
		#search for and copy session to tail: /sub [regex]
		sub*|grep*) 	set -- current current
			REGEX="${name##@(sub|grep)*([$IFS])}" optsession=3
			unset name
			;;
		#copy session from hist option: /copy
		copy*|cp\ *|c\ *)
			_cmdmsgf 'Session' 'copy'
			optsession=3
			set -- "${1##*([/!])@(copy|cp|c)*([$IFS])}" "${@:2}" #two args
			set -- "${@/\~\//"$HOME"\/}"
			;;
		#change to, or create a hist file session
		#break session: //
		[/!]*) 	if [[ "$name" != /[!/]*/* ]] || [[ "$name" = [/!]/*/* ]]
			then 	optsession=2 break=1
				name="${name##[/!]}"
			fi;;
	esac
	
	name="${name##@(session|sub|grep|[Ss])*([$IFS])}"
	name="${name/\~\//"$HOME"\/}"

	#del unused positional args
	args=("$@") ;set --
	for arg in "${args[@]}"
	do 	[[ ${arg} = *[!$IFS]* ]] && set -- "$@" "$arg"
	done

	#print hist option
	if ((OPTHH>1 && OPTHH<=4))
	then 	session_sub_fifof "$name"
		return
	#copy/fork session to destination
	elif ((optsession>2))
	then
		session_copyf "$@" >/dev/null || unset file
		[[ "${OLD_DEST}" = "${FILECHAT}" ]] &&  #check if target is the same as current
		INSTRUCTION_OLD=${GINSTRUCTION:-${INSTRUCTION:-$INSTRUCTION_OLD}} INSTRUCTION= GINSTRUCTION= BREAK_SET= OPTRESUME=1;
		unset OLD_DEST;
	#change to hist file
	else
		#set source session file
		if [[ -f $name ]]
		then 	file="$name"
		elif [[ $name = */* ]] ||
			! file=$(session_globf "$name")
		then
			file=$(session_name_choosef "${name}")
		fi

		case "$file" in
			[Cc]urrent|.) 	file="${FILECHAT}";;
			[Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit) 	return 201;;
		esac
		[[ -f "$file" ]] && msg=change || msg=create
		((!MAIN_LOOP&&!OPTRESUME)) && break=1  #1st invocation
		_cmdmsgf 'Session' "$msg ${break:+ + session break}"

		#break session?
		if [[ -f "${file:-$FILECHAT}" ]]
		then
		    if ((OPTRESUME!=1)) && {  ((break)) || {
		        _sysmsgf 'Break session?' '[N/ys] ' ''
		        case "$(read_charf)" in [YySs]) 	:;; $'\e'|*) 	false ;;esac
		        } ;}
		    then  FILECHAT="${file:-$FILECHAT}" cmd_runf /break;
		          unset MAIN_LOOP HIST_LOOP TOTAL_OLD MAX_PREV;
		    else  #print snippet of tail session
		          [[ ${file:-$FILECHAT} = "$FILECHAT" ]] || ((OPTV+BREAK_SET+break)) ||
		            OPTPRINT=1 session_sub_printf "${file:-$FILECHAT}" >/dev/null
		    fi
		fi
	fi

	[[ ${file:-$FILECHAT} = "$FILECHAT" ]] && msg=Current || msg=Change;
       	FILECHAT="${file:-$FILECHAT}"; _sysmsgf "History $msg:" "${FILECHAT/"$HOME"/"~"}"$'\n';
	((OPTEXIT>1)) && exit;
       	return 0
}
function session_sub_fifof
{
	if [[ -f "$*" ]]
	then 	FILECHAT_OLD="$*"
		session_sub_printf "${*}"
	else 	FILECHAT_OLD="$(session_globf "${*:-*}")" &&
		session_sub_printf "$FILECHAT_OLD"
	fi  >"$FILEFIFO"
	FILECHAT="$FILEFIFO"
}

function cleanupf
{
	((${#PIDS[@]})) || return 0
	for pid in ${PIDS[@]}
       	do 	kill -- $pid 2>/dev/null;
       	done;
	wait ${PIDS[@]}  &>/dev/null;
}

#ollama fun
function set_ollamaf
{
	function list_modelsf
	{
		if ((${#1}))
		then 	curl -\# -L "${OLLAMA_BASE_URL}/api/show" -d "{\"name\": \"$1\"}" -o "$FILE" &&
			{ jq . "$FILE" || ! _warmsgf 'Err' ;}; echo >&2;
			ollama show "$1" --modelfile  2>/dev/null;
		else 	{
			  printf '\nName\tFamily\tFormat\tParam\tQLvl\tSize\tModification\n'
			  curl -s -L "${OLLAMA_BASE_URL}/api/tags" -o "$FILE" &&
			  { jq -r '.models[]|.name?+"\t"+(.details.family)?+"\t"+(.details.format)?+"\t"+(.details.parameter_size)?+"\t"+(.details.quantization_level)?+"\t"+((.size/1000000)|tostring)?+"MB\t"+.modified_at?' "$FILE" || ! _warmsgf 'Err' ;}
			} | { 	column -t -s $'\t' 2>/dev/null || ! _warmsgf 'Err' ;}  #tsv
		fi
	}
	
	ENDPOINTS[0]="/api/generate" ENDPOINTS[5]="/api/embeddings" ENDPOINTS[6]="/api/chat";
	((${#OLLAMA_BASE_URL})) || OLLAMA_BASE_URL=${OPENAI_BASE_URL:-$OLLAMA_BASE_URL_DEF};
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER  #set placeholder as this field is required
	
	OLLAMA_BASE_URL=${OLLAMA_BASE_URL%%*([/$IFS])}; set_model_epnf "$MOD";
	_sysmsgf "OLLAMA URL / Endpoint:" "$OLLAMA_BASE_URL${ENDPOINTS[EPN]}";
}

#host url / endpoint
function set_localaif
{
	if [[ $OPENAI_BASE_URL = *[!$IFS]* ]] || ((OLLAMA))
	then
		BASE_URL=${OPENAI_BASE_URL%%*([/$IFS])};
		((LOCALAI)) &&
		function list_modelsf  #LocalAI only
		{
			if ((${#1}))
			then
				curl -\# -L "${BASE_URL}/models/available" -o "$FILE" &&
				{ jq ".[] | select(.name | contains(\"$1\"))" "$FILE" || ! _warmsgf 'Err' ;}
			else
				curl -\# -L ${FAIL} "${BASE_URL}/models/available" -o "$FILE" &&
				{ jq -r '.[]|.gallery.name+"@"+(.name//empty)' "$FILE" || ! _warmsgf 'Err' ;} ||
				! curl -\# -L "${BASE_URL}/models/" | jq .
				#bug# https://github.com/mudler/LocalAI/issues/2045
			fi
		}  #https://localai.io/models/
		set_model_epnf "$MOD";
		((${#OPENAI_BASE_URL})) && LOCALAI=1;
		((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
		((!LOCALAI)) || _sysmsgf "HOST URL / Endpoint:" "${BASE_URL}${ENDPOINTS[EPN]}${ENDPOINTS[*]:+ [auto-select]}";
	else 	false;
	fi
}

#google ai
function set_googleaif
{
	FILE_PRE="${FILE%%.json}.pre.json";
	GOOGLE_API_KEY=${GOOGLE_API_KEY:-${GEMINI_API_KEY:?Required}}
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
	((${#GOOGLE_BASE_URL})) || GOOGLE_BASE_URL=${OPENAI_BASE_URL:-$GOOGLE_BASE_URL_DEF};
	((OPTC)) || OPTC=2;

	function list_modelsf
	{
		if [[ -z $* ]]
		then 	curl -\# ${FAIL} -L "$GOOGLE_BASE_URL/models?key=$GOOGLE_API_KEY" -o "$FILE"
		else 	curl -\# ${FAIL} -L "$GOOGLE_BASE_URL/models/${1}?key=$GOOGLE_API_KEY" -o "$FILE"
		fi && {
		if ((OPTL>1))
		then 	jq . -- "$FILE";
		else 	jq -r '(.models|.[]?|.name|split("/")|.[1])//.' -- "$FILE" | tee -- "$FILEMODEL";
		fi || cat -- "$FILE" ;};
	}
	function __promptf
	{
		typeset epn;
		epn='generateContent';
		((STREAM)) && epn='streamGenerateContent';
		if curl "$@" ${FAIL} -L "$GOOGLE_BASE_URL/models/$MOD:${epn}?key=$GOOGLE_API_KEY" \
			-H 'Content-Type: application/json' -X POST \
			-d "$BLOCK"  ##| tee "$FILE_PRE" | sed -n 's/^ *"text":.*/{ & }/p'
		then 	[[ \ $*\  = *\ -s\ * ]] || _clr_lineupf;
		else 	return $?;  #E#
		fi
	}
	function embedf
	{
		curl ${FAIL} -L "$GOOGLE_BASE_URL/models/$MOD:embedContent?key=$GOOGLE_API_KEY" \
			-H 'Content-Type: application/json' -X POST \
			-d "{ \"model\": \"models/embedding-001\",
				\"content\": { \"parts\":[{
				  \"text\": \"${1}\"}]} }";
	}
	function __tiktokenf
	{
		typeset epn block buff ret;
		if [[ $MOD = *embedding* ]]
		then 	epn="countTextTokens";
			block="{ \"prompt\": {\"text\": \"${*}\"}}";
		else 	epn="countTokens";
			block="{ \"contents\": [{ \"parts\":[{ \"text\": \"${*}\"}]}]}";
		fi
		if ((${#block}>32000))  #32KB
		then 	buff="${FILE%.*}.block.json";
			printf '%s\n' "$block" >"$buff";
			block="@${buff}";
		fi
		printf '%s\b' 'o' >&2;
		((!${#1})) ||
		  curl -sS --max-time 10 -L "$GOOGLE_BASE_URL/models/$MOD:${epn}?key=$GOOGLE_API_KEY" \
			-H 'Content-Type: application/json' -X POST \
			-d "$block" | jq -er '.totalTokens//.tokenCount//empty'; ret=$?;
		printf '%s\b' ' ' >&2;
		((!ret)) || _tiktokenf "$*";
	}
	function tiktokenf
	{
		if [[ -t 0 ]]
		then 	((!${#1})) || __tiktokenf "$*";
		else 	__tiktokenf "$(<$STDIN)";
		fi
	}
	function response_tknf
	{
		typeset var
		((STREAM)) && var='[-1]';
		jq -r ".${var} | .usageMetadata |
		( (.promptTokenCount//\"0\"), (.candidatesTokenCount//\"0\"), \"0\")" "$@";
	}
	function fmt_ccf
	{
		typeset var ext role
		[[ ${1} = *[!$IFS]* ]] || ((${#MEDIA[@]}+${#MEDIA_CMD[@]})) || return
		var= ext= role=;
		
		case "$2" in
			system) 	role=system; return 1;;
			assistant) 	role=model;;
			''|user|*) 	role=user;;
		esac;
		printf '{"role": "%s", "parts": [ ' "${role}";
		((${#1})) &&
		printf '{"text": "%s"}' "$1";
		for var in "${MEDIA[@]}" "${MEDIA_CMD[@]}"
		do
			if [[ $var != *[!$IFS]* ]]
			then 	continue;
			elif [[ -s $var ]]
			then 	ext=${var##*.}; ((${#ext}<7)) && ext=${ext/[Jj][Pp][Gg]/jpeg} || ext=;
				((${#1})) && printf ',';
				printf '
  {
    "inlineData": {
      "mimeType":"%s/%s",
      "data": "%s"
    }
}' "$(_is_videof "$var" && echo video || echo image)" "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
			elif is_linkf "$var"
			then 	_warmsgf 'GoogleAI: illegal URL --' "${var:0: COLUMNS-25}";
				continue;
			fi
		done;
		printf '%s\n'  ' ] }';
	}
}
#https://ai.google.dev/gemini-api/docs/models/gemini
#Top-P, Top-K, Temperature, Stop sequence, Max output length, Number of response candidates

#anthropic api
function set_anthropicf
{
	: ${ANTHROPIC_API_KEY:?Required}
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER;
	((${#ANTHROPIC_BASE_URL})) || ANTHROPIC_BASE_URL=${OPENAI_BASE_URL:-$ANTHROPIC_BASE_URL_DEF};
	ENDPOINTS[0]="/complete" ENDPOINTS[6]="/messages" OPTA= OPTAA= ;
	if ((ANTHROPICAI)) && ((EPN==0))
	then 	[[ -n ${RESTART+1} ]] || RESTART='\n\nHuman: ';
		[[ -n ${START+1} ]] || START='\n\nAssistant:';
	fi;

	function __promptf
	{
		[[ $MOD =  claude-3-5-sonnet-20240620 ]] &&  #8192 output tokens is in beta 
		  set -- "$@" --header "anthropic-beta: max-tokens-3-5-sonnet-2024-07-15";

		if curl "$@" ${FAIL} -L "${ANTHROPIC_BASE_URL}${ENDPOINTS[EPN]}" \
			--header "x-api-key: $ANTHROPIC_API_KEY" \
			--header "anthropic-version: 2023-06-01" \
			--header "content-type: application/json" \
			--data "$BLOCK";
		then 	[[ \ $*\  = *\ -s\ * ]] || _clr_lineupf;
		else 	return $?;  #E#
		fi
	}
	function response_tknf
	{
		jq -r '(.usage.output_tokens)//"0",
			(.usage.input_tokens)//(.message.usage.input_tokens)//"0", "0"' "$@";
	}
	function _list_modelsf
	{
		printf '%s\n' claude-3-5-sonnet-20240620 claude-3-opus-20240229 \
		claude-3-sonnet-20240229 claude-3-haiku-20240307 \
		claude-2.1 claude-2.0 claude-instant-1.2
	}
	function list_modelsf
	{
		set -- "https://raw.githubusercontent.com/anthropics/anthropic-sdk-python/main/src/anthropic/types";
		{
		  { curl -\# ${FAIL} -L "${1}/model.py" ||
		    curl -\# ${FAIL} -L "${1}/model_param.py" ;} |
		      grep -oe '"[a-z0-9:.-]*"' | tr -d '"';
		  _list_modelsf;
		} | sort | uniq;
	}
}
#there is no model listing endpoint
#rely on the `usage` property in the response for exact token counts
#https://github.com/anthropics/anthropic-sdk-python/blob/main/src/anthropic/_client.py

#@#[[ ${BASH_SOURCE[0]} != "${0}" ]] && return 0;  #!#important for the test script


#parse opts  #DIJQX
unset OPTMM OPTMARG MAIN_LOOP HIST_LOOP; STOPS=();
optstring="a:A:b:B:cCdeEfFgGhHij:kK:lL:m:M:n:N:p:Pqr:R:s:S:t:ToOuUvVxwWyYzZ0123456789@:/,:.:-:"
while getopts "$optstring" opt
do
	case "$opt" in -)  #order matters: anthropic anthropic:ant
		for opt in localai  localai:local-ai  localai:local \
google  google:goo  mistral  openai  groq  grok  grok:xai  anthropic \
anthropic:ant  github  github:git  novita  novita:nov  deepseek deepseek:deep \
w:transcribe  w:stt  W:translate  z:tts  z:speech  Z:last  api-key  multimodal \
vision  audio  markdown  markdown:md  no-markdown  no-markdown:no-md  fold \
fold:wrap  no-fold  no-fold:no-wrap  j:seed  keep-alive  keep-alive:ka \
@:alpha  M:max-tokens  M:max  N:mod-max  N:modmax  a:presence-penalty \
a:presence  a:pre  A:frequency-penalty  A:frequency  A:freq  b:best-of \
b:best  B:logprobs  c:chat  C:resume  C:resume  C:continue  d:text  e:edit \
E:exit  f:no-conf  g:stream  G:no-stream  h:help  H:hist  i:image 'k:no-colo*' \
K:top-k  K:topk  l:list-models  L:log  m:model  m:mod  n:results  o:clipboard \
o:clip  O:ollama  P:print  p:top-p  p:topp  q:insert  r:restart-sequence \
r:restart-seq  r:restart  R:start-sequence  R:start-seq  R:start  s:stop \
S:instruction  t:temperature  t:temp  T:tiktoken  u:multiline  u:multi \
U:cat  v:verbose  x:editor  X:media  y:tik  Y:no-tik  version  info  time \
no-time  awesome-zh  awesome  interactive  no-interactive  effort
		do
			name="${opt##*:}"  name="${name/[_-]/[_-]}"
			opt="${opt%%:*}"
			case "$OPTARG" in $name*) 	break;; esac
		done

		case "$OPTARG" in
			$name|$name=)
				if [[ ${optstring}effort: = *"$opt":* ]]
				then 	OPTARG="${@:$OPTIND:1}"
					OPTIND=$((OPTIND+1))
				fi;;
			$name=*)
				OPTARG="${OPTARG##$name=}"
				;;
			[0-9]*)  #max resp tkns option
				OPTARG="$OPTMM-$OPTARG" opt=M 
				;;
			*) 	_warmsgf "Unknown option:" "--$OPTARG"
				exit 2;;
		esac; unset name;;
	esac
	fix_dotf OPTARG

	case "$opt" in
		@) 	OPT_AT="$OPTARG" EPN=9  #colour name/spec
			if [[ $OPTARG = *%* ]]  #fuzz percentage
			then 	if [[ $OPTARG = *% ]]
				then 	OPT_AT_PC="${OPTARG##${OPTARG%%??%}}"
					OPT_AT_PC="${OPT_AT_PC:-${OPTARG##${OPTARG%%?%}}}"
					OPT_AT_PC="${OPT_AT_PC//[!0-9]}" 
					OPT_AT="${OPT_AT%%"$OPT_AT_PC%"}"
				else 	OPT_AT_PC="${OPTARG%%%*}"
					OPT_AT="${OPT_AT##*%}"
					OPT_AT="${OPT_AT##"$OPT_AT_PC%"}"
				fi ;OPT_AT_PC="${OPT_AT_PC##0}"
			fi;;
		[0-9/-]) 	OPTMM="$OPTMM$opt";;
		M) 	OPTMM="$OPTARG";;
		N) 	[[ $OPTARG = *[!0-9\ ]* ]] && OPTMM="$OPTARG" || OPTNN="$OPTARG";;
		a) 	OPTA="$OPTARG";;
		api-key) if [[ $OPTARG != api-key ]]
			then 	OPENAI_API_KEY="$OPTARG";
			else 	OPENAI_API_KEY=${@: OPTIND:1}; ((++OPTIND));
			fi;;
		A) 	OPTAA="$OPTARG";;
		b) 	OPTB="$OPTARG";;
		B) 	OPTBB="$OPTARG";;
		c) 	((++OPTC));;
		C) 	((++OPTRESUME));;
		d) 	((OPTCMPL)) && OPTCMPL=1 || OPTCMPL=-1;;  #-1: single-turn, 1: multi-turn
		effort) REASON_EFFORT=$OPTARG;;
		e) 	((++OPTE));;
		E) 	((++OPTEXIT));;
		f$OPTF) unset EPN MOD MOD_CHAT MOD_AUDIO MOD_SPEECH MOD_IMAGE MODMAX INSTRUCTION OPTZ_VOICE OPTZ_SPEED OPTZ_FMT OPTC OPTI OPTLOG USRLOG OPTRESUME OPTCMPL CHAT_ENV OPTTIKTOKEN OPTTIK OPTYY OPTFF OPTK OPTKK OPT_KEEPALIVE OPTHH OPTINFO OPTL OPTMARG OPTMM OPTNN OPTMAX OPTA OPTAA OPTB OPTBB OPTN OPTP OPTT OPTTW OPTV OPTVV OPTW OPTWW OPTZ OPTZZ OPTSTOP OPTCLIP CATPR OPTCTRD OPTMD OPT_AT_PC OPT_AT Q_TYPE A_TYPE RESTART START STOPS OPTS_HD OPTI_STYLE OPTSUFFIX SUFFIX CHATGPTRC REC_CMD PLAY_CMD CLIP_CMD STREAM MEDIA MEDIA_CMD MD_CMD OPTE OPTEXIT BASE_URL OLLAMA MISTRALAI LOCALAI GROQAI ANTHROPICAI GITHUBAI NOVITAAI XAI GOOGLEAI GPTCHATKEY READLINEOPT MULTIMODAL OPTFOLD HISTSIZE WAPPEND NO_DIALOG NO_OPTMD_AUTO WHISPER_GROQ INST_TIME REASON_EFFORT REASON_INTERACTIVE;
			unset MOD_LOCALAI MOD_OLLAMA MOD_MISTRAL MOD_GOOGLE MOD_GROQ MOD_AUDIO_GROQ MOD_ANTHROPIC MOD_GITHUB MOD_NOVITA MOD_XAI;
			unset RED BRED YELLOW BYELLOW PURPLE BPURPLE ON_PURPLE CYAN BCYAN WHITE BWHITE INV ALERT BOLD NC;
			unset Color1 Color2 Color3 Color4 Color5 Color6 Color7 Color8 Color9 Color10 Color11 Color200 Inv Alert Bold Nc;
			OPTF=1 OPTIND=1 OPTARG= ;. "${BASH_SOURCE[0]:-$0}" "$@" ;exit;;
		F) 	((++OPTFF));;
		fold) 	OPTFOLD=1;;
		no-fold) 	unset OPTFOLD;;
		g) 	STREAM=1;;
		G) 	unset STREAM;;
		h) 	printf '%s\n' "$REPLY" "$HELP"
			exit;;
		H) 	((++OPTHH));;
		P) 	((OPTHH)) && ((++OPTHH)) || OPTHH=2;;
		interactive) REASON_INTERACTIVE=true;;
		no-interactive)  REASON_INTERACTIVE=false;;
		i) 	OPTI=1 EPN=3;;
		info) 	OPTINFO=1 OPTL=1;;
		keep-alive)
			if [[ $OPTARG != @(keep-alive|ka) ]]
			then 	OPT_KEEPALIVE=$OPTARG;
			elif { (( ${@: OPTIND:1} )) ;} 2>/dev/null
			then 	OPT_KEEPALIVE=${@: OPTIND:1}; ((++OPTIND));
			fi;;
		k) 	OPTK=1;;
		K) 	OPTKK="$OPTARG";;
		l) 	((++OPTL));;
		L) 	OPTLOG=1
			if [[ -d "$OPTARG" ]]
			then 	USRLOG="${OPTARG%%/}/${USRLOG##*/}"
			else 	USRLOG="${OPTARG:-${USRLOG}}"
			fi
			USRLOG="${USRLOG/\~\//"$HOME"\/}"
			_sysmsgf 'Log File' "<${USRLOG/"$HOME"/"~"}>";;
		m) 	OPTMARG="${OPTARG:-$MOD}" MOD="$OPTMARG";;
		markdown) 	((++OPTMD));
			if [[ $OPTARG != @(markdown|md) ]]
			then 	MD_CMD=$OPTARG;
			elif var=${@: OPTIND:1}
				command -v "${var%% *}" &>/dev/null
			then 	MD_CMD=${@: OPTIND:1}; ((++OPTIND));
			fi; unset var;;
		no-markdown) 	OPTMD=0;;
		audio) 	MULTIMODAL=2 EPN=6;;
		multimodal|vision) MULTIMODAL=1 EPN=6;;
		n) 	[[ $OPTARG = *[!0-9\ ]* ]] && OPTMM="$OPTARG" ||  #compat with -Nill option
			OPTN="$OPTARG" ;;
		o) 	OPTCLIP=1;;
		O) 	OLLAMA=1 GOOGLEAI= MISTRALAI= GROQAI= ANTHROPICAI= GITHUBAI= NOVITAAI= XAI= DEEPSEEK= ;;
		google) GOOGLEAI=1 OLLAMA= MISTRALAI= GROQAI= ANTHROPICAI= GITHUBAI= NOVITAAI= XAI= DEEPSEEK= ;;
		mistral) MISTRALAI=1 OLLAMA= GOOGLEAI= GROQAI= ANTHROPICAI= GITHUBAI= NOVITAAI= XAI= DEEPSEEK= ;;
		localai) LOCALAI=1;;
		openai) GOOGLEAI= OLLAMA= MISTRALAI= GROQAI= ANTHROPICAI= GITHUBAI= NOVITAAI= XAI= DEEPSEEK= ;;
		groq) 	GROQAI=1 GOOGLEAI= OLLAMA= MISTRALAI= ANTHROPICAI= GITHUBAI= NOVITAAI= XAI= DEEPSEEK= ;;
		grok) 	XAI=1 GROQAI= GOOGLEAI= OLLAMA= MISTRALAI= ANTHROPICAI= GITHUBAI= NOVITAAI= DEEPSEEK= ;;
		anthropic) ANTHROPICAI=1 GROQAI= GOOGLEAI= OLLAMA= MISTRALAI= GITHUBAI= NOVITAAI= XAI= DEEPSEEK= ;;
		github) GITHUBAI=1 ANTHROPICAI= GROQAI= GOOGLEAI= OLLAMA= MISTRALAI= NOVITAAI= XAI= DEEPSEEK= ;;
		novita) NOVITAAI=1 ANTHROPICAI= GROQAI= GOOGLEAI= OLLAMA= MISTRALAI= GITHUBAI= XAI= DEEPSEEK= ;;
		deepseek) DEEPSEEK=1 NOVITAAI= ANTHROPICAI= GROQAI= GOOGLEAI= OLLAMA= MISTRALAI= GITHUBAI= XAI= ;;
		p) 	OPTP="$OPTARG";;
		q) 	((++OPTSUFFIX)); EPN=0;;
		r) 	RESTART="$OPTARG";;
		R) 	START="$OPTARG";;
		j) 	OPTSEED=$OPTARG;;
		s) 	STOPS=("$OPTARG" "${STOPS[@]}");;
		awesome-zh) INSTRUCTION=%$INSTRUCTION;;
		awesome) INSTRUCTION=/$INSTRUCTION;;
		S|.|,) 	if [[ $opt == S ]] && [[ -f "$OPTARG" ]]
			then 	INSTRUCTION="${opt##S}$(<"$OPTARG")"
			else 	INSTRUCTION="${opt##S}$OPTARG"
			fi;;
		time) 	INST_TIME=1;;
		no-time) 	INST_TIME=-1;;
		t) 	OPTT="$OPTARG" OPTTARG="$OPTARG";;
		T) 	((++OPTTIKTOKEN));;
		u) 	((OPTCTRD)) && unset OPTCTRD || OPTCTRD=1
			cmdmsgf 'Prompter <Ctrl-D>' $(_onoff $OPTCTRD);;
		U) 	CATPR=1;;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		version) while read; do 	[[ $REPLY = \#\ v* ]] || continue; printf '%s\n' "$REPLY"; exit; done <"${BASH_SOURCE[0]:-$0}";;
		x) 	((OPTX)) && OPTX=2 || OPTX=1;;
		w) 	((++OPTW)); WSKIP=1;;
		W) 	((++OPTW)); ((++OPTWW)); WSKIP=1;;
		y) 	OPTTIK=1;;
		Y) 	OPTTIK= OPTYY=1;;
		z) 	OPTZ=1;;
		Z) 	((++OPTZZ));;
		\?) 	exit 1;;
	esac; OPTARG= ;
done
shift $((OPTIND -1))
unset LANGW MTURN CHAT_ENV SKIP EDIT INDEX HERR BAD_RES REPLY REPLY_CMD REPLY_CMD_DUMP REPLY_CMD_BLOCK REPLY_TRANS REGEX SGLOB EXT PIDS NO_CLR WARGS ZARGS WCHAT_C MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND SMALLEST DUMP RINSERT BREAK_SET SKIP_SH_HIST OK_DIALOG DIALOG_CLR OPT_SLES RET CURLTIMEOUT MOD_REASON MOD_THINK STURN LINK_CACHE LINK_CACHE_BAD HARGS GINSTRUCTION_PERM MD_AUTO  init buff var tkn n s
typeset -a PIDS MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND WARGS ZARGS
typeset -l VOICEZ OPTZ_FMT  #lowercase vars

set -o ${READLINEOPT:-emacs};
bind 'set enable-bracketed-paste on';
bind -x '"\C-x\C-e": "_edit_no_execf"';
bind '"\C-j": "\C-v\C-j"';  #add newline with Ctrl-J
[[ $BASH_VERSION = [5-9]* ]] || ((OPTV)) || _warmsgf 'Warning:' 'Bash 5+ recommended';

[[ -t 1 ]] || OPTK=1 ;((OPTK)) || {
  #map colours
  : "${RED:=${Color1:=${Red}}}"       "${BRED:=${Color2:=${BRed}}}"  #warning / error
  : "${YELLOW:=${Color3:=${Bold}}}"   "${BYELLOW:=${Color4}}"  #response
  : "${PURPLE:=${Color5:=${Purple}}}" "${BPURPLE:=${Color6:=${BPurple}}}" "${ON_PURPLE:=${Color7:=${On_Purple}}}"  #whisper
  : "${CYAN:=${Color8:=${Cyan}}}"     "${BCYAN:=${Color9:=${BCyan}}}"  "${ON_CYAN:=${Color12:=${On_Cyan}}}"  #user, Color12 needs adding to all themes
  : "${WHITE:=${Color10}}"            "${BWHITE:=${Color11:=${Bold}}}"  #system
  : "${INV:=${Inv}}" "${ALERT:=${Alert}}" "${BOLD:=${Bold}}" "${NC:=${Nc}}"
  JQCOL="\
  def red:     \"${RED//\\e/\\u001b}\";     \
  def yellow:  \"${YELLOW//\\e/\\u001b}\";  \
  def byellow: \"${BYELLOW//\\e/\\u001b}\"; \
  def bpurple: \"${BPURPLE//\\e/\\u001b}\"; \
  def reset:   \"${NC//\\e/\\u001b}\";"
}
JQCOLNULL="\
def red:     null; \
def yellow:  null; \
def byellow: null; \
def bpurple: null; \
def reset:   null;"

if ((OPTCMPL<0))
then 	OPTCMPL=;  #single-turn text completions -d
elif ((!(OPTCMPL+OPTC+OPTZZ+OPTL+OPTI+OPTTIKTOKEN+OPTFF) ))
then 	OPTT=${OPTT:-0.8} STURN=1;  #single-turn chat completions demo
fi
((OPTL+OPTZZ)) && unset OPTX
((OPTZ && OPTW)) && unset OPTX
((OPTI)) && unset OPTC
((OPTCLIP)) && set_clipcmdf
((OPTW+OPTWW)) && ((!(OPTI+OPTL+OPTFF+OPTHH+OPTZZ+OPTTIKTOKEN) )) && set_reccmdf
((OPTZ)) && set_playcmdf
((OPTC)) || OPTT="${OPTT:-0}"  #!#temp *must* be set
((OPTCMPL)) && unset OPTC  #opt -d
((!OPTC)) && ((OPTRESUME>1)) && OPTCMPL=${OPTCMPL:-$OPTRESUME}  #1# txt cmpls cont
((OPTCMPL)) && ((!OPTRESUME)) && OPTCMPL=2  #2# txt cmpls new
((OPTC+OPTCMPL || OPTRESUME>1)) && MTURN=1  #multi-turn, interactive
((OPTSUFFIX)) && ((OPTC)) && { ((OPTC>1)) || { [[ -n ${RESTART+1} ]] || RESTART=; [[ -n ${START+1} ]] || START= ;}; OPTC=1; };  #-qqc and -qqcc  #weyrd combo#
((OPTSUFFIX>1)) && MTURN=1 OPTSUFFIX=1      #multi-turn -q insert mode
((OPTCTRD)) || unset OPTCTRD  #(un)set <ctrl-d> prompter flush [bash]
[[ ${INSTRUCTION} = *[!$IFS]* ]] || unset INSTRUCTION

#map models
if [[ -n $OPTMARG ]]
then 	((OPTI)) && MOD_IMAGE=$OPTMARG  #default models for functions
	((OPTW && !(OPTC+OPTCMPL+MTURN) )) && MOD_AUDIO=$OPTMARG
	((OPTZ && !(OPTC+OPTCMPL+MTURN) )) && MOD_SPEECH=$OPTMARG
	case "$MOD" in moderation|oderation) 	MOD="text-moderation-stable";; esac;
	[[ $MOD = *moderation* ]] && unset OPTC OPTW OPTWW OPTZ OPTI OPTII MTURN OPTRESUME OPTCMPL OPTEMBED
else
	if ((OLLAMA))
	then 	MOD=$MOD_OLLAMA
	elif ((GOOGLEAI))
	then 	MOD=$MOD_GOOGLE
	elif ((MISTRALAI)) || [[ $OPENAI_BASE_URL = *mistral* ]]
	then 	MOD=$MOD_MISTRAL
	elif ((GROQAI))
	then 	MOD=$MOD_GROQ MOD_AUDIO=$MOD_AUDIO_GROQ
	elif ((XAI))
	then 	MOD=$MOD_XAI
	elif ((ANTHROPICAI))
	then 	MOD=$MOD_ANTHROPIC
	elif ((LOCALAI))
	then 	MOD=$MOD_LOCALAI
	elif ((GITHUBAI))
	then 	MOD=$MOD_GITHUB
	elif ((NOVITAAI))
	then 	MOD=$MOD_NOVITA
	elif ((DEEPSEEK))
	then 	MOD=$MOD_DEEPSEEK
	elif ((!OPTCMPL))
	then 	if ((OPTC>1)) ||  #chat / single-turn
			((STURN && !(OPTW+OPTZ+OPTI) ))
		then 	MOD=$MOD_CHAT
		elif ((OPTW)) && ((!MTURN))  #whisper endpoint
		then 	((GROQAI)) && MOD_AUDIO=$MOD_AUDIO_GROQ
			MOD=$MOD_AUDIO
		elif ((OPTZ)) && ((!MTURN))  #speech endpoint
		then 	MOD=$MOD_SPEECH
		elif ((OPTI))
		then 	MOD=$MOD_IMAGE
		fi
	fi
fi

#image endpoints
if ((OPTI))
then 	command -v base64 >/dev/null 2>&1 || OPTI_FMT=url;
	n=; for arg
	do 	[[ -f $arg ]] && OPTII=1 n=$((n+1));  #img vars or edits
	done;
	((${#OPT_AT} || n>1)) && OPTII=1 OPTII_EDITS=1;  #img edits
	case "$3" in vivid|natural) OPTI_STYLE=$3;; hd|HD|standard) OPTS_HD=$3; set -- "${@:1:2}" "${@:4}";; esac;
	case "$2" in vivid|natural) OPTI_STYLE=$2;; hd|HD|standard) OPTS_HD=$2; set -- "${@:1:1}" "${@:3}";; esac;
	case "$1" in vivid|natural) OPTI_STYLE=$1;; hd|HD|standard) OPTS_HD=$1; shift;; esac;
	[[ -n $OPTS ]] && set_imgsizef "$OPTS";
	set_imgsizef "$1" && shift;
	unset STREAM arg n;
fi

#google integration
if case "${GOOGLE_BASE_URL:-$OPENAI_BASE_URL}" in *googleapis.com*) :;; *) ((GOOGLEAI));; esac
then 	set_googleaif;
	unset OPTTIK OLLAMA MISTRALAI GROQAI ANTHROPICAI GITHUBAI NOVITAAI XAI DEEPSEEK;
else 	unset GOOGLEAI;
fi

#groq integration
if case "${GROQ_BASE_URL:-$OPENAI_BASE_URL}" in *api.groq.com*) :;; *) ((GROQAI));; esac
then
	BASE_URL=${GROQ_BASE_URL:-${OPENAI_BASE_URL:-$GROQ_BASE_URL_DEF}};
	OPENAI_API_KEY=${GROQ_API_KEY:?Required}
	((OPTC==1 || OPTCMPL)) && OPTC=2;
	ENDPOINTS[0]=${ENDPOINTS[6]};
	unset OLLAMA GOOGLEAI MISTRALAI ANTHROPICAI GITHUBAI NOVITAAI XAI DEEPSEEK;
else 	unset GROQAI;
fi  #https://console.groq.com/docs/api-reference

#grok integration
if case "${XAI_BASE_URL:-$OPENAI_BASE_URL}" in *api.x.ai*) :;; *) ((XAI));; esac
then
	BASE_URL=${XAI_BASE_URL:-${OPENAI_BASE_URL:-$XAI_BASE_URL_DEF}};
	OPENAI_API_KEY=${XAI_API_KEY:?Required};
	unset OLLAMA GOOGLEAI MISTRALAI ANTHROPICAI GITHUBAI NOVITAAI GROQAI DEEPSEEK;
else 	unset XAI;
fi  #https://docs.x.ai/api

#anthropic integration
if case "${ANTHROPIC_BASE_URL:-$OPENAI_BASE_URL}" in *api.anthropic.com*) :;; *) ((ANTHROPICAI));; esac
then 	set_anthropicf;
	unset OLLAMA GOOGLEAI MISTRALAI GROQAI GITHUBAI NOVITAAI XAI DEEPSEEK;
else 	unset ANTHROPICAI;
fi

#ollama integration
if case "${OPENAI_BASE_URL}" in *localhost:11434*) :;; *) ((OLLAMA));; esac
then 	set_ollamaf;
	unset GOOGLEAI MISTRALAI GROQAI ANTHROPICAI GITHUBAI NOVITAAI XAI DEEPSEEK;
else  	unset OLLAMA OLLAMA_BASE_URL;
fi

#custom host / localai
if case "${OPENAI_URL_PATH}${OPENAI_BASE_URL}" in *[!$IFS]*) :;; *) ((LOCALAI));; esac
then
	[[ ${OPENAI_URL_PATH} = *[!$IFS]* ]] && OPENAI_BASE_URL=$OPENAI_URL_PATH ENDPOINTS=();  #endpoint auto select
	[[ ${OPENAI_BASE_URL} = *[!$IFS]* ]] || OPENAI_BASE_URL=;
	((${#OPENAI_BASE_URL})) || OPENAI_BASE_URL=$LOCALAI_BASE_URL_DEF;
	set_localaif;
else 	unset OPENAI_URL_PATH;
fi

#mistral ai api
if case "${MISTRAL_BASE_URL:-$OPENAI_BASE_URL}" in *api.mistral.ai*) :;; *) ((MISTRALAI));; esac
then
	OPENAI_API_KEY=${MISTRAL_API_KEY:?Required};
	BASE_URL=${MISTRAL_BASE_URL:-${OPENAI_BASE_URL:-$MISTRAL_BASE_URL_DEF}};

	if [[ $MOD = *code* ]]
	then 	ENDPOINTS[0]="/fim/completions"
		((OPTSUFFIX)) && ((OPTC)) && OPTC=1;
	elif [[ $MOD != *embed* ]]
	then 	OPTSUFFIX= OPTCMPL= OPTC=2;
	fi; MISTRALAI=1;
	unset LOCALAI OLLAMA GOOGLEAI GROQAI ANTHROPICAI GITHUBAI OPTA OPTAA OPTB NOVITAAI XAI DEEPSEEK;
elif unset MISTRAL_API_KEY MISTRAL_BASE_URL MISTRALAI;
#github azure api
	case "${GITHUB_BASE_URL:-$OPENAI_BASE_URL}" in *ai.azure.com*) :;; *) ((GITHUBAI));; esac
then
	OPENAI_API_KEY=${GITHUB_API_KEY:-${GITHUB_TOKEN:?Required}}
	BASE_URL=${GITHUB_BASE_URL:-${OPENAI_BASE_URL:-$GITHUB_BASE_URL_DEF}};

	function list_modelsf
	{
		if ((OPTL<2)) && [[ $* != *[!$IFS]* ]]
		then
			curl -L -\# 'https://github.com/marketplace/models' -H 'x-requested-with: XMLHttpRequest' |
			jq -r '.[] | select(.task == "chat-completion") | .original_name' | tee -- "$FILEMODEL";
		elif [[ $* = *[!$IFS]* ]]
		then
			curl -L -\# 'https://github.com/marketplace/models' -H 'x-requested-with: XMLHttpRequest' |
			jq -r ".[] | select(.original_name == \"$*\")";
			return;
		else
			curl -L -\# "${BASE_URL}/models" -H "Authorization: Bearer $GITHUB_TOKEN" |
			jq -r '.[].name' | tee -- "$FILEMODEL";
		fi
		#https://github.com/marketplace/info
	};
	GITHUBAI=1 OPTC=2;  #chat completions only
	unset LOCALAI OLLAMA GOOGLEAI GROQAI ANTHROPICAI MISTRALAI NOVITAAI XAI DEEPSEEK;
elif unset GITHUB_TOKEN GITHUB_BASE_URL GITHUBAI;
#deepseek
	case "${DEEPSEEK_BASE_URL:-$OPENAI_BASE_URL}" in *deepseek.com*) :;; *) ((DEEPSEEK));; esac
then
	OPENAI_API_KEY=${DEEPSEEK_API_KEY:?Required};
	BASE_URL=${DEEPSEEK_BASE_URL:-$DEEPSEEK_BASE_URL_DEF};
	DEEPSEEK=1;
	unset LOCALAI OLLAMA GOOGLEAI GROQAI ANTHROPICAI MISTRALAI NOVITAAI XAI;

#Unsupported：temperature、top_p、presence_penalty、frequency_penalty、logprobs (err)、top_logprobs  (err).

elif unset DEEPSEEK_API_KEY DEEPSEEK_BASE_URL DEEPSEEK;
#novita ai
	case "${NOVITA_BASE_URL:-$OPENAI_BASE_URL}" in *api.novita.ai*) :;; *) ((NOVITAAI));; esac
then
	OPENAI_API_KEY=${NOVITA_API_KEY:?Required};
	BASE_URL=${NOVITA_BASE_URL:-${OPENAI_BASE_URL:-$NOVITA_BASE_URL_DEF}};
	NOVITAAI=1;
	unset LOCALAI OLLAMA GOOGLEAI GROQAI ANTHROPICAI MISTRALAI XAI DEEPSEEK;
else 	
	unset NOVITA_API_KEY NOVITA_BASE_URL NOVITAAI;
fi

OPENAI_API_KEY="${OPENAI_API_KEY:-${OPENAI_KEY:-${OPENAI_API_KEY:?Required}}}"

pick_modelf "$MOD"
#``model endpoint'' and ``model capacity''
[[ -n $EPN ]] || set_model_epnf "$MOD"
((MODMAX)) || model_capf "$MOD"

#``max model / response tkns''
[[ -n $OPTNN && -z $OPTMM ]] ||
set_maxtknf "${OPTMM:-$OPTMAX}"
[[ -n $OPTNN ]] && MODMAX="$OPTNN"

#model options
((OPTFF+OPTHH+OPTZZ+OPTL+OPTTIKTOKEN)) ||
set_optsf  #IPC#

#model prices (promote var to array)
(( ${#MOD_PRICE[@]}+${#COST_CUSTOM[@]} )) &&  #$COST_CUSTOM is deprecated
  MOD_PRICE=( ${MOD_PRICE[@]:-${COST_CUSTOM[@]}} )

#markdown rendering
if ((OPTMD+${#MD_CMD}))
then 	set_mdcmdf "$MD_CMD";
	((OPTMD)) || OPTMD=1;
fi
((${#OPTMD}+${#MD_CMD})) && NO_OPTMD_AUTO=1  #disable markdown auto detect
#o1 models in the API will avoid generating responses with markdown formatting

#stdin and stderr filepaths
if [[ -n $TERMUX_VERSION ]]
then 	STDIN='/proc/self/fd/0' STDERR='/proc/self/fd/2'
else 	STDIN='/dev/stdin'      STDERR='/dev/stderr'
fi

#dump and append text from supported file types, and stdin
if ((OPTX)) && ((OPTEMBED+OPTI+OPTZ+OPTTIKTOKEN)) && ((!(OPTC+OPTCMPL) ))
then
	((OPTEMBED+OPTI+OPTZ)) && ((${#})) &&
	if is_txtfilef "${@:${#}}" || is_pdff "${@:${#}}" || is_docf "${@:${#}}"
	then
		OPTV=4 cmd_runf /cat "${@:${#}}";
		((!RET && ${#REPLY})) && set -- "${@:1:${#}-1}" "$REPLY";
	elif is_txtfilef "$1" || is_pdff "$1" || is_docf "$1"
	then
		OPTV=4 cmd_runf /cat "$1";
		((!RET && ${#REPLY})) && set -- "$REPLY" "${@:2}";
	fi  #D#

	{ ((OPTI)) && ((${#})) && [[ -f ${@:${#}} ]] ;} ||
	  [[ -t 0 ]] || set -- "$@" "$(<$STDIN)";
	
	edf "$@" && set -- "$(<"$FILETXT")";
elif ! ((OPTTIKTOKEN+OPTI))
then
	((${#})) &&
	if is_txtfilef "${@:${#}}" || is_pdff "${@:${#}}" || is_docf "${@:${#}}"
	then
		OPTV=4 cmd_runf /cat "${@:${#}}";
		((!RET && ${#REPLY})) && set -- "${@:1:${#}-1}" "$REPLY";
	elif is_txtfilef "$1" || is_pdff "$1" || is_docf "$1"
	then
		OPTV=4 cmd_runf /cat "$1";
		((!RET && ${#REPLY})) && set -- "$REPLY" "${@:2}";
	fi  #D#

	[[ -t 0 ]] || ((OPTZZ+OPTL+OPTFF+OPTHH)) || set -- "$@" "$(<$STDIN)";
fi; REPLY= RET=;

#tips and warnings
if ((!(OPTI+OPTL+OPTW+OPTZ+OPTZZ+OPTTIKTOKEN+OPTFF) || (OPTC+OPTCMPL && OPTW+OPTZ) )) && [[ $MOD != *moderation* ]]
then 	if ((!OPTHH)) && ((!OPTV))
	then 	sysmsgf "Response / Capacity:" "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
	elif ((OPTHH>1))
	then 	sysmsgf 'Language Model:' "$MOD"
	fi
fi

(( (OPTI+OPTEMBED) || (OPTW+OPTZ && !MTURN) )) &&
for arg  #!# escape input
do 	((init++)) || set --
	set -- "$@" "$(escapef "$arg")"
done; unset arg init;

#handle options of combined modes: chat + whisper + tts
if ((OPTW+OPTZ)) && ((${#}))
then 	typeset -a argn; argn=();
	n=1 custom=; for arg
	do 	case "${arg:0:4}" in --) argn=(${argn[@]} $n);; esac; ((++n));
	done; #map double hyphens `--'
	case "$1" in [/!.,][[:alnum:]]*|[.,][.,][[:alnum:]]*)
		((${#1}>320)) || { custom="$1"; shift; };;
	esac;  #cmd or custom prompt name
	if ((${#argn[@]}>=2)) && ((OPTW)) && ((OPTZ))  #improbable case
	then 	((ii=argn[1]-argn[0])); ((ii<1)) && ii=1;
		WARGS=("${@: argn[0]+1: ii-1}");
		ZARGS=("${@: argn[1]+1}");
		set -- "${@:1: argn[0]-1}";
	elif ((${#argn[@]}==1)) && ((OPTW)) && ((OPTZ))
	then 	WARGS=("${@:1: argn[0]-1}");
		ZARGS=("${@: argn[0]+1}");
		set -- ;
	elif ((${#argn[@]})) && ((OPTW))
	then 	WARGS=("${@: argn[0]+1}");
		set -- "${@:1: argn[0]-1}";
	elif ((${#argn[@]})) && ((OPTZ))
	then 	ZARGS=("${@: argn[0]+1}");
		set -- "${@:1: argn[0]-1}";
	elif ((MTURN||STURN)) && [[ ! -e $1 && ! -e ${@:${#}} ]]
	then 	if ((OPTW)) && ((${#}<=2 && ${#1}+${#2}+${#3}<18))
		then 	WARGS=("$@");
			set -- ;
		elif ((OPTZ)) && ((${#}<=3 && ${#1}+${#2}+${#3}+${#4}<34))
		then 	ZARGS=("$@");
			set -- ;
		fi;  #best-effort divination
	fi
	((${#custom})) && set -- "$custom" "$@";
	[[ -z ${WARGS[*]} ]] && unset WARGS;
	[[ -z ${ZARGS[*]} ]] && unset ZARGS;
	((${#WARGS[@]})) && ((${#ZARGS[@]})) && ((${#})) && {
	  var=$* p=${var:128} var=${var:0:128}; cmdmsgf 'Text Prompt' "${var//\\\\[nt]/  }${p:+ [..]}" ;}
	((${#WARGS[@]})) && cmdmsgf "Whisper Args #${#WARGS[@]}" "${WARGS[*]:-unset}"
	((${#ZARGS[@]})) && cmdmsgf 'TTS Args' "${ZARGS[*]:-unset}";
	unset n p ii var arg argn custom;
fi

((${#TERMUX_VERSION})) && [[ ! -d $OUTDIR ]] && _warmsgf 'Err:' "Output directory -- ${OUTDIR/"$HOME"/"~"}";
[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR" ||
  { _warmsgf 'Err:' "Cannot create cache directory -- \`${CACHEDIR/"$HOME"/"~"}'"; exit 1; }
if ! command -v jq >/dev/null 2>&1
then 	function jq { 	false ;}
	function escapef { 	_escapef "$@" ;}
	function unescapef { 	_unescapef "$@" ;}
	Color200=$INV _warmsgf 'Warning:' 'JQ not found. Please, install JQ.'
fi
command -v tac >/dev/null 2>&1 || function tac { 	tail -r "$@" ;}  #bsd
((!(OPTHH+OPTFF+OPTZZ) )) &&
  case "$(curl --version 2>&1)" in
    curl\ [0-6][.\ ]*|curl\ 7.[0-9][.\ ]*|curl\ 7.[0-6][0-9][.\ ]*|curl\ 7.7[0-5][.\ ]*)  unset FAIL;;
    *)  FAIL="--fail-with-body";;
  esac;

trap 'cleanupf; exit;' EXIT
trap 'exit' HUP QUIT TERM KILL

if ((OPTZZ))  #last response json
then 	lastjsonf;
elif ((OPTINFO))
then 	get_infof;
elif ((OPTL))  #model list
then 	#(shell completion script)
	((OPTL>2)) && [[ -s $FILEMODEL ]] && cat -- "$FILEMODEL" ||
	list_modelsf "$@";
elif ((OPTFF))
then 	if [[ -s "$CHATGPTRC" ]] && ((OPTFF<2))
	then 	_edf "$CHATGPTRC";
	else 	curl --fail -L "https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/.chatgpt.conf";
		CHATGPTRC="stdout [$CHATGPTRC]";
	fi; _sysmsgf 'Conf File:' "${CHATGPTRC/"$HOME"/"~"}";
elif ((OPTHH && OPTW)) && ((!(OPTC+OPTCMPL+OPTRESUME+MTURN) )) && [[ -f $FILEWHISPERLOG ]]
then  #whisper log
	if ((OPTHH>1))
	then 	BUFF="";
		while IFS= read -r || [[ -n $REPLY ]]
		do 	[[ $REPLY = ==== ]] && [[ -n $BUFF ]] && break;
			BUFF=${REPLY}$'\n'${BUFF};
		done < <(tac "$FILEWHISPERLOG");
		printf '%s' "$BUFF";
	else 	_edf "$FILEWHISPERLOG"
	fi; _sysmsgf 'Whisper Log:' "$FILEWHISPERLOG";
elif ((OPTHH))  #edit history/pretty print last session
then 	OPTRESUME=1 BREAK_SET=
	[[ -z $INSTRUCTION && $1 = [.,][!$IFS]* ]] && INSTRUCTION=$1 && shift;
	if [[ $INSTRUCTION = [.,]* ]]
	then 	custom_prf
	elif [[ -n $* ]] && [[ $* != *($SPC)/* ]]
	then 	set -- /session"$@"
	fi
	session_mainf "${@}"
	fix_breakf "$FILECHAT";

	if ((OPTHH>1))
	then
		((OPTC || EPN==6)) && OPTC=2;
		((OPTC+OPTRESUME+OPTCMPL)) || OPTC=1;
		MODMAX=$((MODMAX+1048576)) || MODMAX=1048576;
		Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" OLLAMA= set_histf '';

		HIST=$(unescapef "${HIST:-"-*>[SESSION BREAK]<*-"}")
		if ((OPTMD))
		then 	usr_logf "$HIST" | mdf
		else 	usr_logf "$HIST" | foldf
		fi
		[[ ! -e $FILEFIFO ]] || rm -- "$FILEFIFO"
	elif [[ -t 1 ]]
	then 	_edf "$FILECHAT"
	else 	cat -- "$FILECHAT"
	fi
	_sysmsgf "Hist   File:" "${FILECHAT_OLD:-$FILECHAT}"
elif ((OPTTIKTOKEN))
then
	((OPTTIKTOKEN>2)) || sysmsgf 'Language Model:' "$MOD"
	((${#})) || [[ -t 0 ]] || set -- "-"
	[[ -f $* ]] && [[ -t 0 ]] &&
	if is_pdff "$*" || is_docf "$*"
	then 	exec 0< <(OPTV=4 cmd_runf /cat "$*"; printf '%s\n' "$REPLY") && set -- "-";
	else 	exec 0<"$*" && set -- "-";  #exec max one file
	fi
	if ((OPTYY))  #option -Y (debug, mostly)
	then 	if [[ ! -t 0 ]]
       		then 	__tiktokenf "$(<$STDIN)";
       		else 	__tiktokenf "$*";
		fi
	else
		tiktokenf "$*" || ! _warmsgf "Err:" "Python / Tiktoken"
	fi
elif ((OPTW)) && ((!MTURN))  #audio transcribe/translation
then
	[[ -z ${WARGS[*]} ]] || set -- "${WARGS[@]}" "$@";
	if [[ $1 = @(.|last|retry) ]] && [[ -s $FILEINW ]]
	then 	set -- "$FILEINW" "${@:2}";
	elif ((${#} >1)) && [[ ${@:${#}} = @(.|last|retry) ]] && [[ -s $FILEINW ]]
	then 	set -- "$FILEINW" "${@:1:${#}-1}";
	fi
	((${#OPTTARG})) && OPTTW=$OPTTARG;
	whisperf "$@" &&
	if ((OPTZ)) && WHISPER_OUT=$(jq -r "if .segments then (.segments[].text//empty) else (.text//empty) end" "$FILE" 2>/dev/null) &&
		((${#WHISPER_OUT}))
	then 	_sysmsgf $'\nText-To-Speech'; CHAT_ENV=1; set -- ;
		[[ -z ${ZARGS[*]} ]] || set -- "${ZARGS[@]}" "$@";
		ttsf "$@" "$(escapef "$WHISPER_OUT")";
	fi
elif ((OPTZ)) && ((!MTURN))  #speech synthesis
then 	[[ -z ${ZARGS[*]} ]] || set -- "${ZARGS[@]}" "$@";
	_ttsf "$@"
elif ((OPTII))     #image variations+edits
then 	if ((${#}>1))
	then 	sysmsgf 'Image Edits'
	else 	sysmsgf 'Image Variations' ;fi
	if [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	sysmsgf 'Image Size / Quality:' "${OPTS:-err} / ${OPTS_HD:-standard}${OPTI_STYLE:+ / $OPTI_STYLE}"
	else 	sysmsgf 'Image Size:' "${OPTS:-err}"
	fi
	imgvarf "$@"
elif ((OPTI))      #image generations
then 	sysmsgf 'Image Generations'
	sysmsgf 'Image Model:' "$MOD_IMAGE"
	if [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	sysmsgf 'Image Size / Quality:' "${OPTS:-err} / ${OPTS_HD:-standard}${OPTI_STYLE:+ / $OPTI_STYLE}"
	else 	sysmsgf 'Image Size:' "${OPTS:-err}"
	fi
	imggenf "$@"
elif ((OPTEMBED))  #embeds
then 	[[ $MOD = *embed* ]] || [[ $MOD = *moderation* ]] \
	|| _warmsgf "Warning:" "Not an embedding model -- $MOD"
	unset Q_TYPE A_TYPE OPTC OPTCMPL STREAM
	if ((!${#}))
	then 	_clr_ttystf; echo 'Input:' >&2;
		read_mainf REPLY </dev/tty
		((OPTCTRD)) && REPLY=$(trim_trailf "$REPLY" $'*([\r])')
		set -- "$REPLY"; echo >&2;
	fi
	if [[ $MOD = *embed* ]]
	then 	embedf "$@"
	else 	moderationf "$@" &&
		printf '%-22s: %s\n' flagged $(lastjsonf | jq -r '.results[].flagged') &&
		printf '%-22s: %.24f (%s)\n' $(lastjsonf | jq -r '.results[].categories|keys_unsorted[]' | while read -r; do 	lastjsonf | jq -r "\"$REPLY \" + (.results[].category_scores.\"$REPLY\"|tostring//empty) + \" \" + (.results[].categories.\"$REPLY\"|tostring//empty)"; done)
	fi
else
	CHAT_ENV=1;
	((OPTW)) && unset OPTX; ((OPTW)) && OPTW=1; ((OPTWW)) && OPTWW=1;
	((OPTC+OPTCMPL)) && ((!OPTEXIT)) && test_dialogf;

	#custom / awesome prompts
	case "$1" in
		[.,][[:alnum:]]*|[.,][.,][[:alnum:]]*) 	((${#INSTRUCTION})) || INSTRUCTION=$1 && shift;;
	esac;
	case "$INSTRUCTION" in
		[/%]*) 	OPTAWE=1 ;((OPTC)) || OPTC=1 OPTCMPL=
			awesomef || case $? in 	210|202|1) exit 1;; 	*) unset INSTRUCTION;; esac;  #err
			_sysmsgf $'\nHist   File:' "${FILECHAT}"
			if ((OPTRESUME==1))
			then 	unset OPTAWE
			elif ((!${#}))
			then 	unset REPLY
				printf '\nAwesome INSTRUCTION set!\a\nPress <enter> to request or append user prompt: ' >&2
				var=$(read_charf)
				case "$var" in 	?) SKIP=1 EDIT=1 OPTAWE= REPLY=$var;; 	*) JUMP=1;; esac; unset var;
			fi; [[ $INSTRUCTION = *[!$IFS]* ]] || unset INSTRUCTION;
			;;
		[.,]*) 	if ((OPTV)) 
			then 	OPTV=100 custom_prf "$@";
			else 	OPTV= custom_prf "$@";
			fi;
			case $? in
				200) 	set -- ;;  #create, read and clear pos args
				1|202|201|[1-9]*) 	exit 1; unset INSTRUCTION;;  #err
			esac;
			[[ $INSTRUCTION = *[!$IFS]* ]] || unset INSTRUCTION;
			;;
	esac

	#text/chat completions
	if ((OPTC))
	then 	((OPTV)) || sysmsgf 'Chat Completions'
		#chatbot must sound like a human, shouldnt be lobotomised
		#presencePenalty:0.6 temp:0.9 maxTkns:150
		#frequencyPenalty:0.5 temp:0.5 top_p:0.3 maxTkns:60 (Marv)
		((NOVITAAI)) && [[ $MOD = sao10k/*euryale* ]] &&
		  OPTT=${OPTT:-1.17} OPTA=${OPTA:-0} BLOCK_USR=${BLOCK_USR:-\"min_p\":0.075,\"repetition_penalty\":1.10}
		#https://huggingface.co/Sao10K/L3-70B-Euryale-v2.1

		#temperature
		OPTT="${OPTT:-0.8}";  #!#

		#presencePenalty may be incompatible with some models!
		((MOD_REASON+ANTHROPICAI+MISTRALAI+GITHUBAI+LOCALAI+OLLAMA)) ||
		{ ((${INSTRUCTION+1}0)) && ((!${#INSTRUCTION})) ;} || OPTA="${OPTA:-0.6}";
		((GITHUBAI)) && unset OPTA OPTAA;
		
		#stop sequences
		((ANTHROPICAI && EPN!=0)) ||  #anthropic skip
		{ ((EPN==6)) && [[ -z ${RESTART:+1}${START:+1} ]] ;} ||  #option -cc conditional skip
		  STOPS+=("${RESTART-$Q_TYPE}" "${START-$A_TYPE}")
	else
		((OPTV)) || sysmsgf 'Text Completions'
	fi
	((MULTIMODAL)) ||
	if is_amodelf "$MOD"
	then 	MULTIMODAL=2;
	elif is_visionf "$MOD" || ((MOD_REASON))
	then 	MULTIMODAL=1;
	fi;
	((MULTIMODAL>1)) && OPTZ_FMT="pcm16";  #audio-model preview
	((OPTV)) || sysmsgf 'Language Model:' "$MOD$( ((MULTIMODAL)) && echo ' / multimodal')";
	
	restart_compf ;start_compf
	function unescape_stopsf
	{   typeset s
	    for s in "${STOPS[@]}"
	    do    set -- "$@" "$(unescapef "$s")"
	    done ;STOPS=("$@")
	} ;((${#STOPS[@]})) && unescape_stopsf

	((OPTCMPL+OPTSUFFIX)) || {
	  ((OPTC && !${#RESTART})) && [[ -n ${RESTART+1} ]] && _warmsgf 'Restart Sequence:' 'Set but null';
	  ((OPTC && !${#START})) && [[ -n ${START+1} ]] && _warmsgf 'Start Sequence:' 'Set but null' ;}

	#model instruction
	INSTRUCTION_OLD="$INSTRUCTION"
	if ((MTURN+OPTRESUME))
	then 	case "${LC_ALL:-$LANG}" in
			en*) 	INSTRUCTION_CHAT=$INSTRUCTION_CHAT_EN;;
			pt*) 	INSTRUCTION_CHAT=$INSTRUCTION_CHAT_PT;;
			es*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_ES;;
			it*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_IT;;
			fr*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_FR;;
			de*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_DE;;
			ru*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_RU;;
			ja*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_JA;;
			hi*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_HI;;
			zh[_-]TW*|zh[_-][Hh][Aa][Nn][Tt]*) INSTRUCTION_CHAT=$INSTRUCTION_CHAT_ZH_TW;;
			zh[_-]CN*|zh*)    INSTRUCTION_CHAT=$INSTRUCTION_CHAT_ZH;;
		esac;
		#((${#WARGS[@]})) || case "${LC_ALL:-$LANG}" in [a-z][a-z][_.]*)
		#	WARGS=(${LC_ALL:-$LANG}) WARGS=(${WARGS[0]:0:2});; esac;  #auto whisper lang

		((MULTIMODAL>1)) && [[ $INSTRUCTION_CHAT = "$INSTRUCTION_CHAT_EN" ]] &&
		  INSTRUCTION_CHAT="${INSTRUCTION_CHAT} Your voice and personality should be warm and engaging, with a lively and playful tone. If interacting in a non-English language, start by using the standard accent or dialect familiar to the user. Talk quickly.";

		[[ $INSTRUCTION = *[!$IFS]* ]] && INSTRUCTION=$(trim_leadf "$INSTRUCTION" "$SPC:$SPC")
		if ((OPTC))
		then 	if ((INST_TIME))
			then 	INSTRUCTION="${INSTRUCTION-$INSTRUCTION_CHAT}";  #IPC#
				((${#INSTRUCTION})) &&
				  INSTRUCTION="$(date2f).${NL}${INSTRUCTION}";  #timestamp
			else 	INSTRUCTION="${INSTRUCTION-$(date2f).${NL}${INSTRUCTION_CHAT}}";
			fi
		fi
		INSTRUCTION_OLD="$INSTRUCTION"
		
		if ((OPTC && OPTRESUME)) || ((OPTCMPL==1 || OPTRESUME==1))
		then 	unset INSTRUCTION;
		elif ((OPTV))
		then 	BREAK_SET=1;
		else 	break_sessionf;
		fi
	elif [[ $INSTRUCTION != *[!:$IFS]* ]]
	then 	unset INSTRUCTION
	fi
	if [[ $INSTRUCTION = *[!:$IFS]* ]]
	then 	_sysmsgf 'INSTRUCTION:' "$INSTRUCTION" 2>&1 | foldf >&2;
		((GOOGLEAI)) && GINSTRUCTION=$INSTRUCTION INSTRUCTION=;
	fi

	if ((MTURN))  #chat mode (multi-turn, interactive)
	then 	[[ -t 1 ]] && _printbf 'history_bash'; var=$SECONDS;  #only visible when large and slow
		history -c; history -r; history -w &  #prune & rewrite history file
		[[ -t 1 ]] && _printbf '            ';
		((SECONDS-var>1)) && _warmsgf 'Warning:' "Bash history size -- $(duf "$HISTFILE")";
		if ((OPTRESUME)) && [[ -s $FILECHAT ]]
		then 	REPLY_OLD=$(grep_usr_lastlinef);
		elif [[ -s $HISTFILE ]]
		then 	case "$BASH_VERSION" in  #avoid bash4 hanging
				[0-3]*|4.[01]*|4|'') 	:;;
				*) 	REPLY_OLD=$(trim_leadf "$(fc -ln -1)" "*([$IFS])");;
			esac;
		fi
		((${#1}+${#2}+${#3}+${#4}+${#5}+${#6}+${#7}+${#8}>512)) ||
		    shell_histf "$*";
	fi
	
	#session and chat cmds
	case "$1" in
		[.]|[/!.][/.]) 	set -- '/fork current' "${@:2}";;
		[/!]) 	set -- '/session' "${@:2}";;
	esac;
	if [[ $1 = /?* ]] && [[ ! -f "$1" && ! -d "$1" ]]
	then 	case "$1" in
			/?| //? | /?(/)@(session|list|ls|fork|sub|grep|copy|cp) )
				OPTV=100 session_mainf "$1" "${@:2:1}" && set -- "${@:3}";;
			*) 	OPTV=100 session_mainf "$1" && set -- "${@:2}";;
		esac
	elif cmd_runf "$@"
	then 	set -- ; SKIP_SH_HIST=;
	else  #print session context?
		if ((OPTRESUME==1)) && ((OPTV<2)) && [[ -s $FILECHAT ]]
		then 	OPTPRINT=1 session_sub_printf "$(tail -- "$FILECHAT" >"$FILEFIFO")$FILEFIFO" >/dev/null;
		fi
	fi
	((ANTHROPICAI)) && ((EPN==6)) && INSTRUCTION=;  #needs review#
	((OPTRESUME)) && BREAK_SET= && fix_breakf "$FILECHAT";

	if ((${#})) && ((!(OPTE+OPTX) )) && [[ ! -e $1 && ! -e ${@:${#}} ]]
	then 	token_prevf "${INSTRUCTION}${INSTRUCTION:+ }${*}"
		sysmsgf "Inst+Prompt:" "~$TKN_PREV tokens"
	fi

	#warnings and tips
	((OPTCTRD)) && _warmsgf '*' '<Ctrl-V Ctrl-J> for newline * '
	((OPTCTRD+CATPR)) && _warmsgf '*' '<Ctrl-D> to flush input * '
	echo >&2  #!#
	
	#option -e, edit first user input
	((OPTE && ${#})) && { 	REPLY=$* EDIT=1 SKIP= WSKIP=; set -- ;}

	while :
	do 	((MTURN+OPTRESUME)) && ((!OPTEXIT)) && CKSUM_OLD=$(cksumf "$FILECHAT");
		if ((REGEN>0))  #regen + edit prompt
		then 	if ((REGEN==1))
       			then 	((OPTX)) && PSKIP=1;
		       		set -- "${REPLY_OLD:-$@}"
			elif ((REGEN>1)) && ((OPTX))
       			then 	PSKIP= ;
		       		set -- "${REPLY_OLD:-$@}"
			fi;
			REGEN=-1; ((--MAIN_LOOP));
		fi; RET=;
		((OPTAWE)) || {  #awesome 1st pass skip

		#prompter pass-through
		if ((PSKIP))
		then 	[[ -z $* ]] && [[ -n ${REPLY:-$REPLY_OLD} ]] && set -- "${REPLY:-$REPLY_OLD}";
		elif ((OPTX))
		#text editor prompter
		then 	((EDIT)) || REPLY=""  #!#
			edf "${REPLY:-$@}"
			case $? in
				179|180) :;;        #jumps
				200) 	set --; REPLY=;
					REPLY_CMD_DUMP= REPLY_CMD_BLOCK= SKIP_SH_HIST= WSKIP= SKIP=;  #E#
					continue;;  #redo
				201) 	set --; OPTX= SKIP_SH_HIST=; false;;   #abort
				202) 	exit 202;;  #exit
				*) 	while [[ -f $FILETXT ]] && REPLY=$(<"$FILETXT"); echo >&2;
						(($(wc -l <<<"$REPLY") < LINES-1)) || echo '[..]' >&2;
						printf "${BRED}${REPLY:+${NC}${BCYAN}}%s${NC}\\n" "${REPLY:-(EMPTY)}" | tail -n $((LINES-2))
					do
					((!BAD_RES)) && {
					((OPTV)) || [[ $REPLY = :* ]] \
					|| [[ $REPLY != *[!$IFS]* ]] \
					|| { is_txturl "${REPLY: ind}" >/dev/null && ((!REPLY_CMD_BLOCK)) ;};
					} || NO_CLR=1 new_prompt_confirmf
						case $? in
							202) 	exit 202;;  #exit
							201) 	set --; OPTX= SKIP_SH_HIST=; break 1;;  #abort
							200) 	set --; REPLY=;
								REPLY_CMD_DUMP= REPLY_CMD_BLOCK= SKIP_SH_HIST= WSKIP= SKIP=;  #E#
								continue 2;;  #redo
							19[6789]) 	edf "${REPLY:-$*}" || break 1;;  #edit
							195) 	WSKIP=1 WAPPEND=1 REPLY_OLD=$REPLY EDIT=;
								((OPTW)) || cmd_runf -ww;
								set --; break;;  #whisper append (hidden option)
							0) 	set -- "$REPLY" ; break;;  #yes
							*) 	set -- ; SKIP_SH_HIST=; break;;  #no
						esac
					done;
					((OPTX>1)) && OPTX=;
			esac
		fi; PSKIP= RET=;

		((JUMP)) ||
		#defaults prompter
		if [[ "$* " = @("${Q_TYPE##$SPC1}"|"${RESTART##$SPC1}")$SPC ]] || [[ -z "$*" ]]
		then 	((OPTC)) && Q="${RESTART:-${Q_TYPE:->}}" || Q="${RESTART:->}"
			B=${Q:0:128} B=${B##*$'\n'} B=${B##*\\n} B=${B//?/\\b}  #backspaces

			while ((SKIP)) ||
				printf "${CYAN}${Q}${B}${NC}${OPTW:+${PURPLE}VOICE: }${NC}" >&2
				printf "${BCYAN}${OPTW:+${NC}${BPURPLE}}" >&2
			do
				((SKIP+OPTW+${#RESTART})) && echo >&2
				if ((OPTW && !EDIT)) || ((RESUBW))
				then 	#auto sleep 3-6 words/sec
					if ((OPTV)) && ((!WSKIP)) && ((!BAD_RES)) && ! is_amodelf "$MOD"
					then
						var=$((SLEEP_WORDS/3)) SLEEP_WORDS=;
						_printbf "${var}s";
						if read_charf -t "${var}" >/dev/null 2>&1
						then 	_clr_lineupf;
						else 	_printbf "${var//?/ } ";
						fi
					fi
					
					((RESUBW)) || record_confirmf
					case $? in
					0) 	((BAD_RES)) ||
						if ((RESUBW)) || recordf "$FILEINW"
						then
							is_amodelf "$MOD" && _sysmsgf $'\nWhisper:' 'Transcript generation..';
							REPLY=$(
								set --;
								((MISTRALAI+NOVITAAI+GITHUBAI+XAI)) &&
								  BASE_URL=$OPENAI_BASE_URL_DEF OPENAI_API_KEY=$OPENAI_API_KEY_DEF;
								
								((WHISPER_GROQ && !GROQAI)) &&
								  BASE_URL=${GROQ_BASE_URL:-$GROQ_BASE_URL_DEF} OPENAI_API_KEY=${GROQ_API_KEY:-$OPENAI_API_KEY};
								((GROQAI+WHISPER_GROQ)) && MOD_AUDIO=$MOD_AUDIO_GROQ;

								MOD=$MOD_AUDIO OPTT=${OPTTW:-0} JQCOL= MULTIMODAL=;
								
								[[ -z ${WARGS[*]} ]] || set -- "${WARGS[@]}" "$@";
								context="${WCHAT_C:-$(escapef "${INSTRUCTION:-${GINSTRUCTION:-$INSTRUCTION_OLD}}")}";
								((${#context})) && set -- "$@" "$context";
								
								whisperf "$FILEINW" "$@";
							)
							if is_amodelf "$MOD" && ((!WAPPEND))
							then
								printf "${NC}${Color5}%s${NC}\n" "$REPLY" | foldf >&2;
								REPLY_TRANS=$REPLY REPLY=${FILEINW/"$HOME"/"~"};
							fi
							((WAPPEND)) && REPLY=$REPLY_OLD${REPLY_OLD:+${REPLY:+ }}$REPLY WAPPEND= ;
						else 	case $? in
								196) 	WSKIP= OPTW= REPLY=; continue 1;;
								199) 	EDIT=1; continue 1;;
								202) 	exit 202;;  #exit
							esac;
							echo '[record abort]' >&2;
						fi; ((OPTW>1)) && OPTW=;;
					202) 	exit 202;;  #exit
					201|196) 	WSKIP= OPTW= REPLY=; continue 1;;  #whisper off
					193) 	WSKIP= OPTW= OPTX= EDIT=1; continue 1;;  #command run + whisper off
					199) 	EDIT=1; continue 1;;  #text edit
					*) 	REPLY=; continue 1;;
					esac; unset RESUBW;
					printf "\\n${NC}${BPURPLE}%s${NC}\\n" "${REPLY:-"(EMPTY)"}" | foldf >&2;
				else
					_clr_ttystf;
					((EDIT)) || REPLY=""  #!#
					if ((CATPR)) && ((!EDIT))
					then 	REPLY=$(cat);
					else 	read_mainf ${REPLY:+-i "$REPLY"} REPLY;
					fi </dev/tty

					((CATPR)) && echo >&2;
					((OPTCTRD+CATPR)) && REPLY=$(trim_trailf "$REPLY" $'*([\r])')
				fi; printf "${NC}" >&2;
				
				if [[ ${REPLY:0:128} = /cat*([$IFS]) ]]
				then 	((CATPR)) || CATPR=2 ;REPLY= PSKIP= SKIP=1
					((CATPR==2)) && _cmdmsgf 'Cat Prompter' "one-shot"
					set -- ;continue  #A#
				elif var="$REPLY" RET=
					cmd_runf "$REPLY"
				then 	((SKIP_SH_HIST)) || shell_histf "$REPLY";
					if ((REGEN>0))
					then 	((MAIN_LOOP)) || [[ ! -s $FILECHAT ]] || REPLY_OLD=$(grep_usr_lastlinef);
						REPLY="${REPLY_OLD:-$REPLY}"
						((REGEN!=1)) || ((OPTV)) || test_cmplsf || printf '\n%s\n' '--- regenerate ---' >&2;
					else 	((SKIP+EDIT)) || REPLY=;
					fi; RET= var=; set --; continue 2
				elif ((${#REPLY}>320)) && ind=$((${#REPLY}-320)) || ind=0  #!#
					case "${REPLY: ind}" in  #cmd: //shell, //sh
					*[$IFS][/!][/!]shell|*[$IFS][/!][/!]sh) var=/shell;;
					*[$IFS][/!]shell|*[$IFS][/!]sh) var=shell;;
					*) 	false;; esac;
				then
					set -- "$(trim_trailf "$REPLY" "${SPC}[/!]@(/shell|shell|/sh|sh)")";
					REPLY_CMD_DUMP=$(
						REPLY=;
						cmd_runf /${var:-shell};
						trim_trailf "$REPLY" "[/!]@(/shell|shell|/sh|sh)"
					)
					if ((${#REPLY_CMD_DUMP}))
					then 	REPLY="${*} ${REPLY_CMD_DUMP}";
						#((SKIP_SH_HIST)) || shell_histf "$REPLY";
					fi
			    		SKIP=1 EDIT=1 REPLY_CMD=;
					set -- ; continue 2;
				elif case "${REPLY: ind}" in  #cmd: /photo, /pick, /save, /g
					*[$IFS][/!]photo|*[$IFS][/!]photo[0-9]) var=photo;;
					*[$IFS][/!]pick|*[$IFS][/!]p) var=pick;;
					*[$IFS][/!]save|*[$IFS][/!]\#) var=save;;
					*[$IFS][/!]g) var=g;;
					*[$IFS][/!][/!]g) var=/g;;
					*) 	false;; esac;
				then
					set -- "$(trim_trailf "$REPLY" "${SPC}[/!]@(photo|pick|p|save|\#|[/!]g|g)")";
					cmd_runf /${var:-pick} "$*";
					set --; continue 2;
				elif ((${#REPLY}))
				then 	PSKIP=;
					((!BAD_RES)) && {
					((OPTV)) || [[ $REPLY = :* ]] \
					|| [[ $REPLY != *[!$IFS]* ]] \
					|| { is_txturl "${REPLY: ind}" >/dev/null && ((!REPLY_CMD_BLOCK)) ;};
					} || new_prompt_confirmf ed whisper
					case $? in
						202) 	exit 202;;  #exit
						201) 	break 2;;   #abort
						200)  #redo
							REPLY=$REPLY_CMD;
							REPLY_CMD_DUMP= REPLY_CMD_BLOCK= SKIP_SH_HIST= WSKIP= SKIP=;  #E#
							printf '\n%s\n' '--- redo ---' >&2; set --; continue;;
						199)  #edit
							WSKIP=1 EDIT=1;
							printf '\n%s\n' '--- edit ---' >&2; continue;;
						198)  #editor one-shot
							((OPTX)) || OPTX=2; EDIT=1 SKIP=1;
							((OPTX==2)) &&
							printf '\n%s\n' '--- text editor one-shot ---' >&2
							set -- ;continue 2;;
						197)  #multiline one-shot
							EDIT=1 SKIP=1; ((OPTCTRD))||OPTCTRD=2
							((OPTCTRD==2)) && printf '\n%s\n' '--- prompter <ctr-d> one-shot ---' >&2
							REPLY="$REPLY"$'\n'; set -- ;continue;;  #A#
						196)  #whisper off
							WSKIP=1 EDIT=1 OPTW= ; continue 2;;
						195)  #whisper append
							WSKIP=1 WAPPEND=1 REPLY_OLD=$REPLY EDIT=;
							((OPTW)) || cmd_runf -ww;
							printf '\n%s\n' '--- whisper append ---' >&2; continue;;
						194)  #whisper retry request
							cmd_runf /resubmit;
							set --; continue 2;;
						0) 	:;;  #yes
						*) 	REPLY=; set -- ;break;;  #no
					esac; unset REPLY_CMD;
				else
					set --; unset REPLY_CMD;
				fi ;set -- "$REPLY"
				((OPTCTRD==1)) || unset OPTCTRD
				((CATPR==1)) || unset CATPR
				WSKIP= PSKIP= SKIP= EDIT= B= Q= ind= var=
				break
			done
		fi; RET=;

		if ((!(JUMP+OPTCMPL) )) && [[ $1 != *[!$IFS]* ]]
		then 	_warmsgf "(empty)"
			set -- ; continue
		fi
		if ((!OPTCMPL)) && ((OPTC)) && [[ "${*}" = *[!$IFS]* ]]
		then 	set -- "$(trimf "$*" "$SPC1")"  #!#
			REPLY="$*"
		fi
		((${#REPLY_OLD})) || REPLY_OLD="${REPLY:-$*}";  #I# Avoid $REPLY_CMD!
		
		}  #awesome 1st pass skip end

		if ((MTURN+OPTRESUME)) && [[ -n "${*}" ]]
		then
			[[ -n $REPLY ]] || REPLY="${*}" #set buffer for EDIT
			((SKIP_SH_HIST)) || shell_histf "${REPLY_CMD:-$*}"; SKIP_SH_HIST=;
			history -a;

			#system/instruction?
			case "${1:0:32}${2:0:16}" in :*)
				var=$(trim_leadf "$*" "$SPC:")

				case "${var:0:32}" in :::*) 	var=${var:1};; esac;  #[DEPRECATED] 
				case "${var:0:32}" in ::*)
					((${#INSTRUCTION}+${#GINSTRUCTION})) && v=added || v=set;
					_sysmsgf "System Prompt $v";
					if ((GOOGLEAI))  #[UNNEEDED]
					then 	RINSERT=${RINSERT}${var:1}${NL}${NL};
					else
						INSTRUCTION_OLD=${INSTRUCTION:-$INSTRUCTION_OLD}
						INSTRUCTION=${INSTRUCTION}${INSTRUCTION:+${NL}${NL}}${var:1}
					fi;
				;;
					*)
					RINSERT=${RINSERT}${var}${NL};
					_sysmsgf 'User Prompt added';
				;;
				esac;
				EDIT= PSKIP= SKIP= REPLY= REPLY_OLD= REPLY_CMD= REPLY_CMD_DUMP= var= v=;
				set --; continue;
			;;
			esac;
			((${#RINSERT})) && { 	set -- "${RINSERT}${*}"; REPLY=${RINSERT}${REPLY} RINSERT= ;}
			REC_OUT="${*}"
		fi

		#insert mode
		if ((OPTSUFFIX)) && [[ "$*" = *${I_TYPE}* ]]
		then 	if ((EPN!=6))
			then 	SUFFIX="${*##*${I_TYPE}}";  #slow in bash + big strings
				PREFIX="${*%%${I_TYPE}*}"; set -- "${PREFIX}";
			else 	_warmsgf "Err: Insert mode:" "wrong endpoint (chat cmpls)"
			fi;
			REC_OUT="${REC_OUT:0:${#REC_OUT}-${#SUFFIX}-${#I_TYPE_STR}}"
		#basic text and pdf file, and text url dumps
		elif ((!REPLY_CMD_BLOCK)) && var=$(is_txturl "$1")  #C#
		then 	RET=;
			if ((!${#REPLY_CMD_DUMP}))
			then
			  REPLY_CMD=$REPLY;
			  cmd_runf /cat"$var";
			  REPLY_CMD_DUMP=$REPLY REPLY=$REPLY_CMD SKIP_SH_HIST= REPLY_CMD_BLOCK=1;
			fi; PSKIP= var=;
			if ((${#REPLY_CMD_DUMP})) &&
				((!RET || (RET>180 && RET<220) ))  #!# our exit codes: >180 and <220
			then
			  REPLY_CMD="${REPLY:-$REPLY_CMD}";  #!#
			  ((RET==200)) || [[ "${REPLY:0:128}" = "${REPLY_CMD_DUMP:0:128}" ]] ||
			    REPLY="${REPLY}${NL}${NL}${REPLY_CMD_DUMP}";
			  case "$RET" in
			    202) echo '[bye]' >&2; exit 202;;
			    201|200) EDIT=1 REPLY=$REPLY_CMD;
				 REPLY_CMD_DUMP= REPLY_CMD_BLOCK= SKIP_SH_HIST= WSKIP= SKIP=;  #E#
			         set --; continue 1;;  #redo / abort
			    199) SKIP=1 EDIT=1; set --; continue 1;;  #edit in bash readline
			    198) ((OPTX)) || OPTX=2; SKIP=1 EDIT=1; set --; continue 1;;  #edit in text editor
			  esac
			  set -- "${*}${NL}${NL}${REPLY_CMD_DUMP}";
			  REC_OUT="${*}";
			else
			  SKIP=1 EDIT=1 REPLY_CMD_DUMP= REPLY_CMD= REPLY_CMD_BLOCK=;
			  set --; continue 1;  #edit orig input
			fi; RET=;
		#vision / audio-model
		elif is_visionf "$MOD" || is_amodelf "$MOD"
		then
			media_pathf "$1";
			((MTURN)) &&
			for var in "${MEDIA_CMD[@]}"
			do 	[[ $var = *\ * ]] && [[ $var != *\\\ * ]] && var=${var// /\\ };  #escape spaces
				REC_OUT="$REC_OUT $var" REPLY="$REPLY $var";
				set -- "$* $var";
			done; var=;
		else 	unset SUFFIX PREFIX;
		fi

		set_optsf

		#audio-models, record filepath for the transcript of it
		if ((OPTW)) && ((${#REPLY_TRANS} || REGEN<0)) && is_amodelf "$MOD"
		then
			var=${FILEINW/"$HOME"/"~"};
			((OPTW)) &&  #IPC# Remove whisper audio filepath from user prompt
			case \ "${MEDIA[*]}"\  in *\ "${var}"\ *|*\ "${FILEINW}"\ *)
				case "${REC_OUT}" in
					*"${var}") 	REC_OUT=${REC_OUT:0:${#REC_OUT}-${#var}};
							set -- "${1:0:${#1}-${#var}}";;
					*"${FILEINW}") 	REC_OUT=${REC_OUT:0:${#REC_OUT}-${#FILEINW}};
							set -- "${1:0:${#1}-${#FILEINW}}";;
					*"${var}"*|*"${FILEINW}"*)
				      		REC_OUT=$(sed -e "s/${var}/ /" -e "s/${FILEINW}/ /" <<<"$REC_OUT" || printf '%s' "$REC_OUT");;
				esac;;
			esac; unset var;
			REPLY_OLD="${REPLY_TRANS}${REPLY_TRANS:+${REPLY:+ }}${REPLY}";
			REC_OUT="${REPLY_TRANS}${REPLY_TRANS:+${REC_OUT:+ }}${REC_OUT}";
		fi

		((MTURN+OPTRESUME)) &&
		if ((EPN==6));
		then 	set_histf "${INSTRUCTION:-$GINSTRUCTION}${*}";
		else 	set_histf "${INSTRUCTION:-$GINSTRUCTION}${Q_TYPE}${*}"; fi
		((MAIN_LOOP||TOTAL_OLD)) || TOTAL_OLD=$(__tiktokenf "${INSTRUCTION:-${GINSTRUCTION:-${ANTHROPICAI:+$INSTRUCTION_OLD}}}")
		if ((OPTC)) || [[ -n "${RESTART}" ]]
		then 	rest="${RESTART-$Q_TYPE}"
			((OPTC && EPN==0)) && [[ ${HIST:+x}$rest = \\n* ]] && rest=${rest:2}  #!#del \n at start of string
		fi
		((JUMP)) && set -- && rest=;
		var="$(escapef "${INSTRUCTION}")${INSTRUCTION:+\\n\\n}";
		ESC="${HIST}${HIST:+${var:+\\n\\n}}${var}${rest}$(escapef "${*}")";
		ESC=$(INDEX=32 trim_leadf "$ESC" "\\n");
		
		if ((EPN==6))
		then 	#chat cmpls
			if [[ ${*} = *([$IFS]):* ]]
			then 	role=system;
				((!MOD_REASON)) || role=developer;
			else 	role=user;
			fi

			((GOOGLEAI)) &&  [[ $MOD = *gemini*-pro-vision* && $MOD != *gemini*-1.5-* ]] &&  #gemini-1.0-pro-vision cannot take it multiturn
			if ((REGEN<0 && MAIN_LOOP<1 && ${#INSTRUCTION_OLD})) || is_visionf "$MOD"
			then 	HIST_G=${HIST}${HIST:+\\n\\n} HIST_C= ;
				((${#MEDIA[@]}+${#MEDIA_CMD[@]})) ||
				MEDIA=("${MEDIA_IND[@]}") MEDIA_CMD=("${MEDIA_CMD_IND[@]}");
			fi
			
			((MOD_REASON)) && var=developer || var=system;
			var=$(unset MEDIA MEDIA_CMD; fmt_ccf "$(escapef "$INSTRUCTION")" "${var}";) && var="${var}${INSTRUCTION:+,${NL}}";  #mind anthropic
			set -- "${HIST_C}${HIST_C:+,${NL}}${var}$(fmt_ccf "${HIST_G}$(escapef "${*}")" "$role")";
		else
			#text cmpls
			if { 	((OPTC)) || [[ -n "${START}" ]] ;} && ((JUMP<2))
			then 	set -- "${ESC}${START-$A_TYPE}"
			else 	set -- "${ESC}"
			fi
		fi; rest= role=;
		
		for media in "${MEDIA_IND[@]}" "${MEDIA_CMD_IND[@]}"
		do 	((media_i++));
		  	var=$(is_audiof "$media" && echo aud || echo img)
			[[ -f $media ]] && media=$(duf "$media");
			_sysmsgf "$var #${media_i}" "${media:0: COLUMNS-6-${#media_i}}$([[ -n ${media: COLUMNS-6-${#media_i}} ]] && printf '\b\b\b%s' ...)";
		done; media= media_i=;

		if ((EPN==6))
		then 	set -- "$(sed -e '/^[[:space:]]*$/d' <<<"$*" | sed -e '$s/,[[:space:]]*$//')";
			if ((GOOGLEAI))
			then 	BLOCK="\"contents\": [ ${*} ],";
			else 	BLOCK="\"messages\": [ ${*} ],";
			fi
		else
			if ((GOOGLEAI))
			then 	BLOCK="\"contents\": [{ \"parts\":[{ \"text\": \"${*}\" }] }],";
			else 	BLOCK="\"prompt\": \"${*}\",";
			fi
		fi

		if ((GOOGLEAI))
		then
			BLOCK_SAFETY="\"safetySettings\": [
  {\"category\": \"HARM_CATEGORY_DANGEROUS_CONTENT\",
    \"threshold\": \"BLOCK_NONE\"},
  {\"category\": \"HARM_CATEGORY_SEXUALLY_EXPLICIT\",
    \"threshold\": \"BLOCK_NONE\"},
  {\"category\": \"HARM_CATEGORY_HATE_SPEECH\",
    \"threshold\": \"BLOCK_NONE\"},
  {\"category\": \"HARM_CATEGORY_HARASSMENT\",
    \"threshold\": \"BLOCK_NONE\"}
    ],"
			BLOCK="{
$(
  case "$MOD" in *gemini-1.0*) 	((MAIN_LOOP)) || _warmsgf 'gemini-1.0:' 'system instruction unsupported'; exit;; esac;  #gemini-1.0 series deprecation: 15/feb/2015
  ((${#GINSTRUCTION}+${#GINSTRUCTION_PERM})) && echo "\"systemInstruction\": { \"role\": \"system\", \"parts\": [ { \"text\": \"$(escapef "${GINSTRUCTION:-$GINSTRUCTION_PERM}")\" } ] }," )
$BLOCK
$BLOCK_SAFETY
\"generationConfig\": {
    ${OPTSTOP/stop/stopSequences}
    ${OPTP_OPT/_p/P} ${OPTKK_OPT/_k/K}
    \"temperature\": $OPTT,
    \"maxOutputTokens\": $OPTMAX${BLOCK_USR:+,$NL}$BLOCK_USR
  }
}"
#PaLM: HARM_CATEGORY_UNSPECIFIED HARM_CATEGORY_DEROGATORY HARM_CATEGORY_TOXICITY HARM_CATEGORY_VIOLENCE HARM_CATEGORY_SEXUAL HARM_CATEGORY_MEDICAL HARM_CATEGORY_DANGEROUS
		elif ((OLLAMA))
		then
			BLOCK="{
$( ((EPN!=6)) && ollama_mediaf && printf '%s' ',')
$( ((EPN!=6)) && echo "\"system\": \"$(escapef "${INSTRUCTION:-$INSTRUCTION_OLD}")\"," )
$BLOCK
\"model\": \"$MOD\", $STREAM_OPT $OPT_KEEPALIVE_OPT
\"options\": {
  $( ((OPTMAX_NILL)) && "\"num_predict\": -2" || echo "\"num_predict\": $OPTMAX" ),
  \"temperature\": $OPTT, $OPTSEED_OPT
  $OPTA_OPT $OPTAA_OPT $OPTP_OPT $OPTKK_OPT
  $OPTB_OPT $OPTBB_OPT $OPTSTOP
  \"num_ctx\": $MODMAX${BLOCK_USR:+,$NL}$BLOCK_USR
  }
}"
		else
			BLOCK="{
$( ((ANTHROPICAI)) && ((EPN==6)) && ((${#INSTRUCTION_OLD})) && echo "\"system\": \"$(escapef "$INSTRUCTION_OLD")\"," )
$BLOCK $OPTSUFFIX_OPT
$(
((ANTHROPICAI)) && ((EPN!=6)) && max="max_tokens_to_sample" || max="max_tokens"
case "$MOD" in o[1-9]*)
	max="max_completion_tokens";
	case "$MOD" in
		*-preview*|*-mini*)  REASON_EFFORT=;;
	esac;
	;;
	*)  REASON_EFFORT=;;
esac
((OPTMAX_NILL && EPN==6)) || echo "\"${max:-max_tokens}\": $OPTMAX,"
((${REASON_EFFORT:+1})) && echo "\"reasoning_effort\": \"${REASON_EFFORT:-medium}\","
)
$STREAM_OPT $OPTA_OPT $OPTAA_OPT $OPTP_OPT $OPTKK_OPT
$OPTB_OPT $OPTBB_OPT $OPTSTOP $OPTSEED_OPT
$(
is_amodelf "$MOD" &&
if ((OPTW+OPTZ))
then  printf '"modalities": ["text", "audio"], "audio": { "voice": "%s", "format": "%s" },' "${OPTZ_VOICE:-echo}" "${OPTZ_FMT:-pcm16}"
else  printf '"modalities": ["text"],'
fi ) \
$( ((MISTRALAI+GROQAI+ANTHROPICAI)) || echo "\"n\": $OPTN," ) \
$( ((MISTRALAI+LOCALAI+ANTHROPICAI+GITHUBAI)) || ((!STREAM)) || echo "\"stream_options\": {\"include_usage\": true}," )
\"model\": \"$MOD\", \"temperature\": $OPTT${BLOCK_USR:+,$NL}$BLOCK_USR
}"
		fi

		((OPTC||(STURN && EPN==6) )) && echo >&2;

		#request and response prompts
		SECONDS_REQ=${EPOCHREALTIME:-$SECONDS} SECONDS_REQ=${SECONDS_REQ/,/.}
		((${#START})) && printf "${YELLOW}%b\\n" "$START" >&2;
		((OLLAMA)) && base_url=$BASE_URL BASE_URL=$OLLAMA_BASE_URL;

		#move cursor to the end of user input in previous line
		if test_cmplsf && ((!JUMP))
		then 	if ((${#MEDIA_IND[@]}+${#MEDIA_CMD_IND[@]}+${#REPLY_CMD_DUMP}))
			then 
			  echo >&2;
			elif ((OPTSUFFIX && ${#SUFFIX}))
			then  #insert mode, print last line of reply
			  _p_linerf "$PREFIX"; var=0;
			elif ! ((ANTHROPICAI && EPN==0))
			then
			  buff=$(sed -n '$p' <<<$REPLY)
			  printf "\\e[A\\e[$((${#buff} % COLUMNS))C" >&2;
			  if ((OPTC))
			  then 	printf '%b' "${START-$A_TYPE}" >&2;
			  else 	printf '%b' "$START" >&2;
			  fi; var=0;
			else  var=$OPTFOLD;
			fi;
		else 	var=$OPTFOLD;
		fi

		if ((${#BLOCK}>96000))  #96KB
		then 	buff="${FILE%.*}.block.json"
			printf '%s\n' "$BLOCK" >"$buff"
			BLOCK="@${buff}" OPTFOLD=$var promptf
		#https://stackoverflow.com/questions/19354870/bash-command-line-and-input-limit
		else 	OPTFOLD=$var promptf
		fi; RET_PRF=$? RET=;
		((OPTEXIT>1)) && exit $RET_PRF;

		((OLLAMA)) && BASE_URL=$base_url;
		buff= base_url=;

		((STREAM)) && ((MTURN || EPN==6)) && echo >&2;
		if ((RET_PRF>120 && !STREAM))
		then 	((${#REPLY_CMD})) && REPLY=$REPLY_CMD;
			PSKIP= JUMP= OPTE= SKIP=1 EDIT=1 RET_PRF= RET_APRF=; set --; continue;  #B#
		fi
		((RET_PRF>120)) && INT_RES='#';
		((RET_PRF)) || REPLY_OLD="${REPLY:-${REPLY_OLD:-$*}}";  #I#

		#record to hist file
		if 	if ((STREAM))
			then 	ans=$(prompt_pf -r -j "$FILE"; echo x) ans=${ans:0:${#ans}-1}
				ans=$(escapef "$ans")
				((OLLAMA+LOCALAI)) ||  #OpenAI, MistralAI, and Groq
				tkn=( $(
					ind="-1" var="";
					##((GOOGLEAI)) && FILE="$FILE_PRE";
					((GROQAI)) && var="x_groq";
					((ANTHROPICAI)) && ind="";
					jq -rs ".[${ind}] | .${var}" "$FILE" | response_tknf;
					((GROQAI)) && { datef;
						jq -rs '.[-1].x_groq.usage | (.completion_time,.completion_tokens/.completion_time)' "$FILE";
					}  #tkn rate
					) )  #[0]input_tkn  [1]output_tkn  [2]reason_tkn  [3]time  [4]cmpl_time  [5]tkn_rate
				((tkn[0]&&tkn[1])) 2>/dev/null || ((OLLAMA)) || {
				  tkn_ans=$( ((EPN==6)) && A_TYPE=; __tiktokenf "${A_TYPE}${ans}");
				  ((tkn_ans+=TKN_ADJ)); ((MAX_PREV+=tkn_ans)); TOTAL_OLD=; tkn=();
				};
			else
				{ ((ANTHROPICAI && EPN==0)) && tkn=(0 0) ;} ||
				((OLLAMA)) || tkn=( $(
					jq "." "$FILE" | response_tknf;
					((GROQAI)) && jq -r '.usage | (.completion_time, .completion_tokens/.completion_time)' "$FILE";  #tkn rate
					) )
				ans= buff= n=;
				for ((n=0;n<OPTN;n++))  #multiple responses
				do 	buff=$(INDEX=$n prompt_pf "$FILE")
					((${#buff}>1)) && buff=${buff:1:${#buff}-2}  #del lead and trail ""
					ans="${ans}"${ans:+${buff:+\\n---\\n}}"${buff}"
				done
			fi
			if ((OLLAMA))
			then 	tkn=($(jq -r -s '.[-1]|.prompt_eval_count//"0", .eval_count//"0", "0", .created_at//"0", (.eval_duration/1000000000)?, (.eval_count/(.eval_duration/1000000000)?)?' "$FILE") )
				((STREAM)) && ((MAX_PREV+=tkn[1]));
			fi

			#audio-model: audio only response
			if ((OPTZ)) && ((!${#ans})) && is_amodelf "$MOD"  #((!RET_APRF))
			then 	read ans < <(jq -r '(.message|select(.audio.data != null)|.audio.id)//(.choices|.[]?|select(.delta.audio.data != null)|.delta.audio.id)//empty' "$FILE" 2>/dev/null);
				#audio-id is not implemented, testing
			fi

			#print error msg and check for OpenAI response length-type error
			if ((!${#ans})) && ((RET_PRF<120))
			then
				((STREAM)) && file=$FILESTREAM || file=$FILE;
				##((GOOGLEAI && STREAM)) && file=$FILE_PRE;

				jq -e '.' "$file" >&2 2>/dev/null || cat -- "$file" >&2 ||
				((OPTCMPL)) || ! _warmsgf 'Err';
				_warmsgf "(response empty)";
				((${#REPLY}<1640)) || read_charf -t 1.6 >/dev/null 2>&1;

				((!(LOCALAI+OLLAMA+GOOGLEAI+MISTRALAI+GROQAI+ANTHROPICAI+GITHUBAI) )) &&
				if ((!OPTTIK)) && ((MTURN+OPTRESUME)) && ((HERR<=${HERR_DEF:=1}*5)) \
					&& var=$(jq -e '(.error.message?)//(.[]?|.error?)//empty' "$file" 2>/dev/null) \
					&& [[ $var = *[Cc]ontext\ length*[Rr]educe* ]] \
					&& [[ $ESC != "$ESC_OLD" ]]
				then 	#[0]modmax [1]resquested [2]prompt [3]cmpl
					var=(${var//[!0-9$IFS]})
					if ((${#var[@]}<2 || var[1]<=(var[0]*3)/2))
					then    ESC_OLD=$ESC; ((OPTW)) && RESUBW=1;
					  ((HERR+=HERR_DEF*2)) ;BAD_RES=1 PSKIP=1; set --
					  _warmsgf "Adjusting Context:" -$((HERR_DEF+HERR))%
					  ((HERR<HERR_DEF*4)) && _sysmsgf '' "* Set \`option -y' to use Tiktoken! * "
					  sleep $(( (HERR/HERR_DEF)+1)) ;continue
					fi
				fi  #adjust context err (OpenAI only)
				unset REPLY_CMD_DUMP file;  
			fi;

			BAD_RES= PSKIP= ESC_OLD=;
			((${#tkn[@]}>1 || STREAM)) && ((${#ans})) && ((MTURN+OPTRESUME))
		then
			if CKSUM=$(cksumf "$FILECHAT") ;[[ $CKSUM != "${CKSUM_OLD:-$CKSUM}" ]]
			then 	Color200=${NC} _warmsgf \
				'Err: History file modified'$'\n' 'Fork session? Y/n/[i]gnore_all ' ''
				case "$(read_charf)" in
					[IiGg]) 	CKSUM= CKSUM_OLD=; function cksumf { 	: ;};;
					[AaNnOoQq]|$'\e') :;;
					*) 		session_mainf /copy "$FILECHAT" || break;;
				esac
			fi
			if ((OPTB>1))  #best_of disables streaming response
			then 	start_tiktokenf
				tkn[1]=$(
					((EPN==6)) && A_TYPE=;
					__tiktokenf "${A_TYPE}${ans}");
			fi
			ans="${A_TYPE##$SPC1}${ans}"
			((${#SUFFIX})) && ans=${ans}${SUFFIX}
			((BREAK_SET)) && _break_sessionf;
			if ((ANTHROPICAI && EPN==6 && BREAK_SET && ${#INSTRUCTION_OLD}))
			then
			    push_tohistf "$(escapef ":$INSTRUCTION_OLD")" $( ((MAIN_LOOP)) || echo $TOTAL_OLD )
			elif ((${#INSTRUCTION}+${#GINSTRUCTION}))
			then
			    push_tohistf "$(escapef ":${INSTRUCTION:-$GINSTRUCTION}")" $( ((MAIN_LOOP)) || echo $TOTAL_OLD )
			fi
			((OPTAWE)) ||
			push_tohistf "$(escapef "${Q_TYPE##$SPC1}${REC_OUT}")" "$(( (tkn[0]-TOTAL_OLD)>0 ? (tkn[0]-TOTAL_OLD) : 0 ))" "${tkn[3]}"
			push_tohistf "$ans" "$((${tkn[1]:-${tkn_ans:-0}}-tkn[2]))" "${tkn[3]}" || OPTC= OPTRESUME= OPTCMPL= MTURN=;

			((TOTAL_OLD=tkn[0]+tkn[1]-tkn[2])) && MAX_PREV=$TOTAL_OLD
			HIST_TIME= BREAK_SET= REPLY_CMD_BLOCK=;
		elif ((MTURN))
		then
			((OPTW)) && RESUBW=1;
			((${#REPLY_CMD})) && REPLY=$REPLY_CMD;
			BAD_RES=1 SKIP=1 EDIT=1 CKSUM_OLD=;
			unset PSKIP JUMP REGEN REPLY_CMD REPLY_CMD_DUMP INT_RES MEDIA  MEDIA_IND  MEDIA_CMD_IND SUFFIX OPTE;
			((OPTX)) && read_charf -t 6 >/dev/null
			set -- ;continue
		fi;
		((MEDIA_IND_LAST = ${#MEDIA_IND[@]} + ${#MEDIA_CMD_IND[@]}));
		unset MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND INT_RES GINSTRUCTION REGEN JUMP PSKIP OPTE;
		HIST_G= SKIP_SH_HIST=;

		((OPTLOG)) && (usr_logf "$(unescapef "${ESC}\\n${ans}")" > "$USRLOG" &)
		((RET_PRF>120)) && { 	PSKIP= JUMP= SKIP=1 EDIT=1 RET_PRF= RET_APRF=; set --; continue ;}  #B# record whatever has been received by streaming

		#auto detect markdown in response
		if ((!NO_OPTMD_AUTO)) && ((!OPTMD)) && ((!OPTEXIT)) &&
			((OPTC)) && ((MTURN)) && is_mdf "${ans}"
		then
			printf '\n%s\n' '--- markdown ---' >&2;
			MD_AUTO=1 cmd_runf /markdown;
		fi

		if ((OLLAMA+GROQAI)) && ((${#tkn[@]}>=5))  #token generation rate
		then  #[0]tokens  [1]response_secs  [2]tkn_rate
			TKN_RATE=( "${tkn[1]}" "$(printf '%.2f' "${tkn[4]}")" "$(printf '%.2f' "${tkn[5]}")" )
		elif 	[[ ${tkn[1]:-$tkn_ans} = *[1-9]* ]]
		then
			var=${EPOCHREALTIME:-$SECONDS};
			TKN_RATE=( "${tkn[1]:-$tkn_ans}" "$(bc <<<"scale=8; ${var/,/.} - $SECONDS_REQ")"
			"$(bc <<<"scale=2; ${tkn[1]:-${tkn_ans:-0}} / (${var/,/.}-$SECONDS_REQ)")" )
		fi;
		SESSION_COST=$(
			cost=$(_model_costf "$MOD") || exit; set -- $cost;
			bc <<<"scale=8; ${SESSION_COST:-0} + $(costf "$( ((tkn[0])) && echo ${tkn[0]} || __tiktokenf "$REPLY" )" "$( ((tkn[1])) && echo ${tkn[1]} || __tiktokenf "$(unescapef "$ans")" )" $@)"
			)

		if ((OPTW)) && ((!OPTZ))
		then
			SLEEP_WORDS=$(wc -w <<<"${ans}");
			((STREAM)) && ((SLEEP_WORDS=(SLEEP_WORDS*2)/3));
			((++SLEEP_WORDS));
		elif ((OPTZ)) && is_amodelf "$MOD"
		then
			_sysmsgf 'TTS:' 'Wrapping PCM in WAV...';
			FILEOUT_TTS=$(
			  ((MULTIMODAL>1)) && OPTZ_FMT="pcm";  #audio-model preview
			  set_fnamef "${FILEOUT_TTS%.*}.${OPTZ_FMT}");
			
			jq -r '(.choices|.[0]?|.message.audio.data)//(.choices|.[0]?|.delta.audio.data)//empty' "$FILE" |
			{ 	base64 -d || base64 -D ;} >"$FILEOUT_TTS" || rm -vf "$FILEOUT_TTS" >&2;
			
			var="${FILEOUT_TTS%.*}.wav";
			if [[ -s $FILEOUT_TTS ]] && case "$OPTZ_FMT" in pcm16|pcm|raw) 	:;; *) 	false;; esac
			then
				if command -v ffmpeg >/dev/null 2>&1
				then 	ffmpeg -hide_banner -f s16le -ar 24000 -ac 1 -i "$FILEOUT_TTS" "$var";
				elif command -v sox >/dev/null 2>&1
				then 	sox -r 24000 -b 16 -e signed-integer -c 1 -L -t raw "$FILEOUT_TTS" "$var";
				elif command -v lame >/dev/null 2>&1
				then 	lame --decode -r -m m -s 24 --bitwidth 16 --little-endian --signed "$FILEOUT_TTS" "$var";
				#elif command -v ecasound >/dev/null 2>&1
				#then 	ecasound -f:s16_le,1,24000 -i "$FILEOUT_TTS" -o "$var";  #.raw only
				else 	false;
				fi >/dev/null 2>&1 || ! _warmsgf 'Err:' 'ffmpeg/sox/lame -- pcm16 to wav';
				
				[[ -s $var ]] && FILEOUT_TTS=$var;
				[[ ! -e $var ]] || du -h "$var" >&2 2>/dev/null || _sysmsgf 'TTS File:' "${var/"$HOME"/"~"}";
			fi
			#Audio formats
			#    raw 16 bit PCM audio at 24kHz, 1 channel, little-endian
			#    G.711 at 8kHz (both u-law and a-law)
			#https://platform.openai.com/docs/guides/realtime#audio-formats

			ok=-1;
			for ((m=1;m<2;++m))
			do 	((++ok)); ((ok<10)) || break;
				((RET_APRF)) && var=8 || var=3;  #3+1 secs
				_warmsgf $'\nReplay?' 'N/y/[w]ait ' '';  #!# #F#
				for ((n=var;n>-1;n--))
				do 	printf '%s\b' "$n" >&2
					if (( (!STREAM && !ok) || RET_APRF)) && { 	RET_APRF= var="y"; printf 'y\n' >&2 ;} ||
						var=$(NO_CLR=1 read_charf -t 1 </dev/tty)
					then 	case "$var" in
						[Q]) 	echo '[bye]' >&2; exit 202;;
						[RrYy]|$'\t') m=0; break 1;;
						[PpWw]|[$' \e']) printf '%s' waiting.. >&2;
							read_charf >/dev/null;
							m=0; break 1;;  #wait key press
						*) 	n=-1 var=; break 1;;
						esac;
					fi; ((n)) || echo >&2;
				done; _clr_lineupf 19;  #!#
				((n<0)) && [[ $var != *[!$IFS]* ]] && break;

				if [[ -s $FILEOUT_TTS ]]
				then 	m=0; cmd_runf /replay;
				else 	rm -vf -- "$FILEOUT_TTS";
					_warmsgf 'Err:' $'audio-model output\n';
				fi
			done; unset RET_APRF ok var m n;
		elif ((OPTZ))
		then
			ans=${ans##"${A_TYPE##$SPC1}"};
			#detect and remove possible markdown from $ans to avoid some tts glitches
			if [[ OPTMD -gt 0 || \\n$ans = *\\n@(\#\ |[\*-]\ |\>\ )* ]]
			then 	ans_tts=$(unescapef "$ans");
				ans_tts=$(
					unmarkdownf <<<"$ans_tts" || {
					command -v pandoc >/dev/null 2>&1 && pandoc --from markdown --to plain <<<"$ans_tts" ;} ) 2>/dev/null;
 				ans_tts=$(escapef "$ans_tts");
			fi

			trap '' INT; 
			ttsf "${ZARGS[@]}" "${ans_tts:-$ans}";
			trap 'exit' INT;
		fi
		if ((OPTW))
		then 	#whisper auto context for better transcription / translation
			WCHAT_C="${WCHAT_C:-$(escapef "${INSTRUCTION:-${GINSTRUCTION:-$INSTRUCTION_OLD}}")}\\n\\n${REPLY:-$*}\\n\\n$(
			  ((${#ans} > 245)) && ans=${ans: ${#ans}-245}; printf '%s' "${ans#*[$IFS]}" )";
			#trim right away, max 224 tkns, GPT-2 encoding
			((${#WCHAT_C}>490)) && WCHAT_C=${WCHAT_C: ${#WCHAT_C}-490};
			WCHAT_C=$(SMALLEST=1 INDEX=64 trim_leadf "${WCHAT_C}" $'*[ \t\n]');
			#https://platform.openai.com/docs/guides/speech-to-text/improving-reliability
		fi

		((++MAIN_LOOP)) ;set --
		role= rest= tkn_ans= ans_tts= ans= buff= var= tkn= glob= out= pid= s= n=;
		HIST_G= TKN_PREV= REC_OUT= HIST= HIST_C= REPLY= ESC= Q= STREAM_OPT= RET= RET_PRF= RET_APRF= WSKIP= PSKIP= SKIP= EDIT= HARGS=;
		unset INSTRUCTION GINSTRUCTION REGEN OPTRESUME JUMP REPLY_CMD REPLY_CMD_DUMP REPLY_TRANS OPTA_OPT OPTAA_OPT OPTB_OPT OPTBB_OPT OPTP_OPT OPTKK_OPT OPTSUFFIX_OPT SUFFIX PREFIX OPTAWE BAD_RES INT_RES;
		((MTURN && !OPTEXIT)) || break
	done
fi


#   &=== &   & &==== ===== &==== &==== =====    &==== &   & 
#   %  % %   % %   %   %   %   % %   %   %      %   " %   % 
#   %=   %===% %===%   %=  %=    %===%   %=     %==== %===%     ^    ^ . 
#   %%   %%  % %%  %   %%  %% "% %%      %%        %% %%  %    /a\  /i\  
#   %%=% %%  % %%  %   %%  %%==% %%      %%  %% %==%% %%  %  ,<___><___>.

## set -x; shopt -s extdebug; PS4=$'\n''$EPOCHREALTIME:$LINENO: ';  # Debug performance by line
## shellcheck -S warning -e SC2034,SC1007,SC2207,SC2199,SC2145,SC2027,SC1007,SC2254,SC2046,SC2124,SC2209,SC1090,SC2164,SC2053,SC1075,SC2068,SC2206,SC1078,SC2128  ~/bin/chatgpt.sh

# vim=syntax sync minlines=800
