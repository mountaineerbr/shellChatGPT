#!/usr/bin/env zsh
# chatgpt.sh -- Ksh93/Bash/Zsh  ChatGPT/DALL-E/Whisper Shell Wrapper
# v0.7.14  2023  by mountaineerbr  GPL+3
[[ -n $BASH_VERSION ]] && shopt -s extglob
[[ -n $ZSH_VERSION  ]] && setopt NO_SH_GLOB KSH_GLOB KSH_ARRAYS SH_WORD_SPLIT GLOB_SUBST NO_NOMATCH NO_POSIX_BUILTINS

# OpenAI API key
#OPENAI_KEY=

# DEFAULTS
# General model
#MOD=text-davinci-003
# Chat model
#MOD_CHAT=gpt-3.5-turbo
# Audio model
#MOD_AUDIO=whisper-1
# Temperature
OPTT=0
# Top_p probability mass (nucleus sampling)
#OPTP=1
# Maximum tokens
OPTMM=1024
# Presence penalty
#OPTA=
# Frequency penalty
#OPTAA=
# Number of responses
OPTN=1
# Image size
OPTS=512x512
# Image format
OPTI_FMT=b64_json  #url
# Minify JSON request
#OPTMINI=

# INSTRUCTION
# Text and chat completions, and edits endpoints
#INSTRUCTION="The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly."

# CHATBOT INTERLOCUTORS
Q_TYPE=Q
A_TYPE=A

# CACHE AND OUTPUT DIRECTORIES
CONFFILE="$HOME/.chatgpt.conf"
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/chatgptsh"
OUTDIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"


# Load user defaults
((OPTF)) || { 	[[ -e "${CHATGPTRC:-$CONFFILE}" ]] && . "${CHATGPTRC:-$CONFFILE}" ;}
INSTRUCTION="${INSTRUCTION:-$CHATINSTR}"  #deprecate envar

# Set file paths
FILE="${CACHEDIR%/}/chatgpt.json"
FILECHAT="${CACHEDIR%/}/chatgpt.tsv"
FILETXT="${CACHEDIR%/}/chatgpt.txt"
FILEOUT="${OUTDIR%/}/dalle_out.png"
FILEIN="${CACHEDIR%/}/dalle_in.png"
FILEINW="${CACHEDIR%/}/whisper_in.mp3"
USRLOG="${OUTDIR%/}/${FILETXT##*/}"

#obs: $OPTM and $EPN ought to be unset and nought for default array index.

