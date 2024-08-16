#!/usr/bin/env bash
# chatgpt.sh -- Shell Wrapper for ChatGPT/DALL-E/Whisper/TTS
# v0.71.6  aug/2024  by mountaineerbr  GPL+3
set -o pipefail; shopt -s extglob checkwinsize cmdhist lithist histappend;
export COLUMNS LINES; ((COLUMNS>2)) || COLUMNS=80; ((LINES>2)) || LINES=24;

# API keys
#OPENAI_API_KEY=
#GOOGLE_API_KEY=
#MISTRAL_API_KEY=
#GROQ_API_KEY=
#ANTHROPIC_API_KEY=

# DEFAULTS
# Text cmpls model
MOD="gpt-3.5-turbo-instruct"
# Chat cmpls model
MOD_CHAT="${MOD_CHAT:-gpt-4o}"
# Image model (generations)
MOD_IMAGE="${MOD_IMAGE:-dall-e-3}"
# Whisper model (STT)
MOD_AUDIO="${MOD_AUDIO:-whisper-1}"
MOD_AUDIO_GROQ="${MOD_AUDIO_GROQ:-whisper-large-v3}"
# Speech model (TTS)
MOD_SPEECH="${MOD_SPEECH:-tts-1}"
# LocalAI model
MOD_LOCALAI="${MOD_LOCALAI:-phi-2}"
# Ollama model
MOD_OLLAMA="${MOD_OLLAMA:-llama3}"
# Google AI model
MOD_GOOGLE="${MOD_GOOGLE:-gemini-1.5-flash-latest}"
# Mistral AI model
MOD_MISTRAL="${MOD_MISTRAL:-mistral-large-latest}"
# Groq model
MOD_GROQ="${MOD_GROQ:-llama-3.1-8b-instant}"
# Anthropic model
MOD_ANTHROPIC="${MOD_ANTHROPIC:-claude-3-5-sonnet-20240620}"
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
OPTZ_FMT=opus   #mp3, opus, aac, flac
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
# Chat mode of text cmpls sets "\nQ: " and "\nA:"
# Restart/Start seqs have priority
# Cost custom rates
# input and output rates (dollars per million tokens)
#COST_CUSTOM="0 0"
# Cost rate against USD
# e.g. BRL is 5.66 USD, JPY is 0.006665 USD
#COST_RATE="1"

# INSTRUCTION
# Chat completions, chat mode only
# INSTRUCTION=""
INSTRUCTION_CHAT="${INSTRUCTION_CHAT-The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.}"

# Awesome-chatgpt-prompts URL
AWEURL="https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv"
AWEURLZH="https://raw.githubusercontent.com/PlexPt/awesome-chatgpt-prompts-zh/main/prompts-zh.json"  #prompts-zh-TW.json

# CACHE AND OUTPUT DIRECTORIES
CACHEDIR="${CACHEDIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/chatgptsh"
if [[ -n $TERMUX_VERSION ]] && [[ -d $HOME/storage/downloads ]]
then 	OUTDIR=${OUTDIR:-$HOME/storage/downloads}
else 	OUTDIR="${OUTDIR:-${XDG_DOWNLOAD_DIR:-$HOME/Downloads}}"
fi

# Colour palette
# Normal Colours   # Bold              # Background
Black='\e[0;30m'   BBlack='\e[1;30m'   On_Black='\e[40m'  \
Red='\e[0;31m'     BRed='\e[1;31m'     On_Red='\e[41m'    \
Green='\e[0;32m'   BGreen='\e[1;32m'   On_Green='\e[42m'  \
Yellow='\e[0;33m'  BYellow='\e[1;33m'  On_Yellow='\e[43m' \
Blue='\e[0;34m'    BBlue='\e[1;34m'    On_Blue='\e[44m'   \
Purple='\e[0;35m'  BPurple='\e[1;35m'  On_Purple='\e[45m' \
Cyan='\e[0;36m'    BCyan='\e[1;36m'    On_Cyan='\e[46m'   \
White='\e[0;37m'   BWhite='\e[1;37m'   On_White='\e[47m'  \
Inv='\e[0;7m'      Nc='\e[m'           Alert=$BWhite$On_Red \
Bold='\033[0;1m'
HISTSIZE=256;

