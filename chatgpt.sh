#!/usr/bin/env bash
# chatgpt.sh -- Shell Wrapper for ChatGPT/DALL-E/Whisper/TTS
# v0.57  may/2024  by mountaineerbr  GPL+3
set -o pipefail; shopt -s extglob checkwinsize cmdhist lithist histappend;
export COLUMNS LINES; ((COLUMNS>2)) || COLUMNS=80; ((LINES>2)) || LINES=24;

# API keys
#OPENAI_API_KEY=
#GOOGLE_API_KEY=
#MISTRAL_API_KEY=

# DEFAULTS
# Text cmpls model
MOD="gpt-3.5-turbo-instruct"
# Chat cmpls model
MOD_CHAT="${MOD_CHAT:-gpt-4-turbo}"  #"gpt-4-turbo-2024-04-09"
# Image model (generations)
MOD_IMAGE="${MOD_IMAGE:-dall-e-3}"
# Whisper model (STT)
MOD_AUDIO="${MOD_AUDIO:-whisper-1}"
# Speech model (TTS)
MOD_SPEECH="${MOD_SPEECH:-tts-1}"   #"tts-1-hd"
# LocalAI model
MOD_LOCALAI="${MOD_LOCALAI:-phi-2}"
# Ollama model
MOD_OLLAMA="${MOD_OLLAMA:-llama2}"  #"llama2-uncensored:latest"
# Google AI model
MOD_GOOGLE="${MOD_GOOGLE:-gemini-1.0-pro-latest}"
# Mistral AI model
MOD_MISTRAL="${MOD_MISTRAL:-mistral-large-latest}"
# Bash readline mode
READLINEOPT="emacs"  #"vi"
# Stream response
STREAM=1
# Prompter flush with <CTRL-D>
#OPTCTRD=
# Temperature
#OPTT=
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
# Set python tiktoken
#OPTTIK=
# Image size
#OPTS=1024x1024
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
# Inject restart text
#RESTART=""
# Inject   start text
#START=""
# Chat mode of text cmpls sets "\nQ: " and "\nA:"
# Restart/Start seqs have priority

# INSTRUCTION
# Chat completions, chat mode only
# INSTRUCTION=""
INSTRUCTION_CHAT="${INSTRUCTION_CHAT-The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.}"

# Awesome-chatgpt-prompts URL
AWEURL="https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv"
AWEURLZH="https://raw.githubusercontent.com/PlexPt/awesome-chatgpt-prompts-zh/main/prompts-zh.json"  #prompts-zh-TW.json

# CACHE AND OUTPUT DIRECTORIES
CACHEDIR="${CACHEDIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/chatgptsh"
OUTDIR="${OUTDIR:-${XDG_DOWNLOAD_DIR:-$HOME/Downloads}}"

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

# Load user defaults
CONFFILE="${CHATGPTRC:-$HOME/.chatgpt.conf}"
[[ -f "${OPTF}${CONFFILE}" ]] && . "$CONFFILE"; OPTMM=  #!#fix <=248c483-github

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
USRLOG="${OUTDIR%/}/${FILETXT##*/}"
HISTFILE="${CACHEDIR%/}/history_bash"
HISTCONTROL=erasedups:ignoredups
HISTSIZE=512 SAVEHIST=512 HISTTIMEFORMAT='%F %T '

# API URL / endpoint
API_HOST="https://api.openai.com";

# Def hist, txt chat types
Q_TYPE="\\nQ: "
A_TYPE="\\nA:"
S_TYPE="\\n\\nSYSTEM: "
I_TYPE="[insert]"

# Globs
SPC="*([$IFS])"
SPC1="*(\\\\[ntrvf]|[$IFS])"
NL=$'\n' BS=$'\b'

UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'  #chrome on win10
PLACEHOLDER='sk-CbCCb0CC0bbbCbb0CCCbC0CbbbCC00bC00bbCbbCbbbCbb0C'