MAN="NAME
	${0##*/} -- ChatGPT / DALL-E / Whisper  Shell Wrapper


SYNOPSIS
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTION] [INPUT]
	${0##*/} -e [opt] [INSTRUCTION] [INPUT]
	${0##*/} -i [opt] [S|M|L] [PROMPT]
	${0##*/} -i [opt] [S|M|L] [INPUT_PNG_PATH]
	${0##*/} -l [MODEL_NAME]
	${0##*/} -w [opt] [AUDIO_FILE] [LANG] [PROMPT-LANG]
	${0##*/} -W [opt] [AUDIO_FILE] [PROMPT-EN]
	${0##*/} -ccw [opt] [LANG]
	${0##*/} -ccW [opt]


	All positional arguments are read as a single PROMPT. If the
	chosen model requires an INSTRUCTION and INPUT prompts, first
	positional argument is taken as INSTRUCTION and the following
	ones as INPUT or PROMPT.

	Set option -c to start the chatbot via the text completion
	endpoint and record the conversation. This option accepts various
	models, defaults to \`text-davinci-003' if none set.
	
	Set option -cc to start the chatbot via the chat endpoint and
	use the turbo models.

	Set -C (with -cc) to resume from last history session.

	Option -e sets the \`edits' endpoint. That endpoint requires
	both INSTRUCTION and INPUT prompts. This option requires
	setting an \`edits model'.

	Option -i generates images according to PROMPT. If first
	positional argument is a picture file, then generate variation
	of it. A size of output image may se set, such as S, M or L.

	Option -w transcribes audio from mp3, mp4, mpeg, mpga, m4a, wav,
	and webm files. First positional argument must be an audio file.
	Optionally, set a two letter input language (ISO-639-1) as second
	argument. A prompt may also be set after language (must be in the
	same language as the audio). Option -W translates audio to English
	text and a prompt in English may be set to guide the model.

	Combine -wW with -cc to start chat with voice input (whisper)
	support. Output may be piped to a voice synthesiser such as
	\`espeakng', to have full voice in and out.

	Stdin is supported when there is no positional arguments left
	after option parsing. Stdin input sets a single PROMPT.

	User configuration is kept at \`${CHATGPTRC:-${CONFFILE/$HOME/"~"}}'.
	Script cache is kept at \`${CACHEDIR/$HOME/"~"}'.

	A personal (free) OpenAI API is required, set it with -k or
	see ENVIRONMENT section.

	For the skill list, see <https://platform.openai.com/examples>.

	For complete model and settings information, refer to OPENAI
	API docs at <https://beta.openai.com/docs/guides>.


COMPLETIONS
	Given a prompt, the model will return one or more predicted
	completions. It can be used a chatbot.

	Set option -c to enter text completion chat and keep a history
	of the conversation and works with a variety of models.

	Set option -cc to use the chat completion endpoint. Works the
	same as the text completion chat (turbo models).

	The defaults chat format is \`Q & A'. A name such as \`NAME:'
	may be introduced as interlocutor. Setting only \`:' works as
	an instruction prompt, send an empty prompt or complete the
	previous answer prompt.

	While in chat mode, type in one of the following commands, and
	a value in the new prompt (e.g. \`!temp0.7', \`!mod1'):

		!NUM |  !max 	  Set maximum tokens.
		-a   |  !pre 	  Set presence.
		-A   |  !freq 	  Set frequency.
		-c   |  !new 	  Starts new session.
		-H   |  !hist 	  Edit history.
		-L   |  !log 	  Save to log file.
		-m   |  !mod 	  Set model by index number.
		-p   |  !top 	  Set top_p.
		-t   |  !temp 	  Set temperature.
		-v   |  !ver	  Set/unset verbose.
		-x   |  !ed 	  Set/unset text editor.
		!q   |  !quit	  Exit.
	
	
	To change chat history, the history file must be edited with
	\`!hist'. Delete entries or comment them out with \`#'.

	Prompt Design
	Make a good prompt. May use bullets for multiple questions in
	a single prompt. Write \`act as [technician]', add examples of
	expected results.

	For the chatbot, the only initial indication given is a \`$Q_TYPE: '
	interlocutor flag. Without previous instructions, the first
	replies may return lax but should stabilise on further promtps.
	
	Alternatively, one may try setting initial instructions prompt
	with the bot identity and how it should behave as, such as:

		prompt>	\": The following is a conversation with an AI
			  assistant. The assistant is helpful, creative,
			  clever, and friendly.\"

		reply_> \"A: Hello! How can I help you?\"

		prompt> \"Q: Hello, what is your name?\"

	Also see section ENVIRONMENT to set defaults chatbot instructions.
	For more on prompt design, see:
	<https://platform.openai.com/docs/guides/completion/prompt-design>
	<https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>


	Settings
	Temperature 	number 	Optional 	Defaults to $OPTT

	Lowering temperature means it will take fewer risks, and
	completions will be more accurate and deterministic. Increasing
	temperature will result in more diverse completions.
	Ex: low-temp:  We’re not asking the model to try to be creative
	with its responses – especially for yes or no questions.

	For more on settings, see <https://beta.openai.com/docs/guides>.


EDITS
	This endpoint is set with models with \`edit' in their name
	or option -e.

	Editing works by specifying existing text as a prompt and an
	instruction on how to modify it. The edits endpoint can be used
	to change the tone or structure of text, or make targeted changes
	like fixing spelling. We’ve also observed edits to work well on
	empty prompts, thus enabling text generation similar to the
	completions endpoint. 


IMAGES / DALL-E
	The first positional parameter sets the output image size
	256x256/Small, 512x512/Medium or 1024x1024/Large. Defaults=$OPTS.

	An image can be created given a prompt. A text description of
	the desired image(s). The maximum length is 1000 characters.

	Also, a variation of a given image can be generated. The image
	to use as the basis for the variation(s). Must be a valid PNG
	file, less than 4MB and square. If Imagemagick is available,
	input image will be converted to square before upload.


AUDIO / WHISPER
	Transcriptions
	Transcribes audio into the input language. Set a two letter
	ISO-639-1 language as the second positional parameter. A prompt
	may also be set as last positional parameter to help guide the
	model. This prompt should match the audio language.

	Translations
	Translates audio into into English. An optional text to guide
	the model's style or continue a previous audio segment is optional
	as last positional argument. This prompt should be in English.
	
	Setting temperature has an effect, the higher the more random.
	Currently, only one audio model is available.


ENVIRONMENT
	CHATGPTRC 	Path to user ${0##*/} configuration.
			Defaults=${CHATGPTRC:-${CONFFILE/$HOME/"~"}}

	INSTRUCTION 	Initial instruction set for the chatbot.

	OPENAI_API_KEY
	OPENAI_KEY 	Set your personal (free) OpenAI API key.

	VISUAL
	EDITOR 		Text editor for external prompt editing.
			Defaults=vim


LIMITS
	For most models this is 2048 tokens, or about 1500 words).
	Davici model limit is 4000 tokens (~3000 words) and for
	turbo models it is 4096 tokens.

	Free trial users
	Text & Embedding        Codex          Edit        Image
                  20 RPM       20 RPM        20 RPM
             150,000 TPM   40,000 TPM   150,000 TPM   50 img/min

	RPM 	(requests per minute)
	TPM 	(tokens per minute)


BUGS
	Certain PROMPTS may return empty responses. Maybe the model has
	nothing to add to the input prompt or it expects more text. Try
	trimming spaces, appending a full stop/ellipsis, or resetting
	temperature or adding more text. See prompt design. Keep in mind
	that prompts ending with a space character may result in lower-
	quality output. This is because the API already incorporates
	trailing spaces in its dictionary of tokens.

	Language models are but a mirror of human written records, they
	do not \`understand' your questions or \`know' the answers to it.
	Garbage in, garbage out.


REQUIREMENTS
	A free OpenAI GPTChat key. Ksh93, Bash or Zsh. cURL. JQ,
	ImageMagick, and Sox/Alsa-tools/FFmpeg are optionally required.


OPTIONS
	-NUM 	 Set maximum tokens. Defaults=$OPTMM. Max=4096.
	-a [VAL] Set presence penalty  (cmpls/chat, unset, -2.0 - 2.0).
	-A [VAL] Set frequency penalty (cmpls/chat, unset, -2.0 - 2.0).
	-b 	 Print log probabilities (cmpls, unset, 0 - 5).
	-c 	 Chat mode in text completions, new session.
	-cc 	 Chat mode in chat endpoint, new session.
	-C 	 Continue from last session (with -cc, compls/chat).
	-e [INSTRUCT] [INPUT]
		 Set Edit mode. Model Defaults=text-davinci-edit-001.
	-f 	 Skip sourcing user configuration file.
	-h 	 Print this help page.
	-H 	 Edit history file with text editor.
	-i [PROMPT]
		 Creates an image given a prompt.
	-i [PNG_PATH]
		 Creates a variation of a given image.
	-j 	 Print raw JSON response (debug with -jVV).
	-k [KEY] Set API key (free).
	-l [MODEL]
		 List models or print details of a MODEL.
	-L [FILEPATH]
		 Set a logfile. Filepath is required.
	-m [MODEL]
		 Set a model name, check with -l. Model name is optional.
	-m [NUM] Set model by index NUM:
		  # Completions           # Moderation
		  0.  text-davinci-003    6.  text-moderation-latest
		  1.  text-curie-001      7.  text-moderation-stable
		  2.  text-babbage-001    # Edits                  
		  3.  text-ada-001        8.  text-davinci-edit-001
		  # Codex                 9.  code-davinci-edit-001
		  4.  code-davinci-002    # Chat
		  5.  code-cushman-001    10. gpt-3.5-turbo
	-n [NUM] Set number of results. Defaults=$OPTN.
	-p [VAL] Set top_p value, nucleus sampling (cmpls/chat),
		 (unset, 0.0 - 1.0).
	-S [INSTRUCTION|FILE]
		 Set an instruction prompt.
	-t [VAL] Set temperature value (cmpls/chat/edits/audio),
		 (0.0 - 2.0, whisper 0.0 - 1.0). Defaults=$OPTT.
	-vv 	 Less verbose in chat mode.
	-VV 	 Pretty-print request body. Set twice to dump raw.
	-x 	 Edit prompt in text editor.
	-w 	 Transcribe audio file into text.
	-W 	 Translate audio file into English text.
	-z 	 Print last response JSON data."

MODELS=(
	#COMPLETIONS
	text-davinci-003          #0
	text-curie-001            #1
	text-babbage-001          #2
	text-ada-001              #3
	#CODEX
	code-davinci-002          #4
	code-cushman-001          #5
	#MODERATIONS
	text-moderation-latest    #6
	text-moderation-stable    #7
	#EDITS
	text-davinci-edit-001     #8
	code-davinci-edit-001     #9
	#CHAT
	gpt-3.5-turbo             #10
	gpt-3.5-turbo-0301        #11
	#AUDIO
	whisper-1                 #12
)

ENDPOINTS=(
	completions               #0
	moderations               #1
	edits                     #2
	images/generations        #3
	images/variations         #4
	embeddings                #5
	chat/completions          #6
	audio/transcriptions      #7
	audio/translations        #8
)


#set model endpoint based on its name
function set_model_epnf
{
	unset OPTE OPTEMBED
	case "$1" in
		*whisper*) 		((OPTWW)) && EPN=8 || EPN=7;;
		*turbo*) 		EPN=6 ;((OPTC)) && OPTC=2 ;unset OPTB;;
		code-*) 	case "$1" in
					*search*) 	EPN=5 OPTEMBED=1;;
					*edit*) 	EPN=2 OPTE=1;;
					*) 		EPN=0;;
				esac;;
		text-*) 	case "$1" in
					*embedding*|*similarity*|*search*) 	EPN=5 OPTEMBED=1;;
					*edit*) 	EPN=2 OPTE=1;;
					*moderation*) 	EPN=1 OPTEMBED=1;;
					*) 		EPN=0;;
				esac;;
		*) 		#fallback
				case "$1" in
					*-edit*) 	EPN=2 OPTE=1;;
					*-embedding*|*-similarity*|*-search*) 	EPN=5 OPTEMBED=1;;
					*) 	EPN=0;;  #defaults
				esac;;
	esac
}

#make request
function promptf
{
	((OPTMINI)) && json_minif
	((OPTVV)) && ((!OPTII)) && { 	block_printf || return ;}

	curl -\# ${OPTV:+-s} -L "https://api.openai.com/v1/${ENDPOINTS[EPN]}" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d "$BLOCK" \
		-o "$FILE"
}

#pretty print request body or dump and exit
function block_printf
{
	if ((OPTVV>1))
	then 	printf '%s\n%s\n' "${ENDPOINTS[EPN]}" "$BLOCK"
		printf '%s ' '<CTRL-D> redo, <CTR-C> exit, or continue' >&2
		typeset REPLY ;read
	else	jq -r '.instruction//empty, .input//empty, .prompt//(.messages[]|"\(.role):\t\(.content)")//empty' <<<"$BLOCK" \
		|| printf '%s\n' "$BLOCK"
	fi >&2
}

#prompt confirmation prompt
function new_prompt_confirmf
{
	typeset REPLY
	((OPTV)) && return

	printf '%s \n' "Confirm prompt? [Y]es, [n]o,${OPTX:+ [e]dit,} [r]edo or [a]bort" >&2
	read -r -n ${ZSH_VERSION:+-k} 1
	case "${REPLY:-$1}" in
		[AaQq]*) 	return 201;;  #break
		[Rr]*) 	return 200;;  #continue
		[EeVv]*) 	return 199;;  #edf
		[Nn]*) 	unset REC_OUT TKN_PREV ;return 1;;  #no
	esac  #yes
}

#print response
function prompt_printf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	else 	((OPTV)) || jq -r '"Model_: \(.model//"?") (\(.object//"?"))",
			"Usage_: \(.usage.prompt_tokens) + \(.usage.completion_tokens) = \(.usage.total_tokens//empty) tokens",
			.choices[].logprobs//empty' "$FILE" >&2
		jq -r '.choices[1] as $sep | .choices[] | (.text//.message.content, if $sep != null then "---" else empty end)' "$FILE" 2>/dev/null \
		|| jq -r '.choices[]|.text//.message.content' "$FILE" 2>/dev/null \
		|| jq . "$FILE" 2>/dev/null || cat -- "$FILE"
	fi
}

#make request to image endpoint
function prompt_imgvarf
{
	curl -\# ${OPTV:+-s} -L "https://api.openai.com/v1/${ENDPOINTS[EPN]}" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-F image="@$1" \
		-F response_format="$OPTI_FMT" \
		-F n="$OPTN" \
		-F size="$OPTS" \
		-o "$FILE"
}

#print image endpoint response
function prompt_imgprintf
{
	typeset n m fname fout
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	elif [[ $OPTI_FMT = b64_json ]]
	then 	[[ -d "${FILEOUT%/*}" ]] || FILEOUT="${FILEIN}"
		n=0 m=0
		for fname in "${FILEOUT%.png}"*
		do 	fname="${fname%.png}" fname="${fname##*[!0-9]}"
			((m>fname)) || ((m=fname+1)) 
		done
		while jq -e ".data[${n}]" "$FILE" >/dev/null 2>&1
		do 	fout="${FILEOUT%.*}${m}.png"
			jq -r ".data[${n}].b64_json" "$FILE" | { 	base64 -d || base64 -D ;} > "$fout"
			printf 'File: %s\n' "${fout/$HOME/"~"}" >&2
			((OPTV)) || if command -v xdg-open >/dev/null 2>&1
			then 	xdg-open "$fout" || function xdg-open { : ;} #fail gracefully
			elif command -v open >/dev/null 2>&1
			then 	open "$fout" || function open { : ;}
			fi
			#https://budts.be/weblog/2011/07/xdf-open-vs-exo-open/
			((++n, ++m)) ;((n<50)) || break
		done
		((n)) || { 	cat -- "$FILE" ;false ;}
	else 	jq -r '.data[].url' "$FILE" || cat -- "$FILE"
	fi
}

function prompt_audiof
{
	curl -\# ${OPTV:+-s} -L "https://api.openai.com/v1/${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-H 'Content-Type: multipart/form-data' \
		-F file="@$1" \
		-F model="$MOD" \
		-F temperature="$OPTT" \
		"${@:2}" \
		-o "$FILE"
}

function list_modelsf
{
	curl "https://api.openai.com/v1/models${1:+/}${1}" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-o "$FILE"
	if [[ -n $1 ]]
	then  	jq . "$FILE" || cat -- "$FILE"
	else 	jq -r '.data[].id' "$FILE" | sort
	fi
}

function lastjsonf
{
	if [[ -s $FILE ]]
	then 	jq . "$FILE" || cat -- "$FILE"
	fi
}

#calculate token preview
#usage: token_prevf [string]
function token_prevf
{
	TKN_PREV=$(__tiktokenf "$*")
	((OPTV)) || printf 'Prompt tokens: ~%d; Max tokens: %d\n' "$TKN_PREV" "$OPTMAX" >&2
}

#poor man's tiktoken
#usage: __tiktokenf [string] [divide_by]
# divide_by  ^:less tokens  v:more tokens
function __tiktokenf
{
	typeset str tkn by
	by="$2"

	# 1 TOKEN ~= 4 CHARS IN ENGLISH
	#str="${1// }" str=${str//[$'\t\n']/xxxx} str="${str//\\[ntrvf]/xxxx}" tkn=$((${#str}/${by:-4}))
	# 1 TOKEN ~= ¾ WORDS
	set -- ${1//[[:punct:]]/x} ;tkn=$(( ($# * 4) / ${by:-3}))
	
	printf '%d\n' "$tkn" ;((tkn>0))
}

#print to history file
#usage: push_tohistf [string] [tokens] [time]
function push_tohistf
{
	typeset string tkn_min tkn
	string="$1" ;tkn_min=$(__tiktokenf "$string" "4")
	((tkn = ${2:-$tkn_min}>0 ? ${2:-$tkn_min} : 0))
	printf '%s\t%d\t"%s"\n' "${3:-$(date -Isec)}" "$tkn" "$string" >> "$FILECHAT"
}

#check for interlocutor
SPC1="?(*+(\\\\n|$'\n'))*([$IFS\"])"
TYPE_GLOB="*([A-Za-z0-9@_/.+-])"
SPC2="*(\\\\t|[$' \t'])"
SPC3="*(\\\\[ntrvf]|[$IFS])"
function check_typef
{
	[[ $* = $SPC1$TYPE_GLOB$SPC2:$SPC3* ]]
}
#set interlocutor if none set
function set_typef
{
	check_typef "$*" || return
	SET_TYPE="$*"
	SET_TYPE="${SET_TYPE%%:*}"
	SET_TYPE="${SET_TYPE%%$SPC2}"
	SET_TYPE="${SET_TYPE##$SPC1}"
}

#set output image size
function set_sizef
{
	case "$1" in
		1024*|[Ll]arge|[Ll]) 	OPTS=1024x1024;;
		512*|[Mm]edium|[Mm]) 	OPTS=512x512;;
		256*|[Ss]mall|[Ss]) 	OPTS=256x256;;
		*) 	return 1;;
	esac ;return 0
}

#command run feedback
function cmd_verf
{
	((OPTV)) || printf '%-11s => %s\n' "$1" "${2:-unset}" >&2
}

#check if input is a command
function check_cmdf
{
	[[ ${*//[$IFS:]} = [/!-]* ]] || return
	set -- "${*##*([$IFS:\/!])}"
	case "$*" in
		-[0-9]*|[0-9]*|max*) 	set -- "${*%.*}"
			set -- "${*//[!0-9]}"  ;OPTMAX="${*:-$OPTMAX}"
			cmd_verf 'Max tokens' "$OPTMAX"
			;;
		-a*|pre*|presence*)
			set -- "${*//[!0-9.]}" ;OPTA="${*:-$OPTA}"
			fix_dotf OPTA  ;cmd_verf 'Presence' "$OPTA"
			set_optsf
			;;
		-A*|freq*|frequency*)
			set -- "${*//[!0-9.]}" ;OPTAA="${*:-$OPTAA}"
			fix_dotf OPTAA ;cmd_verf 'Frequency' "$OPTAA"
			set_optsf
			;;
		-c|br|break|session)
			break_sessionf
			;;
		-[Hh]|hist*|history)
			__edf "$FILECHAT"
			;;
		-[L]|log*) 	((OPTLOG)) && unset OPTLOG || OPTLOG=1
			set -- "${*##-L}" ;set -- "${*##log}"
			USRLOG="${*:-$USRLOG}"
			[[ "$USRLOG" = "$OLD_USRLOG" ]] \
			|| cmd_verf $'\nLog file' "\`\`$USRLOG''"
			OLD_USRLOG="$USRLOG"
			;;
		-m*|mod*|model*)
			set -- "${*#-m}" ;set -- "${*#model}" ;set -- "${*#mod}"
			if [[ $* = *[a-zA-Z]* ]]
			then 	MOD="${*//[$IFS]}"  #by name
			else 	MOD="${MODELS[${*//[!0-9]}]}" #by index
			fi ;set_model_epnf "$MOD" ;cmd_verf 'Model' "$MOD"
			((EPN==6)) && OPTC=2 || OPTC=1
			;;
		-p*|top*)
			set -- "${*//[!0-9.]}" ;OPTP="${*:-$OPTP}"
			fix_dotf OPTP  ;cmd_verf 'Top P' "$OPTP"
			set_optsf
			;;
		-t*|temp*|temperature*)
			set -- "${*//[!0-9.]}" ;OPTT="${*:-$OPTT}"
			fix_dotf OPTT  ;cmd_verf 'Temperature' "$OPTT"
			set_optsf
			;;
		-v|ver|verbose)
			((OPTV)) && unset OPTV || OPTV=1
			;;
		-V|blk|block)
			((OPTVV)) && unset OPTVV || OPTVV=1
			;;
		-VV|[/!]blk|[/!]block)  #debug
			OPTVV=2
			;;
		-x|ed|editor)
			((OPTX)) && unset OPTX || OPTX=1
			;;
		q|quit|exit|bye)
			exit
			;;
		*) 	return 1;;
	esac
	return 0
}

#main plain text editor
function __edf
{
	${VISUAL:-${EDITOR:-vim}} "$1" </dev/tty >/dev/tty
}

#text editor wrapper
function edf
{
	typeset ed_msg pos REPLY
	
	if ((OPTC>0))
	then 	ed_msg=",,,,,,(edit below this line),,,,,,"
		PRE=$(unescapef "$HIST${HIST:+\\n$ed_msg}")
		printf "%s${PRE:+\\n}" "$PRE" >"$FILETXT"
		printf "${PRE:+\\n}%s\n" "${*:-${SET_TYPE:-$Q_TYPE}: }" >>"$FILETXT"
	elif ((!OPTC))
	then 	printf "%s\n" "$*" >"$FILETXT"
	fi
	
	__edf "$FILETXT"
	
	if ((OPTC)) && pos=$(<"$FILETXT") && [[ "$pos" != "$PRE" ]]
	then 	while [[ "$pos" != "$PRE"* ]]
		do 	printf 'Warning: %s \n' 'bad edit: [E]dit, [r]edo or [c]ontinue?' >&2
			read -r -n ${ZSH_VERSION:+-k} 1
			case "${REPLY:-$1}" in
				[CcNnQqAa]) 	break;;  #continue
				[Rr]*) 	return 200;;  #redo
				[Ee]|*) OPTC= edf "$@"  #edit
					pos=$(<"$FILETXT");;
			esac
		done
		set -- "${pos#*"$PRE"}"
		check_cmdf "${*#*:}" && return 200
		set_typef "$*" && REC_OUT="$*" \
		|| REC_OUT="${SET_TYPE:-$Q_TYPE}: $*"
	fi
	return 0
}

function escapef
{
	typeset var
	var="${*%%*([$IFS])}" var="${var##*([$IFS])}"
 	var=${var//[\"]/\\\"}          #double quote marks
	var=${var//[$'\t']/\\t}        #tabs
	var=${var//[$'\n\r\v\f']/\\n}  #new line/form feed
 	var=${var//\\\\[\"]/\\\"}      #rm excess escapes
 	var=${var//\\\\[n]/\\n}
 	var=${var//\\\\[t]/\\t}
	printf '%s\n' "$var"
}

function unescapef
{
	typeset var
 	var=${*//\\\"/\"}
	var=${var//\\t/$'\t'}
	var=${var//\\n/$'\n'}
	printf '%s\n' "$var"
}

function break_sessionf
{
	[[ -e "$FILECHAT" ]] || return
	[[ $(tail -n 20 "$FILECHAT") = *[Bb][Rr][Ee][Aa][Kk] ]] \
	|| tee -a -- "$FILECHAT" >&2 <<<'SESSION BREAK'
}

#fix variable value, add zero before/after dot.
function fix_dotf
{
	eval "[[ \$$1 = .[0-9]* ]] && $1=0\$${1}"
	eval "[[ \$$1 = *[0-9]. ]] && $1=\${${1}}0"
}

#minify json
function json_minif
{
	typeset blk
	blk=$(jq -c . <<<"$BLOCK") || {
		blk=${BLOCK//[$'\t\n\r\v\f']} blk="${blk//\": \"/\":\"}"
		blk="${blk//, \"/,\"}" blk="${blk//\" ,\"/\",\"}"
	}
	BLOCK="$blk"
}

#format for chat completion endpoint
function fmt_ccf
{
	printf '{"role": "%s", "content": "%s"}\n' "${2:-user}" "$1"
}

#create user log
function usr_logf
{
	[[ -d $USRLOG ]] && USRLOG="$USRLOG/${FILETXT##*/}"
	[[ "$USRLOG" = '~'* ]] && USRLOG="${HOME}${USRLOG##\~}"
	printf '%s\n\n' "$(date -R 2>/dev/null||date)" "$@" > "$USRLOG"
}

#check if a value if within a fp range
#usage: check_optrangef [val] [min] [max]
function check_optrangef
{
	typeset val min max prop ret
	val="${1:-0}" min="${2:-0}" max="${3:-0}" prop="${4:-property}"
	if [[ -n $ZSH_VERSION$KSH_VERSION ]]
	then 	ret=$(( (val < min) || (val > max) ))
	elif command -v bc
	then 	ret=$(bc <<<"($val < $min) || ($val > $max)")
	fi >/dev/null 2>&1
	((ret)) && printf 'Warning: bad %s -- %s  (%s - %s)\n' "$prop" "$val" "$min" "$max" >&2
	return ${ret:-0}
}

#optional settings
function set_optsf
{
	check_optrangef "$OPTA" -2.0 2.0 'Presence penalty'
	check_optrangef "$OPTAA" -2.0 2.0 'Frequency penalty'
	check_optrangef "$OPTB" 0 5 Logprobs
	check_optrangef "$OPTP" 0 1.0 Top_p
	check_optrangef "$OPTT" 0 2.0 Temperature  #whisper max=1
	[[ -n ${OPTT#0} ]] && [[ -n ${OPTP#1} ]] \
	&& printf 'Warning: %s\n' "Temperature and Top_p are both set" >&2

	[[ -n $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA," || unset OPTA_OPT
	[[ -n $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA," || unset OPTAA_OPT
	[[ -n $OPTB ]] && OPTB_OPT="\"logprobs\": $OPTB," || unset OPTB_OPT
	[[ -n $OPTP ]] && OPTP_OPT="\"top_p\": $OPTP," || unset OPTP_OPT
}

#record mic
#usage: recordf [filename]
function recordf
{
	typeset termux pid REPLY

	[[ -e $1 ]] && rm -- "$1"  #remove old cache audio file as some programmes don't like overwritting
	if ((!OPTV)) && ((N))
	then 	printf '\r%s\n%s\n\n' '*** Press any key to ***' '*** START recording  ***' >&2
		read -r -n ${ZSH_VERSION:+-k} 1
	fi ;printf '\r%s\n%s\n\n' '*** Press any key to ***' '***  STOP recording  ***' >&2

	if command -v termux-microphone-record >/dev/null 2>&1
	then 	termux=1
		termux-microphone-record -c 1 -l 0 -f "$1" &
	elif command -v sox  >/dev/null 2>&1
	then 	#sox
		rec "$1" &
	elif command -v arecord  >/dev/null 2>&1
	then 	#alsa-utils
		arecord -i "$1" &
	else 	#ffmpeg
		ffmpeg -f alsa -i pulse -ac 1 -y "$1" &
	fi
	pid=$!
	trap "__recordkillf $pid $termux ;exit 2" INT HUP TERM EXIT
	read ;__recordkillf $pid $termux ;trap "-" INT HUP TERM EXIT
	wait ;return 0
}
function __recordkillf
{
	((${2:-0})) && termux-microphone-record -q || kill -INT $1
}

#whisper
function whisperf
{
	typeset file lang REPLY
	check_optrangef "$OPTT" 0 1.0 Temperature
	if [[ ! -e $1 ]]
	then 	printf '%s ' 'Record mic input? [Y/n] ' >&2
		read -r -n ${ZSH_VERSION:+-k} 1
		case "$REPLY" in
			[AaNnQq]) 	:;;
			*) 	recordf "$FILEINW"
				set -- "$FILEINW" "$@";;
		esac
	fi
	if [[ ! -e $1 ]]
	then 	printf 'Err: %s\n' 'audio file required' >&2 ;exit 1
	elif [[ $1 != *@(mp3|mp4|mpeg|mpga|m4a|wav|webm) ]]
	then 	printf 'Err: %s\n' 'file format not supported' >&2 ;exit 1
	else 	file="$1" ;shift
	fi ;[[ -e $1 ]] && shift  #get rid of eventual second filename
	#set language ISO-639-1 (two letters)
	if [[ $1 = [a-z][a-z] ]]
	then 	if ((!OPTWW))
		then 	lang="-F language=$1"
			((OPTV)) || printf 'Audio language -- %s\n' "$1" >&2
		fi
		shift
	fi
	#set a prompt
	[[ -n ${*//@([$IFS]|\\[ntrvf])} ]] && set -- -F prompt="$(escapef "$*")"
	prompt_audiof "$file" $lang "$@"
	jq -r '.text' "$FILE" || cat -- "$FILE"
}

#image variations
function imgvarf
{
	[[ -e ${1:?input PNG path required} ]] || exit
	if command -v magick >/dev/null 2>&1  #convert img to 'square png'
	then 	if [[ $1 != *.[Pp][Nn][Gg] ]] ||
			((! $(magick identify -format '%[fx:(h == w)]' "$1") ))
		then 	magick convert "${1}" -gravity Center -extent 1:1 "${FILEIN}" &&
			set  -- "${FILEIN}" "${@:2}"
		fi
		#https://legacy.imagemagick.org/Usage/resize/
	fi
	prompt_imgvarf "$1"
	prompt_imgprintf
}

#image generations
function imggenf
{
	BLOCK="{
		\"prompt\": \"${*:?IMG PROMPT ERR}\",
		\"size\": \"$OPTS\",
		\"n\": $OPTN,
		\"response_format\": \"$OPTI_FMT\"
	}"
	promptf
	prompt_imgprintf
}

#embeds
function embedf
{
	BLOCK="{
		\"model\": \"$MOD\",
		\"input\": \"${*:?INPUT ERR}\",
		\"temperature\": $OPTT, $OPTP_OPT
		\"max_tokens\": $OPTMAX,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
}

#edits
function editf
{
	BLOCK="{
		\"model\": \"$MOD\",
		\"instruction\": \"${1:-:?EDIT MODE ERR}\",
		\"input\": \"${@:2}\",
		\"temperature\": $OPTT, $OPTP_OPT
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
}


#parse opts
while getopts a:A:b:cCefhHijlL:m:n:kp:S:t:vVxwWz0123456789 c
do 	fix_dotf OPTARG
	case $c in
		[0-9]) 	OPTMAX="$OPTMAX$c";;
		a) 	OPTA="$OPTARG";;
		A) 	OPTAA="$OPTARG";;
		b) 	OPTB="$OPTARG";;
		c) 	((OPTC++));;
		C) 	((OPTRESUME++));;
		e) 	OPTE=1 EPN=2;;
		f$OPTF) 	unset MOD MOD_AUDIO INSTRUCTION CHATINSTR EPN OPTM OPTMM OPTMAX OPTA OPTAA OPTB OPTP OPTMINI
			OPTF=1 ;. "$0" "$@" ;exit;;
		h) 	printf '%s\n' "$MAN" ;exit ;;
		H) 	__edf "$FILECHAT" ;exit ;;
		i) 	OPTI=1 EPN=3 MOD=image;;
		j) 	OPTJ=1;;
		l) 	OPTL=1;;
		L) 	OPTLOG=1 USRLOG="$OPTARG"
			cmd_verf 'Log file' "\`\`$USRLOG''"
			;;
		m) 	OPTMARG="$OPTARG"
			if [[ $OPTARG = *[a-zA-Z]* ]]
			then 	MOD="$OPTARG"  #set model name
			else 	MOD="${MODELS[OPTARG]}" #set one pre defined model number
			fi;;
		n) 	OPTN="$OPTARG" ;;
		k) 	OPENAI_KEY="$OPTARG";;
		p) 	OPTP="$OPTARG";;
		S) 	if [[ -e "$OPTARG" ]]
			then 	INSTRUCTION=$(<"$OPTARG")
			else 	INSTRUCTION="$OPTARG"
			fi;;
		t) 	OPTT="$OPTARG";;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		x) 	OPTX=1;;
		w) 	OPTW=1;;
		W) 	OPTW=1 OPTWW=1;;
		z) 	OPTZ=1;;
		\?) 	exit 1;;
	esac
done ; unset c
shift $((OPTIND -1))

OPTMAX="${OPTMAX:-$OPTMM}"
OPENAI_KEY="${OPENAI_KEY:-${OPENAI_API_KEY:-${GPTCHATKEY:-${BEARER:?API key required}}}}"
((OPTC)) && ((OPTE+OPTI)) && OPTC=  ;((OPTL+OPTZ)) && OPTX= ;set_optsf
if ((OPTI))
then 	command -v base64 >/dev/null 2>&1 || OPTI_FMT=url
	if set_sizef "$1"
	then 	shift
	elif set_sizef "$2"
	then 	set -- "$1" "${@:3}"
	fi
	#set file upload, image variations
	[[ -e "$1" ]] && OPTII=1 EPN=4 MOD=image-var
fi
[[ -n $OPTMARG ]] ||
if ((OPTE))
then 	OPTM=8
elif ((OPTC>1))
then 	OPTM=10 MOD="$MOD_CHAT"
elif ((OPTW)) && ((!OPTC))
then 	OPTM=12 MOD="$MOD_AUDIO"
fi
MOD="${MOD:-${MODELS[OPTM]}}"
[[ -n $EPN ]] || set_model_epnf "$MOD"

(($#)) || [[ -t 0 ]] || set -- "$(</dev/stdin)"
((OPTX)) && ((!OPTC)) && edf "$@" && set -- "$(<"$FILETXT")"  #editor
((OPTI+OPTII+OPTL+OPTZ)) || ((!$#)) || token_prevf "$*"
for arg  #escape input
do 	((init++)) || set --
	set -- "$@" "$(escapef "$arg")"
done ;unset arg init

mkdir -p "$CACHEDIR" || exit
command -v jq >/dev/null 2>&1 || function jq { 	false ;}

if ((OPTZ))        #last received json
then 	lastjsonf
elif ((OPTL))      #model list
then 	list_modelsf "$@"
elif ((OPTW)) && ((!OPTC))  #audio transcribe
then 	whisperf "$@"
elif ((OPTII))     #image variations
then 	imgvarf "$@"
elif ((OPTI))      #image generations
then 	imggenf "$@"
elif ((OPTEMBED))  #embeds
then 	embedf "$@"
elif ((OPTE))      #edits
then 	if (($# == 1)) && [[ -n "$INSTRUCTION" ]]
	then 	set -- "$INSTRUCTION" "$@"
		((OPTV)) || printf '%s -- "%s"\n' 'INSTRUCTION' "$INSTRUCTION" >&2
	fi
	editf "$@"
else               #completions
	if ((OPTW))  #whisper input
	then 	unset OPTX
		INPUT_ORIG=("$@") ;set --
	fi
	((${#INSTRUCTION})) && ((!OPTC)) && [[ -z ${*//@([$IFS]|\\[ntrvf])} ]] && [[ -n ${ERR:?PROMPT} ]]
	((OPTRESUME)) || { 	((OPTC)) && break_sessionf ;}
	if ((${#INSTRUCTION}))  #chatbot instructions
	then 	((OPTV)) || printf '%s -- "%s"\n' 'INSTRUCTION' "$INSTRUCTION" >&2
		INSTRUCTION=$(escapef "$INSTRUCTION")
		if ((!OPTC)) && (($#))  #one-shot
		then 	OPTV=1 token_prevf "$INSTRUCTION\\n\\n$*"
			if ((EPN==6))
			then 	set -- "$(fmt_ccf "$INSTRUCTION" system),$(fmt_ccf "${*##*([$IFS:])}" user)"
			else 	set -- "$INSTRUCTION\\n\\n${*##*([$IFS:])}"
			fi
		elif ((!OPTRESUME)) && ((OPTC))
		then 	push_tohistf ": $INSTRUCTION"
			((OLD_TOTAL+=$(__tiktokenf ": $INSTRUCTION" "4") ))
		fi
	fi
	while :
	do 	if ((OPTC))  #chat mode
		then 	if (($#))  #input from pos args, first pass
			then 	check_cmdf "$*" && { 	set -- ;continue ;}
				set_typef "$*" && REC_OUT="$*" \
				|| REC_OUT="${SET_TYPE:-$Q_TYPE}: $*"
				set -- "${REC_OUT##*([$IFS:])}"
				[[ -n $ZSH_VERSION ]] && print -s -- "$*"
			fi

			#read history file
			if [[ -s "$FILECHAT" ]]
			then 	((MAX_PREV=TKN_PREV)) ;unset HIST HIST_C
				while IFS=$'\t' read -r time token string
				do 	[[ $time$token = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
					[[ ${time//[$IFS]} = \#* ]] && continue
					[[ -n ${string//[$IFS\"]} ]] || continue
					if ((token<1))
					then 	((OPTVV>1||OPTJ)) && printf 'Warning: %s\n' 'zero/negative token count in history' >&2
						token=$(__tiktokenf "$string")
					fi
					if ((MAX_PREV+token<OPTMAX))
					then 	((MAX_PREV+=token))
						string="${string##[ \"]}" string="${string%%[ \"]}"
						string="${string##$SPC3:$SPC3}" HIST="$string\n\n$HIST"
						
						if ((EPN==6))  #gpt-3.5-turbo
						then 	USER_TYPE="$SET_TYPE"
							set_typef "$string" \
							&& string="${string/$SPC1${SET_TYPE:-$Q_TYPE}}" 
							case "${SET_TYPE:-:}" in
								:) 	role=system;;
								${USER_TYPE:-$Q_TYPE}|$Q_TYPE) 	role=user;;
								*) 	role=assistant;;
							esac
							HIST_C="$(fmt_ccf "${string##$SPC2:$SPC3}" "$role")${HIST_C:+,}$HIST_C"
							SET_TYPE="$USER_TYPE"
						fi
					fi
				done < <(tac -- "$FILECHAT")
				((MAX_PREV-=TKN_PREV))
				unset REPLY USER_TYPE time token string role
			fi

			#text editor
			if ((OPTX))
			then 	edf "$@" || continue  #sig:200
				while :
				do 	new_prompt_confirmf
					case $? in
						201) 	break 2;;  #abort
						200) 	continue 2;;  #redo
						199) 	OPTC=-1 edf "$@" || break 2;;  #edit
						0) 	if ((EPN==6))
							then 	[[ ${REC_OUT//[$IFS]} = :* ]] && role=system || role=user
								set -- "${HIST_C}${HIST_C:+,}$(fmt_ccf "$(escapef "${REC_OUT/$SPC1${SET_TYPE:-$Q_TYPE}$SPC2:$SPC3}")" "$role")"
								unset role
							else 	set -- "$(escapef "$(<"$FILETXT")")"
							fi
							break;;  #yes
						*) 	set -- ;break;;  #no
					esac
				done
			fi

			#fallback prompt read
			if [[ ${*//[$'\t\n'\"]} = *($TYPE_GLOB:) ]] \
				|| [[ ${REC_OUT//[$'\t\n'\"]} = *($TYPE_GLOB:) ]]
			then 	while printf '\n%s[%s]: ' "Prompt" "${SET_TYPE:-$Q_TYPE}" >&2
				do 	if ((OPTW))
					then 	recordf "$FILEINW"
						REPLY=$(MOD="${MOD_AUDIO:-${MODELS[12]}}" OPTT=0
							set_model_epnf "$MOD"
							whisperf "$FILEINW" "${INPUT_ORIG[@]}"
						) ;REPLY="${REPLY:-(EMPTY)}"
						printf '%s\n' "$REPLY" >&2
					elif [[ -n $ZSH_VERSION ]]
					then 	unset REPLY
						if vared -p "Prompt[${SET_TYPE:-$Q_TYPE}]: " -eh -c REPLY
						then 	print -s -- "$REPLY"
						fi
					else 	read -r ${BASH_VERSION:+-e}
					fi
					check_cmdf "$REPLY" && continue 2
					if [[ -n $REPLY ]]
					then 	OPTX= new_prompt_confirmf
						case $? in
							201) 	break 2;;  #abort
							200|199) 	continue;;  #redo/edit
							0) 	:;;  #yes
							*) 	unset REPLY; set -- ;break;;  #no
						esac
						set_typef "$REPLY" && REC_OUT="$REPLY" \
						|| REC_OUT="${SET_TYPE:-$Q_TYPE}: $REPLY"
						
						REPLY=$(escapef "$REC_OUT")
						if ((EPN==6))
						then 	set -- "${HIST_C}${HIST_C:+,}$(fmt_ccf "${REPLY/$SPC1${SET_TYPE:-$Q_TYPE}:$SPC2$SPC3}" user)"
						else 	set -- "$HIST$REPLY"
						fi
					else 	set --
					fi ;break
				done
			elif ((!OPTX))
			then 	if ((EPN==6))
				then 	set -- "${HIST_C}${HIST_C:+,}$(fmt_ccf "${REC_OUT/$SPC1${SET_TYPE:-$Q_TYPE}:$SPC2$SPC3}" user)"
				else 	set -- "$HIST${REC_OUT:-$*}"
				fi
			fi
		fi
		#https://thoughtblogger.com/continuing-a-conversation-with-a-chatbot-using-gpt/

		[[ ${REC_OUT//[$IFS]} = :* ]] && {  #instructions/system?
			push_tohistf "$(escapef "$REC_OUT")"
			unset REC_OUT TKN_PREV ;set -- ;continue
		}
		[[ -n "${*:?PROMPT ERR}" ]]
		if ((EPN==6))
		then 	BLOCK="{\"messages\": [${*%,}],"
		else 	BLOCK="{\"prompt\": \"${*}\","
		fi
		BLOCK="$BLOCK
			\"model\": \"$MOD\",
			\"temperature\": $OPTT, $OPTA_OPT $OPTAA_OPT
			\"max_tokens\": $OPTMAX, $OPTB_OPT $OPTP_OPT 
			\"n\": $OPTN
		}"
		promptf
		prompt_printf
		[[ -t 1 ]] || OPTV=1 prompt_printf >&2

		#record to hist file
		if ((OPTC)) && {
		 	tkn=($(jq -r '.usage.prompt_tokens//"0",
				.usage.completion_tokens//"0",
				(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE"
			) )
			ans=$(jq '.choices[0]|.text//.message.content' "$FILE") #ans="${ans//\\\"/''}"
			ans="${ans##*([$IFS]|\\[ntrvf]|\")}" ans="${ans%\"}"
			((${#tkn[@]}>2)) && ((${#ans}))
			}
		then 	check_typef "$ans" || ans="$A_TYPE: $ans"
			push_tohistf "$(escapef "${REC_OUT:-$*}")" "$((tkn[0]-OLD_TOTAL))" "${tkn[2]}"
			push_tohistf "$ans" "${tkn[1]}" "${tkn[2]}"
			((OLD_TOTAL=tkn[0]+tkn[1]))
		fi
		((OPTLOG)) && usr_logf "$(unescapef "$HIST${REC_OUT:-$*}"$'\n\n'"$ans")"
		unset tkn ans

		set --
		unset REPLY TKN_PREV MAX_PREV REC_OUT HIST PRE USER_TYPE HIST_C
		((++N)) ;((OPTC)) || break
	done ;unset OLD_TOTAL N
fi