# Load user defaults
((${#CHATGPTRC})) || CHATGPTRC="$HOME/.chatgpt.conf"
[[ -f "${OPTF}${CHATGPTRC}" ]] && . "$CHATGPTRC"; OPTMM=  #!#fix <=248c483-github

# Set file paths
FILE="${CACHEDIR%/}/chatgpt.json"
FILECHAT="${FILECHAT:-${CACHEDIR%/}/chatgpt.tsv}"
FILEWHISPER="${FILECHAT%/*}/whisper.json"
FILEWHISPERLOG="${OUTDIR%/*}/whisper_log.txt"
FILETXT="${CACHEDIR%/}/chatgpt.txt"
FILEOUT="${OUTDIR%/}/dalle_out.png"
FILEOUT_TTS="${OUTDIR%/}/tts.${OPTZ_FMT:=mp3}"
FILEIN="${CACHEDIR%/}/dalle_in.png"
FILEINW="${CACHEDIR%/}/whisper_in.mp3"
FILEAWE="${CACHEDIR%/}/awesome-prompts.csv"
FILEFIFO="${CACHEDIR%/}/fifo.buff"
FILEMODEL="${CACHEDIR%/}/models.txt"
USRLOG="${OUTDIR%/}/${FILETXT##*/}"
HISTFILE="${CACHEDIR%/}/history_bash"
HISTCONTROL=erasedups:ignoredups
SAVEHIST=$HISTSIZE HISTTIMEFORMAT='%F %T '

# API URL / endpoint
OPENAI_API_HOST_DEF="https://api.openai.com";
OLLAMA_API_HOST_DEF="http://localhost:11434";
LOCALAI_API_HOST_DEF="http://127.0.0.1:8080";
MISTRAL_API_HOST_DEF="https://api.mistral.ai";
GOOGLE_API_HOST_DEF="https://generativelanguage.googleapis.com/v1beta";
GROQ_API_HOST_DEF="https://api.groq.com/openai";
ANTHROPIC_API_HOST_DEF="https://api.anthropic.com";
OPENAI_API_KEY_DEF=$OPENAI_API_KEY;
API_HOST=$OPENAI_API_HOST_DEF;

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

HELP="Name
	${0##*/} -- Wrapper for ChatGPT / DALL-E / Whisper / TTS


Synopsis
	${0##*/} [-cc|-d|-qq] [opt..] [PROMPT|TEXT_FILE|PDF_FILE]
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
	${0##*/} -HPP [/HIST_FILE|.]
	${0##*/} -HPw


Description
	Text Completion Modes

	With no options set, complete INPUT in single-turn mode of
	plain text completions.

	Option -d starts a multi-turn session in plain text completions,
	and does not set further options automatically.

	
	Chat Completion Modes
	
	Set option -c to start multi-turn chat mode via text completions
	(instruct models) or -cc for native chat completions (gpt-3.5+
	models).

	In chat mode, some options are automatically set to un-lobotomise
	the bot.

	Option -C resumes (continues from) last history session. Set option
	-E to exit on response.


	Insert Modes

	Set option -qq for multi turn insert mode, and add tag \`[insert]'
	to the prompt at the location to be filled in (instruct	models).


	Instructions

	Positional arguments are read as a single PROMPT. Optionally set
	INTRUCTION with option -S.

	If a plain text or PDF file path is set as the first positional
	argument or as an argument to \`option -S\`, the file is loaded
	as text PROMPT.

	To create and reuse a custom prompt, set the prompt name as a command
	line option, such as \`-S .[prompt_name]' or \`-S ..[prompt_name]'.
	Alternatively, set the first positional argument with the operator
	and the name, such as  \`..[prompt]'.


	Commands

	If the first positional argument of the script starts with the
	command operator \`/', the command \`/session [HIST_NAME]' to change
	to or create a new history file is assumed (with options -ccCdPP).

	In multi-turn interactions, prompts starting with a colon \`:' are
	appended as user messages to the request block, while double colons
	\`::' append the prompt as instruction / system without initiating
	a new API request.

	With vision models, insert an image to the prompt with command
	\`!img [url|filepath]'. Image urls and files can also be appended
	by typing the operator pipe and a valid input at the end of the
	text prompt, such as \`| [url|filepath]'.


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


	TTS (Text-To-Voice)

	Option -z synthesises voice from text (TTS models). Set a voice as
	the first positional parameter (\`alloy', \`echo', \`fable', \`onyx',
	\`nova', or \`shimmer'). Set the second positional parameter as the
	speed (0.25 - 4.0), and, finally the output file name or the format,
	such as \`./new_audio.mp3' (\`mp3', \`opus', \`aac', and \`flac'),
	or \`-' for stdout. Set options -vz to not play received output.


	Observations

	Input sequences \`\\n' and \`\\t' are only treated specially in
	restart, start and stop sequences!

	A personal OpenAI API is required, set environment or command
	line option --api-key.

	Check the man page for extended description of interface and
	settings. See the online man page and script usage examples at:

	<https://gitlab.com/fenixdragao/shellchatgpt>.


Environment
	BLOCK_USR
	BLOCK_USR_TTS 	Extra options for the request JSON block
			(e.g. \`\"seed\": 33, \"dimensions\": 1024').

	CACHEDIR 	Script cache directory base.
	
	CHATGPTRC 	Path to the user configuration file.
			Defaults=${CHATGPTRC/"$HOME"/"~"}

	FILECHAT 	Path to a history / session TSV file.

	INSTRUCTION 	Initial instruction or system message.

	INSTRUCTION_CHAT
			Initial instruction or system message (chat mode).

	MOD_CHAT
	MOD_IMAGE
	MOD_AUDIO
	MOD_SPEECH
	MOD_LOCALAI
	MOD_OLLAMA
	MOD_MISTRAL
	MOD_GOOGLE
	MOD_GROQ
	MOD_AUDIO_GROQ
	MOD_ANTHROPIC 	Set default model for each endpoint / integration.
	
	OPENAI_API_HOST
	OPENAI_API_HOST_STATIC
			Custom host URL. The STATIC parameter disables
			endpoint auto-selection.

	[PROVIDER]_API_HOST
			API host URL for the providers LOCALAI, OLLAMA,
			MISTRAL, GOOGLE, GROQ, and ANTHROPIC.

	OPENAI_API_KEY
	[PROVIDER]_API_KEY
			Keys for OpenAI, GoogleAI, MistralAI, Groq, and
			Anthropic APIs.

	OUTDIR 		Output directory for received image and audio.

	RESTART
	START           Restart and start sequences. May be set to null.

	VISUAL
	EDITOR 		Text editor for external prompt editing.
			Defaults=\"${VISUAL:-${EDITOR:-vim}}\"

	CLIP_CMD 	Clipboard set command, e.g. \`xsel -b', \`pbcopy'.

	PLAY_CMD 	Audio player command, e.g. \`mpv --no-video --vo=null'.

	REC_CMD 	Audio recorder command, e.g. \`sox -d'.


Commands
	In chat mode, commands are invoked with either \`!' or \`/' as
	operators. These commands allow users to modify settings and
	manage the session.

   -------    ----------    -----------------------------------------
   --- Misc Commands ------------------------------------------------
      -S      :, ::   [PROMPT]  Append user/system prompt to request.
      -S.     -.       [NAME]   Load and edit custom prompt.
      -S/     -S%      [NAME]   Load and edit awesome prompt (zh).
      -Z      !last             Print last response JSON.
     !\#      !save   [PROMPT]  Save current prompt to shell history. ‡
       !      !r, !regen        Regenerate last response.
      !!      !rr               Regenerate response, edit prompt first.
      !i      !info             Info on model and session settings.
      !j      !jump             Jump to request, append response primer.
     !!j     !!jump             Jump to request, no response priming.
     !md      !markdown [SOFTW] Toggle markdown support in response.
    !!md     !!markdown [SOFTW] Render last response in markdown.
     !rep     !replay           Replay last TTS audio response.
     !res     !resubmit         Resubmit last TTS recorded input.
     !cat     -                 Cat prompter (one-shot, ctrd-d).
     !cat     !cat: [TXT|URL|PDF] Cat text or PDF file, dump URL.
     !dialog  -                 Toggle the \`dialog' interface.
     !img     !media [FILE|URL] Append image, media, or URL to prompt.
     !p       !pick,  [PROMPT]  File picker, appends filepath to prompt. ‡
     !pdf     !pdf:    [FILE]   Dump PDF text.
    !photo   !!photo   [INDEX]  Take a photo, camera index (Termux). ‡
     !sh      !shell    [CMD]   Run shell or command, and edit output. ‡
     !sh:     !shell:   [CMD]   Same as !sh but apppend output as user.
    !!sh     !!shell    [CMD]   Run interactive shell (w/ cmd) and exit.
     !url     !url:     [URL]   Dump URL text.
   --- Script Settings and UX ---------------------------------------
    !fold     !wrap             Toggle response wrapping.
      -g      !stream           Toggle response streaming.
      -h     !!h      [REGEX]   Print help, optionally set regex.
    !help     !help-assist [QUERY]  Run the help assistant function.
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
     -Nill    !Nill             Toggle model max response (chat cmpls).
      -M      !NUM !max [NUM]   Set max response tokens.
      -N      !modmax   [NUM]   Set model token capacity.
      -a      !pre      [VAL]   Set presence penalty.
      -A      !freq     [VAL]   Set frequency penalty.
      -b      !best     [NUM]   Set best-of n results.
      -j      !seed     [NUM]   Set a seed number (integer).
      -K      !topk     [NUM]   Set top_k.
      -m      !mod      [MOD]   Set model by name or pick from list.
      -n      !results  [NUM]   Set number of results.
      -p      !topp     [VAL]   Set top_p.
      -r      !restart  [SEQ]   Set restart sequence.
      -R      !start    [SEQ]   Set start sequence.
      -s      !stop     [SEQ]   Set one stop sequence.
      -t      !temp     [VAL]   Set temperature.
      -w      !rec     [ARGS]   Toggle voice chat mode (Whisper).
      -z      !tts     [ARGS]   Toggle TTS chat mode (speech out).
     !ka      !keep-alive [NUM] Set duration of model load in memory
     !blk     !block   [ARGS]   Set and add options to JSON request.
       -       !multimodal       Toggle model as multimodal.
   --- Session Management -------------------------------------------
      -H      !hist             Edit raw history file in editor.
      -P      -HH, !print       Print session history.
      -L      !log  [FILEPATH]  Save to log file (pretty-print).
     !br      !break, !new      Start new session (session break).
     !ls      !list    [GLOB]   List History files with name glob. List
                                prompts \`pr', awesome \`awe', or all \`.'.
     !grep    !sub    [REGEX]   Search sessions and copy to tail.
      !c      !copy [SRC_HIST] [DEST_HIST]
                                Copy session from source to destination.
      !f      !fork [DEST_HIST] Fork current session to destination.
      !k      !kill     [NUM]   Comment out n last entries in hist file.
     !!k     !!kill  [[0]NUM]   Dry-run of command !kill.
      !s      !session [HIST_FILE]
                                Change to, search for, or create hist file.
     !!s     !!session [HIST_FILE]
                                 Same as !session, break session.
   -------    ----------    -----------------------------------------

      : Commands followed by a colon to append command output to prompt.

      ‡ Commands with double dagger may be invoked at the very end of
        the prompt.

      E.g. \`/temp 0.7', \`!modgpt-4', \`-p 0.2', \`/session HIST_NAME',
           \`[PROMPT] /pick', and \`[PROMPT] /sh'.


	To continue from an old session, either \`/copy . .\` or \`/fork.\`
	it as the current session. The dot means the current session. The
	shorthand for this feature is \`/.\`. It is also possible to execute
	\`/grep [regex]\` for a session and resume it.

	To preview a prompt completion, append a forward slash \`/' to it.
	Regenerate it again or flush / accept the prompt and response.

	After a response has been written to the history file, regenerate
	it with command \`!regen' or type in a single exclamation mark or
	forward slash in the new empty prompt (twice for editing the
       	prompt before request).

	Change chat context at run time with the \`!hist' command to edit
	the raw history file (delete or comment out entries).

	Press <CTRL-X CTRL-E> to edit command line in text editor (readline).
	Press <CTRL-J> or <CTRL-V CTRL-J> for newline (readline).
	Press <CTRL-\\> to terminate the script.


Options
	Model Settings
	-@, --alpha  [[VAL%]COLOUR]
		Set transparent colour of image mask. Def=black.
		Fuzz intensity can be set with [VAL%]. Def=0%.
	-Nill
		Unset model max response (chat cmpls only).
	-NUM
	-M, --max  [NUM[-NUM]]
		Set maximum number of \`response tokens'. Def=$OPTMAX.
		A second number in the argument sets model capacity.
	-N, --modmax    [NUM]
		Set \`model capacity' tokens. Def=_auto_, Fallback=4000.
	-a, --presence-penalty   [VAL]
		Set presence penalty  (cmpls/chat, -2.0 - 2.0).
	-A, --frequency-penalty  [VAL]
		Set frequency penalty (cmpls/chat, -2.0 - 2.0).
	-b, --best-of   [NUM]
		Set best of, must be greater than opt -n (cmpls). Def=1.
	-B, --logprobs  [NUM]
		Request log probabilities, see -Z (cmpls, 0 - 5),
	-j, --seed  [NUM]
		Set a seed for deterministic sampling (integer).
	-K, --top-k     [NUM]
		Set Top_k value (local-ai, ollama, google).
	--keep-alive, --ka [NUM]
		Set how long the model will stay loaded into memory (ollama).
	-m, --model     [MOD]
		Set language MODEL name or set it as \`.' to pick
		from the list. Def=$MOD, $MOD_CHAT.
	--multimodal
 		Set model as multimodal.
	-n, --results   [NUM]
		Set number of results. Def=$OPTN.
	-p, --top-p     [VAL]
		Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).
	-r, --restart   [SEQ]
		Set restart sequence string (cmpls).
	-R, --start     [SEQ]
		Set start sequence string (cmpls).
	-s, --stop      [SEQ]
		Set stop sequences, up to 4. Def=\"<|endoftext|>\".
	-S, --instruction  [INSTRUCTION|FILE]
		Set an instruction prompt. It may be a text file.
	-t, --temperature  [VAL]
		Set temperature value (cmpls/chat/whisper),
		Def=${OPTT:-0} (0.0 - 2.0), Whisper=${OPTTW:-0} (0.0 - 1.0).

	Script Modes
	-c, --chat
		Chat mode in text completions (used with -wzvv).
	-cc 	Chat mode in chat completions (used with -wzvv).
	-C, --continue, --resume
		Continue from (resume) last session (cmpls/chat).
	-d, --text
		Start new multi-turn session in plain text completions.
	-e, --edit
		Edit first input from stdin or file (cmpls/chat).
	-E, -EE, --exit
		Exit on first run (even with -cc).
	-g, --stream  (defaults)
		Set response streaming.
	-G, --no-stream
		Unset response streaming.
	-i, --image   [PROMPT]
		Generate images given a prompt.
	-i  [PNG]
		Create variations of a given image.
	-i  [PNG] [MASK] [PROMPT]
		Edit image with mask, and prompt (required).
	-qq, --insert
		Insert text mode. Use \`[insert]' tag within the prompt.
		Set twice for multi-turn (\`instruct', Mistral \`code' models).
	-S .[PROMPT_NAME], -..[PROMPT_NAME]
	-S ,[PROMPT_NAME],    -,[PROMPT_NAME]
		Load, search for, or create custom prompt.
		Set \`.[prompt]' to single-shot edit prompt.
		Set \`..[prompt]' to silently load prompt.
		Set \`,[prompt]' to edit the prompt file.
		Set \`.?' to list prompt template files.
	-S /[AWESOME_PROMPT_NAME]
	-S %[AWESOME_PROMPT_NAME_ZH]
		Set or search an awesome-chatgpt-prompt(-zh).
		Set \`//' or \`%%' to refresh cache. Davinci+ models.
	-TTT, --tiktoken
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
	
	Script Settings
	--api-key  [KEY]
		Set OpenAI API key.
	--anthropic
		Set Anthropic integration (cmpls/chat).
	-f, --no-conf
		Ignore user configuration file.
	-F 	Edit configuration file, if it exists.
		\$CHATGPTRC=${CHATGPTRC/"$HOME"/"~"}.
	-FF 	Dump template configuration file to stdout.
	--fold (defaults), --no-fold
		Set or unset response folding (wrap at white spaces).
	--google
		Set Google Gemini integration (cmpls/chat).
	--groq  Set Groq integration (chat).
	-h, --help
		Print this help page.
	-H, --hist  [/HIST_FILE]
		Edit history file with text editor or pipe to stdout.
		A hist file name can be optionally set as argument.
	-P, -PP, --print  [/HIST_FILE]    (aliases to -HH and -HHH)
		Print out last history session. Set twice to print
		commented out entries, too. Heeds -ccdrR.
	-k, --no-colour
		Disable colour output. Def=auto.
	-l, --list-models  [MOD]
		List models or print details of MODEL.
	-L, --log   [FILEPATH]
		Set log file. FILEPATH is required.
	--localai
		Set LocalAI integration (cmpls/chat).
	--mistral
		Set Mistral AI integration (chat).
	--md, --markdown, --markdown=[SOFTWARE]
		Enable markdown rendering in response. Software is optional:
		\`bat', \`pygmentize', \`glow', \`mdcat', or \`mdless'.
	--no-md, --no-markdown
		Disable markdown rendering.
	-o, --clipboard
		Copy response to clipboard.
	-O, --ollama
		Set and request to Ollama server (cmpls/chat).
	-u, --multiline
		Toggle multiline prompter, <CTRL-D> flush.
	-U, --cat
		Set cat prompter, <CTRL-D> flush.
	-v, --verbose
		Less verbose. With -ccwv, sleep after response. With
		-ccwzvv, stop recording voice input on silence and play
		TTS response right away. May be set multiple times.
	-V  	Dump raw request block to stderr (debug).
	--version
		Print script version.
	-x, --editor
		Edit prompt in text editor.
	-y, --tik
		Set tiktoken for token count (cmpls/chat).
	-Y, --no-tik  (defaults)
		Unset tiktoken use (cmpls/chat).
	-z, --tts   [OUTFILE|FORMAT|-] [VOICE] [SPEED] [PROMPT]
		Synthesise speech from text prompt, set -v to not play.
	-Z, -ZZ, -ZZZ, --last
		Print data from the last JSON responses."

ENDPOINTS=(
	/v1/completions               #0
	/v1/moderations               #1
	/v1/edits                     #2  -> chat/completions
	/v1/images/generations        #3
	/v1/images/variations         #4
	/v1/embeddings                #5
	/v1/chat/completions          #6
	/v1/audio/transcriptions      #7
	/v1/audio/translations        #8
	/v1/images/edits              #9
	/v1/audio/speech              #10
	/v1/models                    #11
)
#https://platform.openai.com/docs/{deprecations/,models/,model-index-for-researchers/}
#https://help.openai.com/en/articles/{6779149,6643408}

#set model endpoint based on its name
function set_model_epnf
{
	unset OPTEMBED TKN_ADJ EPN6
	((LOCALAI+OLLAMA+GOOGLEAI+MISTRALAI+GROQAI+ANTHROPICAI)) && is_visionf "$1" && set -- "vision";
	case "$1" in
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
		text-*|*turbo-instruct*|*davinci*|*babbage*|ada|text*moderation*|*embed*|*similarity*|*search*)
				case "$1" in
					*embed*|*similarity*|*search*) 	EPN=5 OPTEMBED=1;;
					text*moderation*) 	EPN=1 OPTEMBED=1;;
					*) 		EPN=0;;
				esac;;
		gpt-4*|gpt-3.5*|gpt-*|*turbo*|*vision*)
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
						elif ((OPTC>1 || GROQAI || MISTRALAI || GOOGLEAI))
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
	case "${1##ft:}" in  #set model max tokens, ft: fine-tune models
		open-codestral-mamba*|codestral-mamba*) MODMAX=256000;;
		open-mixtral-8x22b) MODMAX=64000;;
		claude-[3-9]*|claude-2.1*) MODMAX=200000;;
		claude-2.0*|claude-instant*) MODMAX=100000;;
		llama-[3-9].[1-9]*|llama[4-9]-*|llama[4-9]*) MODMAX=131072;;
		text*moderation*) 	MODMAX=150000;;
		text-embedding-ada-002|*embedding*-002|*search*-002) MODMAX=8191;;
		davinci-002|babbage-002) 	MODMAX=16384;;
		davinci|curie|babbage|ada) 	MODMAX=2049;;
		code-davinci-00[2-9]*|mistral-embed*) 	MODMAX=8001;;
		gemini*-flash*) 	MODMAX=1048576;;  #standard: 128000
		gemini*-1.[5-9]*|gemini*-[2-9].[0-9]*) 	MODMAX=2097152;;  #standard: 128000
		gpt-4[a-z]*|gpt-[5-9]*|gpt-4-1106*|gpt-4-*preview*|gpt-4-vision*|\
		gpt-4-turbo|gpt-4-turbo-202[4-9]-*|\
		mistral-large*|open-mistral-nemo*) 	MODMAX=128000;;
		gpt-3.5-turbo-1106) 	MODMAX=16385;;
		gpt-4*32k*|*32k|*mi[sx]tral*|*codestral*) MODMAX=32768;;
		gpt-3.5*16K*|*turbo*16k*|*16k) 	MODMAX=16384;;
		gpt-4*|*-bison*|*-unicorn|text-davinci-002-render-sha|\
		llama3*|gemma-*) 	MODMAX=8192;;
		*turbo*|*davinci*) 	MODMAX=4096;;
		gemini*-vision*) 	MODMAX=16384;;
		gemini*-pro*) 	MODMAX=32760;;
		*embedding-gecko*) 	MODMAX=3072;;
		*embed*|*search*) 	MODMAX=2046;;
		aqa) 	MODMAX=7168;;
		*) 	MODMAX=4000;;
	esac
}
#codestral-mamba:256k
#groq: 3.1 models to max_tokens of 8k and 405b to 16k input tokens.
#https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/

#make cmpls request
function __promptf
{
	if curl "$@" ${FAIL} -L "${MISTRAL_API_HOST:-$API_HOST}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer ${MISTRAL_API_KEY:-$OPENAI_API_KEY}" \
		-d "$BLOCK"
	then 	[[ \ $*\  = *\ -s\ * ]] || __clr_lineupf;
	else 	return $?;  #E#
	fi
}

function _promptf
{
	typeset chunk_n chunk str n
	json_minif
	
	if ((STREAM))
	then 	set -- -s "$@" -S --no-buffer;
		  [[ -s $FILE ]] && mv -f -- "$FILE" "${FILE%.*}.2.${FILE##*.}"; : >"$FILE"  #clear buffer asap
		__promptf "$@" | while IFS=  read -r chunk  #|| [[ -n $chunk ]]
		do
			#anthropic sends lots more than only '[DATA]:' fields.
			#google hack does not pass '[DATA]:'.
			((ANTHROPICAI)) && { [[ $chunk = *(\ )[Dd][Aa][Tt][Aa]:* ]] || continue ;}
			chunk=${chunk##*([$' \t'])[Dd][Aa][Tt][Aa]:*(\ )}
			[[ $chunk = *([$IFS]) ]] && continue
			[[ $chunk = *([$IFS])\[+([A-Z])\] ]] && continue
			if ((!n))  #first pass, del leading spaces
			then 	((OPTC)) && {
					str='text":'; ((GOOGLEAI)) ||
					if ((EPN==0)) && ((OLLAMA))
					then 	str='response":';
					elif ((EPN==6))
					then 	str='content":';
					fi
					chunk_n="${chunk/${str}*(\ )\"+(\ |\\[ntr])/$str\"}"
					[[ $chunk_n = *"${str}"\"\"* ]] && continue
				}; ((++n));
				printf '%s\n' "${chunk_n:-$chunk}"; chunk_n= ;
			else 	printf '%s\n' "$chunk"
			fi; 	printf '%s\n' "$chunk" >>"$FILE"
		done
	else
		{ test_cmplsf || ((OPTV>1)) ;} && set -- -s "$@"
		set -- -\# "$@" -o "$FILE"
		__promptf "$@"
	fi
}

function promptf
{
	typeset pid

	if ((OPTVV)) && ((!OPTII))
	then 	block_printf || return
	fi

	if ((STREAM))
	then 	if ((PREVIEW>1))
		then 	cat -- "$FILE"
		else 	test_cmplsf || ((OPTV>1)) || printf "${BYELLOW}%s\\b${NC}" "X" >&2;
			_promptf || exit;  #!#
		fi | prompt_printf
	else
		test_cmplsf || ((OPTV>1)) || printf "${BYELLOW}%*s\\r${YELLOW}" "$COLUMNS" "X" >&2;
		((PREVIEW>1)) || COLUMNS=$((COLUMNS-1)) _promptf || exit;  #!#
		printf "${NC}" >&2;
		if ((OPTI))
		then 	prompt_imgprintf
		else 	prompt_printf
		fi
	fi & pid=$! PIDS+=($!)  #catch <CTRL-C>
	
	trap "trap 'exit' INT; kill -- $pid 2>/dev/null; echo >&2;" INT;
	wait $pid; echo >&2;
	trap 'exit' INT;

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
		(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$@";
}
#https://community.openai.com/t/usage-stats-now-available-when-using-streaming-with-the-chat-completions-api-or-completions-api/738156

#position cursor at end of screen
function __clr_dialogf
{
	printf "${NC}\\n\\n\\033[${LINES};1H" >&2;
}
function __clr_dialoggf { 	((DIALOG_CLR)) && __clr_dialogf ;}

#clear impending stream (tty)
function __clr_ttystf
{
	typeset REPLY n;
	while IFS= read -r -n 1 -t 0.1;
	do 	((++n)); ((n<16384)) || break;
	done </dev/tty;
}

#clear n lines up as needed (assumes one `new line').
function __clr_lineupf
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
SPIN_CHARS6=(⠏ ⠇ ⠧ ⠦ ⠴ ⠼ ⠸ ⠹ ⠙ ⠋)
SPIN_CHARS0=(. o O @ \*)
SPIN_CHARS=(\| \\ - /)
function __spinf
{
	((++SPIN_INDEX)); ((SPIN_INDEX%=${#SPIN_CHARS[@]}));
	printf "%s\\b" "${SPIN_CHARS[SPIN_INDEX]}" >&2;
}
#avoid animations on pipelines
[[ -t 1 ]] || function __spinf { : ;}

#print input and backspaces for all chars
function __printbf { 	printf "%s${1//?/\\b}" "${1}" >&2; };

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
	[[ ${BLOCK:0:10} = @* ]] && cat -- "${BLOCK##@}" | less >&2
	printf '\n%s\n%s\n' "${ENDPOINTS[EPN]}" "$BLOCK" >&2
	printf '\n%s\n' '<Enter> continue, <Ctrl-D> redo, <Ctrl-C> exit' >&2
	__clr_ttystf; read </dev/tty || return 200;
}

#prompt confirmation prompter
function new_prompt_confirmf
{
	typeset REPLY extra
	case \ $*\  in 	*\ ed\ *) extra=", te[x]t editor, m[u]ltiline";; esac;
	case \ $*\  in 	*\ whisper\ *) 	((OPTW)) && extra="${extra}, [W]hspr_Add, [w]hspr_off, whspr_retr[y]";; esac;

	_sysmsgf 'Confirm?' "[Y]es, [n]o, [e]dit${extra}, [r]edo, or [a]bort " ''
	REPLY=$(__read_charf); __clr_lineupf $((8+1+40+${#extra}))  #!#
	case "$REPLY" in
		[aQq]) 		return 201;;  #break
		[Rr]) 		return 200;;  #redo
		[Ee]|$'\e') 	return 199;;  #edit
		[VvXx]) 	return 198;;  #text editor
		[UuMm]) 	return 197;;  #multiline
		[w]) 		return 196;;  #whisper off
		[WA]) 		return 195;;  #whisper append
		[Yy]) 		return 194;;  #whisper retry request
		[NnOo]) 	unset REC_OUT ;return 1;;  #no
	esac  #yes
}

#read one char from user
function __read_charf
{
	typeset REPLY ret
	((NO_CLR)) || __clr_ttystf;
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

#print response
function prompt_printf
{
	typeset stream ret

	if ((STREAM))
	then 	typeset OPTC OPTV; stream=$STREAM;
	else 	set -- "$FILE"
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
		JQCOL= JQCOL2= prompt_prettyf "$@" | mdf;
	else
		prompt_prettyf "$@" | foldf; ret=$?;
		if ((OPTMD))
		then 	printf "${NC}\\n" >&2;
			prompt_pf -r ${stream:+-j --unbuffered} "$@" "$FILE" 2>/dev/null | mdf >&2 2>/dev/null;
		fi
	fi || prompt_pf -r ${stream:+-j --unbuffered} "$@" "$FILE" 2>/dev/null;
	return $ret;
}
function prompt_prettyf
{
	typeset stream; ((STREAM)) && stream=$STREAM;

	jq -r ${stream:+-j --unbuffered} "${JQCOLNULL} ${JQCOL} ${JQCOL2}
	  byellow
	  + (.choices[1].index as \$sep | if .choices? != null then .choices[] else . end |
	  ( ((.delta.content)//(.delta.text)//.text//.response//.completion//(.content[]?|.text?)//(.message.content${ANTHROPICAI:+skip})//(.candidates[]?|.content.parts[]?|.text?)//\"\" ) |
	  if ( (${OPTC:-0}>0) and (${stream:-0}==0) ) then (gsub(\"^[\\\\n\\\\t ]\"; \"\") |  gsub(\"[\\\\n\\\\t ]+$\"; \"\")) else . end)
	  + if any( (.finish_reason//.stop_reason//\"\")?; . != \"stop\" and . != \"stop_sequence\" and . != \"end_turn\" and . != \"\") then
	      red+\"(\"+(.finish_reason//.stop_reason)+\")\"+byellow else null end,
	  if \$sep then \"---\" else empty end) + reset" "$@" && _p_suffixf;
}  #finish_reason: length, max_tokens
function prompt_pf
{
	typeset var
	typeset -a opt
	for var
	do 	[[ -f $var ]] || { 	opt+=("$var"); shift ;}
	done
	set -- "(if .choices? != null then (.choices[$INDEX]) else . end |
		(.delta.content)//(.delta.text)//.text//.response//.completion//(.content[]?|.text?)//(.message.content${ANTHROPICAI:+skip})//(.candidates[]?|.content.parts[]?|.text?)//(.data?))//empty" "$@"
	((${#opt[@]})) && set -- "${opt[@]}" "$@"
	{ jq "$@" && _p_suffixf ;} || ! __warmsgf 'Err';
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
function __openf
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
			((OPTV)) ||  __openf "$fout" || function __openf { : ;}
			((++n, ++m)); ((n<50)) || break;
		done
		((n)) || ! __warmsgf 'Err';
	else 	jq -r '.data[].url' "$FILE" || ! __warmsgf 'Err';
	fi &&
	jq -r 'if .data[].revised_prompt then "\nREVISED PROMPT: "+.data[].revised_prompt else empty end' "$FILE" >&2
}

function prompt_audiof
{
	((OPTVV)) && __warmsgf "Whisper:" "Model: ${MOD_AUDIO:-unset},  Temperature: ${OPTTW:-${OPTT:-unset}}${*:+,  }${*}" >&2

	curl -\# ${OPTV:+-Ss} ${FAIL} -L "${API_HOST}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H 'Content-Type: multipart/form-data' \
		-F file="@$1" \
		-F model="${MOD_AUDIO}" \
		-F temperature="${OPTTW:-$OPTT}" \
		-o "$FILE" \
		"${@:2}" && {
	  [[ -d $CACHEDIR ]] && printf '%s\n\n' "$(<"$FILE")" >> "$FILEWHISPER";
	  ((OPTV)) || __clr_lineupf; ((CHAT_ENV)) || echo >&2;
	}
}

function list_modelsf
{
	((MISTRALAI)) && typeset OPENAI_API_KEY=$MISTRAL_API_KEY API_HOST=$MISTRAL_API_HOST
	curl -\# ${FAIL} -L "${API_HOST}${ENDPOINTS[11]}${1:+/}${1}" \
		-H "Authorization: Bearer $OPENAI_API_KEY" -o "$FILE" &&

	if [[ -n $1 ]]
	then  	jq . "$FILE" || ! __warmsgf 'Err';
	else 	{   jq -r '.data[].id' "$FILE" | sort &&
		    {    ((MISTRALAI+GROQAI+ANTHROPICAI)) || printf '%s\n' text-moderation-latest text-moderation-stable text-moderation-007 ;}
		} | tee -- "$FILEMODEL" || ! __warmsgf 'Err';
	fi || ! __warmsgf 'Err:' 'Model list'
}

function pick_modelf
{
	typeset REPLY mod options
	set -- "${1// }"; set -- "${1##*(0)}";
	((${#1}<3)) || return
	((${#MOD_LIST[@]})) || MOD_LIST=($(list_modelsf))
	if [[ ${REPLY:=$1} = +([0-9]) ]] && ((REPLY && REPLY <= ${#MOD_LIST[@]}))
	then 	mod=${MOD_LIST[REPLY-1]}  #pick model by number from the model list
	else 	__clr_ttystf; REPLY=${REPLY//[!0-9]};
		while ! ((REPLY && REPLY <= ${#MOD_LIST[@]}))
		do
			if test_dialogf
			then 	options=( $(_dialog_optf ${MOD_LIST[@]:-err}) )
				REPLY=$(
				  dialog --backtitle "Model Picker" --title "Selection Menu" \
				    --menu "Choose a model:" 0 40 0 \
				    -- "${options[@]}"  2>&1 >/dev/tty;
				) || typeset NO_DIALOG=1;
				__clr_dialogf;
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
	fi;
}

#set up context from history file ($HIST and $HIST_C)
function set_histf
{
	typeset time token string stringc stringd max_prev q_type a_type role role_last rest com sub ind herr nl x r n;
	typeset -a MEDIA MEDIA_CMD;
	[[ -s $FILECHAT ]] || return; unset HIST HIST_C;
	((BREAK_SET)) && return;
	((OPTTIK)) && HERR_DEF=1 || HERR_DEF=4
	((herr = HERR_DEF + HERR))  #context limit error
	q_type=${Q_TYPE##$SPC1} a_type=${A_TYPE##$SPC1}
	((OPTC>1 || EPN==6)) && typeset A_TYPE="${A_TYPE} "  #pretty-print seq "\\nA: " ($rest)
	((${#})) && token_prevf "${*}"

	while __spinf
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
		sub="${string:0:30}" sub="${sub##@("${q_type}"|"${a_type}"|":")}"
		stringc="${sub}${string:30}"  #del lead seqs `\nQ: ' and `\nA:'

		if ((OPTTIK || token<1))
		then 	((token<1 && OPTVV)) && __warmsgf "Warning:" "Zero/Neg token in history"
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
		then
			((max_prev+=token)); ((MAIN_LOOP)) || ((TOTAL_OLD+=token))
			MAX_PREV=$((max_prev+TKN_PREV))  HIST_TIME="${time##\#}"

			if ((OPTC))
			then 	stringc=$(trim_leadf  "$stringc" "*(\\\\[ntr]| )")
				stringc=$(trim_trailf "$stringc" "*(\\\\[ntr])")
			fi

			role_last=$role role= rest= nl=
			case "${string}" in
				::*) 	role=system rest=  #[DEPRECATED]
					stringc=$(INDEX=32 trim_leadf "$stringc" :)  #append (txt cmpls)
					;;
				:*) 	role=system
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
			if ((!OPTHH)) && is_visionf "$MOD"
			then 	MEDIA=(); _mediachatf "$stringc"
				#((TRUNC_IND)) && stringc=${stringc:0:${#stringc}-TRUNC_IND};
			fi

			#print commented out lines ( $OPTHH > 2 )
			((com)) && stringc=$(sed 's/\\n/\\n# /g' <<<"${rest}${stringc}") rest= com=
			
			HIST="${rest}${stringc}${nl}${HIST}"
			stringd=$(fmt_ccf "${stringc}" "${role}") && ((${#HIST_C}&&${#stringc})) && stringd=${stringd},${NL};
			if ((GOOGLEAI)) && [[ $role = @(system|user) && $role_last = @(system|user) ]] \
			    #&& [[ $stringd != *\"inline_data\":* ]]
			then 	# must fail with inline image objects?!
				#{"role": "%s", "parts": [ {"text": "%s"} ] }
				HIST_C=$(SMALLEST=1 trim_leadf "$HIST_C" $'*"text":?( )"')
				stringd=$(SMALLEST=1 trim_trailf "$stringd" $'"}*')"\\n\\n"
			fi
			((EPN==6)) && HIST_C="${stringd}${HIST_C}"
		else 	break
		fi
	done < <(tac -- "$FILECHAT")
	__printbf ' ' #__spinf() end
	((MAX_PREV+=3)) # chat cmpls, every reply is primed with <|start|>assistant<|message|>
	# in text chat cmpls, prompt is primed with A_TYPE = 3 tkns 
	
	#first system/instruction: add extra newlines and delete $S_TYPE  (txt cmpls) 
	[[ $role = system ]] &&	if ((OLLAMA))
	then 	((OPTC && EPN==0)) && [[ $rest = \\n* ]] && rest+=xx  #!#del \n at start of string
		HIST="${HIST:${#rest}+${#stringc}}"  #delete first system message for ollama
	else 	HIST="${HIST:${#rest}:${#stringc}}\\n${HIST:${#rest}+${#stringc}}"
	fi

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
	string=$1; ((${#string})) || ((OPTCMPL)) || return; unset CKSUM_OLD;
	token=$2; ((token>0)) || {
		start_tiktokenf;    ((OPTTIK)) && __printbf '(tiktoken)';
		token=$(__tiktokenf "${string}");
		((token+=TKN_ADJ)); ((OPTTIK)) && __printbf '          '; };
	time=${3:-$(datef)}
	printf '%s%.22s\t%d\t"%s"\n' "$INT_RES" "$time" "$token" "${string:-${Q_TYPE##$SPC1}}" >> "$FILECHAT"
}

function datef
{
	date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z";
}

#record preview query input and response to hist file
#usage: prev_tohistf [input]
function prev_tohistf
{
	typeset input answer
	input="$*"
	((BREAK_SET)) && { _break_sessionf; unset BREAK_SET ;}
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
	((OPTTIK)) && __printbf '(tiktoken)'
	start_tiktokenf
	TKN_PREV=$(__tiktokenf "${*}")
	((TKN_PREV+=TKN_ADJ))
	((OPTTIK)) && __printbf '          '
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
	then  	! __warmsgf 'Err:' 'get_tiktokenf()'
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
    print(\"Err: python -- \", e)
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
        print(\"Warning: tiktoken -- unknown model/encoding, fallback \", str(enc), file=sys.stderr)

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
	typeset cmd; unset MD_CMD_UNBUFF;
	set -- "$(trimf "${*:-$MD_CMD}" "$SPC")";

	if ! command -v "${1%% *}" &>/dev/null
	then 	for cmd in "bat" "pygmentize" "glow" "mdcat" "mdless"
		do 	command -v $cmd &>/dev/null || continue;
			set -- $cmd; break;
		done;
	fi

	case "$1" in
		bat) 	MD_CMD_UNBUFF=1  #line-buffer support
			function mdf { 	[[ -t 1 || OPTMD -gt 1 ]] && set -- --color always "$@" 
			bat --paging never --language md --style plain "$@" | foldf ;}
			;;
		bat*) 	eval "function mdf { 	$* \"\$@\" ;}"
			MD_CMD_UNBUFF=1
			;;
		pygmentize)
			function mdf { 	pygmentize -s -l md "$@" | foldf ;}
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
	else 	for cmd in "w3m" "lynx" "elinks" "links" "curl"
		do 	command -v $cmd &>/dev/null || continue;
			_set_browsercmdf $cmd && return;
		done; false;
	fi;
}
function _set_browsercmdf
{
	case "$1" in
		w3m*) 	printf '%s' "w3m -T text/html";;
		lynx*) 	printf '%s' "lynx -force_html -nolist";;
		elinks*) printf '%s' "elinks -force-html -no-references";;
		links*) printf '%s' "links -force-html";;
		google-chrome*|chromium*) printf '%s' "${1%% *} --disable-gpu --headless --dump-dom";;
		*) 	printf '%s' "curl -L ${FAIL} --progress-bar";;
	esac;
}

#script help assistant
function help_assistf
(
	typeset REPLY tkn_in tkn_max
	tkn_in=5060 tkn_max=320;

	if ((GOOGLEAI))
	then 	MOD_GOOGLE="gemini-1.5-flash-latest"
		MOD=$MOD_GOOGLE
	elif ((MISTRALAI))
	then 	MOD_MISTRAL="open-mixtral-8x7b";
		MOD=$MOD_MISTRAL
	elif ((GROQAI))
	then 	#MOD_GROQ="gemma-7b-it"
		MOD_GROQ="mixtral-8x7b-32768"
		MOD=$MOD_GROQ
	elif ((ANTHROPICAI))
	then 	MOD_ANTHROPIC="claude-3-haiku-20240307";
		MOD=$MOD_ANTHROPIC
	elif ! ((OLLAMA+LOCALAI))
	then 	MOD_CHAT="gpt-4o-mini";
		MOD=$MOD_CHAT
	fi;

	printf '%s\n' "${ASSIST_MSG//\\Z[[:alnum:]]}" | COLUMNS=42 foldf >&2;
	printf '\nModel: %s   Cost: ~$%.*f\n' "$MOD" 4 "$(costf $tkn_in $tkn_max $(_model_costf "$MOD") )";
	printf '\n%s\n* %s *\a\n%s\n' "****${ASSIST_MSG2//?/\*}" "$ASSIST_MSG2" "${ASSIST_MSG2//?/\*}****" >&2;
	printf '\n%s '  "$ASSIST_MSG3" >&2; __clr_ttystf;
	case "$(__read_charf)" in
		[YySs]|[$' \t']) __clr_lineupf "${#ASSIST_MSG3}";;
		*) exit 200;;
	esac;

	printf "${BWHITE}%s${NC}\\n\\n" "${ASSIST_MSG4//\\Z[[:alnum:]]}" >&2;
	if ((!${#1}))
	then 	read_mainf -i "$1" REPLY </dev/tty;
		((${#REPLY})) || exit 200; 
	else 	printf '>>> %s\n' "$1" >&2;
	fi

	printf "\\n${BWHITE}%s${NC}\\n\\n" "Response:" >&2;
	__printbf wait..; function history { : ;};
	FILECHAT=$FILEFIFO OPTT=0.2 OPTF=1 OPTC=2 EPN=6 OPTEXIT=2 OPTMD=2 OPTV=3 OPTMAX=$tkn_max OPTARG= OPTIND= OPTSUFFIX= OPTCMPL= OPTRESUME= \
	 . "${BASH_SOURCE[0]:-$0}" -S "You are a command line shell expert and a project developer of the bash shell \`chatgpt.sh\` script. A user is currently in the chat mode (REPL mode) of the script and is asking for your assistance. They may be looking for a specific feature, struggling with a command, or simply wanting a general overview. Here is the user's question:" \
	   "${NL}${NL}\`\`\`${REPLY:-$1}\`\`\`${NL}${NL}"   \
	   "${NL}${NL}Below is the script's help page:${NL}${NL}" \
	   "${NL}${NL}\`\`\`${NL}${HELP}${NL}\`\`\`${NL}${NL}" \
	   "${NL}${NL}Lastly, this is the user current chat environment:${NL}${NL}" \
	   "${NL}${NL}\`\`\`${NL}$(BWHITE= NC= cmd_runf /i 2>&1)${NL}\`\`\`${NL}${NL}" \
	   "${NL}${NL}Please provide a concise and helpful response to the user's question, with excerpts of the help page if necessary. Not all options may be set while the user is in chat mode (REPL mode), such as changing service providers. Guide the user and present the correct command syntax to be used in the chat mode or the precise command line invocation. Remember the user is in chat mode right now. Try to be helpful, clear, and a little sassy when appropriate! Provide your best succint answer and make sure to recheck the response before answering as you only have a single turn to answer the user correctly. Thanks! =]" \
	   2>/dev/null;  #stop-seq info from the assistant may stop the answer!
)
ASSIST_MSG4='\ZbQuestion\ZB or \Zbsearch term\ZB:'
ASSIST_MSG3="Proceed?  [N/y]" 
ASSIST_MSG2='Warning: the request will consume about 5000 input tokens'
ASSIST_MSG='\ZuWelcome to Help Assistant!\ZU

Find the right options for the \Zbchatgpt.sh programme\ZB, the precise command line invocation, and the proper chat command.

This is a single-shot turn.'

#calculate cost of query
#usage: costf [input_tokens] [output_tokens] [input_cost] [output_cost] [scale]
function costf
{
	bc <<<"scale=${5:-8};
( ( (${1:-0} / 1000000) * ${3:-0}) + ( (${2:-0} / 1000000) * ${4:-0}) ) * ${COST_RATE:-1}"
}
function _model_costf
{
	case "${COST_CUSTOM[*]}" in *[1-9]*) 	echo  ${COST_CUSTOM[@]}; return;; esac;
	case "$1" in
		claude-3-opus*) 	echo 15 75;;
		claude-3-sonnet*|claude-3-5-sonnet*) echo 3 15;;
		claude-3-haiku*) 	echo 0.25 1.25;;
		claude-2.1*|claude-2*) 	echo 8 24;;
		claude-instant-1.2*) 	echo 0.8 2.4;;
		open-mistral-nemo*) 	echo 0.3 0.3;;
		mistral-large*) 	echo 3 9;;
		codestral*|mistral-small*) echo 1 3;;
		open-mistral-7b*) 	echo 0.25 0.25;;
		open-mixtral-8x7b*) 	echo 0.7 0.7;;
		open-mixtral-8x22b*) 	echo 2 6;;
		mistral-medium*) 	echo 2.75 8.1;;
		gpt-4o-mini*) 	echo 0.15 0.6;;
		gpt-4o-2024-08-06) echo 2.5 10;;
		gpt-4o-2024-05-13|gpt-4o*) 	echo 5 15;;
		text-embedding-3-small) 	echo 0.02 0;;
		text-embedding-3-large) 	echo 0.13 0;;
		text-embedding-ada-002|mistral-embed*) 	echo 0.1 0;;
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
		gemini-1.5-flash*) 	echo 0.075 0.3;;
		#gemini-1.5-flash*) 	echo 0.15 0.6;;  #128K+
		gemini-1.5*) 	echo 3.5 10.5;;
		#gemini-1.5*) 	echo 7 21;;  #128K+
		*) 	echo 0 0; false;;
	esac;
}
#costs updated on aug/24
#https://openai.com/api/pricing/
#https://cloud.google.com/vertex-ai/generative-ai/pricing
#https://ai.google.dev/pricing

#check input and run a chat command  #tags: cmdrunf, runcmdf, run_cmdf
function cmd_runf
{
	typeset opt_append filein var wc xskip pid n
	typeset -a args
	[[ ${1:0:128}${2:0:128} = *([$IFS:])[/!-]* ]] || return;
	((${#1}+${#2}<1024)) || return;
	printf "${NC}" >&2;

	set -- "${1##*([$IFS:])?([/!])}" "${@:2}";
	args=("$@"); set -- "$*";

	case "$*" in
		$GLOB_NILL|$GLOB_NILL2|$GLOB_NILL3)
			set_maxtknf nill
			__cmdmsgf 'Max Response' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} tkns"
			;;
		-[0-9]*|[0-9]*|-M*|[Mm]ax*|\
		-N*|[Mm]odmax*)
			if [[ $* = -N* ]] || [[ $* = -[Mm]odmax* ]]
			then  #model capacity
				set -- "${*##@([Mm]odmax|-N)*([$IFS])}";
				[[ $* = *[!0-9]* ]] && set_maxtknf "$*" || MODMAX="$*"
			else  #response max
				set_maxtknf "${*##?([Mm]ax|-M)*([$IFS])}";
			fi
			if ((HERR))
			then 	unset HERR
				_sysmsgf 'Context Length:' 'error reset'
			fi ;__cmdmsgf 'Max Response / Capacity' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
			;;
		-a*|presence*|pre*)
			set -- "${*//[!0-9.]}"
			OPTA="${*:-$OPTA}"
			fix_dotf OPTA
			__cmdmsgf 'Presence Penalty' "$OPTA"
			;;
		-A*|frequency*|freq*)
			set -- "${*//[!0-9.]}"
			OPTAA="${*:-$OPTAA}"
			fix_dotf OPTAA
			__cmdmsgf 'Frequency Penalty' "$OPTAA"
			;;
		-b*|best[_-]of*)
			set -- "${*//[!0-9.]}" ;set -- "${*%%.*}"
			OPTB="${*:-$OPTB}"
			__cmdmsgf 'Best_Of' "$OPTB"
			;;
		-[cC])
			((OPTC)) && { 	cmd_runf -cc; return ;}
			OPTC=1 EPN=0 OPTCMPL= ;
			__cmdmsgf "Endpoint[$EPN]:" "Text Chat Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$API_HOST}]";
			;;
		-[cC][cC])
			((OPTC>1)) && { 	cmd_runf -d; return ;}
			OPTC=2 EPN=6 OPTCMPL= ;
			__cmdmsgf "Endpoint[$EPN]:" "Chat Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$API_HOST}]";
			;;
		-[dD]|-[dD][dD])
			((!OPTC)) && { 	cmd_runf -c; return ;}
			OPTC= EPN=0 OPTCMPL=1 ;
			__cmdmsgf "Endpoint[$EPN]:" "Text Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$API_HOST}]";
			;;
		break|br|new)
			break_sessionf;
			[[ -n ${INSTRUCTION_OLD:-$INSTRUCTION} ]] && {
			  _sysmsgf 'INSTRUCTION:' "${INSTRUCTION_OLD:-$INSTRUCTION}" 2>&1 | foldf >&2
			  ((GOOGLEAI)) && GINSTRUCTION=${INSTRUCTION_OLD:-$INSTRUCTION} INSTRUCTION= ||
			  INSTRUCTION=${INSTRUCTION_OLD:-$INSTRUCTION};
			}; unset CKSUM_OLD MAX_PREV WCHAT_C MAIN_LOOP TOTAL_OLD; xskip=1;
			;;
#		costs[_-]rate*|cost[_-]rate*)  #costrate
#			set -- "${*##@(cost[_-]rates|cost[_-]rate)$SPC}"
#			set -- "${*//[!0-9.,]}"
#			COST_RATE=${*:-$COST_RATE}
#			__cmdmsgf 'Cost foreign rate (vs dollar):' "${*:-$COST_RATE} \*"
#			;;
		costs*|cost*)
			set -- "${*##@(costs|cost)$SPC}"
			set -- "${*//[!0-9.,]}"
			COST_CUSTOM=( ${*//,/.} )
			__cmdmsgf 'Costs / 1M tkns:' "input: \$ ${COST_CUSTOM[0]}  output: \$ ${COST_CUSTOM[1]}"
			;;
		block*|blk*)
			set -- "${*##@(block|blk)$SPC}"
			__printbf '>';
			read_mainf -i "${BLOCK_USR}${1:+ }${1}" BLOCK_USR;
			__cmdmsgf $'\nUser Block:' "${BLOCK_USR:-unset}";
			;;
		fold|wrap|no-fold|no-wrap)
			((++OPTFOLD)) ;((OPTFOLD%=2))
			__cmdmsgf 'Folding' $(_onoff $OPTFOLD)
			;;
		-g|-G|stream|no-stream)
			((++STREAM)) ;((STREAM%=2))
			__cmdmsgf 'Streaming' $(_onoff $STREAM)
			;;
		help-assist*|help*)
			set -- "${*##@(help-assist|help)$SPC}";
			grep --color=always -i -e "${1%%${NL}*}" <<<"$(cmd_runf -h)" >&2 && return;  #F#
			trap 'trap "-" INT' INT;
			printf '\n%s\n' '============= HELP ASSISTANT =============' >&2;
			help_assistf "$@" || SKIP=1 EDIT=1 RET=$? REPLY="!${args[*]}";
			printf '\n%s\n' '==========================================' >&2;
			trap 'exit' INT;
			if ((RET==200))
			then 	printf '\n%s\n' 'Simple Help Search:' >&2;
				cmd_runf -h "$*"; return;
			#elif ((RET>0)); then 	__warmsgf 'Err:' 'Unknown';
			fi
			;;
		-h|h|help|-\?|\?)
			var=$(sed -n -e 's/^   //' -e '/^[[:space:]]*-----* /,/^[[:space:]]*E\.g\./p' <<<"$HELP");
			less -S <<<"${var}"; xskip=1;
			;;
		-h*|[/!]h*)  #this will only catch -h and //h
			set -- "${*##@(-h|[/!]h)$SPC}";
			if ((${#1}<2)) ||
				! grep --color=always -i -e "${1%%${NL}*}" <<<"$(cmd_runf -h)" >&2;  #F#
			then 	cmd_runf -h; return;
			fi; xskip=1
			;;
		-H|H|history|hist)
			__edf "$FILECHAT"
			unset CKSUM_OLD; xskip=1
			;;
		-HH|-HHH*|HH|HHH*|request|req|print)
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
			__cmdmsgf 'Seed:' "$OPTSEED"
			;;
		j|jump)
			__cmdmsgf 'Jump:' 'append response primer'
			JUMP=1 REPLY=
			return 179
			;;
		[/!]j|[/!]jump|J|Jump)
			__cmdmsgf 'Jump:' 'no response primer'
			JUMP=2 REPLY=
			return 180
			;;
		-K*|top[Kk]*|top[_-][Kk]*)
			set -- "${*//[!0-9.]}"
			OPTKK="${*:-$OPTKK}"
			__cmdmsgf 'Top_K' "$OPTKK"
			;;
		keep-alive*|ka*)
			set -- "${*//[!0-9.]}"
			OPT_KEEPALIVE="${*:-$OPT_KEEPALIVE}"
			__cmdmsgf 'Keep_alive' "$OPT_KEEPALIVE"
			;;
		-L*|log*)
			((OPTLOG)) && [[ -n $* ]] && OPTLOG= ;
			((++OPTLOG)); ((OPTLOG%=2));
			__cmdmsgf 'Logging' $(_onoff $OPTLOG);
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
		-l*|models)
			set -- "${*##@(-l|models)*([$IFS])}";
			list_modelsf "$*" | less >&2;
			;;
		-m*|model*|mod*)
			set -- "${*##@(-m|model|mod)}"; set -- "${1//[$IFS]}"
			if ((${#1}<3))
			then 	pick_modelf "$1"
			else 	MOD=${1:-$MOD};
			fi
			set_model_epnf "$MOD"; model_capf "$MOD"
			send_tiktokenf '/END_TIKTOKEN/'
			__cmdmsgf 'Model Name' "$MOD$(is_visionf "$MOD" && printf ' / %s' 'multimodal')"
			__cmdmsgf 'Max Response / Capacity:' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
			;;
		markdown*|md*)
			((OPTMD)) || (OPTMD=1 cmd_runf //"${args[@]}");
			set -- "${*##@(markdown|md)$SPC}"
			((OPTMD)) && [[ -n $1 ]] && OPTMD= ;
			if ((++OPTMD)); ((OPTMD%=2))
			then 	MD_CMD=${1:-$MD_CMD} xskip=1;
				set_mdcmdf "$MD_CMD";
				__sysmsgf 'MD Cmd:' "$MD_CMD"
			fi;
			__cmdmsgf 'Markdown' $(_onoff $OPTMD);
			((OPTMD)) || unset OPTMD; NO_OPTMD_AUTO=1;
			;;
		[/!]markdown*|[/!]md*)
			set -- "${*##[/!]@(markdown|md)$SPC}"
			set_mdcmdf "${1:-$MD_CMD}"; xskip=1;
			((STREAM)) || unset STREAM;
			printf "${NC}\\n" >&2;
			((BREAK_SET)) ||
			prompt_pf -r ${STREAM:+-j --unbuffered} "$FILE" 2>/dev/null | mdf >&2 2>/dev/null;
			printf "${NC}\\n\\n" >&2;
			;;
		url*|[/!]url*)
			xskip=1;
			[[ $* = ?([/!])url:* ]] && opt_append=1;  #append as user
			set -- "$(trimf "$(trim_leadf "$*" '@(url|[/!]url)*(:)')" "$SPC")";
			if var=$(set_browsercmdf)
			then 	((OPTV)) || __printbf "${var%% *}";
				case "$var" in
				curl*|google-chrome*|chromium*)
				    cmd_runf /sh${opt_append:+:} "${var} ${1// /%20} | sed '/</{ :loop ;s/<[^<]*>//g ;/</{ N ;b loop } }'";  #curl+sed
				    ;;
				*)  cmd_runf /sh${opt_append:+:} "${var} -dump" "${1// /%20}"
				    ;;
				esac; return;
			fi
			;;
		media*|img*)
			set -- "${*##@(media|img)*([$IFS])}";
			set -- "$(trim_trailf "$*" $'*([ \t\n])')";
			CMD_CHAT=1 _mediachatf "$1" && {
			  [[ -f $1 ]] && set -- "$(duf "$1")";
			  var=$((MEDIA_IND_LAST+${#MEDIA_IND[@]}+${#MEDIA_CMD_IND[@]}))
			  _sysmsgf "img ?$var" "${1:0: COLUMNS-6-${#var}}$([[ -n ${1: COLUMNS-6-${#var}} ]] && printf '\b\b\b%s' ...)";
			};
			;;
		multimodal|[/!-]multimodal|--multimodal)
			((++MULTIMODAL)); ((MULTIMODAL%=2))
			__cmdmsgf 'Multimodal Model' $(_onoff $MULTIMODAL)
			;;
		-n*|results*)
			[[ $* = -n*[!0-9\ ]* ]] && { 	cmd_runf "-N${*##-n}"; return ;}  #compat with -Nill option
			set -- "${*//[!0-9.]}" ;set -- "${*%%.*}"
			OPTN="${*:-$OPTN}"
			__cmdmsgf 'Results' "$OPTN"
			;;
		-p*|top[Pp]*|top[_-][Pp]*)
			set -- "${*//[!0-9.]}"
			OPTP="${*:-$OPTP}"
			fix_dotf OPTP
			__cmdmsgf 'Top_P' "$OPTP"
			;;
		-r*|restart*)
			set -- "${*##@(-r|restart)?( )}"
			restart_compf "$*"
			__cmdmsgf 'Restart Sequence' "\"${RESTART-unset}\""
			;;
		-R*|start*)
			set -- "${*##@(-R|start)?( )}"
			start_compf "$*"
			__cmdmsgf 'Start Sequence' "\"${START-unset}\""
			;;
		-s*|stop*)
			set -- "${*##@(-s|stop)?( )}"
			((${#1})) && STOPS=("$(unescapef "${*}")" "${STOPS[@]}")
			__cmdmsgf 'Stop Sequences' "[$(unset s v; for s in "${STOPS[@]}"; do v=${v}\"$(escapef "$s")\",; done; printf '%s' "${v%%,}")]"
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
		-t*|temperature*|temp*)
			set -- "${*//[!0-9.]}"
			OPTT="${*:-$OPTT}"
			fix_dotf OPTT
			__cmdmsgf 'Temperature' "$OPTT"
			;;
		-o|clipboard|clip)
			((++OPTCLIP)); ((OPTCLIP%=2))
			__cmdmsgf 'Clipboard' $(_onoff $OPTCLIP)
			if ((OPTCLIP))  #set clipboard
			then 	set_clipcmdf;
				set -- "$(hist_lastlinef "$FILECHAT")"; [[ $* != *([$IFS]) ]] &&
				unescapef "$*" | ${CLIP_CMD:-false} &&
				  printf "${NC}Clipboard Set -- %.*s..${CYAN}\\n" $((COLUMNS-20>20?COLUMNS-20:20)) "$*" >&2;
			fi
			;;
		-q|insert)
			((++OPTSUFFIX)) ;((OPTSUFFIX%=2))
			__cmdmsgf 'Insert Mode' $(_onoff $OPTSUFFIX)
			;;
		-v|verbose)
			((++OPTV)) ;((OPTV%=3))
			case "${OPTV:-0}" in
				1) var='Less';;  2) var='Much less';;
				0) var='ON'; unset OPTV;;
			esac ;_cmdmsgf 'Verbose' "$var"
			;;
		-V|-VV|debug)  #debug
			((++OPTVV)) ;((OPTVV%=2));
			__cmdmsgf 'Debug Request' $(_onoff $OPTVV)
			;;
		-xx|[/!]editor|[/!]ed|[/!]vim|[/!]vi)
			((!OPTX)) && __cmdmsgf 'Text Editor' 'one-shot'
			((OPTX)) || OPTX=2; REPLY= xskip=1
			;;
		-x|editor|ed|vim|vi)
			((++OPTX)) ;((OPTX%=2)); REPLY= xskip=1
			;;
		-y|-Y|tiktoken|tik|no-tik)
			send_tiktokenf '/END_TIKTOKEN/'
			((++OPTTIK)) ;((OPTTIK%=2))
			__cmdmsgf 'Tiktoken' $(_onoff $OPTTIK)
			;;
		-[Ww]*|[Ww]*|rec*|whisper*)
			set -- "${*##@(-[wW][wW]|-[wW]|[wW][wW]|[wW]|rec|whisper)$SPC}";
			((OPTW+OPTWW)) && [[ -n $* ]] && OPTW= OPTWW= ;
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
			  __cmdmsgf "Whisper Args #${#WARGS[@]}" "${WARGS[*]:-(auto)}"
			fi; __cmdmsgf 'Whisper Chat' $(_onoff $((OPTW+OPTWW)) );
			((OPTW)) || unset OPTW WSKIP SKIP;
			;;
		-z*|tts*|speech*)
			set -- "${*##@(-z*([zZ])|tts|speech)$SPC}"
			((OPTZ)) && [[ -n $* ]] && OPTZ= ;
			if ((++OPTZ)); ((OPTZ%=2))
			then 	set_playcmdf;
				[[ -z $* ]] || ZARGS=("$@"); xskip=1;
				__cmdmsgf 'TTS Args' "${ZARGS[*]:-unset}";
			fi; __cmdmsgf 'TTS Chat' $(_onoff $OPTZ);
			((OPTZ)) || unset OPTZ SKIP;
			;;
		-Z|last)
			lastjsonf >&2
			;;
		[/!]k*|k*)  #kill num hist entries
			typeset IFS dry; IFS=$'\n'; ((PREVIEW)) && BCYAN="${Color9}" PREVIEW= ;
			[[ ${n:=${*//[!0-9]}} = 0* || $* = [/!]* ]] \
			&& n=${n##*([/!0])} dry=4; ((n>0)) || n=1
			if var=($(
				grep -n -e '^[[:space:]]*[^#]' "$FILECHAT" \
				| tail -n $n | cut -c 1-160 | sed -e 's/[[:space:]]/ /g'))
			then
				((n<${#var[@]})) || n=${#var[@]}
				wc=$((COLUMNS>50 ? COLUMNS-6+dry : 60))
				printf "kill${dry:+\\b\\b\\b\\b}:%.${wc}s\\n" "${var[@]}" >&2
				if ((!dry))
				then
					set --
					for ((n=n;n>0;n--))
					do 	set -- -e "${var[${#var[@]}-n]%%:*} s/^/#/" "$@"
					done
					sed -i "$@" "$FILECHAT";
				fi
			fi
			;;
		i|info)
			printf "${NC}${BWHITE}%-13s:${NC} %-5s\\n" \
			$(
			  ((OLLAMA)) && echo ollama-url "${OLLAMA_API_HOST}${ENDPOINTS[EPN]}"
			  ((GOOGLEAI)) && echo google-url "${GOOGLE_API_HOST}${ENDPOINTS[EPN]}"
			  ((ANTHROPICAI)) && echo anthropic-url "${ANTHROPIC_API_HOST}${ENDPOINTS[EPN]}"
			) \
			host-url      "${MISTRAL_API_HOST:-$API_HOST}${ENDPOINTS[EPN]}" \
			model-name    "${MOD:-?}$(is_visionf "$MOD" && printf ' / %s' 'multimodal')" \
			model-cap     "${MODMAX:-?}" \
			response-max  "${OPTMAX:-?}${OPTMAX_NILL:+${EPN6:+ - inf.}}" \
			context-prev  "${MAX_PREV:-?}" \
			token-rate    "${TKN_RATE[2]:-?} tkns/sec  (${TKN_RATE[0]:-?} tkns, ${TKN_RATE[1]:-?} secs)" \
			session-cost  "${SESSION_COST:-0} \$" \
			turn-cost-max "$(costf ${MAX_PREV:-0} ${OPTMAX:-0} $(_model_costf "$MOD") 6 ) \$" \
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
			restart-seq   "\"$(
				((EPN==6)) && echo unavailable && exit;
				((OPTC)) && printf '%s' "${RESTART-$Q_TYPE}" || printf '%s' "${RESTART-unset}")\"" \
			start-seq     "\"$(
				((EPN==6)) && echo unavailable && exit;
				((OPTC)) && printf '%s' "${START-$A_TYPE}"   || printf '%s' "${START-unset}")\"" \
			stop-seqs     "$(set_optsf 2>/dev/null ;OPTSTOP=${OPTSTOP#*:} OPTSTOP=${OPTSTOP%%,} ;printf '%s' "${OPTSTOP:-\"unset\"}")" \
			history-file  "${FILECHAT/"$HOME"/"~"}"  >&2  #2>/dev/null
			;;
		-u|multi|multiline|-uu*(u)|[/!]multi|[/!]multiline)
			case "$*" in
				-uu*|[/!]multi|[/!]multiline)
					((OPTCTRD)) || OPTCTRD=2;
					((OPTCTRD==2)) && __cmdmsgf 'Prompter <Ctrl-D>' 'one-shot';;
				*) 	((OPTCTRD)) && unset OPTCTRD || OPTCTRD=1
					__cmdmsgf 'Prompter <Ctrl-D>' $(_onoff $OPTCTRD)
					((OPTCTRD)) && __warmsgf '*' '<Ctrl-V Ctrl-J> for newline * ';;
			esac
			;;
		-U|-UU*(U))
			case "$*" in
				-UU*) 	((CATPR)) || CATPR=2;
					((CATPR==2)) && __cmdmsgf 'Cat Prompter' "one-shot";;
				*) 	((++CATPR)) ;((CATPR%=2))
					__cmdmsgf 'Cat Prompter' $(_onoff $CATPR);;
			esac
			;;
		cat*)
			set -- "${*}"; filein=$(trimf "${1##cat*(:)}" "$SPC");
			if is_pdff "$filein"
			then 	cmd_runf /pdf"${*##cat}"; return;
			elif _is_linkf "$filein"
			then 	cmd_runf /url"${*##cat}"; return;
			else 	false;
			fi ||
			case "$1" in
				cat:*[!$IFS]*)
					cmd_runf /sh: "cat ${filein}";;
				cat*[!$IFS]*)
					cmd_runf /sh "cat ${filein}";;
				*)
					__warmsgf '*' 'Press <Ctrl-D> to flush * '
					STDERR=/dev/null  cmd_runf /sh cat </dev/tty;;
			esac; return;
			;;
		pdf*)
			set -- "${*}"; filein=$(trimf "${1##pdf*(:)}" "$SPC");
			if command -v pdftotext
			then 	var="pdftotext -layout -nopgbrk ${filein} -";
			elif command -v gs
			then 	var="gs -sDEVICE=txtwrite -o - ${filein}"
			elif command -v abiword
			then 	var="abiword --to=txt --to-name='$FILEFIFO' ${filein}; cat -- '$FILEFIFO'"
			elif command -v ebook-convert
			then 	var="ebook-convert ${filein} '$FILEFIFO'; cat -- '$FILEFIFO'"
			fi 2>/dev/null >&2
			case "$*" in
				pdf:*[!$IFS]*)
					cmd_runf /sh: "$var";;
				pdf*[!$IFS]*)
					cmd_runf /sh "$var";;
				*) 	__warmsgf 'Err:' 'No input or PDF-to-text software available';;
			esac; return;
			;;
		save*|\#*)
			shell_histf "${*##@(save|\#)*([$IFS])}"; history -a;
			((${#1})) && __cmdmsgf 'Shell:' 'Prompt added to history!';
			unset REPLY EDIT SKIP_SH_HIST;
			;;
		[/!]sh*)
			set -- "${*##[/!]@(shell|sh)*([:$IFS])}"
			if [[ -n $1 ]]
			then 	bash -i -c "${1%%;}; exit"
			else 	bash -i
			fi  </dev/tty  >&2;  #>/dev/tty
			;;
		shell*|sh*)
			[[ $* = @(shell|sh):* ]] && opt_append=1;  #append as user
			set -- "${*##@(shell|sh)*([:$IFS])}";
			[[ -n $* ]] || set --; xskip=1;
			while :
			do 	trap 'trap "-" INT' INT;  #disable trap for one <CRTL-C>#
				REPLY=$(trap "-" INT; bash --norc --noprofile ${@:+-c} "${@}" </dev/tty | tee $STDERR);
				RET=$?; trap "exit" INT;
				((RET)) && __warmsgf "Shell:" "$RET"; echo >&2;
				#abort on empty
				((!${#REPLY})) && { 	SKIP=1 EDIT=1 RET=1 REPLY="!${args[*]}"; __warmsgf "Cmd dump:" "(empty)"; return ;}
				_sysmsgf 'Edit buffer?' '[N]o, [y]es, te[x]t editor, [s]hell, or [r]edo ' ''
				((OPTV>2)) && { 	printf '%s\n' 'n' >&2; break ;}
				case "$(__read_charf)" in
					[AaQqRr]) 	SKIP=1 EDIT=1 REPLY="!${args[*]}" RET=200; break;;  #abort, redo
					[EeYy]|$'\e') 	SKIP=1 EDIT=1 RET=199; break;; #yes, bash `read`
					[VvXx]|$'\t'|' ') 	SKIP=1 EDIT=1 RET=198; ((OPTX)) || OPTX=2; break;; #yes, text editor
					[NnOo]|[!Ss]|'') 	SKIP=1 PSKIP=1; break;;  #no need to edit
				esac; set --;
			done; __clr_lineupf $((12+1+47));  #!#
			((opt_append)) && [[ $REPLY != [/!]* ]] && REPLY=:$REPLY;
			((${#args[@]})) && shell_histf "!${args[*]}"; SKIP_SH_HIST=1;
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
					  var2=${var%.*}s.${var##*.}  #shrink
					  size=($(magick identify -format "%w %h" "$var"))
					  _sysmsgf "Camera Raw:" "$(printf '%dx%d' "${size[@]}")  $(duf "$var")";
					  
					  ((size[0]>2048 || size[1]>2048)) && ((size[0]!=size[1])) && 
					  magick "$var" -auto-orient -resize '2048x2048>' "$var2" >&2;
					  
					  [[ -s $var2 ]] && var=$var2 size=($(magick identify -format "%w %h" "$var2"));
					  
					  ((size[0]<size[1] ? size[0]>768 : size[1]>768)) &&
					  magick "$var" -auto-orient -resize '768x768^' "$var2" >&2;

					  [[ -s $var2 ]] && var=$var2 || magick mogrify -auto-orient "$var" >&2;
					  #https://platform.openai.com/docs/guides/vision/calculating-costs
					elif command -v "exiftran" >/dev/null 2>&1;
					then
					  exiftran -ai "$var" >&2;
					fi
					REPLY="${1}${1:+ }${var}";
					__sysmsgf "$(duf "$var")" >&2; :;
				else
					false;
				fi || __warmsgf 'Err:' 'photo camera';
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
			fi && unset TIPS_DIALOG || __warmsgf 'Err:' 'filepicker';
			
			trap 'exit' INT;
			SKIP=1 EDIT=1 xskip=1;
			;;
		r|rr|''|[/!]|regen|[/!]regen|[$IFS])  #regenerate last response / retry
			SKIP=1 EDIT=1
			case "$*" in
				rr|[/!]*) REGEN=2;;  #edit prompt
				*) test_cmplsf && _p_linerf "$REPLY_OLD";
					REGEN=1 REPLY= ;;
			esac
			if ((!BAD_RES)) && [[ -s "$FILECHAT" ]] &&
			[[ "$(tail -n 2 "$FILECHAT")"$'\n' != *[Bb][Rr][Ee][Aa][Kk]*([$' \t'])$'\n'* ]]
			then 	# comment out two lines from tail
				wc=$(wc -l <"$FILECHAT") && ((wc>2)) \
				&& sed -i -e "$((wc-1)),${wc} s/^/#/" "$FILECHAT";
				unset CKSUM_OLD
			fi
			;;
		replay|rep)
			if ((${#REPLAY_FILES[@]})) || [[ -s $FILEOUT_TTS ]]
			then 	for var in "${REPLAY_FILES[@]:-$FILEOUT_TTS}"
				do 	[[ -f $var ]] || continue
					du -h "$var" 2>/dev/null
					${PLAY_CMD} "$var" & pid=$! PIDS+=($!);
					trap "trap 'exit' INT; kill -- $pid 2>/dev/null;" INT;
					wait $pid;
				done;
				trap 'exit' INT;
			else 	__warmsgf 'Err:' 'No TTS audio file to play'
			fi
			;;
		res|resub|resubmit)
			RESUBW=1 SKIP=1 WSKIP=1;
			;;
		dialog|no-dialog)
			((++NO_DIALOG)) ;((NO_DIALOG%=2))
			__cmdmsgf 'Dialog' $(_onoff $( ((NO_DIALOG)) && echo 0 || echo 1) )
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
		__read_charf >/dev/null;
	fi;
       	return 0;
}