HELP="Name
	${0##*/} -- Wrapper for ChatGPT / DALL-E / Whisper / TTS


Synopsis
	${0##*/} [-cc|-d|-qq] [opt..] [PROMPT|TEXT_FILE]
	${0##*/} -i [opt..] [X|L|P][hd] [PROMPT]  #dall-e-3
	${0##*/} -i [opt..] [S|M|L] [PROMPT]
	${0##*/} -i [opt..] [S|M|L] [PNG_FILE]
	${0##*/} -i [opt..] [S|M|L] [PNG_FILE] [MASK_FILE] [PROMPT]
	${0##*/} -w [opt..] [AUDIO_FILE|.] [LANG] [PROMPT]
	${0##*/} -W [opt..] [AUDIO_FILE|.] [PROMPT-EN]
	${0##*/} -z [OUTFILE|FORMAT|-] [VOICE] [SPEED] [PROMPT]
	${0##*/} -ccWwz [opt..] -- [whisper_arg..] -- [tts_arg..]
	${0##*/} -l [MODEL]
	${0##*/} -TTT [-v] [-m[MODEL|ENCODING]] [INPUT|TEXT_FILE]
	${0##*/} -HHH [/HIST_FILE|.]
	${0##*/} -HHw


Description
	With no options set, complete INPUT in single-turn mode of
	plain text completions.

	Option -d starts a multi-turn session in plain text completions,
	and does not set further options automatically.

	Set option -c to start multi-turn chat mode via text completions
	(davinci and lesser models) or -cc for native chat completions
	(gpt-3.5+ models). In chat mode, some options are automatically
	set to un-lobotomise the bot. Set -E to exit on response.

	Option -C resumes (continues from) last history session.
	
	Positional arguments are read as a single PROMPT. Optionally set
	INTRUCTION with option -S.

	In multi-turn interactions, prompts starting with a colon \`:' are
	appended as user messages to the request block, while double colons
	\`::' append the prompt as instruction / system without initiating
	a new API request.

	With vision models, insert an image to the prompt with chat command
	\`!img [url|filepath]'. Image urls and files can also be appended
	by typing the operator pipe and a valid input at the end of the
	text prompt, such as \`| [url|filepath]'.

	If the first positional argument of the script starts with the
	command operator \`/', the command \`/session [HIST_NAME]' to change
	to or create a new history file is assumed (with options -ccCdHH).

	Option -i generates or edits images. A text prompt is required for
	generations. An image file is required for variations. Edits need
	an image file, a mask (or the image must have a transparent layer),
	and a text prompt to direct the editing.

	Size of output image may be set as the first positional parameter,
	options are: \`256x256' (S), \`512x512' (M), \`1024x1024' (L),
	\`1792x1024' (X), and \`1024x1792' (P). The parameter \`hd' may also
	be set for quality (Dall-E-3), such as \`Xhd', or \`1792x1024hd'.

	Option -w transcribes audio to any language, and option -W translates
	audio to English text. Set these options twice to have phrase-level
	timestamps, e.g. -ww, and -WW.

	Option -z synthesises voice from text (TTS models). Set a voice as
	the first positional parameter (\`alloy', \`echo', \`fable', \`onyx',
	\`nova', or \`shimmer'). Set the second positional parameter as the
	speed (0.25 - 4.0), and, finally the output file name or the format,
	such as \`./new_audio.mp3' (\`mp3', \`opus', \`aac', and \`flac'),
	or \`-' for stdout. Set options -vz to not play received output.

	Option -y sets python tiktoken instead of the default script hack
	to preview token count. Set this option for accurate history
	context length (fast).

	Input sequences \`\\n' and \`\\t' are only treated specially in
	restart, start and stop sequences!

	A personal OpenAI API is required, set environment or option -K.


See Also
	Check the man page for extended description of interface and
	settings. See the online man page and script usage examples at:

	<https://gitlab.com/fenixdragao/shellchatgpt>.


Environment
	BLOCK_USR
	BLOCK_USR_TTS 	Extra options for the request JSON block
			(e.g. \`\"seed\": 33, \"dimensions\": 1024').

	CACHEDIR 	Script cache directory base.
	
	CHATGPTRC 	Path to the user configuration file.
			Defaults=\"${CHATGPTRC:-${CONFFILE:-"$HOME/.chatgpt.conf"}}\"

	FILECHAT 	Path to a history / session TSV file.

	GOOGLE_API_KEY
	MISTRAL_API_KEY Google / Mistral AI API keys.
	
	INSTRUCTION 	Initial instruction, or system message.

	INSTRUCTION_CHAT
			Initial instruction, or system message (chat mode).

	MOD_CHAT
	MOD_IMAGE
	MOD_AUDIO
	MOD_SPEECH
	MOD_LOCALAI
	MOD_OLLAMA
	MOD_MISTRAL
	MOD_GOOGLEAI 	Set defaults model for each endpoint / integration.
	
	OLLAMA_API_HOST Ollama host URL (with option -O).

	OPENAI_API_HOST
	OPENAI_API_HOST_STATIC
			Custom host URL. The STATIC parameter disables
			endpoint auto-selection.

	OPENAI_KEY
	OPENAI_API_KEY  Personal OpenAI API key.

	OUTDIR 		Output directory for received images and audio.

	VISUAL
	EDITOR 		Text editor for external prompt editing.
			Defaults=\"${VISUAL:-${EDITOR:-vim}}\"

	CLIP_CMD 	Clipboard set command, e.g. \`xsel -b', \`pbcopy'.

	PLAY_CMD 	Audio player command, e.g. \`mpv --no-video --vo=null'.

	REC_CMD 	Audio recorder command, e.g. \`sox -d'.


Chat Commands
	In chat mode, commands are introduced with either \`!' or \`/' as
	operators. These commands allow users to modify their interaction
	parameters within the chat.

    ------    ----------    ---------------------------------------
    --- Misc Commands ---------------------------------------------
        :     ::       [PROMPT]  Append user/system prompt to request.
       -S.     -.       [NAME]   Load and edit custom prompt.
       -S/     -S%      [NAME]   Load and edit awesome prompt (zh).
       -Z      !last             Print last response JSON.
        !      !r, !regen        Regenerate last response.
       !!      !rr               Regenerate response, edit prompt first.
       !i      !info             Info on model and session settings.
      !img     !media [FILE|URL] Append image/media/url to prompt.
      !url     -         [URL]   Dump URL text, optionally edit it.
      !url:    -         [URL]   Same as !url but append output as user.
       !j      !jump             Jump to request, append response primer.
      !!j     !!jump             Jump to request, no response priming.
      !md      !markdown [SOFTW] Toggle markdown support in response.
     !!md     !!markdown [SOFTW] Render last response in markdown.
     !rep      !replay           Replay last TTS audio response.
     !res      !resubmit         Resubmit last TTS recorded input.
      !sh      !shell    [CMD]   Run shell, or command, and edit output.
      !sh:     !shell:   [CMD]   Same as !sh but apppend output as user.
     !!sh     !!shell    [CMD]   Run interactive shell (w/ cmd) and exit.
    --- Script Settings and UX ------------------------------------
     !fold     !wrap             Toggle response wrapping.
       -g      !stream           Toggle response streaming.
       -l      !models  [NAME]   List language models or model details.
       -o      !clip             Copy responses to clipboard.
       -u      !multi            Toggle multiline, ctrl-d flush.
       -uu    !!multi            Multiline, one-shot, ctrl-d flush.
       -U      -UU               Toggle cat prompter, or set one-shot.
      !cat     -        [FILE]   Cat prompter (once, ctrd-d), or cat file.
      !cat:    -        [FILE]   Same as !cat but append prompt as user.
       -V      !context          Print context before request (see -HH).
       -VV     !debug            Dump raw request block and confirm.
       -v      !ver              Toggle verbose modes.
       -x      !ed               Toggle text editor interface.
       -xx    !!ed               Single-shot text editor.
       -y      !tik              Toggle python tiktoken use.
       !q      !quit             Exit. Bye.
       !?      !help             Print this help snippet.
    --- Model Settings --------------------------------------------
      -Nill    !Nill             Toggle model max response (chat cmpls).
       -M      !NUM !max [NUM]   Set max response tokens.
       -N      !modmax   [NUM]   Set model token capacity.
       -a      !pre      [VAL]   Set presence penalty.
       -A      !freq     [VAL]   Set frequency penalty.
       -b      !best     [NUM]   Set best-of n results.
       -K      !topk     [NUM]   Set top_k.
       !ka     !keep-alive [NUM] Set duration of model load in memory
       -m      !mod      [MOD]   Set model by name, or pick from list.
       -n      !results  [NUM]   Set number of results.
       -p      !topp     [VAL]   Set top_p.
       -r      !restart  [SEQ]   Set restart sequence.
       -R      !start    [SEQ]   Set start sequence.
       -s      !stop     [SEQ]   Set one stop sequence.
       -t      !temp     [VAL]   Set temperature.
       -w      !rec     [ARGS]   Toggle voice chat mode (Whisper).
       -z      !tts     [ARGS]   Toggle TTS chat mode (speech out).
     !blk      !block   [ARGS]   Set and add options to JSON request.
        -      !multimodal       Toggle model as multimodal.
    --- Session Management ----------------------------------------
       -H      !hist             Edit raw history file in editor.
      -HH      !req              Print session history (see -V).
       -L      !log  [FILEPATH]  Save to log file (pretty-print).
      !br      !new, !break      Start new session (session break).
      !ls      !list    [GLOB]   List History files with name glob,
                                 Prompts \`pr', Awesome \`awe', or all \`.'.
      !grep    !sub    [REGEX]   Search sessions and copy to tail.
       !c      !copy [SRC_HIST] [DEST_HIST]
                                 Copy session from source to destination.
       !f      !fork [DEST_HIST]
                                 Fork current session to destination.
       !k      !kill     [NUM]   Comment out n last entries in hist file.
      !!k     !!kill  [[0]NUM]   Dry-run of command !kill.
       !s      !session [HIST_FILE]
                                 Change to, search for, or create hist file.
      !!s     !!session [HIST_FILE]
                                 Same as !session, break session.
    ------    ----------    ---------------------------------------
	
	E.g.: \`/temp 0.7', \`!modgpt-4', \`-p 0.2', and \`/s hist_name'.

	Change chat context at run time with the \`!hist' command to edit
	the raw history file (delete or comment out entries).

	To preview a prompt completion, append a forward slash \`/' to it.
	Regenerate it again or flush / accept the prompt and response.

	After a response has been written to the history file, regenerate
	it with command \`!regen' or type in a single exclamation mark or
	forward slash in the new empty prompt (twice for editing the
       	prompt before request).

	Type in a backslash \`\\' as the last character of the input line
	to append a literal newline, or press <CTRL-V> + <CTRL-J>.

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
	-K, --top-k     [NUM]
		Set Top_k value (local-ai, ollama, google).
	--keep-alive, --ka=[NUM]
		Set how long the model will stay loaded into memory (ollama).
	-m, --model     [MOD]
		Set language MODEL name, or set it as \`.' to pick
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
		(0.0 - 2.0, whisper 0.0 - 1.0). Def=${OPTT:-0}.

	Script Modes
	-c, --chat
		Chat mode in text completions, session break.
	-cc 	Chat mode in chat completions, session break.
	-C, --continue, --resume
		Continue from (resume) last session (cmpls/chat).
	-d, --text
		Start new multi-turn session in plain text completions.
	-e, --edit
		Edit first input from stdin, or file read (cmpls/chat).
	-E, --exit
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
		May be set twice for multi-turn.
	-S .[PROMPT_NAME][.], -.[PROMPT_NAME][.]
	-S ,[PROMPT_NAME],    -,[PROMPT_NAME]
		Load, search for, or create custom prompt.
		Set \`..[prompt]' to silently load prompt.
		Set \`.?' to list prompt template files.
		Set \`,[prompt]' to edit the prompt file.
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
		is optional. Set twice to get phrase-level timestamps. 
	-W, --translate   [AUD] [PROMPT-EN]
		Translate audio file into English text (whisper models).
		Set twice to get phrase-level timestamps. 
	
	Script Settings
	--api-key  [KEY]
		Set OpenAI API key.
	-f, --no-conf
		Ignore user configuration file.
	-F 	Edit configuration file, if it exists.
		\$CHATGPTRC="${CONFFILE/"$HOME"/"~"}".
	-FF 	Dump template configuration file to stdout.
	--fold (defaults), --no-fold
		Set or unset response folding (wrap at white spaces).
	--google
		Set Google Gemini integration (cmpls/chat).
	-h, --help
		Print this help page.
	-H, --hist  [/HIST_FILE]
		Edit history file with text editor or pipe to stdout.
		A hist file name can be optionally set as argument.
	-HH, -HHH  [/HIST_FILE]
		Pretty print last history session to stdout (set twice).
		Set thrice to print commented out hist entries, too.
		Heeds -ccdrR to print the specified (re-)start seqs.
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
	-u, --multi
		Toggle multiline prompter, <CTRL-D> flush.
	-U, --cat
		Set cat prompter, <CTRL-D> flush.
	-v, --verbose
		Less verbose. Sleep after response in voice chat (-vvccw).
		May be set multiple times.
	-V 	Pretty-print context before request.
	-VV 	Dump raw request block to stderr (debug).
	-x, --editor
		Edit prompt in text editor.
	-y, --tik
		Set tiktoken for token count (cmpls/chat).
	-Y, --no-tik  (defaults)
		Unset tiktoken use (cmpls/chat).
	-z, --tts   [OUTFILE|FORMAT|-] [VOICE] [SPEED] [PROMPT]
		Synthesise speech from text prompt, set -v to not play.
	-Z, --last
		Print last response JSON data."

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
	((LOCALAI+OLLAMA+GOOGLEAI)) && is_visionf "$1" && set -- vision;
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
						elif ((OPTCMPL))
						then 	OPTC= EPN=0;
						elif ((OPTC>1))
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
		text*moderation*) 	MODMAX=150000;;
		text-davinci-002-render-sha) 	MODMAX=8191;;
		text-embedding-ada-002|*embedding*-002|*search*-002) MODMAX=8191;;
		davinci-002|babbage-002) 	MODMAX=16384;;
		davinci|curie|babbage|ada) 	MODMAX=2049;;
		code-davinci-00[2-9]) MODMAX=8001;;
		gpt-4-1106*|gpt-4-*preview*|gpt-4-vision*|gpt-4-turbo|gpt-4-turbo-202[4-9]-[0-1][0-9]-[0-3][0-9]) MODMAX=128000;;
		gpt-3.5-turbo-1106) MODMAX=16385;;
		gpt-4*32k*|*32k) 	MODMAX=32768;; 
		gpt-3.5*16K*|*turbo*16k*|*16k) 	MODMAX=16384;;
		gpt-4*|*-bison*|*-unicorn) 	MODMAX=8192;;
		*turbo*|*davinci*) 	MODMAX=4096;;
		gemini*-1.5*) 	MODMAX=128000;;
		gemini*-vision*) 	MODMAX=16384;;
		gemini*-pro*) 	MODMAX=32760;;
		*mi[sx]tral*) 	MODMAX=32000;;
		*embedding-gecko*) 	MODMAX=3072;;
		*embed*|*search*) MODMAX=2046;;
		aqa) 	MODMAX=7168;;
		*) 	MODMAX=4000;;
	esac
}

#make cmpls request
function __promptf
{
	curl "$@" --fail-with-body -L "${MISTRAL_API_HOST:-$API_HOST}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer ${MISTRAL_API_KEY:-$OPENAI_API_KEY}" \
		-d "$BLOCK" \
	&& { 	[[ \ $*\  = *\ -s\ * ]] || __clr_lineupf ;}
}

function _promptf
{
	typeset chunk_n chunk str n
	json_minif
	
	if ((STREAM))
	then 	set -- -s "$@" -S --no-buffer; [[ -s $FILE ]] &&
		  mv -f -- "$FILE" "${FILE%.*}.2.${FILE##*.}"; : >"$FILE"  #clear buffer asap
		__promptf "$@" | while IFS=  read -r chunk  #|| [[ -n $chunk ]]
		do
			chunk=${chunk##*([$' \t'])[Dd][Aa][Tt][Aa]:*([$' \t'])}
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
		((OPTV>1)) && set -- -s "$@"
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
	then 	if ((RETRY>1))
		then 	cat -- "$FILE"
		else 	((OPTK)) || printf "${BYELLOW}%s\\b${NC}" "X" >&2;
			_promptf;
		fi | prompt_printf
	else
		printf "${BYELLOW}%*s\\r${YELLOW}" "$COLUMNS" "X" >&2;
		((RETRY>1)) || COLUMNS=$((COLUMNS-3)) _promptf;
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
		return 0
	fi
}

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
SPIN_CHARS=(⣟ ⣯ ⣷ ⣾ ⣽ ⣻ ⢿ ⡿)
SPIN_CHARS=(⠏ ⠇ ⠧ ⠦ ⠴ ⠼ ⠸ ⠹ ⠙ ⠋)
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

#trim leading spaces
#usage: trim_leadf [string] [glob]
function trim_leadf
{
	typeset var ind sub
	var="$1" ind=${INDEX:-160}
	sub="${var:0:$ind}"
	((SMALLEST)) && sub="${sub#$2}" || sub="${sub##$2}"
	var="${sub}${var:$ind}"
	printf '%s\n' "$var"
}
#trim trailing spaces
#usage: trim_trailf [string] [glob]
function trim_trailf
{
	typeset var ind sub
	var="$1" ind=${INDEX:-160}
	if ((${#var}>ind))
	then 	sub="${var:$((${#var}-${ind}))}"
		((SMALLEST)) && sub="${sub%$2}" || sub="${sub%%$2}"
		var="${var:0:$((${#var}-${ind}))}${sub}"
	else 	((SMALLEST)) && var="${var%$2}" || var="${var%%$2}"
	fi; printf '%s\n' "$var"
}
#fast trim
#usage: trimf [string] [glob]
function trimf
{
	trim_leadf "$(trim_trailf "$1" "$2")" "$2"
}

#pretty print request body or dump and exit
function block_printf
{
	if ((OPTVV>1))
	then 	[[ ${BLOCK:0:10} = @* ]] && cat -- "${BLOCK##@}" | less >&2
		printf '\n%s\n%s\n' "${ENDPOINTS[EPN]}" "$BLOCK"; OPTAWE= SKIP=
		printf '\n%s\n' '<Enter> continue, <Ctrl-D> redo, <Ctrl-C> exit'
		typeset REPLY; __clr_ttystf; read </dev/tty || return 200;
	else 	((STREAM)) && set -- -j "$@"
		jq -r "$@" '.instruction//empty, .input//empty,
		.prompt//(.messages[]|.role+": "+.content)//empty' <<<"$BLOCK" | foldf
		((!OPTC)) || printf ' '
	fi >&2
}

#prompt confirmation prompter
function new_prompt_confirmf
{
	typeset REPLY extra
	((${#1})) && extra=", te[x]t editor, m[u]ltiline"
	((${#2})) && ((OPTW)) && extra="${extra}, [w]hisper_off"

	_sysmsgf 'Confirm?' "[Y]es, [n]o, [e]dit${extra}, [r]edo, or [a]bort " ''
	REPLY=$(__read_charf); __clr_lineupf $((8+1+40+${#extra}))  #!#
	case "$REPLY" in
		[AaQq]) 	return 201;;  #break
		[Rr]) 		return 200;;  #redo
		[Ee]|$'\e') 	return 199;;  #edit
		[VvXx]) 	return 198;;  #text editor
		[UuMm]) 	return 197;;  #multiline
		[Ww]) 		return 196;;  #whisper off
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
	jq -r ${stream:+-j --unbuffered} "${JQCOLNULL} ${JQCOL} ${JQCOL2}
	  byellow
	  + (.choices[1].index as \$sep | if .choices? != null then .choices[] else . end |
	  ( (.text//.response//(.message.content)//(.delta.content)//\"\" ) |
	  if (${OPTC:-0}>0) then (gsub(\"^[\\\\n\\\\t ]\"; \"\") |  gsub(\"[\\\\n\\\\t ]+$\"; \"\")) else . end)
	  + if .finish_reason? != \"stop\" then (if .finish_reason? != null then (if .finish_reason? != \"\" then red+\"(\"+.finish_reason+\")\"+byellow else null end) else null end) else null end,
	  if \$sep then \"---\" else empty end)" "$@" && _p_suffixf;
}
function prompt_pf
{
	typeset var
	typeset -a opt
	for var
	do 	[[ -f $var ]] || { 	opt+=("$var"); shift ;}
	done
	set -- "(if .choices? != null then (.choices[$INDEX]) else . end |.text//.response//(.message.content)//(.delta.content))//(.data?)//empty" "$@"
	((${#opt[@]})) && set -- "${opt[@]}" "$@"
	{ jq "$@" && _p_suffixf ;} || ! cat -- "$@" >&2 2>/dev/null
}
#https://stackoverflow.com/questions/57298373/print-colored-raw-output-with-jq-on-terminal
#https://stackoverflow.com/questions/40321035/  #gsub(\"^[\\n\\t]\"; \"\")

function _p_suffixf { 	((!${#SUFFIX} )) || printf '%s' "$(unescapef "$SUFFIX")" ;}

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
		((n)) || ! cat -- "$FILE" >&2;
	else 	jq -r '.data[].url' "$FILE" || ! cat -- "$FILE" >&2;
	fi &&
	jq -r 'if .data[].revised_prompt then "\nREVISED PROMPT: "+.data[].revised_prompt else empty end' "$FILE" >&2
}

function prompt_audiof
{
	((OPTVV)) && __warmsgf "Whisper:" "Model: ${MOD_AUDIO:-unset},  Temperature: ${OPTT:-unset}${*:+,  }${*}" >&2

	curl -\# ${OPTV:+-Ss} --fail-with-body -L "${API_HOST}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H 'Content-Type: multipart/form-data' \
		-F file="@$1" \
		-F model="${MOD_AUDIO}" \
		-F temperature="$OPTT" \
		-o "$FILE" \
		"${@:2}" && {
	  [[ -d $CACHEDIR ]] && printf '%s\n\n' "$(<"$FILE")" >> "$FILEWHISPER";
	  ((OPTV)) || __clr_lineupf; ((CHAT_ENV)) || echo >&2;
	}
}

function list_modelsf
{
	((MISTRALAI)) && typeset OPENAI_API_KEY=$MISTRAL_API_KEY API_HOST=$MISTRAL_API_HOST
	curl -\# --fail-with-body -L "${API_HOST}${ENDPOINTS[11]}${1:+/}${1}" \
		-H "Authorization: Bearer $OPENAI_API_KEY" -o "$FILE" &&

	if [[ -n $1 ]]
	then  	jq . "$FILE" || ! cat -- "$FILE"
	else 	jq -r '.data[].id' "$FILE" | sort \
		&& { ((MISTRALAI)) || printf '%s\n' text-moderation-latest text-moderation-stable text-moderation-007 ;} \
		|| ! cat -- "$FILE"
	fi || ! __warmsgf 'Err:' 'Model list'
}

function pick_modelf
{
	typeset REPLY mod
	set -- "${1// }"; set -- "${1##*(0)}";
	((${#1}<3)) || return
	((${#MOD_LIST[@]})) || MOD_LIST=($(list_modelsf))
	if [[ ${REPLY:=$1} = +([0-9]) ]] && ((REPLY && REPLY <= ${#MOD_LIST[@]}))
	then 	mod=${MOD_LIST[REPLY-1]}  #pick model by number from the model list
	else 	__clr_ttystf; REPLY=${REPLY//[!0-9]};
		while ! ((REPLY && REPLY <= ${#MOD_LIST[@]}))
		do 	echo $'\nPick model:' >&2;
			select mod in ${MOD_LIST[@]:-err}
			do 	break;
			done </dev/tty; REPLY=${REPLY//[$' \t\b\r']}
			[[ \ ${MOD_LIST[*]:-err}\  = *\ "$REPLY"\ * ]] && mod=$REPLY && break;
		done;  #pick model by number or name
	fi; MOD=${mod:-$MOD};
}

function lastjsonf
{
	if [[ -s $FILE ]]
	then 	jq "$@" . "$FILE" || cat "$@" -- "$FILE"
	fi
}

#set up context from history file ($HIST and $HIST_C)
function set_histf
{
	typeset time token string stringc stringd max_prev q_type a_type role role_last rest com sub ind herr nl x r n;
	typeset -a MEDIA MEDIA_CMD;
	[[ -s $FILECHAT ]] || return; HIST= HIST_C= ;
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
		then 	((token<1 && OPTVV>1)) && __warmsgf "Warning:" "Zero/Neg token in history"
			start_tiktokenf
			if ((EPN==6))
			then 	token=$(__tiktokenf "$(INDEX=16 trim_leadf "$stringc" :)" )
			else 	token=$(__tiktokenf "\\n$(INDEX=16 trim_leadf "$stringc" :)" )
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
				::*) 	role=system rest=
					stringc=$(INDEX=16 trim_leadf "$stringc" :)  #append (txt cmpls)
					;;
				:*) 	role=system
					((OPTC)) && rest="$S_TYPE" nl="\\n"  #system message
					;;
				"${a_type:-%#}"*|"${START:-%#}"*)
					role=assistant
					if ((OPTC)) || [[ -n "${START}" ]]
					then 	rest="${START:-${A_TYPE}}"
					fi
					;;
				*) #q_type, RESTART
					role=user
					if ((OPTC)) || [[ -n "${RESTART}" ]]
					then 	rest="${RESTART:-$Q_TYPE}"
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
			stringd=$(fmt_ccf "${stringc}" "${role}")${HIST_C:+,${NL}}
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

function hist_lastlinef
{
	sed -n -e 's/\t"/\t/; s/"$//;' -e '$s/^[^\t]*\t[^\t]*\t//p' "$FILECHAT" \
	| sed -e "s/^://; s/^${Q_TYPE//\\n}//; s/^${A_TYPE//\\n}//;"
}

#print to history file
#usage: push_tohistf [string] [tokens] [time]
function push_tohistf
{
	typeset string token time
	string=$1; ((${#string})) || return; unset CKSUM_OLD
	token=$2; ((token>0)) || {
		start_tiktokenf;    ((OPTTIK)) && __printbf '(tiktoken)';
		token=$(__tiktokenf "${string}");
		((token+=TKN_ADJ)); ((OPTTIK)) && __printbf '          '; };
	time=${3:-$(date -Iseconds 2>/dev/null||date +"%Y-%m-%dT%H:%M:%S%z")}
	printf '%s%.22s\t%d\t"%s"\n' "$INT_RES" "$time" "$token" "$string" >> "$FILECHAT"
}

#record preview query input and response to hist file
#usage: prev_tohistf [input]
function prev_tohistf
{
	typeset input answer
	input="$*"
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
	set -- "$(trimf "$*" "$SPC")";

	if ! command -v "${1%% *}" &>/dev/null
	then 	for cmd in "bat" "pygmentize" "glow" "mdcat" "mdless"
		do 	command -v $cmd &>/dev/null || continue;
			set -- $cmd; break;
		done;
	fi

	case "$1" in
		bat) 	MD_CMD_UNBUFF=1  #line-buffer support
			function mdf { 	[[ -t 1 ]] && set -- --color always "$@" 
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
	esac;
}

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
		*) 	printf '%s' "curl -L -f --progress-bar";;
	esac;
}

#check input and run a chat command
function cmd_runf
{
	typeset opt_append var wc xskip pid n
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
		-b*|best[_-]of*|best*)
			set -- "${*//[!0-9.]}" ;set -- "${*%%.*}"
			OPTB="${*:-$OPTB}"
			__cmdmsgf 'Best_Of' "$OPTB"
			;;
		-[cC])
			OPTC=1 EPN=0 OPTCMPL= ;
			__cmdmsgf "Endpoint[$EPN]:" "Chat Text Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$API_HOST}]";
			;;
		-[cC][cC])
			OPTC=2 EPN=6 OPTCMPL= ;
			__cmdmsgf "Endpoint[$EPN]:" "Chat Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$API_HOST}]";
			;;
		-[dD])
			OPTC= EPN=0 OPTCMPL=1 ;
			__cmdmsgf "Endpoint[$EPN]:" "Text Completions$(printf "${NC}") [${ENDPOINTS[EPN]:-$API_HOST}]";
			;;
		break|br|new)
			break_sessionf
			[[ -n ${INSTRUCTION_OLD:-$INSTRUCTION} ]] && {
			  _sysmsgf 'INSTRUCTION:' "${INSTRUCTION_OLD:-$INSTRUCTION}" 2>&1 | foldf >&2
			  ((GOOGLEAI)) && GINSTRUCTION=${INSTRUCTION_OLD:-$INSTRUCTION} INSTRUCTION= ||
			  INSTRUCTION=${INSTRUCTION_OLD:-$INSTRUCTION};
			}; unset CKSUM_OLD MAX_PREV WCHAT_C MAIN_LOOP; xskip=1;
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
		-h*|h*|help*|-\?*|\?*)
			sed -n -e 's/^\t*//' -e '/^[[:space:]]*------ /,/^[[:space:]]*------ /p' <<<"$HELP" | less -S
			xskip=1
			;;
		-H|H|history|hist)
			__edf "$FILECHAT"
			unset CKSUM_OLD; xskip=1
			;;
		-HH|-HHH*|HH|HHH*|request|req)
			[[ $* = ?(-)HHH* ]] && typeset OPTHH=3
			Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" MOD= OLLAMA= set_histf
			var=$( usr_logf "$(unescapef "$HIST")" )
			printf "\\n---\\n%s\\n---\\n" "$var" >&2
			((OPTCLIP)) && ${CLIP_CMD:-false} <<<"$var" && echo 'Clipboard set!' >&2
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
		-K*|top[Kk]*|top[_-][Kk]*|topk*)
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
			((OPTLOG)) && [[ $* != $SPC ]] && OPTLOG= ;
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
		-l*|models|models\ *|model\ [Ii]nstall*|[Ii]nstall*)
			set -- "${*##@(-l|models|model\ )*([$IFS])}";
			if [[ $1 = *[Ii]nstall* ]]
			then 	list_modelsf "$*";
			else 	list_modelsf "$*" | less >&2;
			fi
			;;
		-m*|model*|mod*)
			set -- "${*##@(-m|model|mod)}"; set -- "${1//[$IFS]}"
			if ((${#1}<3))
			then 	pick_modelf "$1"
			else 	MOD=${1:-$MOD};
			fi
			set_model_epnf "$MOD"; model_capf "$MOD"
			send_tiktokenf '/END_TIKTOKEN/'
			__cmdmsgf 'Model Name' "$MOD"
			__cmdmsgf 'Max Response / Capacity:' "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
			;;
		markdown*|md*)
			set -- "${*##@(markdown|md)$SPC}"
			((OPTMD)) && [[ $1 != $SPC ]] && OPTMD= ;
			if ((++OPTMD)); ((OPTMD%=2))
			then 	set_mdcmdf "${1:-$MD_CMD}"; MD_CMD=${1:-$MD_CMD} xskip=1;
				__sysmsgf 'MD Cmd:' "$(trimf "$(declare -f mdf | sed '1d;2d;$d' | tr -d '\n')" "$SPC")"
			fi;
			__cmdmsgf 'Markdown' $(_onoff $OPTMD);
			((OPTMD)) || unset OPTMD;
			;;
		[/!]markdown*|[/!]md*)
			set -- "${*##[/!]@(markdown|md)$SPC}"
			set_mdcmdf "${1:-$MD_CMD}"; xskip=1;
			((STREAM)) || unset STREAM;
			printf "${NC}\\n" >&2;
			prompt_pf -r ${STREAM:+-j --unbuffered} "$FILE" 2>/dev/null | mdf >&2 2>/dev/null;
			printf "${NC}\\n" >&2;
			;;
		url*|[/!]url*)
			set -- "$(trimf "${*##@(url|[/!]url)}" "$SPC")"; xskip=1;
			[[ $* = :* ]] && { 	opt_append=1; set -- "${1##:*([$IFS])}" ;};  #append as user message
			if var=$(set_browsercmdf)
			then 	case "$var" in
				curl*|google-chrome*|chromium*)
				    cmd_runf /sh${opt_append:+:} "${var} ${1// /%20} | sed '/</{ :loop ;s/<[^<]*>//g ;/</{ N ;b loop } }'";  #curl+sed
				    ;;
				*)  cmd_runf /sh${opt_append:+:} "${var} -dump" "${1// /%20}"
				    ;;
				esac;
			fi
			;;
		media*|img*)
			set -- "${*##@(media|img)*([$IFS])}";
			set -- "$(trim_trailf "$*" $'*([ \t\n])')";
			CMD_CHAT=1 _mediachatf "$1" && {
			  [[ -f $1 ]] && set -- "$(du -h -- "$1" 2>/dev/null||du -- "$1")" && set -- "${@//$'\t'/ }";
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
		-p*|top[Pp]*|top[_-][Pp]*|topp*)
			set -- "${*//[!0-9.]}"
			OPTP="${*:-$OPTP}"
			fix_dotf OPTP
			__cmdmsgf 'Top_P' "$OPTP"
			;;
		-r*|restart*)
			set -- "${*##@(-r|restart)$SPC}"
			restart_compf "$*"
			__cmdmsgf 'Restart Sequence' "$RESTART"
			;;
		-R*|start*)
			set -- "${*##@(-R|start)$SPC}"
			start_compf "$*"
			__cmdmsgf 'Start Sequence' "$START"
			;;
		-s*|stop*)
			set -- "${*##@(-s|stop)$SPC}"
			((${#1})) && STOPS=("$(unescapef "${*}")" "${STOPS[@]}")
			__cmdmsgf 'Stop Sequences' "${STOPS[*]}"
			;;
		-?(S)*([$' \t'])[.,]*)
			set -- "${*##-?(S)*([$' \t'])}"; SKIP=1 EDIT=1 
			var=$(INSTRUCTION=$* OPTRESUME=1 CMD_CHAT=1; custom_prf "$@" && echo "$INSTRUCTION")
			case $? in [1-9]*|201|[!0]*) 	REPLY="!${args[*]}";; 	*) REPLY=$var;; esac
			;;
		-?(S)*([$' \t'])[/%]*)
			set -- "${*##-?(S)*([$' \t'])}"; SKIP=1 EDIT=1 
			var=$(INSTRUCTION=$* CMD_CHAT=1; awesomef && echo "$INSTRUCTION") && REPLY=$var
			;;
		-S*|-:*)
			set -- "${*##-[S:]*([$': \t'])}"
			SKIP=1 EDIT=1 REPLY=":${*}"
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
				set -- "$(hist_lastlinef)"; [[ $* != *([$IFS]) ]] &&
				unescapef "$*" | ${CLIP_CMD:-false} &&
				  printf "${NC}Clipboard Set -- %.*s..${CYAN}\\n" $((COLUMNS-20>20?COLUMNS-20:20)) "$*" >&2;
			fi
			;;
		-q|insert)
			((++OPTSUFFIX)) ;((OPTSUFFIX%=2))
			__cmdmsgf 'Insert Mode' $(_onoff $OPTSUFFIX)
			;;
		-v|verbose|ver)
			((++OPTV)) ;((OPTV%=4))
			case "${OPTV:-0}" in
				1) var='Less';;  2) var='Much less';;
				3) var='OFF';;   0) var='ON'; unset OPTV;;
			esac ;_cmdmsgf 'Verbose' "$var"
			;;
		-V|context)
			((OPTVV==1)) && unset OPTVV || OPTVV=1
			__cmdmsgf 'Print Request' $(_onoff $OPTVV)
			;;
		-VV|debug)  #debug
			((OPTVV==2)) && unset OPTVV || OPTVV=2
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
		-w*|-W*|[Ww]*|rec*|whisper*)
			[[ $* = -W* ]] && var=translate;
			set -- "${*##@(-[wW][wW]|-[wW]|[Ww]|rec|whisper)$SPC}";

			((OPTW+OPTWW)) && [[ $* != $SPC ]] && OPTW= OPTWW= ;
			if [[ $var = translate ]]
			then 	((++OPTWW)); OPTW= ;
			else 	((++OPTW)); OPTWW= ;
			fi
			((OPTW%=2)); ((OPTWW%=2));
			if ((OPTW+OPTWW))
			then
			  set_reccmdf

			  var="${*##$SPC}"
			  [[ $var = [a-z][a-z][$IFS]*[[:graph:]]* ]] \
			  && set -- "${var:0:2}" "${var:3}"
			  for var
			  do 	((${#var})) || shift; break;
			  done

			  [[ $* = $SPC ]] || WARGS=("$@"); xskip=1;
			  __cmdmsgf "Whisper Args #${#WARGS[@]}" "${WARGS[*]:-(auto)}"
			fi; __cmdmsgf 'Whisper Chat' $(_onoff $((OPTW+OPTWW)) );
			((OPTW)) || unset OPTW WSKIP SKIP;
			;;
		-z*|tts*|speech*)
			set -- "${*##@(-z*([zZ])|tts|speech)$SPC}"
			((OPTZ)) && [[ $* != $SPC ]] && OPTZ= ;
			if ((++OPTZ)); ((OPTZ%=2))
			then 	set_playcmdf;
				[[ $* = $SPC ]] || ZARGS=("$@"); xskip=1;
				__cmdmsgf 'TTS Args' "${ZARGS[*]:-unset}";
			fi; __cmdmsgf 'TTS Chat' $(_onoff $OPTZ);
			((OPTZ)) || unset OPTZ SKIP;
			;;
		-Z|last)
			lastjsonf >&2
			;;
		[/!]k*|k*)  #kill num hist entries
			typeset IFS dry; IFS=$'\n'; ((RETRY)) && BCYAN="${Color9}" RETRY= ;
			[[ ${n:=${*//[!0-9]}} = 0* || $* = [/!]* ]] \
			&& n=${n##*([/!0])} dry=4; ((n>0)) || n=1
			if var=($(grep -n -e '^[[:space:]]*[^#]' "$FILECHAT" \
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
			printf "${NC}${BWHITE}%-12s:${NC} %-5s\\n" \
			$( ((LOCALAI)) && echo host-url "${API_HOST//[$IFS]/_}${ENDPOINTS[EPN]}") \
			$( ((OLLAMA)) && echo ollama-url "${OLLAMA_API_HOST//[$IFS]/_}${ENDPOINTS[EPN]}") \
			model-name   "${MOD:-?}$(is_visionf "$MOD" && printf '  %s' '[multimodal]')" \
			model-cap    "${MODMAX:-?}" \
			response-max "${OPTMAX:-?}${OPTMAX_NILL:+${EPN6:+ - inf.}}" \
			context-prev "${MAX_PREV:-?}" \
			token-rate   "${TKN_RATE[2]:-?} tkns/sec  (${TKN_RATE[0]:-?} tkns, ${TKN_RATE[1]:-?} secs)" \
			tiktoken     "${OPTTIK:-0}" \
			keep-alive   "${OPT_KEEPALIVE:-unset}" \
			temperature  "${OPTT:-0}" \
			pres-penalty "${OPTA:-unset}" \
			freq-penalty "${OPTAA:-unset}" \
			top-k        "${OPTKK:-unset}" \
			top-p        "${OPTP:-unset}" \
			results      "${OPTN:-1}" \
			best-of      "${OPTB:-unset}" \
			logprobs     "${OPTBB:-unset}" \
			insert-mode  "${OPTSUFFIX:-unset}" \
			streaming    "${STREAM:-unset}" \
			clipboard    "${OPTCLIP:-unset}" \
			ctrld-prpter "${OPTCTRD:-unset}" \
			cat-prompter "${CATPR:-unset}" \
			restart-seq  "\"$( ((EPN==6)) && echo unavailable && exit;
				((OPTC)) && printf '%s' "${RESTART:-$Q_TYPE}" || printf '%s' "${RESTART:-unset}")\"" \
			start-seq    "\"$( ((EPN==6)) && echo unavailable && exit;
				((OPTC)) && printf '%s' "${START:-$A_TYPE}"   || printf '%s' "${START:-unset}")\"" \
			stop-seqs    "$(set_optsf 2>/dev/null ;OPTSTOP=${OPTSTOP#*:} OPTSTOP=${OPTSTOP%%,} ;printf '%s' "${OPTSTOP:-\"unset\"}")" \
			history-file "${FILECHAT/"$HOME"/"~"}"  >&2  #2>/dev/null
			;;
		-u|multi|multiline|-uu*(u)|[/!]multi|[/!]multiline)
			case "$*" in
				-uu*|[/!]multi|[/!]multiline)
					((OPTCTRD)) || OPTCTRD=2;
					((OPTCTRD==2)) && __cmdmsgf 'Prompter <Ctrl-D>' 'one-shot';;
				*) 	((OPTCTRD)) && unset OPTCTRD || OPTCTRD=1
					__cmdmsgf 'Prompter <Ctrl-D>' $(_onoff $OPTCTRD)
					((OPTCTRD)) && __warmsgf '*' '<Ctrl-V> + <Ctrl-J> for newline * ';;
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
		cat*|[/!-]cat*)
			set -- "${*##[/!-]}"
			if [[ $* = cat:*[!$IFS]* ]]
			then 	cmd_runf /sh: "cat${1:4}";
			elif [[ $* = cat*[!$IFS]* ]]
			then 	cmd_runf /sh "${@}"
			else 	__warmsgf '*' 'Press <Ctrl-D> to flush * '
				STDERR=/dev/null  cmd_runf /sh cat </dev/tty
			fi; xskip=1
			;;
		[/!]sh*)
			set -- "${*##[/!]sh?(ell)*([$IFS])}"
			if [[ -n $1 ]]
			then 	bash -i -c "${1%%;}; exit"
			else 	bash -i
			fi </dev/tty;
			;;
		shell*|sh*)
			set -- "${*##sh?(ell)*([$IFS])}"
			[[ $* = :* ]] && { 	opt_append=1; set -- "${1##:*([$IFS])}" ;};  #append as user message
			[[ -n $* ]] || set --; xskip=1;
			while :
			do 	REPLY=$(bash --norc --noprofile ${@:+-c} "${@}" </dev/tty | tee $STDERR); echo >&2
				#abort on empty
				[[ $REPLY = *([$IFS]) ]] && { 	SKIP=1 EDIT=1 REPLY="!${args[*]}" ;return ;}

				_sysmsgf 'Edit buffer?' '[Y]es, [n]o, [e]dit, te[x]t editor, [s]hell, or [r]edo ' ''
				case "$(__read_charf)" in
					[AaQqRr]) 	SKIP=1 EDIT=1 REPLY="!${args[*]}"; break;;  #abort, redo
					[Ee]|$'\e') 	SKIP=1 EDIT=1; break;; #yes, bash `read`
					[VvXx]) 	SKIP=1; ((OPTX)) || OPTX=2; break;; #yes, text editor
					[NnOo]) 	SKIP=1 PSKIP=1; break;;  #no need to edit
					[!Ss]|'') 	SKIP=1 EDIT=1;
							printf '\n%s\n' '---' >&2; break;;  #yes
				esac ;set --
			done ;__clr_lineupf $((12+1+55))  #!#
			((opt_append)) && [[ $REPLY != [/!]* ]] && REPLY=":$REPLY";
			((${#args[@]})) && shell_histf "!${args[*]}"
			;;
		[/!]session*|session*|list*|copy*|cp\ *|fork*|sub*|grep*|[/!][Ss]*|[Ss]*|[/!][cf]\ *|[cf]\ *|ls*)
			echo Session and History >&2
			session_mainf /"${args[@]}"
			;;
		r|rr|''|[/!]|regenerate|regen|[/!]regenerate|[/!]regen|[$IFS])  #regenerate last response
			SKIP=1 EDIT=1
			case "$*" in
				rr|[/!]*) REGEN=2;;  #edit prompt
				*) 	REGEN=1 REPLY= ;;
			esac
			if ((!BAD_RES)) && [[ -s "$FILECHAT" ]] &&
			[[ "$(tail -n 2 "$FILECHAT")"$'\n' != *[Bb][Rr][Ee][Aa][Kk]$'\n'* ]]
			then 	# comment out two lines from tail
				wc=$(wc -l <"$FILECHAT") && ((wc>2)) \
				&& sed -i -e "$((wc-1)),${wc} s/^/#/" "$FILECHAT";
				unset CKSUM_OLD
			fi
			;;
		replay|rep)
			if ((${#REPLAY_FILES[@]}))
			then 	for var in "${REPLAY_FILES[@]}"
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
		q|quit|exit|bye)
			send_tiktokenf '/END_TIKTOKEN/' && wait
			echo '[bye]' >&2; exit 0
			;;
		*) 	return 1
			;;
	esac; ((OPTCMPL)) && typeset Q_TYPE; [[ ${RESTART:-$Q_TYPE} != @($'\n'|\\n)* ]] && echo >&2;
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
	((OPTC)) && rest="${RESTART:-$Q_TYPE}" || rest="${RESTART}"
	rest="$(_unescapef "$rest")"
	((GOOGLEAI)) && typeset INSTRUCTION=${INSTRUCTION:-$GINSTRUCTION};

	if ((CHAT_ENV))
	then 	MAIN_LOOP=1 Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" MOD= \
		OLLAMA= set_histf "${rest}${*}"
	fi

	pre="${INSTRUCTION}${INSTRUCTION:+$'\n\n'}""$(unescapef "$HIST")"
	((OPTCMPL)) || [[ $pre = *([$IFS]) ]] || pre="${pre}${ed_msg}"
	printf "%s\\n" "${pre}"$'\n\n'"${rest}${*}" > "$FILETXT"

	set_filetxtf
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

function break_sessionf
{
	[[ -f "$FILECHAT" ]] || return
	[[ BREAK"$(tail -n 20 "$FILECHAT")" = *[Bb][Rr][Ee][Aa][Kk] ]] \
	|| _sysmsgf "$(tee -a -- "$FILECHAT" <<<'SESSION BREAK')"
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
			then 	ext=${var##*.}; ((${#ext}<7)) && ext=${ext/[Jj][Pp][Gg]/jpeg} || ext=;
				printf ',\n{ "type": "image_url", "image_url": { "url": "data:image/%s;base64,%s" } }' "${ext:-jpeg}" "$(base64 "$var" | tr -d $'\n')";
			else 	printf ',\n{ "type": "image_url", "image_url": { "url": "%s" } }' "$var";
			fi
		done;
		printf '%s\n' ' ] }';
	fi
}

#set media for ollama *generation endpoint*
function ollama_mediaf
{
	typeset var n
	set -- "${MEDIA[@]}" "${MEDIA_CMD[@]}";
	[[ $* != $SPC1 ]] || return;
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
	typeset var spc spc2 spc_sep ftrim break i n; unset TRUNC_IND;
       	i=${#1} spc=$'(\\[tnr]|[ \t\n\r])' spc2="+$spc" spc="*$spc";

	#process only the last line of input, fix for escaped white spaces in filename, del trailing spaces and trailing pipe separator
	set -- "$(sed -n 's/\\n/\n/g; s/\\\\ / /g; s/\\ / /g; s/[[:space:]|]*$//; $p' <<<"$*")";

	((!CMD_CHAT)) && ((${#1}>2048)) && set -- "${1:${#1}-2048}";  #avoid too long an input (too slow)

	while [[ $1 = $SPC1 ]] || ((n>99)) && break;
		[[ $1 = *[\|\ ]*[[:alnum:]]* ]] || {  #prompt is the raw filename / url:
		  ftrim=$(trim_leadf "$1" $'*(\\\\[ntr]|[ \n\t\|])');
		  { [[ -f $ftrim ]] || is_linkf "$ftrim" ;} && break=1;
		}
	do 	if ((break))
		then var=$ftrim;
		elif [[ $1 = *\|* ]]
		then 	var=${1##*\|${spc}};  #pipe separator
		else 	var=${1##*${spc2}} spc_sep=1;  #space separator
		fi

		#check if file or url and add to array (max 20MB)
		if is_imagef "$var" || { ((GOOGLEAI)) && is_videof "$var" ;} || is_linkf "$var"  #|| ((MULTIMODAL))
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
			then 	set -- "${1%\|*}";
			else 	set -- "${1%${spc2}*}";
			fi; spc_sep= ;
			set -- "${1%%${spc}}";
			((TRUNC_IND = i - ${#1}));
		else
			((spc_sep)) ||
			__warmsgf 'err: invalid --' "${var:0: COLUMNS-20}$([[ -n ${var: COLUMNS-20} ]] && echo ...)";

			[[ $1 = *\|*[[:alnum:]]*\|* ]] || break;
			set -- "${1%\|*}";
		fi  #https://stackoverflow.com/questions/12199059/
		((break)) && break;
	done; ((n));
}

function is_linkf
{
	[[ ! -f $1 ]] || return;
	[[ $1 =~ ^(https|http|ftp|file|telnet|gopher|about|wais)://[-[:alnum:]\+\&@\#/%?=~_\|\!:,.\;]*[-[:alnum:]\+\&@\#/%=~_\|] ]] ||
	[[ $1 = [Ww][Ww][Ww].* ]] || [[ \ $LINK_CACHE\  = *\ "${1:-empty}"\ * ]] || {
	curl --output /dev/null --max-time 10 --silent --head --fail --location -H "$UAG" -- "$1" 2>/dev/null && LINK_CACHE="$LINK_CACHE $1" ;}
}

function is_txtfilef
{
	[[ "$(file -- "$1")" = *[Tt][Ee][Xx][Tt]* ]]
}

function _is_imagef
{
	case "$1" in
		*[Pp][Nn][Gg] | *[Jj][Pp]?([Ee])[Gg] | *[Ww][Ee][Bb][Pp] | *[Gg][Ii][Ff] | *[Hh][Ee][Ii][CcFf] )
			:;;
		*) 	false;;
	esac;
}
function is_imagef
{
	[[ -f $1 ]] && _is_imagef "$1";
}

function _is_videof
{
	case "$1" in
		*[Mm][Oo][Vv] | *[Mm][Pp][Ee][Gg] | *[Mm][Pp][Gg4] | *[Aa][Vv][Ii] | *[Ww][Mm][Vv] | *[Mm][Pp][Ee][Gg][Pp][Ss] | *[Ff][Ll][Vv] ) :;;
		*) false;;
	esac;
}
function is_videof
{
	[[ -f $1 ]] && _is_videof "$1";
}

#check for multimodal (vision) model
function is_visionf
{
	case "$1" in 
	*vision*|*llava*|*cogvlm*|*cogagent*|*qwen*|*detic*|*codet*|*kosmos-2*|*fuyu*|*instructir*|*idefics*|*unival*|*glamm*|\
	gpt-4-turbo|gpt-4-turbo-202[4-9]-[0-1][0-9]-[0-3][0-9]) 	:;;
	*) 	((MULTIMODAL));;
	esac;
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
	typeset s n p
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
	  check_optrangef "$OPTT"  0.0 2.0 'Temperature'  #whisper max=1
	}
	((OPTI)) && check_optrangef "$OPTN"  1 10 'Number of Results'

	[[ -n $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA," || unset OPTA_OPT
	[[ -n $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA," || unset OPTAA_OPT
	{ ((OPTB)) && OPTB_OPT="\"best_of\": $OPTB," || unset OPTB OPTB_OPT;
	  ((OPTBB)) && OPTBB_OPT="\"logprobs\": $OPTBB," || unset OPTBB OPTBB_OPT; } 2>/dev/null
	[[ -n $OPTP ]] && OPTP_OPT="\"top_p\": $OPTP," || unset OPTP_OPT
	[[ -n $OPTKK ]] && OPTKK_OPT="\"top_k\": $OPTKK," || unset OPTKK_OPT
	[[ -n $SUFFIX ]] && OPTSUFFIX_OPT="\"suffix\": \"$(escapef "$SUFFIX")\"," || unset OPTSUFFIX_OPT
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
		if ((n==1))
		then 	OPTSTOP="\"stop\":${OPTSTOP},"
		elif ((n))
		then 	OPTSTOP="\"stop\":[${OPTSTOP}],"
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

function restart_compf { ((${#1})) && RESTART=$(escapef "$(unescapef "${*:-$RESTART}")") RESTART_OLD="$RESTART" ;}
function start_compf { ((${#1})) && START=$(escapef "$(unescapef "${*:-$START}")")   START_OLD="$START" ;}

function record_confirmf
{
	if ((OPTV<1)) && { 	((!WSKIP)) || [[ ! -t 1 ]] ;}
	then 	printf "\\n${NC}${BWHITE}${ON_PURPLE}%s${NC}" ' * Press ENTER to START record * ' >&2
		case "$(__read_charf)" in [OoQqWw]) 	return 196;; [Ee]|$'\e') 	return 199;; [AaNnQq]) 	return 201;; esac
		__clr_lineupf 33  #!#
	fi
	printf "\\n${NC}${BWHITE}${ON_PURPLE}%s\\a${NC}\\n" ' * [e]dit, [r]edo, [w]hspr off * ' >&2
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

	$REC_CMD "$1" & pid=$! PIDS+=($!);
	trap "trap 'exit' INT; ret=199;" INT;
	
	case "$(__read_charf)" in
		[OoQqWw])   ret=196  #whisper off
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
#
function ffmpeg_recf
{
	ffmpeg -f alsa -i pulse -ac 1 -y "$1" || ffmpeg -f avfoundation -i ":1" -y "$1"  #macos
}
#-acodec libmp3lame -ab 32k -ac 1  #https://stackoverflow.com/questions/19689029/

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
	typeset file rec var pid ret;
	typeset -a args;
       	unset WHISPER_OUT;
	
	if ((!(CHAT_ENV+MTURN) ))
	then 	__sysmsgf 'Whisper Model:' "$MOD_AUDIO"; __sysmsgf 'Temperature:' "$OPTT";
	fi;
	check_optrangef "$OPTT" 0 1.0 Temperature
	set_model_epnf "$MOD_AUDIO"
	
	((${#})) || [[ ${WARGS[*]} = $SPC ]] || set -- "${WARGS[@]}" "$@";
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
			*) 	((CHAT_ENV)) || __sysmsgf 'Rec Cmd:' "\"${REC_CMD}\"";
				OPTV=4 record_confirmf || return
				WSKIP=1 recordf "$FILEINW"
				set -- "$FILEINW" "$@"; rec=1;;
		esac
	fi
	
	var='@([Mm][Pp][34]|[Mm][Pp][Gg]|[Mm][Pp][Ee][Gg]|[Mm][Pp][Gg][Aa]|[Mm]4[Aa]|[Ww][Aa][Vv]|[Ww][Ee][Bb][Mm])'
	if [[ -f $1 && $1 = *${var} ]] #mp3|mp4|mpeg|mpga|m4a|wav|webm
	then 	file="$1"; shift;
	elif (($#)) && [[ -f ${@:${#}} && ${@:${#}} = *${var} ]]
	then 	file="${@:${#}}"; set -- "${@:1:$((${#}-1))}";
	else 	printf "${BRED}Err: %s --${NC} %s\\n" 'Unknown audio format' "${1:-nill}" >&2
		return 1
	fi ;[[ -f $1 ]] && shift  #get rid of eventual second filename
	if var=$(wc -c <"$file"); ((var > 25000000));
	then 	du -h "$file" >&2;
		__warmsgf 'Warning:' "Whisper input exceeds API limit of 25MBytes";
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

	[[ -s $FILE ]] && mv -f -- "$FILE" "${FILE%.*}.2.${FILE##*.}";

	#response_format (timestamps) - testing
	if ((OPTW>1 || OPTWW>1)) && ((!CHAT_ENV))
	then
		OPTW_FMT=verbose_json   #json, text, srt, verbose_json, or vtt.
		[[ -n $OPTW_FMT ]] && set -- -F response_format="$OPTW_FMT" "$@"

		prompt_audiof "$file" $LANGW "$@" && {
		jq -r "${JQCOLNULL} ${JQCOL} ${JQDATE}
			\"Task: \(.task)\" +
			\"\\t\" + \"Lang: \(.language)\" +
			\"\\t\" + \"Dur: \(.duration|seconds_to_time_string)\" +
			\"\\n\", (.segments[]| \"[\" + yellow + \"\(.start|seconds_to_time_string)\" + reset + \"]\" +
			bpurple + .text + reset)" "$FILE" | foldf \
		|| jq -r 'if .segments then (.segments[] | (.start|tostring) + (.text//empty)) else (.text//empty) end' "$FILE" || ! cat -- "$FILE" >&2 ;}
	else
		prompt_audiof "$file" $LANGW "$@" && {
		jq -r "${JQCOLNULL} ${JQCOL} ${JQDATE}
		bpurple + (.text//empty) + reset" "$FILE" | foldf \
		|| jq -r '.text//empty' "$FILE" || ! cat -- "$FILE" >&2 ;}
	fi & pid=$! PIDS+=($!);
	trap "trap 'exit' INT; kill -- $pid 2>/dev/null;" INT;

	wait $pid; ret=$?; trap 'exit' INT; ((!ret)) &&
	if WHISPER_OUT=$(jq -r "${JQDATE} if .segments then (.segments[] | \"[\(.start|seconds_to_time_string)]\" + (.text//empty)) else (.text//empty) end" "$FILE" 2>/dev/null) &&
		((${#WHISPER_OUT}))
	then
		((!CHAT_ENV)) && [[ -d ${FILEWHISPERLOG%/*} ]] &&  #log output
		printf '\n====\n%s\n\n%s\n' "$(date -R 2>/dev/null||date)" "$WHISPER_OUT" >>"$FILEWHISPERLOG" &&
		_sysmsgf 'Whisper Log:' "$FILEWHISPERLOG";

		((OPTCLIP && !CHAT_ENV)) && (${CLIP_CMD:-false} <<<"$WHISPER_OUT" &);  #clipboard
		:;
	else 	false;
	fi || {
		{ [[ ! -s $FILE ]] && ! jq . "$FILE" >&2 2>/dev/null ;} && {
		__warmsgf $'\nerr:' 'whisper response'
		printf 'Retry request? Y/n ' >&2;
		case "$(__read_charf)" in
			[AaNnQq]) false;;  #no
			*) 	((rec)) && args+=("$FILEINW")
				whisperf "${args[@]}";;
		esac
		}
	}
}
#JQ function: seconds to compound time
JQDATE="def pad(x): tostring | (length | if . >= x then \"\" else \"0\" * (x - .) end) as \$padding | \"\(\$padding)\(.)\";
def seconds_to_time_string:
def nonzero: floor | if . > 0 then . else empty end;
if . == 0 then \"00\"
else
[(./60/60         | nonzero),
 (./60       % 60 | pad(2)),
 (.          % 60 | pad(2))]
| join(\":\")
end;"
#https://rosettacode.org/wiki/Convert_seconds_to_compound_duration#jq
#https://stackoverflow.com/questions/64957982/how-to-pad-numbers-with-jq

#request tts prompt
function prompt_ttsf
{
	curl -N -Ss --fail-with-body -L "${API_HOST}${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H 'Content-Type: application/json' \
		-d "$BLOCK" \
		-o "$FOUT"
}
#disable curl progress-bar because of `chunk transfer encoding'

#speech synthesis (tts)
function ttsf
{
	typeset FOUT VOICEZ SPEEDZ fname xinput input max ret pid var secs ok n m i
	((${#OPTZ_VOICE})) && VOICEZ=$OPTZ_VOICE
	((${#OPTZ_SPEED})) && SPEEDZ=$OPTZ_SPEED
	
	((${#})) || [[ ${ZARGS[*]} = $SPC ]] || set -- "${ZARGS[@]}" "$@";
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
	then 	n=0 m=0  #set a filename for output
		for fname in "${FILEOUT_TTS%.*}"*
		do 	fname=${fname##*/} fname=${fname%.*}
			fname=${fname%-*([0-9])} fname=${fname##*[!0-9]}
			((m>fname)) || ((m=fname+1)) 
		done
		FOUT="${FILEOUT_TTS%.*}${m}.${OPTZ_FMT}"
	fi

	xinput=$*; [[ ${MOD_SPEECH} = tts-1* ]] && max=4096 || max=40960;
	if ((!CHAT_ENV))
	then 	__sysmsgf 'Speech Model:' "$MOD_SPEECH";
		__sysmsgf 'Voice:' "$VOICEZ";
		__sysmsgf 'Speed:' "${SPEEDZ:-1}";
	fi; ((${#SPEEDZ})) && check_optrangef "$SPEEDZ" 0.25 4 'TTS speed'
	[[ $* != *([$IFS]) ]] || ! echo '(empty)' >&2 || return 2

	if ((${#xinput}>max))
	then 	__warmsgf 'Warning:' "User input ${#xinput} chars / max ${max} chars"  #max ~5 minutes
		i=1 FOUT=${FOUT%.*}-${i}.${OPTZ_FMT};
	fi  #https://help.openai.com/en/articles/8555505-tts-api
	REPLAY_FILES=();

	while input=${xinput:0: max};
	do
		if ((!CHAT_ENV))
		then 	var=${xinput//\\\\[nt]/  };
			_sysmsgf $'\nFile Out:' "${FOUT/"$HOME"/"~"}";
			__sysmsgf 'Text Prompt:' "${var:0: COLUMNS-17}$([[ -n ${xinput: COLUMNS-17} ]] && echo ...)";
		fi; REPLAY_FILES=("${REPLAY_FILES[@]}" "$FOUT"); var= ;
		
		BLOCK="{
\"model\": \"${MOD_SPEECH}\",
\"input\": \"${*}\",
\"voice\": \"${VOICEZ}\", ${SPEEDZ:+\"speed\": ${SPEEDZ},}
\"response_format\": \"${OPTZ_FMT}\"${BLOCK_USR_TTS:+,$NL}$BLOCK_USR_TTS
}"
		((OPTVV)) && __warmsgf "TTS:" "Model: ${MOD_SPEECH:-unset}, Voice: ${VOICEZ:-unset}, Speed: ${SPEEDZ:-unset}, Block: ${BLOCK}"
		_sysmsgf 'TTS:' '<ctr-c> [k]ill, <enter> play ' '';  #!#

		prompt_ttsf "${input:-$*}" &
		pid=$! secs=$SECONDS;
		trap "trap 'exit' INT; kill -- $pid 2>/dev/null; return;" INT;
		while __spinf; ok=
			kill -0 -- $pid  >/dev/null 2>&1 || ! echo >&2
		do 	var=$(NO_CLR=1 __read_charf -t 0.3) &&
			case "$var" in
				[Pp]|' '|''|$'\t')
					ok=1
					((SECONDS>secs+3)) ||
					__read_charf -t 1  >/dev/null 2>&1
					break 1;;
				[CcEeKkQqSs]|$'\e')
					ok=1
					kill -- $pid 2>/dev/null;
					break 1;;
			esac
		done </dev/tty; __clr_lineupf $((4+1+29+${#var}));  #!#
		((ok)) || wait $pid; ret=$?;
		trap 'exit' INT
		jq . "$FOUT" >&2 2>/dev/null && ret=1  #only if response is json

		case $ret in
			0|1[2-9][0-9]|2[0-5][0-9]) 	:;;
			[1-9]|[1-9][0-9]) 	break 1;;
			*) 	__warmsgf $'\rerr:' 'tts response'
				printf 'Retry request? Y/n ' >&2;
				case "$(__read_charf)" in
					[AaNnQq]) false;;  #no
					*) 	continue;;
				esac
		esac

	[[ $FOUT = "-"* ]] || [[ ! -e $FOUT ]] || { 
		du -h "$FOUT" 2>/dev/null || _sysmsgf 'TTS file:' "$FOUT"; 
		((OPTV)) || [[ ! -s $FOUT ]] || {
			((CHAT_ENV)) || __sysmsgf 'Play Cmd:' "\"${PLAY_CMD}\"";
			case "$PLAY_CMD" in false) 	return $ret;; esac;
		while 	${PLAY_CMD} "$FOUT" & pid=$! PIDS+=($!);
		do 	trap "trap 'exit' INT; kill -- $pid 2>/dev/null; case \"\$PLAY_CMD\" in *termux-media-player*) termux-media-player stop;; esac;" INT;
			wait $pid;
			case $? in
				0) 	case "$PLAY_CMD" in *termux-media-player*) while sleep 1 ;[[ $(termux-media-player info 2>/dev/null) = *[Pp]laying* ]] ;do : ;done;; esac;  #termux fix
					var=3;;  #3+1 secs
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
		xinput=${xinput: max};
		((${#xinput})) && ((!ret)) || break 1;
	}
	done;
	return $ret
}
function __set_ttsf { 	__set_outfmtf "$1" || __set_voicef "$1" || __set_speedf "$1" ;}
function __set_voicef
{
	case "$1" in
		#alloy|echo|fable|onyx|nova|shimmer
		[Aa][Ll][Ll][Oo][Yy]|[Ee][Cc][Hh][Oo]|[Ff][Aa][Bb][Ll][Ee]|[Oo][Nn][YyIi][Xx]|[Nn][Oo][Vv][Aa]|[Ss][Hh][Ii][Mm][Mm][Ee][Rr]) 	VOICEZ=$1;;
		*) 	false;;
	esac
}
function __set_outfmtf
{
	case "$1" in  #mp3|opus|aac|flac
		mp3|[Mm][Pp]3|[Oo][Pp][Uu][Ss]|[Aa][Aa][Cc]|[Ff][Ll][Aa][Cc]) 	OPTZ_FMT=$1;;
		*.[Mm][Pp]3|*.[Oo][Pp][Uu][Ss]|*.[Aa][Aa][Cc]|*.[Ff][Ll][Aa][Cc]) 	OPTZ_FMT=${1##*.} FILEOUT_TTS=$1;;
		*/) 	[[ -d $1 ]] && FILEOUT_TTS=${1%%/}/${FILEOUT_TTS##*/};;
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
	then 	block_x="\"model\": \"$MOD_IMAGE\", \"quality\": \"${OPTS_HD:-standard}\",";
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
	curl -\# ${OPTV:+-Ss} --fail-with-body -L "${API_HOST}${ENDPOINTS[EPN]}" \
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

	prompt_imgvarf "$@"
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

	if magick convert "$1" -background none -gravity center -extent 1:1 "${@:2}"
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
	typeset REPLY act_keys act_keys_n act zh a l n
	[[ "$INSTRUCTION" = %* ]] && FILEAWE="${FILEAWE%%.csv}-zh.csv" zh=1

	set -- "$(trimf "${INSTRUCTION##[/%]}" "*( )" )";
	set -- "${1// /_}";
	FILECHAT="${FILECHAT%/*}/awesome.tsv"
	_cmdmsgf 'Awesome Prompts' "$1"

	if [[ ! -s $FILEAWE ]] || [[ $1 = [/%]* ]]  #second slash
	then 	set -- "${1##[/%]}"
		if 	if ((zh))
			then 	! { curl -\#Lf "$AWEURLZH" \
				| jq '"act,prompt",(.[]|join(","))' \
				| sed 's/,/","/' >"$FILEAWE" ;}  #json to csv
			else 	! curl -\#Lf "$AWEURL" -o "$FILEAWE"
			fi
		then 	[[ -f $FILEAWE ]] && rm -- "$FILEAWE"
			return 1
		fi
	fi; set -- "${1:-%#}";

	#map prompts to indexes and get user selection
	act_keys=$(sed -e '1d; s/,.*//; s/^"//; s/"$//; s/""/\\"/g; s/[][()`*_]//g; s/ /_/g' "$FILEAWE")
	case "$1" in
		list*|ls*|+([./%*?-]))  #list awesome keys
			{ 	pr -T -t -n:3 -W $COLUMNS -$(( (COLUMNS/80)+1)) || cat ;} <<<"$act_keys" >&2;
			return 210;;
	esac

	act_keys_n=$(wc -l <<<"$act_keys")
	while ! { 	((act && act <= act_keys_n)) ;}
	do 	if ! act=$(grep -n -i -e "${1//[ _-]/[ _-]}" <<<"${act_keys}")
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
			done <<<"${act_keys}"
			printf '#? <enter> ' >&2
			__clr_ttystf; read -r -e act </dev/tty;
		fi ;set -- "$act"
	done

	INSTRUCTION=$(sed -n -e 's/^[^,]*,//; s/^"//; s/"$//; s/""/"/g' -e "$((act+1))p" "$FILEAWE")
	((CMD_CHAT)) ||
	if __clr_ttystf; ((OPTX))  #edit chosen awesome prompt
	then 	INSTRUCTION=$(ed_outf "$INSTRUCTION") || exit
		printf '%s\n\n' "$INSTRUCTION" >&2 ;
	else 	read_mainf -i "$INSTRUCTION" INSTRUCTION
		((OPTCTRD)) && INSTRUCTION=$(trim_trailf "$INSTRUCTION" $'*([\r])')
	fi </dev/tty
	if [[ -z $INSTRUCTION ]]
	then 	__warmsgf 'Err:' 'awesome-chatgpt-prompts fail'
		unset OPTAWE ;return 1
	fi
}

# Custom prompts
function custom_prf
{
	typeset file filechat name template list msg new skip ret
	filechat="$FILECHAT"
	FILECHAT="${FILECHAT%%.[Tt][SsXx][VvTt]}.pr"
	case "$INSTRUCTION" in  #lax syntax
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
		! file=$(SESSION_LIST=$list SGLOB='[Pp][Rr]' EXT='pr' \
			session_globf "$name")
	then 	template=1
		file=$(SGLOB='[Pp][Rr]' EXT='pr' \
			session_name_choosef "$name")
		[[ -f $file ]] && msg=${msg:-LOAD} || msg=CREATE
	fi
	((list)) && exit

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
	then 	REC_CMD='termux-microphone-record -c 1 -l 0 -f'
	elif command -v sox  #sox, best auto option
	then 	REC_CMD='sox -d'
	elif command -v arecord  #alsa utils
	then 	REC_CMD='arecord -i'
	elif command -v ffmpeg
	then 	REC_CMD='ffmpeg_recf'
	else 	REC_CMD='false'
	fi >/dev/null 2>&1
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
	typeset REPLY file glob sglob ext ok
	sglob="${SGLOB:-[Tt][Ss][Vv]}" ext="${EXT:-tsv}"

	[[ ! -f "$1" ]] || return
	case "$1" in
		[Nn]ew) 	return 2;;
		[Cc]urrent|.) 	set -- "${FILECHAT##*/}" "${@:2}";;
	esac

	cd -- "${CACHEDIR}"
	glob="${1%%.${sglob}}" glob="${glob##*/}"
	#input is exact filename, or ends with extension?
	[[ -f "${glob}".${ext} ]] || [[ "$1" = *?.${sglob} ]] \
	|| set -- *${glob}*.${sglob}  #set the glob
	
	if ((SESSION_LIST))
	then 	ls -- "$@" >&2 ;return
	fi

	if ((${#} >1)) && [[ "$glob" != *[$IFS]* ]]
	then 	__clr_ttystf;
		printf '# Pick file [.%s]:\n' "${ext}" >&2
		select file in 'current' 'new' 'abort' "${@%%.${sglob}}"
		do 	break
		done </dev/tty
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
	typeset fname new print_name sglob ext
	fname="$1" sglob="${SGLOB:-[Tt][Ss][Vv]}" ext="${EXT:-tsv}" 
	case "$fname" in [Nn]ew|*[N]ew.${sglob}) 	set --; fname= ;; esac
	while
		fname="${fname%%\/}"
		fname="${fname%%.${sglob}}"
		fname="${fname/\~\//"$HOME"\/}"
		
		if [[ -d "$fname" ]]
		then 	__warmsgf 'Err:' 'is a directory'
			fname="${fname%%/}"
		( 	cd "$fname" &&
			ls -- "${fname}"/*.${sglob} ) >&2 2>/dev/null
			shell_histf "${fname}${fname:+/}"
			unset fname
		fi

		if [[ ${fname} = *([$IFS]) ]]
		then 	[[ pr = ${sglob} ]] \
			&& _sysmsgf 'New prompt file name <enter/abort>:' \
			|| _sysmsgf 'New session name <enter/abort>:'
			__clr_ttystf; read -r -e -i "$fname" fname </dev/tty;
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
			_sysmsgf "Confirm${new}? [Y]es/[n]o/[a]bort:" "${print_name} " '' ''
			case "$(__read_charf)" in [AaQq]|$'\e') 	echo abort; echo abort >&2; return 201;; [NnOo]) 	:;; *) 	false;; esac
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
	[[ -s ${file:=$1} ]] || return; [[ $file = */* ]] || [[ ! -e "./$file" ]] || file="./$file";
	FILECHAT_OLD="$file" regex="$REGEX"
 
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
					string="${string##[\"]}" string="${string%%[\"]}"
					buff_end="${buff_end}"${buff_end:+$'\n'}"${string}"
				done <<<"${buff}"
			fi
			
			((${#buff})) && {
			  if ((${#buff_end}))
			  then 	((${#buff_end}>672)) && ((index=${#buff_end}-672)) || index= ;
				printf -- '===\n%s%s\n---\n' "${index:+[..]}" "$(_unescapef "${buff_end:${index:-0}}")" | foldf >&2;
			  fi
			  ((OPTPRINT)) && break 2;

			  if ((${regex:+1}))
			  then 	_sysmsgf "Right session?" '[Y/n/a] ' ''
			  else 	_sysmsgf "Tail of the right session?" '[Y]es, [n]o, [r]egex, [a]bort ' ''
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
	&& FILECHAT="${dest}" INSTRUCTION_OLD= INSTRUCTION= cmd_runf /break 2>/dev/null \
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
					typeset SGLOB='[Pp][Rr]' EXT='pr' name= msg=Prompts;;  #duplicates opt `-S .list` fun
				[Aa]ll|[Ee]verything|[Aa]nything|+([./*?-]))
					typeset SGLOB='*' EXT='*' name= msg=All;;
				[Tt][Ss][Vv]|[Ss]ession|[Ss]essions|*)
					name= msg=Sessions;;
			esac
			_cmdmsgf "$msg Files" $'list\n'
			session_listf "$name"; return 0
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
		if ((OPTRESUME==1))  #print snippet of tail session
		then 	((break)) || OPTPRINT=1 session_sub_printf "${file:-$FILECHAT}" >/dev/null
		else
		  [[ -f "$file" ]] &&
		    if ((break))  || {
			_sysmsgf 'Break session?' '[N/ys] ' ''
			case "$(__read_charf)" in [YySs]) 	:;; $'\e'|*) 	false ;;esac
			}
		    then 	FILECHAT="$file" cmd_runf /break
		    fi
		fi
	fi

	[[ ${file:-$FILECHAT} = "$FILECHAT" ]] && msg=Current || msg=Change;
       	FILECHAT="${file:-$FILECHAT}"; _sysmsgf "History $msg:" "${FILECHAT/"$HOME"/"~"}"$'\n';
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
			{ jq . "$FILE" || ! cat -- "$FILE" ;}; echo >&2;
			ollama show "$1" --modelfile  2>/dev/null;
		else 	{
			  printf '\nName\tFamily\tFormat\tParam\tQLvl\tSize\tModification\n'
			  curl -s -L "${OLLAMA_API_HOST}/api/tags" -o "$FILE" &&
			  { jq -r '.models[]|.name?+"\t"+(.details.family)?+"\t"+(.details.format)?+"\t"+(.details.parameter_size)?+"\t"+(.details.quantization_level)?+"\t"+((.size/1000000)|tostring)?+"MB\t"+.modified_at?' "$FILE" || ! cat -- "$FILE" ;}
			} | { 	column -t -s $'\t' 2>/dev/null || ! cat -- "$FILE" ;}  #tsv
		fi
	}
	ENDPOINTS[0]="/api/generate" ENDPOINTS[5]="/api/embeddings" ENDPOINTS[6]="/api/chat";
	((${#OLLAMA_API_HOST})) || OLLAMA_API_HOST="http://localhost:11434";
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER  #set placeholder as this field is required
	
	OLLAMA_API_HOST=${OLLAMA_API_HOST%%*([/$IFS])}; set_model_epnf "$MOD";
	_sysmsgf "OLLAMA URL / Endpoint:" "$OLLAMA_API_HOST${ENDPOINTS[EPN]}";
}

#host url / endpoint
function set_localaif
{
	[[ $OPENAI_API_HOST_STATIC != *([$IFS]) ]] && OPENAI_API_HOST=$OPENAI_API_HOST_STATIC;
	if [[ $OPENAI_API_HOST != *([$IFS]) ]] && LOCALAI=1 || ((OLLAMA))
	then
		API_HOST=${OPENAI_API_HOST%%*([/$IFS])};
		((OLLAMA+MISTRALAI)) ||
		function list_modelsf  #LocalAI only
		{
			if [[ $* = [Ii]nstall* ]]  #install a model
			then
				typeset response job_id block proc msg_old msg
				set -- "$*"; set -- "${1##[Ii]nstall$SPC}";
				if [[ $1 = *.yaml ]]
				then
					block="{\"url\": \"$1\"}";
				else
					[[ $1 = *@* ]] || set -- "huggingface@$1";
					block="{\"id\": \"$1\"}";
				fi; echo >&2;
				( trap 'printf "%s\\a\\n" " The job is still running server-side!" >&2; exit 1;' HUP QUIT KILL TERM INT;
				response=$(curl -\# -L -H "Content-Type: application/json" "${API_HOST}/models/apply" -d "$block")
				job_id=$(jq -r '.uuid' <<<"$response")
				while proc=$(curl -s -L "${API_HOST}/models/jobs/$job_id") && [[ -n $proc ]] || break
					[[ $(jq -r '.processed' <<<"$proc") != "true" ]]
				do
					msg=$(jq -r '"progress: "+.downloaded_size?+" / "+.file_size?+"\t"+(.progress|tostring)?+" %"' <<<"$proc");
					__clr_lineupf ${#msg_old}; printf '%s\n' "$msg" >&2; msg_old=$msg;
					sleep 1;
				done;
				jq -r '.error//empty,.message//empty,"Job completed"' <<<"$proc" >&2; )
			elif ((${#1}))
			then
				curl -\# -L "${API_HOST}/models/available" -o "$FILE" &&
				{ jq ".[] | select(.name | contains(\"$1\"))" "$FILE" || ! cat -- "$FILE" ;}
			else
				curl -\# -fL "${API_HOST}/models/available" -o "$FILE" &&
				{ jq -r '.[]|.gallery.name+"@"+(.name//empty)' "$FILE" || ! cat -- "$FILE" ;} ||
				! curl -\# -L "${API_HOST}/models/" | jq .
				#bug# https://github.com/mudler/LocalAI/issues/2045
			fi
		}  #https://localai.io/models/
		set_model_epnf "$MOD";
		#disable endpoint auto select?
		[[ $OPENAI_API_HOST_STATIC = *([$IFS]) ]] || unset ENDPOINTS;
		((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
		((!LOCALAI)) || _sysmsgf "HOST URL / Endpoint:" "${API_HOST}${ENDPOINTS[EPN]}${ENDPOINTS[*]:+ [auto-select]}";
	else 	false;
	fi
}

#ollama fun
function set_googleaif
{
	FILE_PRE="${FILE%%.json}.pre.json";
	GOOGLE_API_HOST="${GOOGLE_API_HOST:-https://generativelanguage.googleapis.com/v1beta}";
	: ${GOOGLE_API_KEY:?Required}
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER

	function list_modelsf
	{
		if [[ $* = $SPC1 ]]
		then 	curl -\# --fail-with-body -L "$GOOGLE_API_HOST/models?key=$GOOGLE_API_KEY" -o "$FILE"
		else 	curl -\# --fail-with-body -L "$GOOGLE_API_HOST/models/${1}?key=$GOOGLE_API_KEY" -o "$FILE"
		fi && {
		if ((OPTL>1))
		then 	jq . -- "$FILE";
		else 	jq -r '(.models|.[]?|.name|split("/")|.[1])//.' -- "$FILE";
		fi || cat -- "$FILE" ;};
	}
	function __promptf
	{
		typeset epn;
		epn='generateContent';
		((STREAM)) && epn='streamGenerateContent'; : >"$FILE_PRE";
		if curl "$@" --fail-with-body -L "$GOOGLE_API_HOST/models/$MOD:${epn}?key=$GOOGLE_API_KEY" \
			-H 'Content-Type: application/json' -X POST \
			-d "$BLOCK" | tee "$FILE_PRE" | sed -n 's/^ *"text":.*/{ & }/p'
		then 	[[ \ $*\  = *\ -s\ * ]] || __clr_lineupf;
		else 	false;
		fi
	}
	function embedf
	{
		curl --fail-with-body -L "$GOOGLE_API_HOST/models/$MOD:embedContent?key=$GOOGLE_API_KEY" \
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
			fi
		done;
		printf '%s\n'  ' ] }';
	}
}


#@#[[ ${BASH_SOURCE[0]} != "${0}" ]] && return 0;  #sourced file


unset OPTMM STOPS MAIN_LOOP
#parse opts
optstring="a:A:b:B:cCdeEfFgGhHikK:lL:m:M:n:N:p:qr:R:s:S:t:ToOuUvVxwWyYzZ0123456789@:/,:.:-:"
while getopts "$optstring" opt
do
	if [[ $opt = - ]]  #long options
	then 	for opt in api-key  multimodal  markdown  markdown:md  no-markdown \
			no-markdown:no-md   fold  fold:wrap  no-fold  no-fold:no-wrap \
			localai  localai:local-ai google google:goo  mistral  keep-alive \
			keep-alive:ka  @:alpha  M:max-tokens  M:max  N:mod-max  N:modmax \
			a:presence-penalty      a:presence   a:pre \
			A:frequency-penalty     A:frequency  A:freq \
			b:best-of   b:best      B:logprobs   c:chat \
			C:resume    C:resume    C:continue   C:cont  d:text \
			e:edit      E:exit      f:no-conf    g:stream \
			G:no-stream h:help      H:hist       i:image \
			'j:synthesi[sz]e'  j:synth 'J:synthesi[sz]e-voice' \
			J:synth-voice  'k:no-colo*' K:top-k  K:topk  l:list-model \
			l:list-models    L:log    m:model    m:mod  \
			n:results   o:clipboard o:clip  O:ollama \
			p:top-p  p:topp  q:insert  \
			r:restart-sequence  r:restart-seq  r:restart \
			R:start-sequence  R:start-seq  R:start \
			s:stop      S:instruction  t:temperature \
			t:temp      T:tiktoken   u:multiline  u:multi  U:cat \
			v:verbose   x:editor     X:media  w:transcribe w:stt \
			W:translate y:tik  Y:no-tik  z:tts  z:speech  Z:last
			#opt:long_name
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
			*) 	__warmsgf "Unkown option:" "--$OPTARG"
				exit 2;;
		esac ;unset name
	fi
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
		C) 	((++OPTRESUME)); MAIN_LOOP=2;;
		d) 	OPTCMPL=1;;
		e) 	OPTE=1;;
		E) 	OPTEXIT=1;;
		f$OPTF) unset EPN MOD MOD_CHAT MOD_AUDIO MOD_SPEECH MOD_IMAGE MODMAX INSTRUCTION OPTZ_VOICE OPTZ_SPEED OPTZ_FMT OPTC OPTI OPTLOG USRLOG OPTRESUME OPTCMPL MTURN CHAT_ENV OPTTIKTOKEN OPTTIK OPTYY OPTFF OPTK OPTKK OPT_KEEPALIVE OPTHH OPTL OPTMARG OPTMM OPTNN OPTMAX OPTA OPTAA OPTB OPTBB OPTN OPTP OPTT OPTV OPTVV OPTW OPTWW OPTZ OPTZZ OPTSTOP OPTCLIP CATPR OPTCTRD OPTMD OPT_AT_PC OPT_AT Q_TYPE A_TYPE RESTART START STOPS OPTSUFFIX SUFFIX CHATGPTRC CONFFILE REC_CMD PLAY_CMD CLIP_CMD STREAM MEDIA MEDIA_CMD MD_CMD OPTE OPTEXIT API_HOST OLLAMA MISTRALAI LOCALAI GPTCHATKEY READLINEOPT MULTIMODAL OPTFOLD;  #OLLAMA_API_HOST OPENAI_API_HOST OPENAI_API_HOST_STATIC CACHEDIR OUTDIR
			unset RED BRED YELLOW BYELLOW PURPLE BPURPLE ON_PURPLE CYAN BCYAN WHITE BWHITE INV ALERT BOLD NC;
			unset Color1 Color2 Color3 Color4 Color5 Color6 Color7 Color8 Color9 Color10 Color11 Color200 Inv Alert Bold Nc;
			OPTF=1 OPTIND=1 OPTARG= ;. "$0" "$@" ;exit;;
		F) 	((++OPTFF));;
		fold) 	OPTFOLD=1;;
		no-fold) 	unset OPTFOLD;;
		g) 	STREAM=1;;
		G) 	unset STREAM;;
		h) 	while read
			do 	[[ $REPLY = \#\ v* ]] && break
			done <"$0"
			printf '%s\n' "$REPLY" "$HELP"
			exit;;
		H) 	((++OPTHH));;
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
		markdown) 	OPTMD=1;
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
		O) 	OLLAMA=1 GOOGLEAI= MISTRALAI= ;;
		google) GOOGLEAI=1 OLLAMA= MISTRALAI= ;;
		mistral)
			[[ -z $MISTRAL_API_HOST ]] && MISTRAL_API_HOST="https://api.mistral.ai/";
			MISTRALAI=1 OLLAMA= GOOGLEAI= ;;
		localai)
			[[ -z $OPENAI_API_HOST$OPENAI_API_HOST_STATIC ]] && OPENAI_API_HOST="http://127.0.0.1:8080";
			LOCALAI=1;;
		p) 	OPTP="$OPTARG";;
		q) 	((++OPTSUFFIX)); EPN=0;;
		r) 	RESTART="$OPTARG";;
		R) 	START="$OPTARG";;
		s) 	STOPS=("$OPTARG" "${STOPS[@]}");;
		S|.|,) 	if [[ -f "$OPTARG" ]]
			then 	INSTRUCTION="${opt##S}$(<"$OPTARG")"
			else 	INSTRUCTION="${opt##S}$OPTARG"
			fi;;
		t) 	OPTT="$OPTARG";;
		T) 	((++OPTTIKTOKEN));;
		u) 	((OPTCTRD)) && unset OPTCTRD || OPTCTRD=1
			__cmdmsgf 'Prompter <Ctrl-D>' $(_onoff $OPTCTRD);;
		U) 	CATPR=1;;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		x) 	OPTX=1;;
		w) 	((++OPTW)); WSKIP=1;;
		W) 	((OPTW)) || OPTW=1 ;((++OPTWW)); WSKIP=1;;
		y) 	OPTTIK=1;;
		Y) 	OPTTIK= OPTYY=1;;
		z) 	OPTZ=1;;
		Z) 	OPTZZ=1;;
		\?) 	exit 1;;
	esac; OPTARG= ;
done
shift $((OPTIND -1))
unset LANGW MTURN CHAT_ENV SKIP EDIT INDEX HERR BAD_RES REPLY REGEX SGLOB EXT PIDS NO_CLR WARGS ZARGS WCHAT_C MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND SMALLEST DUMP init buff var n s
typeset -a PIDS MEDIA MEDIA_CMD MEDIA_IND MEDIA_CMD_IND WARGS ZARGS
typeset -l VOICEZ OPTZ_FMT  #lowercase vars

set -o ${READLINEOPT:-emacs}; 
bind 'set enable-bracketed-paste on';
bind '"\C-j": "\C-v\C-j"'  #CTRL-J for newline (instead of accept-line)
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

#mistral ai
if [[ $OPENAI_API_HOST = *mistral* ]] || ((MISTRALAI))
then 	[[ $MOD = *embed* ]] || OPTSUFFIX= OPTCMPL= OPTC=2;
fi

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
((OPTSUFFIX>1)) && MTURN=1 OPTSUFFIX=1      #multi-turn -q insert mode
((OPTI+OPTEMBED)) && ((OPTVV)) && OPTVV=2
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
	elif ((LOCALAI))
	then 	MOD=$MOD_LOCALAI
	elif ((!OPTCMPL))
	then 	if ((OPTC>1))  #chat
		then 	MOD=$MOD_CHAT
		elif ((OPTW)) && ((!MTURN))  #whisper endpoint
		then 	MOD=$MOD_AUDIO
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
	[[ -n $OPTS ]] && set_imgsizef "$OPTS";
	set_imgsizef "$1" && shift;
	unset STREAM arg n;