#print msg to stderr
#usage: __sysmsgf [string_one] [string_two] ['']
function __sysmsgf
{
	((OPTV<2)) || return
	printf "${BWHITE}%s${NC}${Color200}${2:+ }%s${NC}${3-\\n}" "$1" "$2" >&2
}
function _sysmsgf { 	OPTV=  __sysmsgf "$@" ;}

function __warmsgf
{
	OPTV= BWHITE="${RED}" Color200="${Color200:-${RED}}" \
	__sysmsgf "$@"
}

#command run feedback
function __cmdmsgf
{
	BWHITE="${WHITE}" Color200="${CYAN}" \
	__sysmsgf "$(printf '%-14s' "$1")" "=> ${2:-unset}"
}
function _cmdmsgf { 	OPTV=  __cmdmsgf "$@" ;}
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
function __edf
{
	${VISUAL:-${EDITOR:-vim}} "$1" </dev/tty >/dev/tty
}

#text editor stdout wrapper
function ed_outf
{
	set_filetxtf
	printf "%s${*:+\\n}" "${*}" > "$FILETXT"
	__edf "$FILETXT" &&
	cat -- "$FILETXT"
}

#text editor chat wrapper
function edf
{
	typeset ed_msg pre rest pos ind sub
	ed_msg=$'\n\n'",,,,,,(edit below this line),,,,,,"
	((OPTC)) && rest="${RESTART-$Q_TYPE}" || rest="${RESTART}"
	rest="$(_unescapef "$rest")"
	((GOOGLEAI)) && typeset INSTRUCTION=${GINSTRUCTION:-$INSTRUCTION};

	if ((CHAT_ENV))
	then 	MAIN_LOOP=1 Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" MOD= \
		  OLLAMA= TKN_PREV= MAX_PREV= set_histf "${rest}${*}"
	fi

	set_filetxtf
	pre="${INSTRUCTION}${INSTRUCTION:+$'\n\n'}""$(unescapef "$HIST")"
	((OPTCMPL)) || [[ $pre = *([$IFS]) ]] || pre="${pre}${ed_msg}"
	((OPTMD)) && pre="# vi: filetype=markdown${NL}${NL}${pre}"
	printf "%s\\n" "${pre}"$'\n\n'"${rest}${*}" > "$FILETXT"

	__edf "$FILETXT"

	while [[ -f $FILETXT ]] && pos="$(<"$FILETXT")"
		[[ "$pos" != "${pre}"* ]] || [[ "$pos" = *"${rest:-%#}" ]]
	do 	__warmsgf "Warning:" "Bad edit: [E]dit, [c]ontinue, [r]edo or [a]bort? " ''
		case "$(__read_charf)" in
			[AaQq]) echo abort >&2; return 201;;  #abort
			[CcNn]) break;;      #continue
			[Rr])  return 200;;  #redo
			[Ee]|$'\e'|*) __edf "$FILETXT";;  #edit
		esac
	done
	
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
	if __edf "$FILETXT" && [[ -s $FILETXT ]]
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
	((${#tail}>12000)) && tail=${tail:${#tail} -10000};
	
	[[ BREAK${tail} = *[Bb][Rr][Ee][Aa][Kk]*([$IFS]) ]] \
	|| printf '%s\n' 'SESSION BREAK' >> "$FILECHAT";
}
function break_sessionf
{
	BREAK_SET=1; _sysmsgf 'SESSION BREAK';
}

#fix: remove session break
function fix_breakf
{
	[[ $(tail -n 1 "$1") = *[Bb][Rr][Ee][Aa][Kk]*([$' \t']) ]] &&
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
	if [[ ${BLOCK:0:10} = @* ]]
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
	typeset var ext
	[[ ${1} != *([$IFS]) ]] || return
	
	if ! ((${#MEDIA[@]}+${#MEDIA_CMD[@]}))
	then
		((ANTHROPICAI)) && [[ $2 = system ]] && return 1;
		printf '{"role": "%s", "content": "%s"}\n' "${2:-user}" "$1";
	elif ((OLLAMA))
	then
		printf '{"role": "%s", "content": "%s",\n' "${2:-user}" "$1";
		ollama_mediaf && printf '%s' ' }'
	elif is_visionf "$MOD"
	then
		printf '{ "role": "%s", "content": [ { "type": "text", "text": "%s" }' "${2:-user}" "$1";
		for var in "${MEDIA[@]}" "${MEDIA_CMD[@]}"
		do
			if [[ $var = *([$IFS]) ]]
			then 	continue;
			elif [[ -f $var ]]
			then 	ext=${var##*.}; ext=${ext,,};  #!#bash ,, expansion
				ext=${ext/[Jj][Pp][Gg]/jpeg}; ((${#ext}<7)) || ext=;
				case "$ext" in jpeg|png|gif|webp) :;;  #20MB per image
					*)  __warmsgf 'Warning' "filetype may be unsupported -- ${ext}" ;;
				esac
				if ((ANTHROPICAI))
				then
				  printf ',\n{ "type": "image", "source": { "type": "base64", "media_type": "image/%s", "data": "%s" } }' "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
				else
				  printf ',\n{ "type": "image_url", "image_url": { "url": "data:image/%s;base64,%s" } }' "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
				  #groq: detail  string  Optional  #groq: image URL or base64
				fi
			else  #img url
				((ANTHROPICAI)) ||  #mistral groq
				printf ',\n{ "type": "image_url", "image_url": { "url": "%s" } }' "$var";
			fi
		done;
		printf '%s\n' ' ] }';
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
		1) 	__clr_dialoggf;
			_sysmsgf "No file selected";
			return 1;
			;;
		-1|5|128|130|255) __clr_dialoggf;
			__warmsgf "An unexpected error has occurred";
			return 1;
			;;
		esac;
	do 	typeset TIPS_DIALOG;
		[[ -d ${file:-$PWD} ]] || [[ ! -f $file ]] || break;
	done;
	__clr_dialoggf;

	printf '%s' "$file";
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
	((!OPTCMPL && !OPTC && !MTURN && !OPTSUFFIX))  #demo
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
		if [[ $var = *([$IFS]) ]]
		then 	continue;
		elif [[ -f $var ]] && [[ -s $var ]]
		then 	printf '"%s"' "$(base64 "$var" | tr -d $'\n')";
			((n < ${#})) && printf '%s' ',';
		fi
	done;
       	printf '%s' ']'
}

#process files and urls from input
#$TRUNC_IND is set to the number of chars to be subtracted from the input tail to delete the processed filenames from it
#will _NOT_ work with whitespace in filename if not pipe-delimited and may not work with mixed pipe- and whitespace-delimited input
function _mediachatf
{
	typeset var spc_sep ftrim break i n; unset TRUNC_IND;
       	i=${#1}

	#process only the last line of input, fix for escaped white spaces in filename, del trailing spaces and trailing pipe separator
	set -- "$(sed -n 's/\\n/\n/g; s/\\\\ / /g; s/\\ / /g; s/[[:space:]|]*$//; $p' <<<"$*")";

	((!CMD_CHAT)) && ((${#1}>2048)) && set -- "${1:${#1}-2048}";  #avoid too long an input (too slow)

	while [[ -z $1 ]] || [[ $1 = *[a-zA-Z0-9]*$'\n'*[a-zA-Z0-9]* ]] || ((n>99)) && break;
		[[ $1 = *[\|\ ]*[[:alnum:]]* ]] || {  #prompt is the raw filename / url:
		  ftrim=$(trim_leadf "$1" $'*(\\\\[ntr]|[ \n\t\|])');
		  { [[ -f $ftrim ]] || is_linkf "$ftrim" ;} && break=1;
		}
	do 	if ((break))
		then var=$ftrim;
		elif [[ $1 = *\|* ]]
		then 	var=$(sed 's/^.*[|][[:space:]]*//' <<<"$1");  #pipe separator
		else 	var=$(sed 's/^.*[[:space:]][[:space:]]*//' <<<"$1") spc_sep=1;  #space separator
		fi

		#check if file or url and add to array (max 20MB)
		if is_imagef "$var" || { ((GOOGLEAI)) && is_videof "$var" ;} \
			|| { ((!GOOGLEAI)) && is_linkf "$var" ;}  #|| ((MULTIMODAL))
		then 	((++n));
			if ((CMD_CHAT))
			then 	MEDIA_CMD=("${MEDIA_CMD[@]}" "$var");
				MEDIA_CMD_IND=("${MEDIA_CMD_IND[@]}" "$var");
			else 	MEDIA=("$var" "${MEDIA[@]}");  #read by fmt_ccf()
				MEDIA_IND=("$var" "${MEDIA_IND[@]}");
			fi;
			if ((break))
			then 	set -- ;
			elif [[ $1 = *\|* ]]
			then 	set -- "$(sed 's/[[:space:]]*[|][^|]*$//' <<<"$1")";
			else 	set -- "$(sed 's/\\[tnr]/ /g; s/[[:space:]]*[[:space:]][^[:space:]]*$//' <<<"$1")"
			fi; spc_sep= ;
			set -- "$(trim_trailf "$1" $'*(\\[tnr]|[ \t\n\r])')";
			((TRUNC_IND = i - ${#1}));
		else
			((spc_sep)) || {
			  var="${var:0: COLUMNS-25}$([[ -n ${var: COLUMNS-25} ]] && printf '\b\b\b%s' ...)";
			  var=${var//$'\t'/ };
			  __warmsgf 'multimodal: invalid --' "\"$var\"";
			}

			break;
			#[[ $1 = *\|*[[:alnum:]]*\|* ]] || break;
			#set -- "${1%\|*}";
		fi  #https://stackoverflow.com/questions/12199059/
		((break)) && break;
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
	_is_linkf "$1" || [[ \ $LINK_CACHE\  = *\ "${1:-empty}"\ * ]] || {
	  curl --output /dev/null --max-time 10 --silent --head ${FAIL} --location -H "$UAG" -- "$1" 2>/dev/null &&
	  LINK_CACHE="$LINK_CACHE $1" ;}
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
		*?.[Pp][Nn][Gg] | *?.[Jj][Pp][Gg] | *?.[Jj][Pp][Ee][Gg] | *?.[Ww][Ee][Bb][Pp] | *?.[Gg][Ii][Ff] | *?.[Hh][Ee][Ii][CcFf] ) :;;
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
		*) false;;
	esac
}
function is_audiof { 	[[ -f $1 ]] && _is_audiof "$1" ;}

#test whether file is text or pdf file, or url
function is_txturl
{
	((${#1}>320)) && set -- "${1: ${#1}-320}"
	set -- "$(trim_leadf "$(trim_trailf "$1" "$SPC")" $'*[ \t\n]')"  #C#
	case "$1" in \~\/*) 	set -- "$HOME/${1:2}";; esac;
	is_txtfilef "$1" || is_pdff "$1" || { _is_linkf "$1" && ! _is_imagef "$1" && ! _is_videof "$1" ;}
	((!${?})) && printf '%s' "$1";
}

#check for multimodal (vision) model
function is_visionf
{
	case "$1" in 
	*vision*|*llava*|*cogvlm*|*cogagent*|*qwen*|*detic*|*codet*|*kosmos-2*|*fuyu*|*instructir*|*idefics*|*unival*|*glamm*|\
	gpt-4[a-z]*|gpt-[5-9]*|gpt-4-turbo|gpt-4-turbo-202[4-9]-[0-1][0-9]-[0-3][0-9]|\
	gemini*-1.[5-9]*|gemini*-[2-9].[0-9]*|*multimodal*|\
	claude-[3-9]*|llama[3-9][.-]*|llama-[3-9][.-]*|*mistral-7b*) :;;
	*) 	((MULTIMODAL));;
	esac;
}

function is_mdf
{
	[[ "\\n$1" =~ (\*\*|__|\[[^\]]*\]\([^\)]*\)|\\n\ *\`\`\`|\\n\#\#*\ |\\n\ *[\*-]\ |\\n\ *[0-9][0-9]*\.\ ) ]]
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
	else 	typeset REPLY r x n;

		while IFS= read -r -d ' ' && REPLY=$REPLY' ' || ((${#REPLY}))
		do
			r=$REPLY;
			r=${r//$'\t'/        };  #fix for tabs
	    ((OPTK)) || r=${r//$'\e['*([0-9;])m};  #delete ansi codes
			#LC_CTYPE=C;  #character encoding locale
			
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
	((OPT_KEEPALIVE)) && OPT_KEEPALIVE_OPT="\"keep_alive\": $OPT_KEEPALIVE," || unset OPT_KEEPALIVE_OPT
	((OPTV<1)) && unset OPTV
	
	if ((${#STOPS[@]})) && [[ "${STOPS[*]}" != "${STOPS_OLD[*]:-%#}" ]]
	then  #compile stop sequences  #def: <|endoftext|>
		unset OPTSTOP
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

	#update pid array
	for p in ${PIDS[@]}
	do 	kill -0 -- $p 2>/dev/null && pids+=($p);
	done; PIDS=(${pids[@]});
}

function restart_compf { ((${#1}+${#RESTART})) && RESTART=$(escapef "$(unescapef "${1:-$RESTART}")") RESTART_OLD="$RESTART" ;}
function start_compf { ((${#1}+${#START})) && START=$(escapef "$(unescapef "${1:-$START}")") START_OLD="$START" ;}

function record_confirmf
{
	if ((OPTV<1)) && { 	((!WSKIP)) || [[ ! -t 1 ]] ;}
	then 	printf "\\n${NC}${BWHITE}${ON_PURPLE}%s${NC}" ' * [e]dit text,  [w]hisper_off * ' \
							      ' * Press ENTER to START record * ' >&2;
		case "$(__read_charf)" in [AaOoQqWw]) 	return 196;; [Ee]|$'\e') 	return 199;; esac;
		__clr_lineupf 33; __clr_lineupf 33;  #!#
	fi
	printf "\\n${NC}${BWHITE}${ON_PURPLE}%s\\a${NC}\\n" ' * [e]dit, [r]edo, [w]hspr_off * ' >&2
	printf "\\r${NC}${BWHITE}${ON_PURPLE}%s\\a${NC}\\n" ' * Press ENTER to  STOP record * ' >&2
	#((!OPTV)) || bellf;
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

	$REC_CMD "$1" & pid=$! PIDS+=($!);
	trap "trap 'exit' INT; ret=199;" INT;
	
	#see record_confirmf()
	case "$(
		  # ~ experimental option -vv ~ #
		  # hands-free experience, detect silence #
		  min_len=1.2 #seconds (float)
		  tmout=0.5   #seconds (float)
		  rms=0.04    #0.001 - 0.01 (rms amplitude, sox)
		  db=-28      #decibels (ffmpeg)

		  if ((OPTV>1)) && ((!${#TERMUX_VERSION})) &&
		      command -v ffmpeg >/dev/null 2>&1
		  then
		    _cmdmsgf "Silence Detection:" "tolerance: ${db}dB  min_length: ${min_len}s";
		    __clr_ttystf; sleep ${min_len};
		    while var=$(
		        ffmpeg -i "$1" -af silencedetect=n=${db}dB:d=${min_len} -f null - 2>&1 |
		        sed -n 's/^.*silence_start:[[:space:]]*//p' | sed -n '$ p'
		      )
		      (( $(bc <<<"scale=8; ${var:-0} < ${min_len}") ))
		    do
		      NO_CLR=1 __read_charf -t ${tmout} && break 1;
		    done;
		  elif ((OPTV>1)) && ((!${#TERMUX_VERSION})) &&
		      command -v sox >/dev/null 2>&1
		  then
		    _cmdmsgf "Silence Detection:" "rms_amplitude: ${rms}  min_length: ${min_len}s";
		    __clr_ttystf; sleep ${min_len};
		    while var=$(
			sox "$1" -n trim -${min_len} ${min_len} stat 2>&1 |
		        sed -n 's/RMS .*amplitude:[[:space:]]*//p'
		      )
		      (( $(bc <<<"scale=8; ${var:-100} > ${rms}") ))
		    do
		      NO_CLR=1 __read_charf -t ${tmout} && break 1;
		    done;
		  else
		      __read_charf;  #defaults
		  fi
		)" in
		[AaOoQqWw])   ret=196  #whisper off
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
	wait $pid; return ${ret:-0};
}
#avfoundation for macos: <https://apple.stackexchange.com/questions/326388/>
function rec_killf
{
	typeset pid termux
	pid=$1 termux=$2
	((termux)) && termux-microphone-record -q >&2 || kill -INT -- $pid 2>/dev/null >&2;
}

#set whisper language
function __set_langf
{
	if [[ $1 = [a-z][a-z] ]]
	then 	if ((!OPTWW))
		then 	LANGW="-F language=$1"
			((OPTV)) || __sysmsgf 'Language:' "$1"
		fi ;return 0
	fi ;return 1
}

#whisper
function whisperf
{
	typeset file rec var pid granule scale;
	typeset -a args;
       	unset WHISPER_OUT;
	
	if ((!(CHAT_ENV+MTURN) ))
	then 	__sysmsgf 'Whisper Model:' "$MOD_AUDIO"; __sysmsgf 'Temperature:' "${OPTTW:-$OPTT}";
	fi;
	check_optrangef "${OPTTW:-$OPTT}" 0 1.0 Temperature
	set_model_epnf "$MOD_AUDIO"
	
	((${#})) || [[ -z ${WARGS[*]} ]] || set -- "${WARGS[@]}" "$@";
	for var
	do    [[ $var = *([$IFS]) ]] && shift || break;
	done; var= ; args=("$@");

	#set language ISO-639-1 (two letters)
	if __set_langf "$1"
	then 	shift
	elif __set_langf "$2"
	then 	set -- "${@:1:1}" "${@:3}"
	fi
	
	if { 	((!$#)) || [[ ! -e $1 && ! -e ${@:${#}} ]] ;} && ((!CHAT_ENV))
	then 	printf "${PURPLE}%s ${NC}" 'Record mic input? [Y/n]' >&2
		[[ -t 1 ]] && echo >&2 || var=$(__read_charf)
		case "$var" in
			[AaNnQq]|$'\e') 	:;;
			*) 	((CHAT_ENV)) || __sysmsgf 'Rec Cmd:' "\"${REC_CMD%% *}\"";
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
		__warmsgf 'Warning:' "Whisper input exceeds API limit of 25 MB";
	fi
	
	#set a prompt
	if [[ ${*} != *([$IFS]) ]]
	then 	((CHAT_ENV+MTURN)) || { var=$*;
		  __sysmsgf 'Text Prompt:' "${var:0: COLUMNS-17}$([[ -n ${var: COLUMNS-17} ]] && echo ...)";
		}; set -- -F prompt="$*";
	elif ((CHAT_ENV+MTURN))
	then 	var="${WCHAT_C:-$(escapef "${INSTRUCTION:-${GINSTRUCTION:-$INSTRUCTION_OLD}}")}";
		((${#var})) && set -- -F prompt="$var";
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
		|| jq -r "if .${granule}s then (.${granule}s[] | (.start|tostring) + (.text//.${granule}//empty)) else (.text//.${granule}//empty) end" "$FILE" || ! __warmsgf 'Err' ;}
	else
		prompt_audiof "$file" $LANGW "$@" && {
		jq -r "def scale: 1; ${JQCOLNULL} ${JQCOL} ${JQDATE}
		bpurple + (.text//.${granule}//empty) + reset" "$FILE" | foldf \
		|| jq -r ".text//.${granule}//empty" "$FILE" || ! __warmsgf 'Err' ;}
	fi & pid=$! PIDS+=($!);
	trap "trap 'exit' INT; kill -- $pid 2>/dev/null;" INT;

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
		__warmsgf $'\nerr:' 'whisper response'
		printf 'Retry request? Y/n ' >&2;
		case "$(__read_charf)" in
			[AaNnQq]) false;;  #no
			*) 	((rec)) && args+=("$FILEINW")
				whisperf "${args[@]}";;
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
	curl -N -Ss ${FAIL} -L "${API_HOST}${ENDPOINTS[EPN]}" \
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
	do    [[ $var = *([$IFS]) ]] && shift || break;
	done; var= ;
	
	if ((!CHAT_ENV)) || ((${#ZARGS[@]}))
	then 	#set speech voice, out file format, and speed
		__set_ttsf "$3" && set -- "${@:1:2}" "${@:4}"
		__set_ttsf "$2" && set -- "${@:1:1}" "${@:3}"
		__set_ttsf "$1" && shift
	fi

	if [[ $FOUT != "-" ]]
	then 	if [[ -s $FILEOUT_TTS ]]
		then 	n=0 m=0  #set a filename for output
			for fname in "${FILEOUT_TTS%.*}"*
			do 	fname=${fname##*/} fname=${fname%.*}
				fname=${fname%%-*([0-9])} fname=${fname##*[!0-9]}
				((m>fname)) || ((m=fname+1)) 
			done
			FOUT=${FILEOUT_TTS%.*} FOUT=${FOUT%%?(-)*([0-9])};
			while [[ -s ${FOUT}${m}.${OPTZ_FMT} ]]; do 	((++m)); done;
			FOUT=${FOUT}${m}.${OPTZ_FMT};
		else
			FOUT=${FILEOUT_TTS%.*}.${OPTZ_FMT};
		fi
	fi

	[[ ${MOD_SPEECH} = tts-1* ]] && max=4096 || max=40960;
	((${#} >1)) && set -- "$*";

	if ((!CHAT_ENV))
	then 	__sysmsgf 'Speech Model:' "$MOD_SPEECH";
		__sysmsgf 'Voice:' "$VOICEZ";
		__sysmsgf 'Speed:' "${SPEEDZ:-1}";
	fi; ((${#SPEEDZ})) && check_optrangef "$SPEEDZ" 0.25 4 'TTS speed'
	[[ $1 != *([$IFS]) ]] || ! echo '(empty)' >&2 || return 2

	if ((${#1}>max))
	then 	__warmsgf 'Warning:' "User input ${#1} chars / max ${max} chars"  #max ~5 minutes
		i=1 FOUT=${FOUT%.*}-${i}.${OPTZ_FMT};
	fi  #https://help.openai.com/en/articles/8555505-tts-api
	REPLAY_FILES=();

	while input=${1:0: max}; set -- "${1:max}";
	do
		if ((!CHAT_ENV))
		then 	var=${input//\\\\[nt]/ };
			_sysmsgf $'\nFile Out:' "${FOUT/"$HOME"/"~"}";
			__sysmsgf 'Text Prompt:' "${var:0: COLUMNS-17}$([[ -n ${input: COLUMNS-17} ]] && echo ...)";
		fi; REPLAY_FILES=("${REPLAY_FILES[@]}" "$FOUT"); var= ;
		
		BLOCK="{
\"model\": \"${MOD_SPEECH}\",
\"input\": \"${input:-$*}\",
\"voice\": \"${VOICEZ}\", ${SPEEDZ:+\"speed\": ${SPEEDZ},}
\"response_format\": \"${OPTZ_FMT}\"${BLOCK_USR_TTS:+,$NL}$BLOCK_USR_TTS
}"
		((OPTVV)) && __warmsgf "TTS:" "Model: ${MOD_SPEECH:-unset}, Voice: ${VOICEZ:-unset}, Speed: ${SPEEDZ:-unset}, Block: ${BLOCK}"
		_sysmsgf 'TTS:' '<ctr-c> [k]ill, <enter> play ' '';  #!#

		prompt_ttsf & pid=$! secs=$SECONDS;
		trap "trap 'exit' INT; kill -- $pid 2>/dev/null; return;" INT;
		while __spinf; ok=
			kill -0 -- $pid  >/dev/null 2>&1 || ! echo >&2
		do 	var=$(
			  if ((OPTV>0)) && ((!${#TERMUX_VERSION}))
			  then
			    printf '%s\n' 'p' >&2;
			  else
			    NO_CLR=1 __read_charf -t 0.3;
			  fi
			) &&
			case "$var" in
				[Pp]|' '|''|$'\t')  ok=1;
					((SECONDS>secs+2)) ||  #buffer
					__read_charf -t $((secs+2-SECONDS)) >/dev/null 2>&1;
					break 1;;
				[CcEeKkQqSs]|$'\e')  ok=1 ret=130;
					kill -s INT -- $pid 2>/dev/null;
					break 1;;
			esac
		done </dev/tty; __clr_lineupf $((4+1+29+${#var}));  #!#

		((ok)) || wait $pid || ((ret+=$?));
		trap 'exit' INT;
		jq . "$FOUT" >&2 2>/dev/null && ((ret+=$?));  #json response is an err

		case $ret in
			1[2-9][0-9]|2[0-5][0-9]) break 1;;
			[1-9]|[1-9][0-9])
				__warmsgf $'\rerr:' 'tts response'
				printf 'Retry request? Y/n ' >&2;
				case "$(__read_charf)" in
					[AaNnQq]) break 1;;  #no
					*) 	continue;;
				esac;;
		esac

	[[ $FOUT = "-"* ]] || [[ ! -e $FOUT ]] || { 
		du -h "$FOUT" 2>/dev/null || _sysmsgf 'TTS file:' "$FOUT"; 
		((OPTV && !CHAT_ENV)) || [[ ! -s $FOUT ]] || {
			((CHAT_ENV)) || __sysmsgf 'Play Cmd:' "\"${PLAY_CMD}\"";
			case "$PLAY_CMD" in false) 	return $ret;; esac;
		while 	${PLAY_CMD} "$FOUT" & pid=$! PIDS+=($!);
		do 	trap "trap 'exit' INT; kill -- $pid 2>/dev/null; case \"\$PLAY_CMD\" in *termux-media-player*) termux-media-player stop;; esac;" INT;
			wait $pid;
			case $? in
				0) 	case "$PLAY_CMD" in *termux-media-player*) while sleep 1 ;[[ $(termux-media-player info 2>/dev/null) = *[Pp]laying* ]] ;do : ;done;; esac;  #termux fix
					var=3;  #3+1 secs
					((OPTV)) && var=2;;
				*) 	wait $pid;
					var=8;;  #8+1 secs
			esac;
			trap 'exit' INT;
			__warmsgf $'\nReplay?' '[N/y/w] ' '';  #!#
			for ((n=var;n>-1;n--))
			do 	printf '%s\b' "$n" >&2
				if var=$(NO_CLR=1 __read_charf -t 1)
				then 	case "$var" in
					[RrYy]|$'\t') continue 2;;
					[PpWw]|[$' \e']) printf '%s' waiting.. >&2; __read_charf >/dev/null;
						continue 2;;  #wait until key press
					*) 	break;;
					esac;
				fi; ((n)) || echo >&2;
			done; __clr_lineupf 16;  #!#
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
	then 	typeset API_HOST OPENAI_API_KEY ENDPOINTS EPN MOD;
		ENDPOINTS=(); MOD=$MOD_SPEECH;
		EPN=10 ENDPOINTS[10]="/v1/audio/speech";
		API_HOST=$OPENAI_API_HOST_DEF;
		OPENAI_API_KEY=$OPENAI_API_KEY_DEF;
	fi
	_ttsf "$@";
}
function __set_ttsf { 	__set_outfmtf "$1" || __set_voicef "$1" || __set_speedf "$1" ;}
function __set_voicef
{
	case "$1" in
		#alloy|echo|fable|onyx|nova|shimmer
		[Aa][Ll][Ll][Oo][Yy]|[Ee][Cc][Hh][Oo]|[Ff][Aa][Bb][Ll][Ee]|[Oo][Nn][YyIi][Xx]|[Nn][Oo][Vv][Aa]|[Ss][Hh][Ii][Mm][Mm][Ee][Rr]|sky) 	VOICEZ=$1;;
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
	curl -\# ${OPTV:+-Ss} ${FAIL} -L "${API_HOST}${ENDPOINTS[EPN]}" \
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
	then 	if ! __is_pngf "$1" || ! __is_squaref "$1" || ! __is_rgbf "$1" ||
			{ 	((${#} > 1)) && [[ ! -e $2 ]] ;} || [[ -n ${OPT_AT+force} ]]
		then  #not png or not square, or needs alpha
			if ((${#} > 1)) && [[ ! -e $2 ]]
			then  #needs alpha
				__set_alphaf "$1"
			else  #no need alpha
			      #resize and convert (to png32?)
				if __is_opaquef "$1"
				then  #is opaque
					ARGS="" PNG32="" ;((OPTV)) ||
					printf '%s\n' 'Alpha not needed, opaque image' >&2
				else  #is transparent
					ARGS="-alpha set" PNG32="png32:" ;((OPTV)) ||
					printf '%s\n' 'Alpha not needed, transparent image' >&2
				fi
			fi
			__is_rgbf "$1" || { 	PNG32="png32:" ;printf '%s\n' 'Image colour space is not RGB(A)' >&2 ;}
			img_convf "$1" $ARGS "${PNG32}${FILEIN}" &&
				set -- "${FILEIN}" "${@:2}"  #adjusted
		else 	((OPTV)) ||
			printf '%s\n' 'No adjustment needed in image file' >&2
		fi ;unset ARGS PNG32
						
		if [[ -f $2 ]]  #edits + mask file
		then 	size=$(print_imgsizef "$1") 
			if ! __is_pngf "$2" || ! __is_rgbf "$2" || {
				[[ $(print_imgsizef "$2") != "$size" ]] &&
				{ 	((OPTV)) || printf '%s\n' 'Mask size differs' >&2 ;}
			} || __is_opaquef "$2" || [[ -n ${OPT_AT+true} ]]
			then 	mask="${FILEIN%.*}_mask.png" PNG32="png32:" ARGS=""
				__set_alphaf "$2"
				img_convf "$2" -scale "$size" $ARGS "${PNG32}${mask}" &&
					set  -- "$1" "$mask" "${@:3}"  #adjusted
			else 	((OPTV)) ||
				printf '%s\n' 'No adjustment needed in mask file' >&2
			fi
		fi
	fi ;unset ARGS PNG32
	
	__chk_imgsizef "$1" || return 2

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
function __set_alphaf
{
	unset ARGS PNG32
	if __has_alphaf "$1"
	then  #has alpha
		if __is_opaquef "$1"
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
function __is_pngf
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
		__sysmsgf 'Edit with ImageMagick?' '[Y/n] ' ''
		case "$(__read_charf)" in [AaNnQq]|$'\e') 	return 2;; esac
	fi

	if magick "$1" -background none -gravity center -extent 1:1 "${@:2}"
	then 	if ((!OPTV))
		then 	set -- "${@##png32:}" ;__openf "${@:${#}}"
			__sysmsgf 'Confirm edit?' '[Y/n] ' ''
			case "$(__read_charf)" in [AaNnQq]|$'\e') 	return 2;; esac
		fi
	else 	false
	fi
}
#check for image alpha channel
function __has_alphaf
{
	typeset alpha
	alpha=$(magick identify -format '%A' "$1")
	[[ $alpha = [Tt][Rr][Uu][Ee] ]] || [[ $alpha = [Bb][Ll][Ee][Nn][Dd] ]]
}
#check if image is opaque
function __is_opaquef
{
	typeset opaque
	opaque=$(magick identify -format '%[opaque]' "$1")
	[[ $opaque = [Tt][Rr][Uu][Ee] ]]
}
#https://stackoverflow.com/questions/2581469/detect-alpha-channel-with-imagemagick
#check if image is square
function __is_squaref
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
function __chk_imgsizef
{
	typeset chk_fsize
	if chk_fsize=$(wc -c <"$1" 2>/dev/null) ;(( (chk_fsize+500000)/1000000 >= 4))
	then 	__warmsgf "Warning:" "Max image size is 4MB [file:$((chk_fsize/1000))KB]"
		(( (chk_fsize+500000)/1000000 < 5))
	fi
}
#is image colour space rgb?
function __is_rgbf
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
		__clr_dialogf;

		for act in ${act_keys}
		do  ((++n))
		    case "$REPLY" in "$act")  act=${n:-1}; break;; esac;
		done
	else
	echo >&2;
	set -- "${1:-%#}";
	while ! { 	((act && act <= act_keys_n)) ;}
	do 	if ! act=$(grep -n -i -e "${glob}${1//[ _-]/[ _-]}" <<<"${act_keys}")
		then 	__clr_ttystf;
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
			__clr_ttystf; read -r -e act </dev/tty;
			printf '\n\n' >&2;
		fi ;set -- "$act"; glob= n= a= l=;
	done
	fi

	INSTRUCTION=$(sed -n -e 's/^[^,]*,//; s/^"//; s/"$//; s/""/"/g' -e "$((act+1))p" "$FILEAWE")
	((CMD_CHAT)) ||
	if __clr_ttystf; ((OPTX))  #edit chosen awesome prompt
	then 	INSTRUCTION=$(ed_outf "$INSTRUCTION") || exit
		printf '%s\n\n' "$INSTRUCTION" >&2 ;
	else 	read_mainf -i "$INSTRUCTION" INSTRUCTION
		((OPTCTRD)) && INSTRUCTION=$(trim_trailf "$INSTRUCTION" $'*([\r])')
	fi </dev/tty
	case "$INSTRUCTION" in ''|prompt|act)
		__warmsgf 'Err:' 'awesome-chatgpt-prompts fail'
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
	case "${INSTRUCTION// }"  in
		+([.,])@(list|\?)|[.,]+([.,/*?-]))
			INSTRUCTION= list=1
			_cmdmsgf 'Prompt File' 'LIST'
			;;
		,*|.,*)   #edit template prompt file
			INSTRUCTION="${INSTRUCTION##[.,]*( )}"
			template=1 skip=0 msg='EDIT TEMPLATE'
			;;
		[.,]) #pick prompt file
			INSTRUCTION=
			;;
	esac
	
	#set skip confirmation (catch ./file)
	[[ $INSTRUCTION = ..* ]] && [[ $INSTRUCTION != ../*([!/]) ]] \
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
	then 	template=1
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
	_sysmsgf 'Prompt File:' "${file/"$HOME"/"~"}"
	_cmdmsgf "${new:+New }Prompt Cmd" " ${msg}"
	#{ 	[[ ! -t 1 ]] || ((OPTEXIT)) || ((!MTURN)) ;} && skip=1

	if { 	[[ $msg = *[Cc][Rr][Ee][Aa][Tt][Ee]* ]] && INSTRUCTION="$*" ret=200 ;} ||
		[[ $msg = *[Ee][Dd][Ii][Tt]* ]] || (( (MTURN+CHAT_ENV) && OPTRESUME!=1 && skip==0))
	then
		__clr_ttystf;
		if ((OPTX))  #edit prompt
		then 	INSTRUCTION=$(ed_outf "$INSTRUCTION") || exit
			printf '%s\n\n' "$INSTRUCTION" >&2 ;
		else 	__printbf '>'; read_mainf -i "$INSTRUCTION" INSTRUCTION;
			((OPTCTRD)) && INSTRUCTION=$(trim_trailf "$INSTRUCTION" $'*([\r])')
		fi </dev/tty

		if ((template))  #push changes to file
		then 	printf '%s' "$INSTRUCTION"${INSTRUCTION:+$'\n'} >"$file"
			[[ -f "$file" && ! -s "$file" ]] && { rm -v -- "$file" || rm -- "$file" ;} >&2
		fi
		if [[ -z $INSTRUCTION ]]
		then 	__warmsgf 'Err:' 'custom prompts fail'
			return 1
		fi
	fi
	return ${ret:-0}
} #exit codes: 1) err; 	200) create new pr; 	201) abort.

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
	((${#PLAY_CMD})) ||
	if command -v play-audio  #termux
	then 	PLAY_CMD='play-audio'
	elif command -v termux-media-player
	then 	PLAY_CMD='termux-media-player play'
	elif command -v mpv
	then 	PLAY_CMD='mpv --no-video --vo=null'
	elif command -v play  #sox
	then 	PLAY_CMD='play'
	elif command -v cvlc
	then 	PLAY_CMD='cvlc --no-loop --no-repeat'
	elif command -v ffplay
	then 	PLAY_CMD='ffplay -nodisp'
	elif command -v afplay  #macos
	then 	PLAY_CMD='afplay'
	else 	PLAY_CMD='false'
	fi >/dev/null 2>&1
}  #streaming: ffplay -nodisp -, cvlc -

#set audio recorder command
function set_reccmdf
{
	((${#REC_CMD})) ||
	if command -v termux-microphone-record
	then 	REC_CMD='termux-microphone-record -r 16000 -c 1 -l 0 -f'
	elif command -v sox
	then 	REC_CMD='sox -d -r 16000 -c 1'  #'silence 1 0.50 0.1%'
	elif command -v arecord  #alsa utils
	then 	REC_CMD='arecord -f S16_LE -r 16000 -c 1 -i'
	elif command -v ffmpeg
	then 	case "${OSTYPE:-$(uname -a)}" in
		    *[Dd]arwin*)
			REC_CMD='ffmpeg -f avfoundation -i ":1" -ar 16000 -ac 1 -y';;
		    *)  REC_CMD='ffmpeg -f alsa -i pulse -ar 16000 -ac 1 -y';;
		    #'-af silenceremove=start_periods=1:start_silence=0.2:start_threshold=-28dB'
		esac;
	else 	REC_CMD='false'
	fi >/dev/null 2>&1
}
#id.luchkin: https://community.openai.com/t/whisper-api-hallucinating-on-empty-sections/93646/5  

#play audio bell
function bellf
{
	typeset bell
	bell="/usr/share/sounds/freedesktop/stereo/message.oga";
	[[ -s $bell ]] || bell="${OUTDIR%/}/bell.oga";
	if [[ -s $bell ]]
	then 	set_playcmdf;
		$PLAY_CMD "$bell";
	else 	curl -s -L "https://gitlab.com/mountaineerbr/etc/-/raw/main/media/message.oga" -o "$bell";
	fi >/dev/null 2>&1 & PIDS+=($!);
}

#append to shell hist list
function shell_histf
{
	[[ ${*} != *([$IFS]) ]] || return
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
		[Cc]urrent|.) 	set -- "${FILECHAT##*/}" "${@:2}";;
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
	then 	__clr_ttystf;
		if test_dialogf
		then 	options=( $(_dialog_optf 'current' 'new' "${@%%.${sglob}}") )
			file=$(
			  dialog --backtitle "Selection Menu" --title "$([[ $ext = *[Tt][Ss][Vv] ]] && echo History File || echo Prompt) Selection" \
			    --menu "Choose one of the following:" 0 40 0 \
			    -- "${options[@]}"  2>&1 >/dev/tty;
			) || { file=abort; typeset NO_DIALOG=1 ;}
			__clr_dialogf;
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
			echo abort; echo abort >&2
			return 201
			;;
		"$REPLY")
			ok=1
			;;
	esac

	file="${CACHEDIR%%/}/${file:-${*:${#}}}"
	file="${file%%.${sglob}}.${ext}"
	[[ -f $file || $ok -gt 0 ]] && printf '%s\n' "${file}"
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
		then 	__warmsgf 'Err:' 'is a directory'
			fname="${fname%%/}"
		( 	cd "$fname" &&
			ls -- "${fname}"/*.${sglob} ) >&2 2>/dev/null
			shell_histf "${fname}${fname:+/}"
			unset fname
		fi

		if [[ ${fname} = *([$IFS]) ]]
		then
			if test_dialogf
			then 	fname=$(
				dialog --backtitle "${item} manager" \
				--title "new ${item} file" \
				--inputbox "enter new ${item} name" 8 32  2>&1 >/dev/tty )
				__clr_dialogf;
			else
				_sysmsgf "New ${item} name <enter/abort>:" \
				__clr_ttystf; read -r -e -i "$fname" fname </dev/tty;
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
		then 	case "$fname" in *[N]ew.${sglob}) 	:;; *[Aa]bort.${sglob}|*[Cc]ancel.${sglob}|*[Ee]xit.${sglob}|*[Qq]uit.${sglob}) 	echo abort; echo abort >&2; return 201;; esac
			if test_dialogf
			then 	dialog --colors --backtitle "${item} manager" \
				--title "confirm${new} ${item} file?" \
				--yesno " \\Zb${new:+\\Z1}${print_name}\\Zn" 8 $((${#print_name}+6))  >/dev/tty
				case $? in
					-1|1|5|255) var=abort;;
				esac;
				__clr_dialogf;
			else
				_sysmsgf "Confirm${new}? [Y]es/[n]o/[a]bort:" "${print_name} " '' ''
				var=$(__read_charf)
			fi
			case "$var" in [AaQq]|$'\e'|*[Aa]bort|*[Aa]bort.${sglob}) 	echo abort; echo abort >&2; return 201;; [NnOo]) 	:;; *) 	false;; esac
		else 	false
		fi
	do 	unset fname new print_name
	done
	
	if [[ ! -e ${fname} ]]
	then 	[[ ${fname} = *.[Pp][Rr] ]] \
		&& printf '(new prompt file)\n' >&2 \
		|| printf '(new hist file)\n' >&2
	fi
	[[ ${fname} != *([$IFS]) ]] && printf '%s\n' "$fname"
}
#pick and print a session from hist file
function session_sub_printf
{
	typeset REPLY reply file time token string buff buff_end index regex skip sopt copt ok m n
	typeset -a SPIN_CHARS=("${SPIN_CHARS0[@]}");
	[[ -s ${file:=$1} ]] || return; [[ $file = */* ]] || [[ ! -e "./$file" ]] || file="./$file";
	FILECHAT_OLD="$file" regex="${REGEX%%${NL}*}";
 
	while ((skip)) || IFS= read -r
	do 	__spinf; skip= ;
		if [[ ${REPLY} = *([$IFS])\#* ]] && ((OPTHH<3))
		then 	continue
		elif [[ ${REPLY} = *[Bb][Rr][Ee][Aa][Kk]*([$IFS]) ]]
		then
for ((m=1;m<2;++m))
do 	__spinf 	#grep session with user regex
			if ((${regex:+1}))
			then 	if ((!ok))
				then 	[[ $regex = -?* ]] && sopt="${regex%% *}" regex="${regex#* }"
					grep $sopt "${regex}" <<<" " >/dev/null  #test user syntax
					(($?<2)) || return 1; ((OPTK)) || copt='--color=always';
					
					_sysmsgf 'Regex': "\`${regex}'";
					if ! grep -q $copt $sopt "${regex}" "$file" 1>&2 2>/dev/null;  #grep regex match in current file
					then 	grep -n -o $copt $sopt "${regex}" "${file%/*}"/*"${file##*.}" 1>&2 2>/dev/null  #grep other files
						__warmsgf 'Err:' "No match at \`${file/"$HOME"/"~"}'";
						buff= ; break 2;
					fi; ok=1;
				fi;
				grep $copt $sopt "${regex}" < <(_unescapef "$(cut -f1,3- -d$'\t' <<<"$buff")") >&2 || buff= ;
			else
				for ((n=0;n<12;++n))
				do 	__spinf
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
			  then 	_sysmsgf "Correct session?" '[Y/n/a] ' ''
			  else 	_sysmsgf "Tail of the correct session?" '[Y]es, [n]o, [r]egex, [a]bort ' ''
			  fi;
			  reply=$(__read_charf);
			  case "$reply" in
				[]GgSsRr/?:\;-]|[$' \t']) _sysmsgf 'grep:' '<-opt> <regex> <enter>';
					__clr_ttystf;
					read -r -e -i "${regex:-${reply//[!-]}}" regex </dev/tty;
					skip=1 ok= ;
					continue 2;
					;;
				[NnOo]|$'\e') ((${regex:+1})) && printf '%s\n' '---' >&2;
					false;
					;;
				[AaQq]) echo abort >&2;
					return 201;
					;;
				*) 	((${regex:+1})) && printf '%s\n' '---' >&2;
					break 2;
					;;
			esac
			}
done
			unset REPLY reply time token string buff buff_end index m n
			continue
		fi
		buff="${REPLY}"${buff:+$'\n'}"${buff}"
	done < <( 	tac -- "$file" && {
			((OPTPRINT+OPTHH)) || __warmsgf '(end of hist file)' ;}
			echo BREAK;
		); __printbf ' '
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
	fi; case "$src" in [Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit) 	echo abort >&2; return 201;; esac
	_sysmsgf 'Destination hist file: ' '' ''
	dest="$(session_globf "$@" || session_name_choosef "$@")"; echo "${dest:-err}" >&2
	dest="${dest:-$FILECHAT}"; case "$dest" in [Aa]bort|[Cc]ancel|[Ee]xit|[Qq]uit) 	echo abort >&2; return 201;; esac

	buff=$(session_sub_printf "$src") \
	&& if [[ -f "$dest" ]] ;then 	[[ "$(<"$dest")" != *"${buff}" ]] || return 0 ;fi \
	&& { FILECHAT="${dest}" INSTRUCTION_OLD= INSTRUCTION= cmd_runf /break 2>/dev/null;
	     FILECHAT="${dest}" _break_sessionf; OLD_DEST="${dest}";
	     #check if dest is the same as current
	     [[ "$dest" = "$FILECHAT" ]] && unset BREAK_SET MAIN_LOOP TOTAL_OLD MAX_PREV ;} \
	&& _sysmsgf 'SESSION FORK' \
	&& printf '%s\n' "$buff" >> "$dest" \
	&& printf '%s\n' "$dest"
}
#create or copy a session, search for and change to a session file.
function session_mainf
{
	typeset name file optsession arg break msg
	typeset -a args
	name="${*}"               ;((${#name}<512)) || return
	name="${name##*([$IFS])}" ;[[ $name = [/!]* ]] || return
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
	do 	[[ ${arg} != *([$IFS]) ]] && set -- "$@" "$arg"
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
		INSTRUCTION_OLD=${GINSTRUCTION:-${INSTRUCTION:-$INSTRUCTION_OLD}} INSTRUCTION= GINSTRUCTION= OPTRESUME=1;
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
		        case "$(__read_charf)" in [YySs]) 	:;; $'\e'|*) 	false ;;esac
		        } ;}
		    then  FILECHAT="${file:-$FILECHAT}" cmd_runf /break;
		          unset MAIN_LOOP TOTAL_OLD MAX_PREV;
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
		then 	curl -\# -L "${OLLAMA_API_HOST}/api/show" -d "{\"name\": \"$1\"}" -o "$FILE" &&
			{ jq . "$FILE" || ! __warmsgf 'Err' ;}; echo >&2;
			ollama show "$1" --modelfile  2>/dev/null;
		else 	{
			  printf '\nName\tFamily\tFormat\tParam\tQLvl\tSize\tModification\n'
			  curl -s -L "${OLLAMA_API_HOST}/api/tags" -o "$FILE" &&
			  { jq -r '.models[]|.name?+"\t"+(.details.family)?+"\t"+(.details.format)?+"\t"+(.details.parameter_size)?+"\t"+(.details.quantization_level)?+"\t"+((.size/1000000)|tostring)?+"MB\t"+.modified_at?' "$FILE" || ! __warmsgf 'Err' ;}
			} | { 	column -t -s $'\t' 2>/dev/null || ! __warmsgf 'Err' ;}  #tsv
		fi
	}
	ENDPOINTS[0]="/api/generate" ENDPOINTS[5]="/api/embeddings" ENDPOINTS[6]="/api/chat";
	((${#OLLAMA_API_HOST})) || OLLAMA_API_HOST=$OLLAMA_API_HOST_DEF;
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER  #set placeholder as this field is required
	
	OLLAMA_API_HOST=${OLLAMA_API_HOST%%*([/$IFS])}; set_model_epnf "$MOD";
	_sysmsgf "OLLAMA URL / Endpoint:" "$OLLAMA_API_HOST${ENDPOINTS[EPN]}";
}

#host url / endpoint
function set_localaif
{
	[[ $OPENAI_API_HOST_STATIC != *([$IFS]) ]] && OPENAI_API_HOST=$OPENAI_API_HOST_STATIC;
	if [[ $OPENAI_API_HOST != *([$IFS]) ]] || ((OLLAMA))
	then
		API_HOST=${OPENAI_API_HOST%%*([/$IFS])};
		((LOCALAI)) &&
		function list_modelsf  #LocalAI only
		{
			if ((${#1}))
			then
				curl -\# -L "${API_HOST}/models/available" -o "$FILE" &&
				{ jq ".[] | select(.name | contains(\"$1\"))" "$FILE" || ! __warmsgf 'Err' ;}
			else
				curl -\# -L ${FAIL} "${API_HOST}/models/available" -o "$FILE" &&
				{ jq -r '.[]|.gallery.name+"@"+(.name//empty)' "$FILE" || ! __warmsgf 'Err' ;} ||
				! curl -\# -L "${API_HOST}/models/" | jq .
				#bug# https://github.com/mudler/LocalAI/issues/2045
			fi
		}  #https://localai.io/models/
		set_model_epnf "$MOD";
		((${#OPENAI_API_HOST})) && LOCALAI=1;
		((${#OPENAI_API_HOST_STATIC})) && unset ENDPOINTS;  #endpoint auto select
		((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
		((!LOCALAI)) || _sysmsgf "HOST URL / Endpoint:" "${API_HOST}${ENDPOINTS[EPN]}${ENDPOINTS[*]:+ [auto-select]}";
	else 	false;
	fi
}

#google ai
function set_googleaif
{
	FILE_PRE="${FILE%%.json}.pre.json";
	GOOGLE_API_HOST="${GOOGLE_API_HOST:-$GOOGLE_API_HOST_DEF}";
	: ${GOOGLE_API_KEY:?Required}
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
	((OPTC)) || OPTC=2;

	function list_modelsf
	{
		if [[ -z $* ]]
		then 	curl -\# ${FAIL} -L "$GOOGLE_API_HOST/models?key=$GOOGLE_API_KEY" -o "$FILE"
		else 	curl -\# ${FAIL} -L "$GOOGLE_API_HOST/models/${1}?key=$GOOGLE_API_KEY" -o "$FILE"
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
		((STREAM)) && epn='streamGenerateContent'; : >"$FILE_PRE";
		if curl "$@" ${FAIL} -L "$GOOGLE_API_HOST/models/$MOD:${epn}?key=$GOOGLE_API_KEY" \
			-H 'Content-Type: application/json' -X POST \
			-d "$BLOCK" | tee "$FILE_PRE" | sed -n 's/^ *"text":.*/{ & }/p'
		then 	[[ \ $*\  = *\ -s\ * ]] || __clr_lineupf;
		else 	return $?;  #E#
		fi
	}
	function embedf
	{
		curl ${FAIL} -L "$GOOGLE_API_HOST/models/$MOD:embedContent?key=$GOOGLE_API_KEY" \
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
		  curl -sS --max-time 10 -L "$GOOGLE_API_HOST/models/$MOD:${epn}?key=$GOOGLE_API_KEY" \
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
		jq -r ".${var} | .usageMetadata | (.promptTokenCount,.candidatesTokenCount)" "$@";
	}
	function fmt_ccf
	{
		typeset var ext role
		[[ ${1} != *([$IFS]) ]] || return
		
		case "$2" in
			assistant) 	role=model;;
			''|system|user|*) 	role=user;;
		esac;
		printf '{"role": "%s", "parts": [ {"text": "%s"}' "${role}" "$1";
		for var in "${MEDIA[@]}" "${MEDIA_CMD[@]}"
		do
			if [[ $var = *([$IFS]) ]]
			then 	continue;
			elif [[ -f $var ]]
			then 	ext=${var##*.}; ((${#ext}<7)) && ext=${ext/[Jj][Pp][Gg]/jpeg} || ext=;
				printf ',
  {
    "inline_data": {
      "mime_type":"%s/%s",
      "data": "%s"
    }
}' "$(_is_videof "$var" && echo video || echo image)" "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
			elif is_linkf "$var"
			then 	__warmsgf 'GoogleAI: illegal URL --' "${var:0: COLUMNS-25}";
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
	((${#ANTHROPIC_API_HOST})) || ANTHROPIC_API_HOST=$ANTHROPIC_API_HOST_DEF;
	ENDPOINTS[0]="/v1/complete" ENDPOINTS[6]="/v1/messages" OPTA= OPTAA= ;
	if ((ANTHROPICAI)) && ((EPN==0))
	then 	[[ -n ${RESTART+1} ]] || RESTART='\n\nHuman: ';
		[[ -n ${START+1} ]] || START='\n\nAssistant:';
	fi;

	function __promptf
	{
		[[ $MOD =  claude-3-5-sonnet-20240620 ]] &&  #8192 output tokens is in beta 
		  set -- "$@" --header "anthropic-beta: max-tokens-3-5-sonnet-2024-07-15";

		if curl "$@" ${FAIL} -L "${ANTHROPIC_API_HOST}${ENDPOINTS[EPN]}" \
			--header "x-api-key: $ANTHROPIC_API_KEY" \
			--header "anthropic-version: 2023-06-01" \
			--header "content-type: application/json" \
			--data "$BLOCK";
		then 	[[ \ $*\  = *\ -s\ * ]] || __clr_lineupf;
		else 	return $?;  #E#
		fi
	}
	function response_tknf
	{
		jq -r '(.usage.output_tokens)//empty,
			(.usage.input_tokens)//(.message.usage.input_tokens)//empty' "$@";
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


unset OPTMM OPTMARG STOPS MAIN_LOOP
#parse opts  #DIJQX
optstring="a:A:b:B:cCdeEfFgGhHij:kK:lL:m:M:n:N:p:Pqr:R:s:S:t:ToOuUvVxwWyYzZ0123456789@:/,:.:-:"
while getopts "$optstring" opt
do
	case "$opt" in -)  #order matters: anthropic anthropic:ant
		for opt in api-key  multimodal  markdown  markdown:md  \
no-markdown  no-markdown:no-md  fold  fold:wrap  no-fold  no-fold:no-wrap \
localai  localai:local-ai  localai:local  google  google:goo  mistral \
openai  groq  groq:grok  anthropic  anthropic:ant  j:seed  keep-alive \
keep-alive:ka  @:alpha  M:max-tokens  M:max  N:mod-max  N:modmax \
a:presence-penalty  a:presence  a:pre  A:frequency-penalty  A:frequency \
A:freq  b:best-of  b:best  B:logprobs  c:chat  C:resume  C:resume  C:continue \
d:text  e:edit  E:exit  f:no-conf  g:stream  G:no-stream  h:help  H:hist \
i:image  'j:synthesi[sz]e'  j:synth  'J:synthesi[sz]e-voice'  J:synth-voice \
'k:no-colo*'  K:top-k  K:topk  l:list-model  l:list-models  L:log  m:model \
m:mod  n:results  o:clipboard  o:clip  O:ollama  p:top-p  p:topp  q:insert \
r:restart-sequence  r:restart-seq  r:restart  R:start-sequence  R:start-seq \
R:start  s:stop  S:instruction  t:temperature  t:temp  T:tiktoken  \
u:multiline  u:multi  U:cat  v:verbose  x:editor  X:media  w:transcribe \
w:stt  W:translate  y:tik  Y:no-tik  z:tts  z:speech  Z:last  P:print  version
		do
			name="${opt##*:}"  name="${name/[_-]/[_-]}"
			opt="${opt%%:*}"
			case "$OPTARG" in $name*) 	break;; esac
		done

		case "$OPTARG" in
			$name|$name=)
				if [[ $optstring = *"$opt":* ]]
				then 	OPTARG="${@:$OPTIND:1}"
					OPTIND=$((OPTIND+1))
				fi;;
			$name=*)
				OPTARG="${OPTARG##$name=}"
				;;
			[0-9]*)  #max resp tkns option
				OPTARG="$OPTMM-$OPTARG" opt=M 
				;;
			*) 	__warmsgf "Unknown option:" "--$OPTARG"
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
		d) 	OPTCMPL=1;;
		e) 	OPTE=1;;
		E) 	((++OPTEXIT));;
		f$OPTF) unset EPN MOD MOD_CHAT MOD_AUDIO MOD_SPEECH MOD_IMAGE MODMAX INSTRUCTION OPTZ_VOICE OPTZ_SPEED OPTZ_FMT OPTC OPTI OPTLOG USRLOG OPTRESUME OPTCMPL MTURN CHAT_ENV OPTTIKTOKEN OPTTIK OPTYY OPTFF OPTK OPTKK OPT_KEEPALIVE OPTHH OPTL OPTMARG OPTMM OPTNN OPTMAX OPTA OPTAA OPTB OPTBB OPTN OPTP OPTT OPTTW OPTV OPTVV OPTW OPTWW OPTZ OPTZZ OPTSTOP OPTCLIP CATPR OPTCTRD OPTMD OPT_AT_PC OPT_AT Q_TYPE A_TYPE RESTART START STOPS OPTS_HD OPTI_STYLE OPTSUFFIX SUFFIX CHATGPTRC REC_CMD PLAY_CMD CLIP_CMD STREAM MEDIA MEDIA_CMD MD_CMD OPTE OPTEXIT API_HOST OLLAMA MISTRALAI LOCALAI GROQAI ANTHROPICAI GPTCHATKEY READLINEOPT MULTIMODAL OPTFOLD HISTSIZE WAPPEND NO_DIALOG NO_OPTMD_AUTO;
			#OLLAMA_API_HOST OPENAI_API_HOST OPENAI_API_HOST_STATIC CACHEDIR OUTDIR
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
		i) 	OPTI=1 EPN=3;;
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
		no-markdown) 	unset OPTMD;;
		multimodal) 	MULTIMODAL=1 EPN=6;;
		n) 	[[ $OPTARG = *[!0-9\ ]* ]] && OPTMM="$OPTARG" ||  #compat with -Nill option
			OPTN="$OPTARG" ;;
		o) 	OPTCLIP=1;;
		O) 	OLLAMA=1 GOOGLEAI= MISTRALAI= GROQAI= ANTHROPICAI= ;;
		google) GOOGLEAI=1 OLLAMA= MISTRALAI= GROQAI= ANTHROPICAI= ;;
		mistral) MISTRALAI=1 OLLAMA= GOOGLEAI= GROQAI= ANTHROPICAI= ;;
		localai) LOCALAI=1;;
		openai) GOOGLEAI= OLLAMA= MISTRALAI= GROQAI= ANTHROPICAI= ;;
		groq) 	GROQAI=1 GOOGLEAI= OLLAMA= MISTRALAI= ANTHROPICAI= ;;
		anthropic) ANTHROPICAI=1 GROQAI= GOOGLEAI= OLLAMA= MISTRALAI= ;;
		p) 	OPTP="$OPTARG";;
		q) 	((++OPTSUFFIX)); EPN=0;;
		r) 	RESTART="$OPTARG";;
		R) 	START="$OPTARG";;
		j) 	OPTSEED=$OPTARG;;
		s) 	STOPS=("$OPTARG" "${STOPS[@]}");;
		S|.|,) 	if [[ -f "$OPTARG" ]]
			then 	INSTRUCTION="${opt##S}$(<"$OPTARG")"
			else 	INSTRUCTION="${opt##S}$OPTARG"
			fi;;
		t) 	OPTT="$OPTARG" OPTTARG="$OPTARG";;
		T) 	((++OPTTIKTOKEN));;
		u) 	((OPTCTRD)) && unset OPTCTRD || OPTCTRD=1
			__cmdmsgf 'Prompter <Ctrl-D>' $(_onoff $OPTCTRD);;
		U) 	CATPR=1;;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		version) while read; do 	[[ $REPLY = \#\ v* ]] || continue; printf '%s\n' "$REPLY"; exit; done <"${BASH_SOURCE[0]:-$0}";;
		x) 	OPTX=1;;
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
unset LANGW MTURN CHAT_ENV SKIP EDIT INDEX HERR BAD_RES REPLY REPLY_CMD REPLY_CMD_DUMP REGEX SGLOB EXT PIDS NO_CLR WARGS ZARGS WCHAT_C MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND SMALLEST DUMP RINSERT BREAK_SET SKIP_SH_HIST OK_DIALOG DIALOG_CLR PREVIEW RET init buff var n s
typeset -a PIDS MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND WARGS ZARGS
typeset -l VOICEZ OPTZ_FMT  #lowercase vars

set -o ${READLINEOPT:-emacs}; 
bind 'set enable-bracketed-paste on';
bind -x '"\C-x\C-e": "_edit_no_execf"'
bind '"\C-j": "\C-v\C-j"'  #add newline
[[ $BASH_VERSION = [5-9]* ]] || ((OPTV)) || __warmsgf 'Warning:' 'Bash 5+ required';

[[ -t 1 ]] || OPTK=1 ;((OPTK)) || {
  #map colours
  : "${RED:=${Color1:=${Red}}}"       "${BRED:=${Color2:=${BRed}}}"
  : "${YELLOW:=${Color3:=${Yellow}}}" "${BYELLOW:=${Color4:=${BYellow}}}"
  : "${PURPLE:=${Color5:=${Purple}}}" "${BPURPLE:=${Color6:=${BPurple}}}" "${ON_PURPLE:=${Color7:=${On_Purple}}}"
  : "${CYAN:=${Color8:=${Cyan}}}"     "${BCYAN:=${Color9:=${BCyan}}}"  "${ON_CYAN:=${Color12:=${On_Cyan}}}"  #Color12 needs adding to all themes
  : "${WHITE:=${Color10:=${White}}}"  "${BWHITE:=${Color11:=${BWhite}}}"
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

((OPTL+OPTZZ)) && unset OPTX
((OPTZ && OPTW && !MTURN)) && unset OPTX
((OPTI)) && unset OPTC
((OPTCLIP)) && set_clipcmdf
((OPTW+OPTWW)) && set_reccmdf
((OPTZ)) && set_playcmdf
((OPTC)) || OPTT="${OPTT:-0}"  #!#temp *must* be set
((OPTCMPL)) && unset OPTC  #opt -d
((!OPTC)) && ((OPTRESUME>1)) && OPTCMPL=${OPTCMPL:-$OPTRESUME}  #1# txt cmpls cont
((OPTCMPL)) && ((!OPTRESUME)) && OPTCMPL=2  #2# txt cmpls new
((OPTC+OPTCMPL || OPTRESUME>1)) && MTURN=1  #multi-turn, interactive
((OPTSUFFIX)) && ((OPTC)) && { ((OPTC>1)) || { [[ -n ${RESTART+1} ]] || RESTART=; [[ -n ${START+1} ]] || START= ;}; OPTC=1; };  #-qqc and -qqcc  #weyrd combo#
((OPTSUFFIX>1)) && MTURN=1 OPTSUFFIX=1      #multi-turn -q insert mode
((OPTCTRD)) || unset OPTCTRD  #(un)set <ctrl-d> prompter flush [bash]
[[ ${INSTRUCTION} != *([$IFS]) ]] || unset INSTRUCTION

#map models
if [[ -n $OPTMARG ]]
then 	((OPTI)) && MOD_IMAGE=$OPTMARG  #default models for functions
	((OPTW && !(OPTC+OPTCMPL+MTURN) )) && MOD_AUDIO=$OPTMARG
	((OPTZ && !(OPTC+OPTCMPL+MTURN) )) && MOD_SPEECH=$OPTMARG
	case "$MOD" in moderation|mod|oderation|od) 	MOD="text-moderation-stable";; esac;
	[[ $MOD = *moderation* ]] && unset OPTC OPTW OPTWW OPTZ OPTI OPTII MTURN OPTRESUME OPTCMPL OPTEMBED
else
	if ((OLLAMA))
	then 	MOD=$MOD_OLLAMA
	elif ((GOOGLEAI))
	then 	MOD=$MOD_GOOGLE
	elif ((MISTRALAI)) || [[ $OPENAI_API_HOST = *mistral* ]]
	then 	MOD=$MOD_MISTRAL
	elif ((GROQAI))
	then 	MOD=$MOD_GROQ MOD_AUDIO=$MOD_AUDIO_GROQ
	elif ((ANTHROPICAI))
	then 	MOD=$MOD_ANTHROPIC
	elif ((LOCALAI))
	then 	MOD=$MOD_LOCALAI
	elif ((!OPTCMPL))
	then 	if ((OPTC>1))  #chat
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
if ((GOOGLEAI))
then 	set_googleaif;
	unset OPTTIK OLLAMA MISTRALAI GROQAI ANTHROPICAI;
else 	unset GOOGLEAI;
fi

#groq integration
if ((GROQAI))
then 	OPENAI_API_KEY=${GROQ_API_KEY:?Required}
	((OPTC==1 || OPTCMPL)) && OPTC=2;
	ENDPOINTS[0]=${ENDPOINTS[6]};
	API_HOST=${GROQ_API_HOST:-$GROQ_API_HOST_DEF};
	unset OLLAMA GOOGLEAI MISTRALAI ANTHROPICAI;
else 	unset GROQAI;
fi  #https://console.groq.com/docs/api-reference

#anthropic integration
if ((ANTHROPICAI))
then 	set_anthropicf;
	unset OLLAMA GOOGLEAI MISTRALAI GROQAI;
else 	unset ANTHROPICAI;
fi

#ollama integration
if ((OLLAMA))
then 	set_ollamaf;
	unset GOOGLEAI MISTRALAI GROQAI ANTHROPICAI;
else  	unset OLLAMA OLLAMA_API_HOST;
fi

#custom host / localai
if [[ ${OPENAI_API_HOST_STATIC}${OPENAI_API_HOST} != *([$IFS]) ]] || ((LOCALAI))
then 	((${#OPENAI_API_HOST})) || OPENAI_API_HOST=$LOCALAI_API_HOST_DEF;
	set_localaif;
else 	unset OPENAI_API_HOST OPENAI_API_HOST_STATIC;
fi

#mistral ai api
if [[ $OPENAI_API_HOST = *mistral* ]] || ((MISTRALAI))
then 	: ${MISTRAL_API_KEY:?Required}
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
	((${#MISTRAL_API_HOST})) || MISTRAL_API_HOST=$MISTRAL_API_HOST_DEF;
	if [[ $MOD = *code* ]]
	then 	ENDPOINTS[0]="/v1/fim/completions"
		((OPTSUFFIX)) && ((OPTC)) && OPTC=1;
	elif [[ $MOD != *embed* ]]
	then 	OPTSUFFIX= OPTCMPL= OPTC=2;
	fi; MISTRALAI=1;
	unset LOCALAI OLLAMA GOOGLEAI GROQAI ANTHROPICAI OPTA OPTAA OPTB;
else 	unset MISTRAL_API_KEY MISTRAL_API_HOST;
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
set_optsf

#promote var to array (model costs)
COST_CUSTOM=( $COST_CUSTOM )

#markdown rendering
if ((OPTMD+${#MD_CMD}))
then 	set_mdcmdf "$MD_CMD";
	((OPTMD)) || OPTMD=1;
fi
((${#OPTMD}+${#MD_CMD})) && NO_OPTMD_AUTO=1  #disable markdown auto detect

#stdin and stderr filepaths
if [[ -n $TERMUX_VERSION ]]
then 	STDIN='/proc/self/fd/0' STDERR='/proc/self/fd/2'
else 	STDIN='/dev/stdin'      STDERR='/dev/stderr'
fi

#load text file from last arg or first arg, and stdin
if ((OPTX)) && ((OPTEMBED+OPTI+OPTZ+OPTTIKTOKEN)) && ((!(OPTC+OPTCMPL) ))
then
	if ((OPTEMBED+OPTI+OPTZ)) && ((${#}))
	then 	if [[ -f ${@:${#}} ]] && is_txtfilef "${@:${#}}"
		then 	set -- "${@:1:${#}-1}" "$(<"${@:${#}}")";
		elif [[ -f ${@:${#}} ]] && is_pdff "${@:${#}}"
		then 	set -- "${@:1:${#}-1}" "$(OPTV=4 cmd_runf /pdf "${@:${#}}"; printf '%s\n' "$REPLY")";
		elif [[ -f $1 ]] && is_txtfilef "$1"
		then 	set -- "$(<"$1")" "${@:2}";
		elif [[ -f $1 ]] && is_pdff "$1"
		then 	set -- "$(OPTV=4 cmd_runf /pdf "$1"; printf '%s\n' "$REPLY")" "${@:2}";
		else 	false;
		fi && SKIP_SH_HIST=1;
	fi

	{ ((OPTI)) && ((${#})) && [[ -f ${@:${#}} ]] ;} ||
	  [[ -t 0 ]] || set -- "$@" "$(<$STDIN)";
	
	edf "$@" && set -- "$(<"$FILETXT")";
elif ! ((OPTTIKTOKEN+OPTI))
then
	if ((${#}))
	then 	if [[ -f ${@:${#}} ]] && is_txtfilef "${@:${#}}"
		then 	set -- "${@:1:${#}-1}" "$(<"${@:${#}}")";
		elif [[ -f ${@:${#}} ]] && is_pdff "${@:${#}}"
		then 	set -- "${@:1:${#}-1}" "$(OPTV=4 cmd_runf /pdf "${@:${#}}"; printf '%s\n' "$REPLY")";
		elif [[ -f $1 ]] && is_txtfilef "$1"
		then 	set -- "$(<"$1")" "${@:2}";
		elif [[ -f $1 ]] && is_pdff "$1"
		then 	set -- "$(OPTV=4 cmd_runf /pdf "$1"; printf '%s\n' "$REPLY")" "${@:2}";
		else 	false;
		fi && SKIP_SH_HIST=1;
	fi

	[[ -t 0 ]] || ((OPTZZ+OPTL+OPTFF+OPTHH)) || set -- "$@" "$(<$STDIN)";
fi

#tips and warnings
if ((!(OPTI+OPTL+OPTW+OPTZ+OPTZZ+OPTTIKTOKEN+OPTFF) || (OPTC+OPTCMPL && OPTW+OPTZ) )) && [[ $MOD != *moderation* ]]
then 	if ((!OPTHH))
	then 	__sysmsgf "Max Response / Capacity:" "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
	elif ((OPTHH>1))
	then 	__sysmsgf 'Language Model:' "$MOD"
	fi
fi

(( (OPTI+OPTEMBED) || (OPTW+OPTZ && !MTURN) )) &&
for arg  #!# escape input
do 	((init++)) || set --
	set -- "$@" "$(escapef "$arg")"
done; unset arg init;

if ((OPTW+OPTZ))  #handle options of combined modes in chat + whisper + tts
then 	typeset -a argn
	n=1; for arg
	do 	case "${arg:0:4}" in --) argn=(${argn[@]} $n);; esac; ((++n));
	done; #map double hyphens `--'
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
	elif ((MTURN))
	then 	if ((OPTW))
		then 	WARGS=("$@");
		elif ((OPTZ))
		then 	ZARGS=("$@");
		fi; set -- ;
	fi
	[[ -z ${WARGS[*]} ]] && unset WARGS;
	[[ -z ${ZARGS[*]} ]] && unset ZARGS;
	((${#WARGS[@]})) && ((${#ZARGS[@]})) && ((${#})) && {
	  var=$* p=${var:128} var=${var:0:128}; __cmdmsgf 'Text Prompt' "${var//\\\\[nt]/  }${p:+ [..]}" ;}
	((${#WARGS[@]})) && __cmdmsgf "Whisper Args #${#WARGS[@]}" "${WARGS[*]:-unset}"
	((${#ZARGS[@]})) && __cmdmsgf 'TTS Args' "${ZARGS[*]:-unset}";
	unset n p ii var arg argn;
fi

[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR" ||
{ 	_sysmsgf 'Err:' "Cannot create cache directory -- \`${CACHEDIR/"$HOME"/"~"}'"; exit 1; }
if ! command -v jq >/dev/null 2>&1
then 	function jq { 	false ;}
	function escapef { 	_escapef "$@" ;}
	function unescapef { 	_unescapef "$@" ;}
	Color200=$INV __warmsgf 'Warning:' 'JQ not found. Please, install JQ.'
fi
command -v tac >/dev/null 2>&1 || function tac { 	tail -r "$@" ;}  #bsd
{ curl --help all || curl --help ;} 2>&1 | grep -F -q -e "--fail-with-body" && FAIL="--fail-with-body" || FAIL="--fail";

trap 'cleanupf; exit;' EXIT
trap 'exit' HUP QUIT TERM KILL

if ((OPTZZ))  #last response json
then 	lastjsonf;
elif ((OPTL))  #model list
then 	#(shell completion script)
	((OPTL>2)) && [[ -s $FILEMODEL ]] && cat -- "$FILEMODEL" ||
	list_modelsf "$@";
elif ((OPTFF))
then 	if [[ -s "$CHATGPTRC" ]] && ((OPTFF<2))
	then 	__edf "$CHATGPTRC";
	else 	curl --fail -L "https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/.chatgpt.conf";
		CHATGPTRC="stdout [$CHATGPTRC]";
	fi; _sysmsgf 'Conf File:' "${CHATGPTRC/"$HOME"/"~"}";
elif ((OPTHH && OPTW)) && ((!(OPTC+OPTCMPL+OPTRESUME+MTURN) )) && [[ -f $FILEWHISPERLOG ]]
then  #whisper log
	if ((OPTHH>1))
	then 	while IFS= read -r || [[ -n $REPLY ]]
		do 	[[ $REPLY = ==== ]] && [[ -n $BUFF ]] && break;
			BUFF=${REPLY}$'\n'${BUFF};
		done < <(tac "$FILEWHISPERLOG");
		printf '%s' "$BUFF";
	else 	__edf "$FILEWHISPERLOG"
	fi; _sysmsgf 'Whisper Log:' "$FILEWHISPERLOG";
elif ((OPTHH))  #edit history/pretty print last session
then 	OPTRESUME=1 
	[[ -z $INSTRUCTION && $1 = [.,][!$IFS]* ]] && INSTRUCTION=$1 && shift;
	if [[ $INSTRUCTION = [.,]* ]]
	then 	##[[ $INSTRUCTION = [.,][.,]* ]] && OPTV=4  #when "..[prompt]"
		custom_prf
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
	then 	__edf "$FILECHAT"
	else 	cat -- "$FILECHAT"
	fi
	_sysmsgf "Hist   File:" "${FILECHAT_OLD:-$FILECHAT}"
elif ((OPTTIKTOKEN))
then
	((OPTTIKTOKEN>2)) || __sysmsgf 'Language Model:' "$MOD"
	((${#})) || [[ -t 0 ]] || set -- "-"
	[[ -f $* ]] && [[ -t 0 ]] &&
	if is_pdff "$*"
	then 	exec 0< <(OPTV=4 cmd_runf /pdf "$*"; printf '%s\n' "$REPLY") && set -- "-";
	else 	exec 0<"$*" && set -- "-";  #exec max one file
	fi
	if ((OPTYY))  #option -Y (debug, mostly)
	then 	if [[ ! -t 0 ]]
       		then 	__tiktokenf "$(<$STDIN)";
       		else 	__tiktokenf "$*";
		fi
	else
		tiktokenf "$*" || ! __warmsgf "Err:" "Python / tiktoken"
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
	then 	__sysmsgf 'Image Edits'
	else 	__sysmsgf 'Image Variations' ;fi
	if [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	__sysmsgf 'Image Size / Quality:' "${OPTS:-err} / ${OPTS_HD:-standard}${OPTI_STYLE:+ / $OPTI_STYLE}"
	else 	__sysmsgf 'Image Size:' "${OPTS:-err}"
	fi
	imgvarf "$@"
elif ((OPTI))      #image generations
then 	__sysmsgf 'Image Generations'
	__sysmsgf 'Image Model:' "$MOD_IMAGE"
	if [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	__sysmsgf 'Image Size / Quality:' "${OPTS:-err} / ${OPTS_HD:-standard}${OPTI_STYLE:+ / $OPTI_STYLE}"
	else 	__sysmsgf 'Image Size:' "${OPTS:-err}"
	fi
	imggenf "$@"
elif ((OPTEMBED))  #embeds
then 	[[ $MOD = *embed* ]] || [[ $MOD = *moderation* ]] \
	|| __warmsgf "Warning:" "Not an embedding model -- $MOD"
	unset Q_TYPE A_TYPE OPTC OPTCMPL STREAM
	if ((!${#}))
	then 	__clr_ttystf; echo 'Input:' >&2;
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
	[[ -z $INSTRUCTION && $1 = [.,][!$IFS]* ]] && INSTRUCTION=$1 && shift;
	case "$INSTRUCTION" in
		[/%]*) 	OPTAWE=1 ;((OPTC)) || OPTC=1 OPTCMPL=
			awesomef || case $? in 	210|1) exit 1;; 	*) unset INSTRUCTION;; esac;  #err
			_sysmsgf $'\nHist   File:' "${FILECHAT}"
			if ((OPTRESUME==1))
			then 	unset OPTAWE
			elif ((!${#}))
			then 	unset REPLY
				printf '\nAwesome INSTRUCTION set!\a\nPress <enter> to request or append user prompt: ' >&2
				var=$(__read_charf)
				case "$var" in 	?) SKIP=1 EDIT=1 OPTAWE= REPLY=$var;; 	*) JUMP=1;; esac; unset var;
			fi;;
		[.,]*) custom_prf "$@"
			case $? in
				200) 	set -- ;;  #create, read and clear pos args
				1|201|[1-9]*) 	exit 1; unset INSTRUCTION;;  #err
			esac;;
	esac

	#text/chat completions
	if ((OPTC))
	then 	__sysmsgf 'Chat Completions'
		#chatbot must sound like a human, shouldnt be lobotomised
		#presencePenalty:0.6 temp:0.9 maxTkns:150
		#frequencyPenalty:0.5 temp:0.5 top_p:0.3 maxTkns:60 (Marv)
		OPTT="${OPTT:-0.8}";  #!#
		((ANTHROPICAI)) || OPTA="${OPTA:-0.6}";
		((MISTRALAI)) && unset OPTA;

		((ANTHROPICAI && EPN!=0)) ||  #anthropic skip
		{ ((EPN==6)) && [[ -z ${RESTART:+1}${START:+1} ]] ;} ||  #option -cc conditional skip
		  STOPS+=("${RESTART-$Q_TYPE}" "${START-$A_TYPE}")
	else 	((EPN==6)) || __sysmsgf 'Text Completions'
	fi
	__sysmsgf 'Language Model:' "$MOD$(is_visionf "$MOD" && echo ' / multimodal')"
	
	restart_compf ;start_compf
	function unescape_stopsf
	{   typeset s
	    for s in "${STOPS[@]}"
	    do    set -- "$@" "$(unescapef "$s")"
	    done ;STOPS=("$@")
	} ;((${#STOPS[@]})) && unescape_stopsf

	((OPTCMPL+OPTSUFFIX)) || {
	  ((OPTC && !${#RESTART})) && [[ -n ${RESTART+1} ]] && __warmsgf 'Restart Sequence:' 'Set but null';
	  ((OPTC && !${#START})) && [[ -n ${START+1} ]] && __warmsgf 'Start Sequence:' 'Set but null' ;}

	#model instruction
	INSTRUCTION_OLD="$INSTRUCTION"
	if ((MTURN+OPTRESUME))
	then 	INSTRUCTION=$(trim_leadf "$INSTRUCTION" "$SPC:$SPC")
		shell_histf "$INSTRUCTION"
		((OPTC)) && INSTRUCTION="${INSTRUCTION:-$INSTRUCTION_CHAT}"
		if ((OPTC && OPTRESUME)) || ((OPTCMPL==1 || OPTRESUME==1))
		then 	unset INSTRUCTION;
		else 	break_sessionf;
		fi
		INSTRUCTION_OLD="$INSTRUCTION"
	elif [[ $INSTRUCTION = *([:$IFS]) ]]
	then 	unset INSTRUCTION
	fi
	if [[ $INSTRUCTION != *([:$IFS]) ]]
	then 	_sysmsgf 'INSTRUCTION:' "$INSTRUCTION" 2>&1 | foldf >&2;
		((GOOGLEAI)) && GINSTRUCTION=$INSTRUCTION INSTRUCTION=;
	fi

	if ((MTURN))  #chat mode (multi-turn, interactive)
	then 	[[ -t 1 ]] && __printbf 'history_bash'; var=$SECONDS;  #only visible when large and slow
		history -c; history -r; history -w;  #prune & rewrite history file
		[[ -t 1 ]] && __printbf '            '; ((SECONDS-var>1)) && __warmsgf 'Warning:' "Bash history size -- $(duf "$HISTFILE")";
		if ((OPTRESUME)) && [[ -s $FILECHAT ]]
		then 	REPLY_OLD=$(grep_usr_lastlinef);
		elif [[ -s $HISTFILE ]]
		then 	case "$BASH_VERSION" in  #avoid bash4 hanging
				[0-3]*|4.[01]*|4|'') 	:;;
				*) 	REPLY_OLD=$(trim_leadf "$(fc -ln -1)" "*([$IFS])");;
			esac;
		fi
		shell_histf "$*";
	fi
	
	#session and chat cmds
	[[ $1 = [/!]. ]] && set -- '/fork current' "${@:2}";
	if [[ $1 = /?* ]] && [[ ! -f "$1" && ! -d "$1" ]]
	then 	case "$1" in
			/?| //? | /?(/)@(session|list|ls|fork|sub|grep|copy|cp) )
				session_mainf "$1" "${@:2:1}" && set -- "${@:3}";;
			*) 	session_mainf "$1" && set -- "${@:2}";;
		esac
	elif cmd_runf "$@"
	then 	set -- ;
	else  #print session context?
		if ((OPTRESUME==1)) && ((OPTV<2)) && [[ -s $FILECHAT ]]
		then 	OPTPRINT=1 session_sub_printf "$(tail -- "$FILECHAT" >"$FILEFIFO")$FILEFIFO" >/dev/null;
		fi
	fi
	((ANTHROPICAI)) && ((EPN==6)) && INSTRUCTION=;
	((OPTRESUME)) && fix_breakf "$FILECHAT";

	if ((${#})) && [[ ! -e $1 ]]
	then 	token_prevf "${INSTRUCTION}${INSTRUCTION:+ }${*}"
		__sysmsgf "Inst+Prompt:" "~$TKN_PREV tokens"
	fi

	#warnings and tips
	((OPTCTRD)) && __warmsgf '*' '<Ctrl-V Ctrl-J> for newline * '
	((OPTCTRD+CATPR)) && __warmsgf '*' '<Ctrl-D> to flush input * '
	echo >&2  #!#
	
	#option -e, edit first user input
	((OPTE && OPTX)) && unset OPTE;  #option -x always edits, anyways
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
		fi
		((OPTAWE)) || {  #awesome 1st pass skip

		#prompter pass-through
		if ((PSKIP))
		then 	[[ -z $* ]] && [[ -n ${REPLY:-$REPLY_OLD} ]] && set -- "${REPLY:-$REPLY_OLD}";
		elif ((OPTX))
		#text editor prompter
		then 	edf "${@:-$REPLY}"
			case $? in
				179|180) :;;        #jumps
				200) 	set --; unset REPLY; continue;;  #redo
				201) 	set --; unset OPTX; false;;   #abort
				*) 	while [[ -f $FILETXT ]] && REPLY=$(<"$FILETXT"); echo >&2;
						(($(wc -l <<<"$REPLY") < LINES-1)) || echo '[..]' >&2;
						printf "${BRED}${REPLY:+${NC}${BCYAN}}%s${NC}\\n" "${REPLY:-(EMPTY)}" | tail -n $((LINES-2))
					do 	((OPTV)) || new_prompt_confirmf
						case $? in
							201) 	set --; unset OPTX; break 1;;  #abort
							200) 	set --; unset REPLY; continue 2;;  #redo
							19[6789]) 	edf "${REPLY:-$*}" || break 1;;  #edit
							195) 	WSKIP=1 WAPPEND=1 REPLY_OLD=$REPLY; ((OPTW)) || cmd_runf -ww;
								set --; break;;  #whisper append (hidden option)
							0) 	set -- "$REPLY" ; break;;  #yes
							*) 	set -- ; break;;  #no
						esac
					done;
					((OPTX>1)) && unset OPTX;
			esac
			((EDIT==2)) && REPLY_CMD_DUMP=$REPLY;
			case "${REPLY: ${#REPLY}-1}" in /) 	__warmsgf 'Warning:' "text editor mode doesn't support previewing!";; esac;
		fi

		((JUMP)) ||
		#defaults prompter
		if [[ "$* " = @("${Q_TYPE##$SPC1}"|"${RESTART##$SPC1}")$SPC ]] || [[ -z "$*" ]]
		then 	((OPTC)) && Q="${RESTART:-${Q_TYPE:->}}" || Q="${RESTART:->}"
			B=$(_unescapef "${Q:0:320}") B=${B##*$'\n'} B=${B//?/\\b}  #backspaces

			while ((SKIP)) ||
				printf "${CYAN}${Q}${B}${NC}${OPTW:+${PURPLE}VOICE: }${NC}" >&2
				printf "${BCYAN}${OPTW:+${NC}${BPURPLE}}" >&2
			do
				((SKIP+OPTW+${#RESTART})) && echo >&2
				if ((OPTW && !EDIT)) || ((RESUBW))
				then 	#auto sleep 3-6 words/sec
					if ((OPTV)) && ((!WSKIP))
					then
						var=$((SLEEP_WORDS/3)) SLEEP_WORDS=0;
						for ((n=var;n>0;n--))
						do 	printf "%0*d${var//?/\\b}" "${#var}" "$n" >&2;
							__read_charf -t 1 >/dev/null 2>&1 && { __clr_lineupf && break ;}
						done;
						__printbf "${var//?/ }";
					fi
					
					((RESUBW)) || record_confirmf
					case $? in
						0) 	if ((RESUBW)) || recordf "$FILEINW"
							then 	REPLY=$(
								((GROQAI))&& MOD_AUDIO=$MOD_AUDIO_GROQ;
								set --; MOD=$MOD_AUDIO OPTT=${OPTTW:-0} JQCOL= JQCOL2= ;
								[[ -z ${WARGS[*]} ]] || set -- "${WARGS[@]}" "$@";
								whisperf "$FILEINW" "$@";
							)
								((WAPPEND)) && REPLY=$REPLY_OLD${REPLY_OLD:+${REPLY:+ }}$REPLY WAPPEND= ;
							else 	case $? in
									196) 	unset WSKIP OPTW REPLY; continue 1;;
									199) 	EDIT=1; continue 1;;
								esac;
								echo record abort >&2;
							fi; ((OPTW>1)) && unset OPTW;;
						196|201) 	unset WSKIP OPTW REPLY; continue 1;;  #whisper off
						199) 	EDIT=1; continue 1;;  #text edit
						*) 	unset REPLY; continue 1;;
					esac; unset RESUBW;
					printf "\\n${NC}${BPURPLE}%s${NC}\\n" "${REPLY:-"(EMPTY)"}" | foldf >&2;
				else
					__clr_ttystf;
					((EDIT)) || unset REPLY  #!#
					if ((CATPR)) && ((!EDIT))
					then 	REPLY=$(cat);
					else 	read_mainf ${REPLY:+-i "$REPLY"} REPLY;
					fi </dev/tty

					((CATPR)) && echo >&2;
					((OPTCTRD+CATPR)) && REPLY=$(trim_trailf "$REPLY" $'*([\r])')
					((EDIT==2)) && REPLY_CMD_DUMP=$REPLY;
				fi; printf "${NC}" >&2;
				
				if [[ ${REPLY:0:8} = /cat*([$IFS]) ]]
				then 	((CATPR)) || CATPR=2 ;REPLY= SKIP=1
					((CATPR==2)) && __cmdmsgf 'Cat Prompter' "one-shot"
					set -- ;continue  #A#
				elif cmd_runf "$REPLY"
				then 	((SKIP_SH_HIST)) || shell_histf "$REPLY"; SKIP_SH_HIST=1;
					if ((REGEN>0))
					then 	((MAIN_LOOP)) || [[ ! -s $FILECHAT ]] || REPLY_OLD=$(grep_usr_lastlinef);
						REPLY="${REPLY_OLD:-$REPLY}"
					else 	((SKIP)) || REPLY=
					fi; set --; continue 2
				elif ((${#REPLY}>320)) && ind=$((${#REPLY}-320)) || ind=0  #!#
					[[ ${REPLY: ind} = */ ]]  #preview (mind no trailing spaces)
				then
					((PREVIEW)) && [[ ${REPLY_CMD:-$REPLY_OLD} != "$REPLY" ]] &&
					  prev_tohistf "$(escapef "${REPLY_CMD:-$REPLY_OLD}")";
					
					#check whether last arg is url or directory
					var=$(trim_leadf "$(trim_trailf "${REPLY: ind}" "$SPC")" $'*[ \t\n]')  #C#
					case "$var" in \~\/*) 	var="$HOME/${var:2}";; esac;
					if { _is_linkf "$var" && ! _is_imagef "$var" && ! _is_videof "$var" && [[ $var != *\/\/ ]] ;} ||
						{ [[ -d $var ]] && [[ $var != \/ ]] ;}
					then 	((PREVIEW)) && PREVIEW=2 BCYAN="${Color9}";
					else 	test_cmplsf || printf '\n%s\n' '--- preview ---' >&2;
						PREVIEW=1;
					fi
					
					#del trailing slashes, and set preview colour
					((PREVIEW==1)) && REPLY=$(INDEX=160 trim_trailf "$REPLY" $'*([ \t\n])/*([ \t\n/])') REPLY_OLD=$REPLY BCYAN=${Color8};
				elif case "${REPLY: ind}" in  #cmd: //shell, //sh
					*?[/!][/!]shell|*?[/!][/!]sh) var=/shell;;
					*?[/!]shell|*?[/!]sh) var=shell;;
					*) 	false;; esac;
				then
					set -- "$(trim_trailf "$REPLY" "${SPC}[/!]@(/shell|shell|/sh|sh)")";
					REPLY_CMD_DUMP=$(
						unset REPLY
						cmd_runf /${var:-shell};
						trim_trailf "$REPLY" "[/!]@(/shell|shell|/sh|sh)"
					)
					if ((${#REPLY_CMD_DUMP}))
					then 	REPLY="${*} ${REPLY_CMD_DUMP}";
						((SKIP_SH_HIST)) || shell_histf "$REPLY";
					fi
			    		SKIP=1 EDIT=1 REPLY_CMD=;
					set -- ; continue 2;
				elif case "${REPLY: ind}" in  #cmd: /photo, /pick, /save
					*?[/!]photo|*?[/!]photo[0-9]) var=photo;;
					*?[/!]pick|*?[/!]p) var=pick;;
					*?[/!]save|*?[/!]\#) var=save;;
					*) 	false;; esac;
				then
					set -- "$(trim_trailf "$REPLY" "${SPC}[/!]@(photo|pick|p|save|\#)")";
					cmd_runf /${var:-pick} "$*";
					((SKIP_SH_HIST)) || shell_histf "$REPLY";
					set --; continue 2;
				elif ((${#REPLY}))
				then
					((PREVIEW+OPTV && EDIT!=2)) || [[ $REPLY = :* ]] \
					|| is_txturl "${REPLY: ind}" >/dev/null \
					|| new_prompt_confirmf ed whisper
					case $? in
						201) 	break 2;;  #abort
						200) 	WSKIP=1 REPLY= REPLY_CMD_DUMP=; set --; ((EDIT==2)) && REPLY=$REPLY_CMD;
							printf '\n%s\n' '--- redo ---' >&2; continue;;  #redo
						199) 	WSKIP=1 EDIT=1;
							printf '\n%s\n' '--- edit ---' >&2; continue;;  #edit
						198) 	((OPTX)) || OPTX=2
							((OPTX==2)) &&
							printf '\n%s\n' '--- text editor one-shot ---' >&2
							set -- ;continue 2;;
						197) 	EDIT=1 SKIP=1; ((OPTCTRD))||OPTCTRD=2
							((OPTCTRD==2)) && printf '\n%s\n' '--- prompter <ctr-d> one-shot ---' >&2
							REPLY="$REPLY"$'\n'; set -- ;continue;;  #multiline one-shot  #A#
						196) 	WSKIP=1 EDIT=1 OPTW= ; continue 2;;  #whisper off
						195) 	WSKIP=1 WAPPEND=1 REPLY_OLD=$REPLY; ((OPTW)) || cmd_runf -ww;
							printf '\n%s\n' '--- whisper append ---' >&2; continue;;  #whisper append
						194) 	cmd_runf /resubmit; set --; continue 2;;  #whisper retry request
						0) 	:;;  #yes
						*) 	unset REPLY; set -- ;break;;  #no
					esac

					if ((PREVIEW))
					then 	case "$REPLY" in "$REPLY_OLD"|"$REPLY_CMD")
						 	PREVIEW=2 BCYAN="${Color9}";;
						*) 	#record prev resp
							prev_tohistf "$(escapef "${REPLY_CMD:-$REPLY_OLD}")";
							((EDIT==2)) || REPLY_CMD_DUMP= ;;
						esac; REPLY_OLD="$REPLY";
					fi
				else
					set --
				fi ;set -- "$REPLY"
				((OPTCTRD==1)) || unset OPTCTRD
				((CATPR==1)) || unset CATPR
				unset WSKIP SKIP EDIT B Q ind var
				break
			done
		fi

		if ! ((OPTCMPL+JUMP+${#1}))
		then 	__warmsgf "(empty)"
			set -- ; continue
		fi
		if ((!OPTCMPL)) && ((OPTC)) && [[ "${*}" != *([$IFS]) ]]
		then 	set -- "$(trimf "$*" "$SPC1")"  #!#
			REPLY="$*"
		fi
		((${#REPLY_OLD})) || REPLY_OLD="${REPLY:-$*}";
		
		}  #awesome 1st pass skip end

		if ((MTURN+OPTRESUME)) && [[ -n "${*}" ]]
		then
			[[ -n $REPLY ]] || REPLY="${*}" #set buffer for EDIT

			if ((PREVIEW!=1))
			then 	((SKIP_SH_HIST)) || shell_histf "${REPLY_CMD:-$*}"; unset SKIP_SH_HIST;
				history -a
			fi

			#system/instruction?
			if [[ ${*} = :* ]]
			then
				var=$(escapef "$( trim_leadf "$*" "$SPC:" )")

				   [[ ${*} = :::* ]] && var=${var:1}  #[DEPRECATED] 
				if [[ ${*} = ::* ]]
				then
					((${#INSTRUCTION}+${#GINSTRUCTION})) && v=added || v=set;
					_sysmsgf "System prompt $v";
					if ((GOOGLEAI))
					then 	RINSERT=${RINSERT}${var:1}${NL}${NL};
					else 	INSTRUCTION_OLD=${INSTRUCTION:-$INSTRUCTION_OLD}
						INSTRUCTION=${INSTRUCTION}${INSTRUCTION:+${NL}${NL}}${var:1}
					fi
				else
					RINSERT=${RINSERT}${var}${NL};
					_sysmsgf 'User prompt added'
				fi
				unset EDIT SKIP REPLY REPLY_OLD var v;
				set --; continue;
			fi
			((${#RINSERT})) && { 	set -- "${RINSERT}${*}"; REPLY=${RINSERT}${REPLY}; unset RINSERT ;}
			REC_OUT="${Q_TYPE##$SPC1}${*}"
		fi

		#insert mode
		if ((OPTSUFFIX)) && [[ "$*" = *${I_TYPE}* ]]
		then 	if ((EPN!=6))
			then 	SUFFIX="${*##*${I_TYPE}}";  #slow in bash + big strings
				PREFIX="${*%%${I_TYPE}*}"; set -- "${PREFIX}";
			else 	__warmsgf "Err: Insert mode:" "wrong endpoint (chat cmpls)"
			fi;
			REC_OUT="${REC_OUT:0:${#REC_OUT}-${#SUFFIX}-${#I_TYPE_STR}}"
		#basic text and pdf file, and text url dumps
		elif var=$(is_txturl "$1")
		then
			if ((${#REPLY_CMD_DUMP}))
			then 	var=$REPLY_CMD_DUMP;
			else 	trap 'trap "-" INT' INT;
				var=$(cmd_runf /cat"$var"; printf '%s\n' "$REPLY"; exit $RET);
				ret=${?}; trap "exit" INT;
			fi
			if ((${#var})) && ((ret!=1))
			then
			  REPLY_CMD="${REPLY:-$REPLY_CMD}" REPLY_CMD_DUMP="$var";
			  REPLY="${REPLY}${NL}${NL}${var}";
			  ((PREVIEW)) && REPLY_OLD="$REPLY";
			  case "$ret" in
			    201|200) SKIP=1 EDIT=1 REPLY=$REPLY_CMD REPLY_CMD_DUMP= REPLY_CMD=;
			         set --; continue 1;;  #redo / abort
			    199) SKIP=1 EDIT=2; set --; continue 1;;  #edit in bash readline
			    198) ((OPTX)) || OPTX=2; SKIP=1 EDIT=2; set --; continue 1;;  #edit in text editor
			  esac
			  set -- "${*}${NL}${NL}${var}";
			  REC_OUT="${Q_TYPE##$SPC1}${*}";
			else
			  SKIP=1 EDIT=1 REPLY_CMD_DUMP= REPLY_CMD=;
			  set --; continue 1;  #edit orig input
			fi;
		#vision
		elif is_visionf "$MOD"
		then
			_mediachatf "$1";
			#((TRUNC_IND)) && REPLY_OLD=$* && set -- "${1:0:${#1}-TRUNC_IND}";
			((MTURN)) &&
			for var in "${MEDIA_CMD[@]}"
			do 	REC_OUT="$REC_OUT| $var" REPLY="$REPLY| $var";
				set -- "$*| $var";
			done; unset var;
		else 	unset SUFFIX PREFIX
		fi

		if ((PREVIEW<2))
		then 	((MTURN+OPTRESUME)) &&
			if ((EPN==6));
			then 	set_histf "${INSTRUCTION:-$GINSTRUCTION}${*}";
			else 	set_histf "${INSTRUCTION:-$GINSTRUCTION}${Q_TYPE}${*}"; fi
			((MAIN_LOOP||TOTAL_OLD)) || TOTAL_OLD=$(__tiktokenf "${INSTRUCTION:-${GINSTRUCTION:-${ANTHROPICAI:+$INSTRUCTION_OLD}}}")
			if ((OPTC)) || [[ -n "${RESTART}" ]]
			then 	rest="${RESTART-$Q_TYPE}"
				((OPTC && EPN==0)) && [[ ${HIST:+x}$rest = \\n* ]] && rest=${rest:2}  #!#del \n at start of string
			fi
			((JUMP)) && set -- && unset rest
			var="$(escapef "${INSTRUCTION:-$GINSTRUCTION}")${INSTRUCTION:+\\n\\n}${GINSTRUCTION:+\\n\\n}";
			ESC="${HIST}${HIST:+${var:+\\n\\n}}${var}${rest}$(escapef "${*}")";
			ESC=$(INDEX=32 trim_leadf "$ESC" "\\n");
			
			if ((EPN==6))
			then 	#chat cmpls
				[[ ${*} = *([$IFS]):* ]] && role=system || role=user
				((GOOGLEAI)) &&  [[ $MOD = *gemini*-pro-vision* && $MOD != *gemini*-1.5-* ]] &&  #gemini-1.0-pro-vision cannot take it multiturn
				if { (( (REGEN<0 || PREVIEW) && MAIN_LOOP<1)) && ((${#INSTRUCTION_OLD})) ;} || is_visionf "$MOD"
				then 	HIST_G=${HIST}${HIST:+\\n\\n} HIST_C= ;
					((${#MEDIA[@]}+${#MEDIA_CMD[@]})) ||
					MEDIA=("${MEDIA_IND[@]}") MEDIA_CMD=("${MEDIA_CMD_IND[@]}");
				fi
				var="$(unset MEDIA MEDIA_CMD; fmt_ccf "$(escapef "$INSTRUCTION")" system;)${INSTRUCTION:+,${NL}}"
				set -- "${HIST_C}${HIST_C:+,${NL}}${var}$(
					fmt_ccf "${HIST_G}$(escapef "${GINSTRUCTION}${GINSTRUCTION:+$NL$NL}${*}")" "$role")";
			else 	#text cmpls
				if { 	((OPTC)) || [[ -n "${START}" ]] ;} && ((JUMP<2))
				then 	set -- "${ESC}${START-$A_TYPE}"
				else 	set -- "${ESC}"
				fi
			fi; unset rest role;
			
			for media in "${MEDIA_IND[@]}" "${MEDIA_CMD_IND[@]}"
			do 	((media_i++));
				[[ -f $media ]] && media=$(duf "$media");
				_sysmsgf "img #${media_i}" "${media:0: COLUMNS-6-${#media_i}}$([[ -n ${media: COLUMNS-6-${#media_i}} ]] && printf '\b\b\b%s' ...)";
			done; unset media media_i;
		fi
		
		set_optsf

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
$( ((ANTHROPICAI)) && ((EPN!=6)) && max="max_tokens_to_sample" || max="max_tokens"
((OPTMAX_NILL && EPN==6)) || echo "\"${max:-max_tokens}\": $OPTMAX," )
$STREAM_OPT $OPTA_OPT $OPTAA_OPT $OPTP_OPT $OPTKK_OPT
$OPTB_OPT $OPTBB_OPT $OPTSTOP $OPTSEED_OPT
$( ((MISTRALAI+GROQAI+ANTHROPICAI)) || echo "\"n\": $OPTN," ) \
$( ((MISTRALAI+LOCALAI+ANTHROPICAI)) || ((!STREAM)) || echo "\"stream_options\": {\"include_usage\": true}," )
\"model\": \"$MOD\", \"temperature\": $OPTT${BLOCK_USR:+,$NL}$BLOCK_USR
}"
		fi

		#response colours for jq
		if ((PREVIEW==1))
		then 	((OPTK)) || JQCOL2='def byellow: yellow;'
		else 	unset JQCOL2
		fi; ((OPTC)) && echo >&2

		#request and response prompts
		SECONDS_REQ=${EPOCHREALTIME:-$SECONDS};
		((${#START})) && printf "${YELLOW}%b\\n" "$START" >&2;
		((OLLAMA)) && api_host=$API_HOST API_HOST=$OLLAMA_API_HOST;

		#move cursor to the end of user input in previous line
		if test_cmplsf && ((!JUMP))
		then 	if ((OPTSUFFIX && ${#SUFFIX}))
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

		if ((${#BLOCK}>96000))  #96KB #https://stackoverflow.com/questions/19354870/bash-command-line-and-input-limit
		then 	buff="${FILE%.*}.block.json"
			printf '%s\n' "$BLOCK" >"$buff"
			BLOCK="@${buff}" OPTFOLD=$var promptf
		else 	OPTFOLD=$var promptf
		fi; RET_PRF=$?;

		((OPTEXIT>1)) && exit $RET_PRF;
		((OLLAMA)) && API_HOST=$api_host;
		unset buff api_host;
		((STREAM)) && ((MTURN || EPN==6)) && echo >&2;
		if (( (RET_PRF>120 && !STREAM) || (!RET_PRF && PREVIEW==1) ))
		then 	((${#REPLY_CMD})) && REPLY=$REPLY_CMD;
			SKIP=1 EDIT=1; set --; continue;  #B#
		fi
		((RET_PRF>120)) && INT_RES='#'; ((RET_PRF)) || REPLY_OLD="${REPLY:-${REPLY_OLD:-$*}}";

		#record to hist file
		if 	if ((STREAM))
			then 	ans=$(prompt_pf -r -j "$FILE"; echo x) ans=${ans:0:${#ans}-1}
				ans=$(escapef "$ans")
				((OLLAMA+LOCALAI)) ||  #OpenAI, MistralAI, and Groq
				tkn=( $(
					ind="-1" var="";
					((GOOGLEAI)) && FILE="$FILE_PRE";
					((GROQAI)) && var="x_groq";
					((ANTHROPICAI)) && ind="";
					jq -rs ".[${ind}] | .${var}" "$FILE" | response_tknf;
					((GROQAI)) && datef && jq -rs '.[-1].x_groq.usage | (.completion_time,.completion_tokens/.completion_time)' "$FILE";  #tkn rate
					) )
				((tkn[0]&&tkn[1])) 2>/dev/null || ((OLLAMA)) || {
				  tkn_ans=$( ((EPN==6)) && unset A_TYPE; __tiktokenf "${A_TYPE}${ans}");
				  ((tkn_ans+=TKN_ADJ)); ((MAX_PREV+=tkn_ans)); unset TOTAL_OLD tkn;
				};
			else
				{ ((ANTHROPICAI && EPN==0)) && tkn=(0 0) ;} ||
				((OLLAMA)) || tkn=( $(
					jq "." "$FILE" | response_tknf;
					((GROQAI)) && jq -r '.usage | (.completion_time, .completion_tokens/.completion_time)' "$FILE";  #tkn rate
					) )
				unset ans buff n
				for ((n=0;n<OPTN;n++))  #multiple responses
				do 	buff=$(INDEX=$n prompt_pf "$FILE")
					((${#buff}>1)) && buff=${buff:1:${#buff}-2}  #del lead and trail ""
					ans="${ans}"${ans:+${buff:+\\n---\\n}}"${buff}"
				done
			fi
			if ((OLLAMA))
			then 	tkn=($(jq -r -s '.[-1]|.prompt_eval_count//"0", .eval_count//"0", .created_at//"0", (.eval_duration/1000000000)?, (.eval_count/(.eval_duration/1000000000)?)?' "$FILE") )
				((STREAM)) && ((MAX_PREV+=tkn[1]));
			fi

			#print error msg and check for OpenAI response length-type error
			if ((!${#ans})) && ((RET_PRF<120))
			then
				var=$FILE; ((GOOGLEAI)) && ((STREAM)) && var=$FILE_PRE;
				jq -e '(.error?)//(.[]?|.error?)//(..|.error?)//empty' "$var" >&2 || ((OPTCMPL)) || ! __warmsgf 'Err';
				__warmsgf "(response empty)";
				((!(LOCALAI+OLLAMA+GOOGLEAI+MISTRALAI+GROQAI+ANTHROPICAI) )) &&
				if ((!OPTTIK)) && ((MTURN+OPTRESUME)) && ((HERR<=${HERR_DEF:=1}*5)) \
					&& var=$(jq -e '(.error.message?)//(.[]?|.error?)//empty' "$FILE" 2>/dev/null) \
					&& [[ $var = *[Cc]ontext\ length*[Rr]educe* ]] \
					&& [[ $ESC != "$ESC_OLD" ]]
				then 	#[0]modmax [1]resquested [2]prompt [3]cmpl
					var=(${var//[!0-9$IFS]})
					if ((${#var[@]}<2 || var[1]<=(var[0]*3)/2))
					then    ESC_OLD=$ESC
					  ((HERR+=HERR_DEF*2)) ;BAD_RES=1 PSKIP=1; set --
					  __warmsgf "Adjusting context:" -$((HERR_DEF+HERR))%
					  ((HERR<HERR_DEF*4)) && _sysmsgf '' "* Set \`option -y' to use Tiktoken! * "
					  sleep $(( (HERR/HERR_DEF)+1)) ;continue
					fi
				fi  #adjust context err (OpenAI only)
			fi;

			unset BAD_RES PSKIP ESC_OLD;
			((${#tkn[@]}>1 || STREAM)) && ((${#ans})) && ((MTURN+OPTRESUME))
		then
			if CKSUM=$(cksumf "$FILECHAT") ;[[ $CKSUM != "${CKSUM_OLD:-$CKSUM}" ]]
			then 	Color200=${NC} __warmsgf \
				'Err: History file modified'$'\n' 'Fork session? [Y]es/[n]o/[i]gnore all ' ''
				case "$(__read_charf)" in
					[IiGg]) 	unset CKSUM CKSUM_OLD ;function cksumf { 	: ;};;
					[AaNnOoQq]|$'\e') :;;
					*) 		session_mainf /copy "$FILECHAT" || break;;
				esac
			fi
			if ((OPTB>1))  #best_of disables streaming response
			then 	start_tiktokenf
				tkn[1]=$(
					((EPN==6)) && unset A_TYPE;
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
			push_tohistf "$(escapef "$REC_OUT")" "$(( (tkn[0]-TOTAL_OLD)>0 ? (tkn[0]-TOTAL_OLD) : 0 ))" "${tkn[2]}"
			push_tohistf "$ans" "${tkn[1]:-$tkn_ans}" "${tkn[2]}" || unset OPTC OPTRESUME OPTCMPL MTURN
			
			((TOTAL_OLD=tkn[0]+tkn[1])) && MAX_PREV=$TOTAL_OLD
			unset HIST_TIME BREAK_SET
		elif ((MTURN))
		then
			((PREVIEW)) && BCYAN="${Color9}";
			((${#REPLY_CMD})) && REPLY=$REPLY_CMD;
			BAD_RES=1 SKIP=1 EDIT=1;
			unset CKSUM_OLD PSKIP JUMP REGEN PREVIEW REPLY_CMD REPLY_CMD_DUMP RET INT_RES MEDIA  MEDIA_IND  MEDIA_CMD_IND SUFFIX;
			((OPTX)) && __read_charf >/dev/null
			set -- ;continue
		fi;
		((MEDIA_IND_LAST = ${#MEDIA_IND[@]} + ${#MEDIA_CMD_IND[@]}));
		unset MEDIA  MEDIA_CMD  MEDIA_IND  MEDIA_CMD_IND INT_RES GINSTRUCTION HIST_G REGEN SKIP_SH_HIST;

		((OPTLOG)) && (usr_logf "$(unescapef "${ESC}\\n${ans}")" > "$USRLOG" &)
		((RET_PRF>120)) && { 	SKIP=1 EDIT=1; set --; continue ;}  #B# record whatever has been received by streaming

		#auto detect markdown in response
		if ((!NO_OPTMD_AUTO)) && ((!OPTMD)) && ((!OPTEXIT)) &&
			((OPTC)) && ((MTURN)) && is_mdf "${ans}"
		then
			echo >&2;
			_cmdmsgf 'Markdown' "AUTO";
			cmd_runf /markdown;
		fi
		
		if ((OLLAMA+GROQAI)) && ((${#tkn[@]}==5))  #token generation rate  #0 tokens, #1 secs, #2 rate
		then
			TKN_RATE=( "${tkn[1]}" "$(printf '%.2f' "${tkn[3]}")" "$(printf '%.2f' "${tkn[4]}")" )
		elif 	[[ ${tkn[1]:-$tkn_ans} = *[1-9]* ]]
		then
			TKN_RATE=( "${tkn[1]:-$tkn_ans}" "$(bc <<<"scale=8; ${EPOCHREALTIME:-$SECONDS} - $SECONDS_REQ")"
			"$(bc <<<"scale=2; ${tkn[1]:-${tkn_ans:-0}} / (${EPOCHREALTIME:-$SECONDS}-$SECONDS_REQ)")" )
		fi
		SESSION_COST=$(
			cost=$(_model_costf "$MOD") || exit; set -- $cost;
			bc <<<"scale=8; ${SESSION_COST:-0} + $(costf "$( ((tkn[0])) && echo ${tkn[0]} || __tiktokenf "$REPLY" )" "$( ((tkn[1])) && echo ${tkn[1]} || __tiktokenf "$(unescapef "$ans")" )" $@)"
			)

		if ((OPTW)) && ((!OPTZ))
		then
			SLEEP_WORDS=$(wc -w <<<"${ans}");
			((STREAM)) && ((SLEEP_WORDS=(SLEEP_WORDS*2)/3));
			((++SLEEP_WORDS));
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
			WCHAT_C="${WCHAT_C:-$(escapef "${INSTRUCTION:-${GINSTRUCTION:-$INSTRUCTION_OLD}}")}\\n\\n${REPLY:-$*}";
			if ((${#WCHAT_C}>224*4))
			then 	((n = ${#WCHAT_C} - (220*4) ));
				WCHAT_C=$(trim_leadf "${WCHAT_C: n}" "$SPC1");
			fi  #max 224 tkns, GPT-2 encoding
			#https://platform.openai.com/docs/guides/speech-to-text/improving-reliability
		fi

		((++MAIN_LOOP)) ;set --
		unset INSTRUCTION GINSTRUCTION HIST_G REGEN OPTRESUME TKN_PREV REC_OUT HIST HIST_C SKIP PSKIP WSKIP JUMP EDIT REPLY REPLY_CMD REPLY_CMD_DUMP RET STREAM_OPT OPTA_OPT OPTAA_OPT OPTP_OPT OPTB_OPT OPTBB_OPT OPTSUFFIX_OPT SUFFIX PREFIX OPTAWE PREVIEW BAD_RES INT_RES ESC RET_PRF Q
		unset role rest tkn tkn_ans ans_tts ans buff glob out var pid s n
		((MTURN && !OPTEXIT)) || break
	done
fi


#   &=== &   & &==== ===== &==== &==== =====    &==== &   & 
#   %  % %   % %   %   %   %   % %   %   %      %   " %   % 
#   %=   %===% %===%   %=  %=    %===%   %=     %==== %===%     ^    ^ . 
#   %%   %%  % %%  %   %%  %% "% %%      %%        %% %%  %    /a\  /i\  
#   %%=% %%  % %%  %   %%  %%==% %%      %%  %% %==%% %%  %  ,<___><___>.

## set -x; shopt -s extdebug; PS4='$EPOCHREALTIME:$LINENO: ';  # Debug performance by line
## shellcheck -S warning -e SC2034,SC1007,SC2207,SC2199,SC2145,SC2027,SC1007,SC2254,SC2046,SC2124,SC2209,SC1090,SC2164,SC2053,SC1075,SC2068,SC2206,SC1078  ~/bin/chatgpt.sh

# vim=syntax sync minlines=600