fi

#google integration
if ((GOOGLEAI))
then 	set_googleaif;
	unset OPTTIK OLLAMA MISTRALAI;
else 	unset GOOGLEAI;
fi

#ollama integration
if ((OLLAMA))
then 	set_ollamaf;
	unset GOOGLEAI MISTRALAI;
else  	unset OLLAMA OLLAMA_API_HOST;
fi

#custom host / localai
if [[ ${OPENAI_API_HOST_STATIC}${OPENAI_API_HOST} != *([$IFS]) ]]
then 	set_localaif;
else 	unset OPENAI_API_HOST OPENAI_API_HOST_STATIC;
fi

#mistral ai api
if [[ $OPENAI_API_HOST = *mistral* ]] || ((MISTRALAI))
then 	: ${MISTRAL_API_KEY:?Required}
	((${#OPENAI_API_KEY})) || OPENAI_API_KEY=$PLACEHOLDER
	unset LOCALAI OLLAMA GOOGLEAI; MISTRALAI=1;
	unset OPTA OPTAA OPTB;
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

#markdown rendering
if ((OPTMD+${#MD_CMD}))
then 	set_mdcmdf "$MD_CMD" && OPTMD=1;
fi

#stdin and stderr filepaths
if [[ -n $TERMUX_VERSION ]]
then 	STDIN='/proc/self/fd/0' STDERR='/proc/self/fd/2'
else 	STDIN='/dev/stdin'      STDERR='/dev/stderr'
fi

#load text file (last arg) and stdin
if ((OPTX)) && ((OPTEMBED+OPTI+OPTZ+OPTTIKTOKEN))
then
	((OPTEMBED+OPTI+OPTZ)) && ((${#})) && [[ -f ${@:${#}} ]] &&
	  is_txtfilef "${@:${#}}" && set -- "${@:1:${#}-1}" "$(<"${@:${#}}")";

	{ ((OPTI)) && ((${#})) && [[ -f ${@:${#}} ]] ;} ||
	  [[ -t 0 ]] || set -- "$@" "$(<$STDIN)";
	
	edf "$@" && set -- "$(<"$FILETXT")";
elif ! ((OPTTIKTOKEN+OPTI))
then
	! ((OPTW && !MTURN)) && ((${#})) && [[ -f ${@:${#}} ]] && 
	  is_txtfilef "${@:${#}}" && set -- "${@:1:${#}-1}" "$(<"${@:${#}}")";

	[[ -t 0 ]] || ((OPTZZ+OPTL+OPTFF+OPTHH)) || set -- "$@" "$(<$STDIN)";
fi

#tips and warnings
if ((!(OPTI+OPTL+OPTW+OPTZ+OPTZZ+OPTTIKTOKEN+OPTFF) )) && [[ $MOD != *moderation* ]]
then 	if ((!OPTHH))
	then 	__sysmsgf "Max Response / Capacity:" "$OPTMAX${OPTMAX_NILL:+${EPN6:+ - inf.}} / $MODMAX tkns"
		if ((${#})) && [[ ! -f $1 ]]
		then 	token_prevf "${INSTRUCTION}${INSTRUCTION:+ }${*}"
			__sysmsgf "Prompt:" "~$TKN_PREV tokens"
		fi
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
	do 	[[ ${arg:0:4} = -- ]] && argn=(${argn[@]} $n); ((++n));
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
	[[ ${WARGS[*]} = $SPC ]] && unset WARGS;
	[[ ${ZARGS[*]} = $SPC ]] && unset ZARGS;
	((${#WARGS[@]})) && ((${#ZARGS[@]})) && ((${#})) && {
	  var=$* p=${var:128} var=${var:0:128}; __cmdmsgf 'Text Prompt' "${var//\\\\[nt]/  }${p:+ [..]}" ;}
	((${#WARGS[@]})) && __cmdmsgf "Whisper Args #${#WARGS[@]}" "${WARGS[*]:-unset}"
	((${#ZARGS[@]})) && __cmdmsgf 'TTS Args' "${ZARGS[*]:-unset}";
	unset n p ii var arg argn;
fi

mkdir -p "$CACHEDIR" || { 	_sysmsgf 'Err:' "Cannot create cache directory -- \`${CACHEDIR/"$HOME"/"~"}'"; exit 1; }
if ! command -v jq >/dev/null 2>&1
then 	function jq { 	false ;}
	function escapef { 	_escapef "$@" ;}
	function unescapef { 	_unescapef "$@" ;}
	Color200=$INV __warmsgf 'Warning:' 'JQ not found. Please, install JQ.'
fi
command -v tac >/dev/null 2>&1 || function tac { 	tail -r "$@" ;}  #bsd

trap 'cleanupf; exit;' EXIT
trap 'exit' HUP QUIT KILL TERM

if ((OPTZZ))  #last response json
then 	lastjsonf;
elif ((OPTL))  #model list
then
	list_modelsf "$@";
elif ((OPTFF))
then 	if [[ -s "$CONFFILE" ]] && ((OPTFF<2))
	then 	__edf "$CONFFILE";
	else 	curl -f -L "https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/.chatgpt.conf";
		CONFFILE=stdout;
	fi; _sysmsgf 'Conf File:' "$CONFFILE";
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
	if [[ $INSTRUCTION = [.,]* ]]
	then 	custom_prf
	elif [[ $* != $SPC ]] && [[ $* != *($SPC)/* ]]
	then 	set -- /session"$@"
	fi
	session_mainf "${@}"

	if ((OPTHH>1))
	then 	((OPTC || EPN==6)) && OPTC=2
		((OPTC+OPTRESUME+OPTCMPL)) || OPTC=1
		Q_TYPE="\\n${Q_TYPE}" A_TYPE="\\n${A_TYPE}" \
		MODMAX=65536 OLLAMA= set_histf ''
		HIST=$(unescapef "$HIST")
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
	[[ -f $* ]] && [[ -t 0 ]] && exec 0<"$*" && set -- "-"  #exec max one file
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
	[[ ${WARGS[*]} = $SPC ]] || set -- "${WARGS[@]}" "$@";
	if [[ $1 = @(.|last) ]] && [[ -s $FILEINW ]]
	then 	set -- "$FILEINW" "${@:2}";
	elif ((${#} >1)) && [[ ${@:${#}} = @(.|last) ]] && [[ -s $FILEINW ]]
	then 	set -- "$FILEINW" "${@:1:${#}-1}";
	fi
	whisperf "$@" &&
	if ((OPTZ)) && WHISPER_OUT=$(jq -r "if .segments then (.segments[].text//empty) else (.text//empty) end" "$FILE" 2>/dev/null) &&
		((${#WHISPER_OUT}))
	then 	_sysmsgf $'\nText-To-Speech'; set -- ;
		MOD=$MOD_SPEECH; set_model_epnf "$MOD_SPEECH";
		[[ ${ZARGS[*]} = $SPC ]] || set -- "${ZARGS[@]}" "$@";
		ttsf "$@" "$(escapef "$WHISPER_OUT")";
	fi
elif ((OPTZ)) && ((!MTURN))  #speech synthesis
then 	[[ ${ZARGS[*]} = $SPC ]] || set -- "${ZARGS[@]}" "$@";
	ttsf "$@"
elif ((OPTII))     #image variations+edits
then 	if ((${#}>1))
	then 	__sysmsgf 'Image Edits'
	else 	__sysmsgf 'Image Variations' ;fi
	if [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	__sysmsgf 'Image Size / Quality:' "${OPTS:-err} / ${OPTS_HD:-standard}"
	else 	__sysmsgf 'Image Size:' "${OPTS:-err}"
	fi
	imgvarf "$@"
elif ((OPTI))      #image generations
then 	__sysmsgf 'Image Generations'
	__sysmsgf 'Image Model:' "$MOD_IMAGE"
	if [[ $MOD_IMAGE = *dall-e*[3-9] ]]
	then 	__sysmsgf 'Image Size / Quality:' "${OPTS:-err} / ${OPTS_HD:-standard}"
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
	CHAT_ENV=1; ((OPTW)) && unset OPTX;

	#custom / awesome prompts
	if [[ $INSTRUCTION = [/%.,]* ]]
	then 	if [[ $INSTRUCTION = [/%]* ]]
		then 	OPTAWE=1 ;((OPTC)) || OPTC=1 OPTCMPL=
			awesomef || case $? in 	210) exit 0;; 	*) exit 1;; esac
			_sysmsgf $'\nHist   File:' "${FILECHAT}"
			if ((OPTRESUME==1))
			then 	unset OPTAWE
			elif ((!${#}))
			then 	unset REPLY
				printf '\nAwesome INSTRUCTION set!\a\nPress <enter> to request, or append user prompt: ' >&2
				case "$(__read_charf)" in 	?) SKIP=1 EDIT=1 OPTAWE= ;; 	*) JUMP=1;; esac
			fi
		else 	custom_prf "$@"
			case $? in
				200) 	set -- ;;  #create, read and clear pos args
				[1-9]*|[!0]*) exit $? ;;  #err
			esac
		fi
	fi

	#text/chat completions
	if ((OPTC))
	then 	__sysmsgf 'Chat Completions'
		#chatbot must sound like a human, shouldnt be lobotomised
		#presencePenalty:0.6 temp:0.9 maxTkns:150
		#frequencyPenalty:0.5 temp:0.5 top_p:0.3 maxTkns:60 :Marv is a chatbot that reluctantly answers questions with sarcastic responses:
		OPTA="${OPTA:-0.6}" OPTT="${OPTT:-0.8}"  #!#
		STOPS+=("${Q_TYPE//$SPC1}" "${A_TYPE//$SPC1}")
		((MISTRALAI)) && unset OPTA
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

	#session cmds
	if [[ $1 = /?* ]] && [[ ! -f "$1" && ! -d "$1" ]]
	then 	case "$1" in
			/?| //? | /?(/)@(session|list|ls|fork|sub|grep|copy|cp) )
				session_mainf "$1" "${@:2:1}" && set -- "${@:3}";;
			*) 	session_mainf "$1" && set -- "${@:2}";;
		esac
	fi

	#model instruction
	INSTRUCTION_OLD="$INSTRUCTION"
	((OPTRESUME)) && [[ $(tail -n 1 "$FILECHAT") = *[Bb][Rr][Ee][Aa][Kk] ]] && sed -i -e '$d' "$FILECHAT";
	if ((MTURN+OPTRESUME))
	then 	INSTRUCTION=$(trim_leadf "$INSTRUCTION" "$SPC:$SPC")
		shell_histf "$INSTRUCTION"
		((OPTC)) && INSTRUCTION="${INSTRUCTION:-$INSTRUCTION_CHAT}"
		if ((OPTC && OPTRESUME)) || ((OPTCMPL==1 || OPTRESUME==1))
		then 	unset INSTRUCTION
		else 	break_sessionf
		fi
		INSTRUCTION_OLD="$INSTRUCTION"
	elif [[ $INSTRUCTION = *([:$IFS]) ]]
	then 	unset INSTRUCTION
	fi
	if [[ $INSTRUCTION != *([:$IFS]) ]]
	then 	_sysmsgf 'INSTRUCTION:' "$INSTRUCTION" 2>&1 | foldf >&2;
		((GOOGLEAI)) && GINSTRUCTION=$INSTRUCTION INSTRUCTION=;
	fi

	#warnings and tips
	((OPTCTRD)) && __warmsgf '*' '<Ctrl-V> + <Ctrl-J> for newline * '
	((OPTCTRD+CATPR)) && __warmsgf '*' '<Ctrl-D> to flush input * '
	echo >&2  #!#

	if ((MTURN))  #chat mode (multi-turn, interactive)
	then 	history -c; history -r; history -w;  #prune & fix history file
		[[ -s $HISTFILE ]] &&
		case "$BASH_VERSION" in  #avoid bash4 hanging
			[0-3]*|4.[01]*) 	:;;
			*) 	REPLY_OLD=$(trim_leadf "$(fc -ln -1 | cut -c1-1000)" "*([$IFS])");;
		esac
		shell_histf "$*";
	fi
	cmd_runf "$@" && set -- ;
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
				200) 	continue;;  #redo
				201) 	set --; false;;   #abort
				*) 	while [[ -f $FILETXT ]] && REPLY=$(<"$FILETXT"); echo >&2;
						(($(wc -l <<<"$REPLY") < LINES-1)) || echo '[..]' >&2;
						printf "${BRED}${REPLY:+${NC}${BCYAN}}%s${NC}\\n" "${REPLY:-(EMPTY)}" | tail -n $((LINES-2))
					do 	((OPTV)) || new_prompt_confirmf
						case $? in
							201) 	set --; break 1;;  #abort
							200) 	continue 2;;  #redo
							19[6789]) 	edf "${REPLY:-$*}" || break 1;;  #edit
							0) 	set -- "$REPLY" ; break;;  #yes
							*) 	set -- ; break;;  #no
						esac
					done;
					((OPTX>1)) && unset OPTX;
			esac
		fi

		((JUMP)) ||
		#defaults prompter
		if [[ "$* " = @("${Q_TYPE##$SPC1}"|"${RESTART##$SPC1}")$SPC ]] || [[ "$*" = $SPC ]]
		then 	((OPTC)) && Q="${RESTART:-${Q_TYPE:-> }}" || Q="${RESTART:-> }"
			B=$(_unescapef "${Q:0:320}") B=${B##*$'\n'} B=${B//?/\\b}  #backspaces

			while ((SKIP)) ||
				printf "${CYAN}${Q}${B}${NC}${OPTW:+${PURPLE}VOICE: }${NC}" >&2
				printf "${BCYAN}${OPTW:+${NC}${BPURPLE}}" >&2
			do
				((SKIP+OPTW+${#RESTART})) && echo >&2
				if ((OPTW && !EDIT)) || ((RESUBW))
				then 	#auto sleep 3-6 words/sec
					((OPTV)) && ((!WSKIP)) && __read_charf -t $((SLEEP_WORDS/3))  &>/dev/null
					
					((RESUBW)) || record_confirmf
					case $? in
						0) 	if ((RESUBW)) || recordf "$FILEINW"
							then 	REPLY=$(
								set --; MOD=$MOD_AUDIO OPTT=0 JQCOL= JQCOL2= ;
								[[ ${WARGS[*]} = $SPC ]] || set -- "${WARGS[@]}" "$@";
								whisperf "$FILEINW" "$@";
							)
							else 	case $? in
									196) 	unset WSKIP OPTW REPLY; continue 1;;
									199) 	EDIT=1; continue 1;;
								esac;
								echo record abort >&2;
							fi;;
						196) 	unset WSKIP OPTW REPLY; continue 1;;  #whisper off
						199) 	EDIT=1; continue 1;;  #text edit
						*) 	unset REPLY; continue 1;;
					esac; unset RESUBW;
					printf "\\n${NC}${BPURPLE}%s${NC}\\n" "${REPLY:-"(EMPTY)"}" | foldf >&2;
				else

					if ((OPTCMPL)) && ((MAIN_LOOP || OPTCMPL==1)) \
						&& ((EPN!=6)) && [[ -z "${RESTART}${REPLY}" ]]
					then 	REPLY=" " EDIT=1  #txt cmpls: start with space?
					fi;
					((EDIT)) || unset REPLY  #!#

					__clr_ttystf;
					if ((CATPR)) && ((!EDIT))
					then 	REPLY=$(cat);
					else 	read_mainf ${REPLY:+-i "$REPLY"} REPLY;
					fi </dev/tty
					((OPTCTRD+CATPR)) && REPLY=$(trim_trailf "$REPLY" $'*([\r])') && echo >&2
				fi; printf "${NC}" >&2;
				
				if [[ $REPLY = *\\ ]]
				then 	printf '\n%s\n' '---' >&2
					EDIT=1 SKIP=1; ((OPTCTRD))||OPTCTRD=2
					REPLY=$(trim_trailf "$REPLY" "*(\\)")$'\n'
					set --; continue;
				elif [[ $REPLY = /cat*([$IFS]) ]]
				then 	((CATPR)) || CATPR=2 ;REPLY= SKIP=1
					((CATPR==2)) && __cmdmsgf 'Cat Prompter' "one-shot"
					set -- ;continue  #A#
				elif cmd_runf "$REPLY"
				then 	shell_histf "$REPLY"
					if ((REGEN>0))
					then 	REPLY="${REPLY_OLD:-$REPLY}"
					else 	((SKIP)) || REPLY=
					fi; set --; continue 2
				elif ((${#REPLY}>320)) && ind=$((${#REPLY}-320)) || ind=0
					[[ ${REPLY: ind} = */ ]]  #preview / regen cmds
				then
					((RETRY)) && [[ $REPLY_OLD != "$REPLY" ]] && 
					  prev_tohistf "$(escapef "$REPLY_OLD")"
					[[ $REPLY = *([$IFS])/* ]] && REPLY="${REPLY_OLD:-$REPLY}"  #regen cmd integration
					[[ $REPLY = */*([$IFS]) ]] && REPLY=$(SMALLEST=1 INDEX=16 trim_trailf "$REPLY" $'\/*')
					REPLY_OLD=$REPLY RETRY=1 BCYAN="${Color8}"
				elif [[ -n $REPLY ]]
				then
					((RETRY+OPTV)) || [[ $REPLY = $SPC:* ]] \
					|| new_prompt_confirmf ed whisper
					case $? in
						201) 	break 2;;  #abort
						200) 	WSKIP=1; printf '\n%s\n' '--- redo ---' >&2; continue;;  #redo
						199) 	WSKIP=1 EDIT=1; printf '\n%s\n' '--- edit ---' >&2; continue;;  #edit
						198) 	((OPTX)) || OPTX=2
							((OPTX==2)) && printf '\n%s\n' '--- text editor one-shot ---' >&2
							set -- ;continue 2;;
						197) 	EDIT=1 SKIP=1; ((OPTCTRD))||OPTCTRD=2
							((OPTCTRD==2)) && printf '\n%s\n' '--- prompter <ctr-d> one-shot ---' >&2
							REPLY="$REPLY"$'\n'; set -- ;continue;;  #multiline one-shot  #A#
						196) 	WSKIP=1 EDIT=1 OPTW= ; continue 2;;  #whisper off
						0) 	:;;  #yes
						*) 	unset REPLY; set -- ;break;;  #no
					esac

					if ((RETRY))
					then 	if [[ "$REPLY" = "$REPLY_OLD" ]]
						then 	RETRY=2 BCYAN="${Color9}"
						else 	#record prev resp
							prev_tohistf "$(escapef "$REPLY_OLD")"
						fi ;REPLY_OLD="$REPLY"
					fi
				else
					set --
				fi ;set -- "$REPLY"
				((OPTCTRD==1)) || unset OPTCTRD
				((CATPR==1)) || unset CATPR
				unset WSKIP SKIP EDIT B Q ind
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

			if ((RETRY!=1))
			then 	shell_histf "$*"
				history -a
			fi

			#system/instruction?
			if [[ ${*} = $SPC:* ]]
			then
				var=$(escapef "$( trim_leadf "$*" "$SPC:" )")

				if [[ ${*} = $SPC:::* ]] &&  #append (text cmpls) 
				{ 	((EPN!=6)) || ! var=${var:1} ;}
				then
					p=$(hist_lastlinef) q=${var:2}  #user feedback
					n=$((COLUMNS-19>30 ? (COLUMNS-19)/2 : 30/2))
					((${#p}>n)) && p=${p:${#p}-n+1} pp=".."
					((${#q}>n)) && q=${q:0: n}      qq=".."
					_sysmsgf $'\nText appended:' "$(printf "${NC}${CYAN}%s${BCYAN}%s${NC}" "${pp}${p}" "${q}${qq}")"
				elif [[ ${*} = $SPC::* ]]
				then
					_sysmsgf 'System prompt added'
					((${#INSTRUCTION_OLD})) || INSTRUCTION_OLD=${INSTRUCTION:-${GINSTRUCTION:-${var:1}}}
				else
					var=${Q_TYPE##$SPC1}${var}
					_sysmsgf 'User prompt added'
				fi
				if ((GOOGLEAI))
				then 	GINSERT=${GINSERT}${var##?("${Q_TYPE##$SPC1}")*(:)}${NL}${NL};
				else 	INSTRUCTION_OLD=${INSTRUCTION:-$INSTRUCTION_OLD} INSTRUCTION=${var};
				fi
				unset EDIT SKIP REPLY REPLY_OLD p q n pp qq var;
				set --; continue;
			fi
			((${#GINSERT})) && { 	set -- "${GINSERT}${*}"; REPLY=${GINSERT}${REPLY}; unset GINSERT ;}
			REC_OUT="${Q_TYPE##$SPC1}${*}"
		fi

		#vision
		if is_visionf "$MOD"
		then 	((${#}<2)) || set -- "$*";
			_mediachatf "$1";
			#((TRUNC_IND)) && REPLY_OLD=$* && set -- "${1:0:${#1}-TRUNC_IND}";
			((MTURN)) &&
			for var in "${MEDIA_CMD[@]}"
			do 	REC_OUT="$REC_OUT| $var" REPLY="$REPLY| $var";
				set -- "$*| $var";
			done; unset var;
		#insert mode option
		elif ((OPTSUFFIX)) && [[ "$*" = *"${I_TYPE}"* ]]
		then 	if ((EPN!=6))
			then 	i=${I_TYPE//\[/\\[} i=${i//\]/\\]}
				SUFFIX=$(sed "\$s/^.*${i}//" <<<"$*")
				set -- "$(sed "\$s/${i}.*//" <<<"$*")"; unset i;
				#SUFFIX="${*##*"${I_TYPE}"}"; set -- "${*%%"${I_TYPE}"*}"
			else 	__warmsgf "Err: Insert mode:" "wrong endpoint (chat cmpls)"
			fi;
			REC_OUT="${REC_OUT:0:${#REC_OUT}-${#SUFFIX}-${#I_TYPE}}"
		else 	unset SUFFIX
		fi

		if ((RETRY<2))
		then 	((MTURN+OPTRESUME)) &&
			if ((EPN==6)); then 	set_histf "${*}"; else 	set_histf "${Q_TYPE}${*}"; fi
			((MAIN_LOOP||TOTAL_OLD)) || TOTAL_OLD=$(__tiktokenf "${INSTRUCTION:-$GINSTRUCTION}")
			if ((OPTC)) || [[ -n "${RESTART}" ]]
			then 	rest="${RESTART:-$Q_TYPE}"
				((OPTC && EPN==0)) && [[ ${HIST:+x}$rest = \\n* ]] && rest=${rest:2}  #!#del \n at start of string
			fi
			((JUMP)) && set -- && unset rest
			ESC="${HIST}${rest}$(escapef "${*}")"
			ESC="$(escapef "${INSTRUCTION:-$GINSTRUCTION}")${INSTRUCTION:+\\n\\n}${GINSTRUCTION:+\\n\\n}$(INDEX=16 trim_leadf "$ESC" "\\n")"
			
			if ((EPN==6))
			then 	#chat cmpls
				[[ ${*} = *([$IFS]):* ]] && role=system || role=user
				((GOOGLEAI)) &&  #gemini-vision cannot take it multiturn
				if { (( (REGEN<0 || RETRY) && MAIN_LOOP<1)) && ((${#INSTRUCTION_OLD})) ;} || is_visionf "$MOD"
				then 	HIST_G=${HIST}${HIST:+\\n\\n} HIST_C= ;
					((${#MEDIA[@]}+${#MEDIA_CMD[@]})) ||
					MEDIA=("${MEDIA_IND[@]}") MEDIA_CMD=("${MEDIA_CMD_IND[@]}");
				fi
				set -- "$(unset MEDIA MEDIA_CMD;
				  fmt_ccf "$(escapef "$INSTRUCTION")" system;
				  )${INSTRUCTION:+,${NL}}${HIST_C}${HIST_C:+,${NL}}$(
				  fmt_ccf "${HIST_G}$(escapef "${GINSTRUCTION}${GINSTRUCTION:+$NL$NL}${*}")" "$role")";
			else 	#text cmpls
				if { 	((OPTC)) || [[ -n "${START}" ]] ;} && ((JUMP<2))
				then 	set -- "${ESC}${START:-$A_TYPE}"
				else 	set -- "${ESC}"
				fi
			fi; unset rest role;
			
			#((REGEN || RETRY)) ||
			for media in "${MEDIA_IND[@]}" "${MEDIA_CMD_IND[@]}"
			do 	((media_i++));
				[[ -f $media ]] && media=$(du -h -- "$media" 2>/dev/null||du -- "$media") media=${media//$'\t'/ };
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
  \"temperature\": $OPTT,
  $OPTA_OPT $OPTAA_OPT $OPTP_OPT $OPTKK_OPT
  $OPTB_OPT $OPTBB_OPT $OPTSTOP
  \"num_ctx\": $MODMAX${BLOCK_USR:+,$NL}$BLOCK_USR
  }
}"
		else
			BLOCK="{
$BLOCK $OPTSUFFIX_OPT
$( ((OPTMAX_NILL && EPN==6)) || echo "\"max_tokens\": $OPTMAX," )
$STREAM_OPT $OPTA_OPT $OPTAA_OPT $OPTP_OPT $OPTKK_OPT
$OPTB_OPT $OPTBB_OPT $OPTSTOP
$( ((MISTRALAI)) || echo "\"n\": $OPTN," ) \
$( ((MISTRALAI+LOCALAI)) || ((!STREAM)) || echo "\"stream_options\": {\"include_usage\": true}," )
\"model\": \"$MOD\", \"temperature\": $OPTT${BLOCK_USR:+,$NL}$BLOCK_USR
}"
		fi

		#response colours for jq
		if ((RETRY==1))
		then 	((OPTK)) || JQCOL2='def byellow: yellow;'
		else 	unset JQCOL2
		fi; ((OPTC)) && echo >&2

		#request and response prompts
		SECONDS_REQ=$SECONDS;
		((${#START})) && printf "${YELLOW}%b\\n" "$START" >&2;
		((OLLAMA)) && api_host=$API_HOST API_HOST=$OLLAMA_API_HOST;

		if ((${#BLOCK}>96000))  #96KB #https://stackoverflow.com/questions/19354870/bash-command-line-and-input-limit
		then 	buff="${FILE%.*}.block.json"
			printf '%s\n' "$BLOCK" >"$buff"
			BLOCK="@${buff}" promptf
		else 	promptf
		fi; RET_PRF=$?;

		((OLLAMA)) && API_HOST=$api_host;
		unset buff api_host;
		((STREAM)) && ((MTURN || EPN==6)) && echo >&2;
		(( (RET_PRF>120 && !STREAM) || RETRY==1)) && { 	SKIP=1 EDIT=1; set --; continue ;}  #B#
		((RET_PRF>120)) && INT_RES='#'; REPLY_OLD="${REPLY:-$*}";

		#record to hist file
		if 	if ((STREAM))  #no token information in response
			then 	ans=$(prompt_pf -r -j "$FILE"; echo x) ans=${ans:0:${#ans}-1}
				ans=$(escapef "$ans")
				((LOCALAI+OLLAMA+GOOGLEAI+MISTRALAI)) ||
				tkn=( $(jq -s '.[-1]' "$FILE" | jq -r '.usage.prompt_tokens//empty,
					.usage.completion_tokens//empty,
					(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))') )  #https://community.openai.com/t/usage-stats-now-available-when-using-streaming-with-the-chat-completions-api-or-completions-api/738156
				((${#tkn[@]}>2)) || ((OLLAMA)) || {
				  tkn_ans=$( ((EPN==6)) && unset A_TYPE; __tiktokenf "${A_TYPE}${ans}");
				  ((tkn_ans+=TKN_ADJ)); ((MAX_PREV+=tkn_ans)); unset TOTAL_OLD tkn;
				}
			else
				((OLLAMA)) ||
				tkn=($(jq -r '.usage.prompt_tokens//"0",
					.usage.completion_tokens//"0",
					(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE") )
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

			if [[ -z "$ans" ]] && ((RET_PRF<120)) && ((!(LOCALAI+OLLAMA+GOOGLEAI) ))
			then 	jq -e '(.error?)//(.[]?|.error?)//.' "$FILE" >&2 || ! cat -- "$FILE" >&2 || ((!GOOGLEAI)) || jq . "$FILE_PRE" >&2 2>/dev/null;
				__warmsgf "(response empty)"
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
				fi  #adjust context err
			fi;
			unset BAD_RES PSKIP ESC_OLD;
			((${#tkn[@]}>2 || STREAM)) && ((${#ans})) && ((MTURN+OPTRESUME))
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
				tkn[1]=$( ((EPN==6)) && unset A_TYPE;
					__tiktokenf "${A_TYPE}${ans}");
			fi
			ans="${A_TYPE##$SPC1}${ans}"
			((${#SUFFIX})) && ans=${ans}${SUFFIX}
			((${#INSTRUCTION}+${#GINSTRUCTION})) && push_tohistf "$(escapef ":${INSTRUCTION:-$GINSTRUCTION}")" $( ((MAIN_LOOP)) || echo $TOTAL_OLD )
			((OPTAWE)) ||
			push_tohistf "$(escapef "$REC_OUT")" "$(( (tkn[0]-TOTAL_OLD)>0 ? (tkn[0]-TOTAL_OLD) : 0 ))" "${tkn[2]}"
			push_tohistf "$ans" "${tkn[1]:-$tkn_ans}" "${tkn[2]}" || unset OPTC OPTRESUME OPTCMPL MTURN
			
			((TOTAL_OLD=tkn[0]+tkn[1])) && MAX_PREV=$TOTAL_OLD
			unset HIST_TIME
		elif ((MTURN))
		then
			BAD_RES=1 SKIP=1 EDIT=1; unset CKSUM_OLD PSKIP JUMP REGEN INT_RES MEDIA  MEDIA_IND  MEDIA_CMD_IND;
			((OPTX)) && __read_charf >/dev/null
			set -- ;continue
		fi;
		((MEDIA_IND_LAST = ${#MEDIA_IND[@]} + ${#MEDIA_CMD_IND[@]}));
		unset MEDIA  MEDIA_CMD  MEDIA_IND  MEDIA_CMD_IND INT_RES GINSTRUCTION HIST_G REGEN;

		((OPTLOG)) && (usr_logf "$(unescapef "${ESC}\\n${ans}")" > "$USRLOG" &)
		((RET_PRF>120)) && { 	SKIP=1 EDIT=1; set --; continue ;}  #B# record whatever has been received by streaming
		
		if ((OLLAMA))  #token generation rate  #0 tokens, #1 secs, #2 rate
		then 	TKN_RATE=( "${tkn[1]}" "$(printf '%.2f' "${tkn[3]}")" "$(printf '%.2f' "${tkn[4]}")" )
		elif 	[[ ${tkn[1]:-$tkn_ans} = *[1-9]* ]]
		then 	((SECONDS==SECONDS_REQ)) && ((--SECONDS_REQ));
			TKN_RATE=( "${tkn[1]:-$tkn_ans}" $((SECONDS-SECONDS_REQ))
			"$(bc <<<"scale=2; ${tkn[1]:-${tkn_ans:-0}} / ($SECONDS-$SECONDS_REQ)")" )
		fi

		if ((OPTW)) && ((!OPTZ))
		then
			SLEEP_WORDS=$(wc -w <<<"${ans}");
			((STREAM)) && ((SLEEP_WORDS=(SLEEP_WORDS*2)/3));
			((++SLEEP_WORDS));
		elif ((OPTZ))
		then
			trap '' INT;
			OPTV= MOD=$MOD_SPEECH EPN=10 \
			ttsf "${ZARGS[@]}" "${ans##"${A_TYPE##$SPC1}"}";
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
		unset INSTRUCTION GINSTRUCTION HIST_G REGEN OPTRESUME TKN_PREV REC_OUT HIST HIST_C SKIP PSKIP WSKIP JUMP EDIT REPLY STREAM_OPT OPTA_OPT OPTAA_OPT OPTP_OPT OPTB_OPT OPTBB_OPT OPTSUFFIX_OPT SUFFIX OPTAWE RETRY BAD_RES INT_RES ESC RET_PRF Q
		unset role rest tkn tkn_ans ans buff glob out var pid s n
		((MTURN && !OPTEXIT)) || break
	done
fi

# Notes:
# - Debug command performance by line in Bash:
## set -x; shopt -s extdebug; PS4='$EPOCHREALTIME:$LINENO: '
## shellcheck -S warning -e SC2034,SC1007,SC2207,SC2199,SC2145,SC2027,SC1007,SC2254,SC2046,SC2124,SC2209,SC1090,SC2164,SC2053,SC1075,SC2068,SC2206,SC1078  ~/bin/chatgpt.sh
# - <https://help.openai.com/en/articles/6654000>
# - Dall-e-3 trick: "I NEED to test how the tool works with extremely simple prompts. DO NOT add any detail, just use it AS-IS: [very detailed prompt]"
# - The number of tokens in streaming, may be had counting how many JSON objects received

# vim=syntax sync minlines=1200
