% CHATGPT.SH(1) v0.72.1 | General Commands Manual
% mountaineerbr
% August 2024


### NAME

|    chatgpt.sh \-- Wrapper for ChatGPT / DALL-E / Whisper / TTS


### SYNOPSIS

|    **chatgpt.sh** \[`-cc`|`-d`|`-qq`] \[`opt`..] \[_PROMPT_|_TEXT_FILE_|_PDF_FILE_]
|    **chatgpt.sh** `-i` \[`opt`..] \[_X_|_L_|_P_]\[_hd_] \[_PROMPT_]  #Dall-E-3
|    **chatgpt.sh** `-i` \[`opt`..] \[_S_|_M_|_L_] \[_PROMPT_]
|    **chatgpt.sh** `-i` \[`opt`..] \[_S_|_M_|_L_] \[_PNG_FILE_]
|    **chatgpt.sh** `-i` \[`opt`..] \[_S_|_M_|_L_] \[_PNG_FILE_] \[_MASK_FILE_] \[_PROMPT_]
|    **chatgpt.sh** `-w` \[`opt`..] \[_AUDIO_FILE_|_._] \[_LANG_] \[_PROMPT_]
|    **chatgpt.sh** `-W` \[`opt`..] \[_AUDIO_FILE_|_._] \[_PROMPT-EN_]
|    **chatgpt.sh** `-z` \[`opt`..] \[_OUTFILE_|_FORMAT_|_-_] \[_VOICE_] \[_SPEED_] \[_PROMPT_]
|    **chatgpt.sh** `-ccWwz` \[`opt`..] \-- \[_PROMPT_] \-- \[`whisper_arg`..] \-- \[`tts_arg`..] 
|    **chatgpt.sh** `-l` \[_MODEL_]
|    **chatgpt.sh** `-TTT` \[-v] \[`-m`\[_MODEL_|_ENCODING_]] \[_INPUT_|_TEXT_FILE_|_PDF_FILE_]
|    **chatgpt.sh** `-HPP` \[`/`_HIST_FILE_|_._]
|    **chatgpt.sh** `-HPw`


### DESCRIPTION

#### Text Completion Modes

With no options set, complete INPUT in single-turn mode of
plain text completions. 

`Option -d` starts a multi-turn session in **plain text completions**.
This does not set further options automatically.


#### Chat Completion Modes
	
Set `option -c` to start a multi-turn chat mode via **text completions**
and record conversation. This option works with instruct models,
defaults to _gpt-3.5-turbo-instruct_ if none set.

In chat mode, some options are automatically set to un-lobotomise the bot.

Set `option -cc` to start the chat mode via **native chat completions**
and defaults to _gpt-4o_.

Set `option -C` to **resume** (continue from) last history session, and
set `option -E` to exit on the first response (even in multi turn mode).


#### Insert Modes (Fill-In-the-Middle)

Set `option -q` for **insert mode**. The flag "_[insert]_" must be present
in the middle of the input prompt. Insert mode works completing
between the end of the text preceding the flag, and ends completion
with the succeeding text after the flag.

Insert mode works with `instruct` and Mistral `code` models.


#### Instructions

Positional arguments are read as a single **PROMPT**. Model **INSTRUCTION**
is optional but recommended and can be set with `option -S`.

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text cmpls,
and chat cmpls. A text file path may be supplied as the single argument.
Also see *CUSTOM / AWESOME PROMPTS* section below.

In multi-turn interactions, prompts prefixed with a single colon "_:_"
are appended to the current request buffer as user messages without
making a new API call. Conversely, prompts starting with double colons
"_::_" are appended as instruction / system messages. For text cmpls only,
triple colons append the text immediately to the previous prompt
without a restart sequence.

To create and reuse a custom prompt, set the prompt name as a command
line option, such as "`-S .[_prompt_name_]`" or "`-S ..[_prompt_name_]`".
Note that loading a custom prompt will also change to its respective
history file.

Alternatively, set the first positional argument with the operator
and the prompt name, such as "`..[_prompt_]`", unless instruction was
set at the command line.


#### Commands

If the first positional argument of the script starts with the
command operator forward slash "`/`" and a history file name, the
command "`/session` \[_HIST_NAME_]" is assumed. This will
change to or create a new history file (with `options -ccCdPP`).

If a plain text or PDF file path is set as the first positional argument,
or as an argument to `option -S` (set instruction prompt), the file
is loaded as text PROMPT.

With **vision models**, insert an image to the prompt with chat
command "`!img` \[_url_|_filepath_]". Image urls and files can also
be appended by typing the operator pipe and a valid input at the
end of the text prompt, such as "`|` \[_url_|_filepath_]".


#### Model and Capacity

Set model with "`-m` \[_MODEL_]", with _MODEL_ as its name,
or set it as "_._" to pick from the model list.
List available models with `option -l`.

Set _maximum response tokens_ with `option` "`-`_NUM_" or "`-M` _NUM_".
This defaults to _1024_ tokens.

If a second _NUM_ is given to this option, _maximum model capacity_
will also be set. The option syntax takes the form of "`-`_NUM/NUM_",
and "`-M` _NUM-NUM_".

_Model capacity_ (maximum model tokens) can be set more intuitively with
`option` "`-N` _NUM_", otherwise model capacity is set automatically
for known models or to _2048_ tokens as fallback.

List models with `option -l` or run `/models` in chat mode.

<!--
Install models with `option -l` or command `/models`
and the `install` keyword.

Also supply a _model configuration file URL_ or,
if LocalAI server is configured with Galleries,
set "_\<GALLERY>_@_\<MODEL_NAME>_".
Gallery defaults to HuggingFace.

* NOTE: *  I recommend using LocalAI own binary to install the models!
-->
<!-- LocalAI only tested with text and chat completion models (vision) -->

`Option -y` sets python tiktoken instead of the default script hack
to preview token count. This option makes token count preview
accurate fast (we fork tiktoken as a coprocess for fast token queries).
Useful for rebuilding history context independently from the original
model used to generate responses.


#### Image Generations and Edits (Dall-E)

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an _IMAGE_ file, then **generate variations** of
it. If the first positional argument is an _IMAGE_ file and the second
a _MASK_ file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** _IMAGE_ according to _MASK_ and PROMPT.
If _MASK_ is not provided, _IMAGE_ must have transparency.

The **size of output images** may be set as the first positional parameter
in the command line: "_256x256_" (_S_), "_512x512_" (_M_),
"_1024x1024_" (_L_), "_1792x1024_" (_X_), and "_1024x1792_" (_P_).

The parameter "_hd_" may also be set for image quality (_Dall-E-3_),
such as "_Xhd_" or "_1792x1024hd_". Defaults=_1024x1024_.

For Dalle-3, optionally set the generation style as either "_natural_"
or "_vivid_" as a positional parameter in the command line invocation.

See **IMAGES section** below for more information on **inpaint** and **outpaint**.


#### Speech-To-Text (Whisper)

`Option -w` **transcribes audio** from _mp3_, _mp4_, _mpeg_, _mpga_, _m4a_,
_wav_, _webm_, _flac_ and _ogg_ files. First positional argument must be
an _AUDIO_ file. Optionally, set a _TWO-LETTER_ input language (_ISO-639-1_)
as the second argument. A PROMPT may also be set to guide the model's style,
or continue a previous audio segment. The text prompt should match the audio language.

Note that `option -w` can also be set to **translate audio** input to any
text language to the target language.

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional
argument.

Set these options twice to have phrasal-level timestamps, options -ww and -WW.
Set thrice for word-level timestamps.

Combine `options -wW` **with** `options -cc` to start **chat with voice input**
(Whisper) support.
Additionally, set `option -z` to enable **text-to-speech** (TTS) models and voice out.


#### TTS (Text-To-Voice)

`Option -z` synthesises voice from text (TTS models). Set a _voice_ as
the first positional parameter ("_alloy_", "_echo_", "_fable_", "_onyx_",
"_nova_", or "_shimmer_"). Set the second positional parameter as the
_voice speed_ (_0.25_ - _4.0_), and, finally the _output file name_ or
the _format_, such as "_./new_audio.mp3_" ("_mp3_", "_opus_", "_aac_",
and "_flac_"), or "_-_" for stdout. Set `options -vz` to _not_ play received output.


### API Integrations

For LocalAI integration, run the script with `option --localai`,
or set environment **$OPENAI_API_HOST** with the server URL.

For Mistral AI set environment variable **\$MISTRAL_API_KEY**,
and run the script with `option --mistral` or set **$OPENAI_API_HOST**
to "https://api.mistral.ai/".
Prefer setting command line `option --mistral` for complete integration.
<!-- also see: \$MISTRAL_API_HOST -->

For Ollama, set `option -O` (`--ollama`), and set **$OLLAMA_API_HOST**
if the server URL is different from the defaults.

Note that model management (downloading and setting up) must
follow the Ollama project guidelines and own methods.

For Google Gemini, set environment variable **$GOOGLE_API_KEY**, and
run the script with the command line `option --google`.

And for Groq, set the environmental variable `$GROQ_API_KEY`.
Run the script with `option --groq`.
Whisper endpoint available.

And for Anthropic, set envar `$ANTHROPIC_API_KEY`.
Command line options are `--anthropic` or `--ant`.


#### Observations

User configuration is kept at "_~/.chatgpt.conf_".
Script cache is kept at "_~/.cache/chatgptsh/_".

The moderation endpoint can be accessed by setting the model name
to _text-moderation-latest_.

Stdin text is appended to PROMPT, to set a single PROMPT.

While _cURL_ is in the middle of transmitting a request or receiving
a response, \<_CTRL-C_> may be pressed once to interrupt the call.

Press \<_CTRL-X_ _CTRL-E_> to edit command line in text editor (readline).

Press \<_CTRL-J_> or \<_CTRL-V_ _CTRL-J_> for newline (readline).

Press \<_CTRL-\\_> to exit from the script, even if recording,
requesting, or playing TTS.

A personal OpenAI API is required, set it with `option --api-key`.
See also **ENVIRONMENT section**.

This script also supports warping LocalAI, Ollama, Gemini and Mistral APIs.

For complete model and settings information, refer to OpenAI
API docs at <https://platform.openai.com/docs/>.

See the online man page and `chatgpt.sh` usage examples at:
<https://gitlab.com/fenixdragao/shellchatgpt>.


### TEXT / CHAT COMPLETIONS

### 1. Text Completion Modes

Given a prompt, the model will return one or more predicted
completions. For example, given a partial input, the language
model will try completing it until probable "`<|endoftext|>`",
or other stop sequences (stops may be set with `-s`).

**Restart** and **start sequences** may be optionally set. Restart and start
sequences are not set automatically if the chat mode of text completions
is not activated with `option -c`.

To enable **multiline input**, set `option -u`. With this option set,
press \<_CTRL-D_> to flush input! This is useful to paste from clipboard.
Alternatively, set `option -U` to set _cat command_ as prompter.

<!--  [DISABLED]
Type in a backslash "_\\_" as the last character of the input line
to append a literal newline once and return to edition,
or press \<_CTRL-V_ _CTRL-J_>.
-->

Bash bracketed paste is enabled, meaning multiline input may be
pasted or typed, even without setting `options -uU` (_v25.2+_).

Language model **SKILLS** can be activated with specific prompts,
see <https://platform.openai.com/examples>.


### 2. Chat Modes


#### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps
a history file, and keeps new questions in context. This works
with a variety of models. Set `option -E` to exit on response.


#### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. More recent
models are also the best option for many non-chat use cases.


#### 2.3 Q & A Format

The defaults chat format is "**Q & A**". The **restart sequence**
"_\\nQ:\ _" and the **start text** "_\\nA:_" are injected
for the chat bot to work well with text cmpls.

In native chat completions, setting a prompt with "_:_" as the initial
character sets the prompt as a **SYSTEM** message. In text completions,
however, typing a colon "_:_" at the start of the prompt
causes the text following it to be appended immediately to the last
(response) prompt text.


#### 2.4 Voice input (Whisper), and voice output (TTS)

The `options -ccwz` may be combined to have voice recording input and
synthesised voice output, specially nice with chat modes.
When setting `flag -w` or `flag -z`, the first positional parameters are read as
Whisper or TTS  arguments. When setting both `flags -wz`,
add a double hyphen to set first Whisper, and then TTS arguments.

Set chat mode, plus Whisper language and prompt, and the TTS voice option argument:

    chatgpt.sh -ccwz  en 'whisper prompt'  --  nova


#### 2.5 GPT-4-Vision

To send an _image_ or _url_ to **vision models**, either set the image
with the `!img` command with one or more _filepaths_ / _urls_
separated by the operator pipe _|_.

    chatgpt.sh -cc -m gpt-4-vision-preview '!img path/to/image.jpg'


Alternatively, set the _image paths_ / _urls_ at the end of the
text prompt interactively:

    chatgpt.sh -cc -m gpt-4-vision-preview

    [...]
    Q: In this first user prompt, what can you see? | https://i.imgur.com/wpXKyRo.jpeg


#### 2.6 Commands

While in chat mode, the following commands can be invoked in the
new prompt to execute a task or set parameters. The command operator
may be either "`!`" or "`/`".


 Misc              Commands
 --------------    ------------------------------    ----------------------------------------------------------
       `-S`        `:`, `::`    \[_PROMPT_]          Append user or system prompt to request buffer.
      `-S.`        `-.`         \[_NAME_]            Load and edit custom prompt.
      `-S/`        `-S%`        \[_NAME_]            Load and edit awesome prompt (zh).
       `-Z`        `!last`                           Print last response JSON.
       `!#`        `!save`       \[_PROMPT_]         Save current prompt to shell history. _‡_
        `!`        `!r`, `!regen`                    Regenerate last response.
       `!!`        `!rr`                             Regenerate response, edit prompt first.
       `!i`        `!info`                           Information on model and session settings.
       `!j`        `!jump`                           Jump to request, append start seq primer (text cmpls).
      `!!j`        `!!jump`                          Jump to request, no response priming.
      `!md`        `!markdown`  \[_SOFTW_]           Toggle markdown rendering in response.
     `!!md`        `!!markdown` \[_SOFTW_]           Render last response in markdown.
     `!rep`        `!replay`                         Replay last TTS audio response.
     `!res`        `!resubmit`                       Resubmit last TTS recorded input from cache.
     `!cat`         \-                               Cat prompter as one-shot, \<_CTRL-D_> flush.
     `!cat`        `!cat:` \[_TXT_|_URL_|_PDF_]      Cat _text_, _PDF_ file, or dump _URL_.
  `!dialog`         \-                               Toggle the "dialog" interface.
     `!img`        `!media` \[_FILE_|_URL_]          Append image, media, or URL to prompt.
       `!p`        `!pick`,     \[_PROPMT_]          File picker, appends filepath to user prompt. _‡_
     `!pdf`        `!pdf:`      \[_FILE_]            Convert PDF and dump text.
   `!photo`        `!!photo`   \[_INDEX_]            Take a photo, optionally set camera index (Termux). _‡_
      `!sh`        `!shell`      \[_CMD_]            Run shell or _command_, and edit output. _‡_
     `!sh:`        `!shell:`     \[_CMD_]            Same as `!sh` but apppend output as user.
     `!!sh`        `!!shell`     \[_CMD_]            Run interactive shell (with _command_) and exit.
     `!url`        `!url:`       \[_URL_]            Dump URL text.
 --------------    ------------------------------    ----------------------------------------------------------

 Script            Settings and UX
 --------------    -----------------------    ----------------------------------------------------------
   `!fold`         `!wrap`                    Toggle response wrapping.
      `-g`         `!stream`                  Toggle response streaming.
      `-h`         `!!h`       \[_REGEX_]     Print help or grep help for regex.
      `!help`      `!help-assist` \[_QUERY_]  Run the help assistant function.
      `-l`         `!models`    \[_NAME_]     List language models or show model details.
      `-o`         `!clip`                    Copy responses to clipboard.
      `-u`         `!multi`                   Toggle multiline prompter. \<_CTRL-D_> flush.
     `-uu`         `!!multi`                  Multiline, one-shot. \<_CTRL-D_> flush.
      `-U`         `-UU`                      Toggle cat prompter or set one-shot. \<_CTRL-D_> flush.
      `-V`         `!debug`                   Dump raw request block and confirm.
      `-v`         `!ver`                     Toggle verbose modes.
      `-x`         `!ed`                      Toggle text editor interface.
     `-xx`         `!!ed`                     Single-shot text editor.
      `-y`         `!tik`                     Toggle python tiktoken use.
      `!q`         `!quit`                    Exit. Bye.
 --------------    -----------------------    ----------------------------------------------------------

 Model             Settings
 --------------    -----------------------    ------------------------------------------------
   `-Nill`         `!Nill`                    Toggle model max response (chat cmpls).
      `-M`         `!NUM` `!max` \[_NUM_]     Set maximum response tokens.
      `-N`         `!modmax`     \[_NUM_]     Set model token capacity.
      `-a`         `!pre`        \[_VAL_]     Set presence penalty.
      `-A`         `!freq`       \[_VAL_]     Set frequency penalty.
      `-b`         `!best`       \[_NUM_]     Set best-of n results.
      `-j`         `!seed`       \[_NUM_]     Set a seed number (integer).
      `-K`         `!topk`       \[_NUM_]     Set top_k.
      `-m`         `!mod`        \[_MOD_]     Set model by name, empty to pick from list.
      `-n`         `!results`    \[_NUM_]     Set number of results.
      `-p`         `!topp`       \[_VAL_]     Set top_p.
      `-r`         `!restart`    \[_SEQ_]     Set restart sequence.
      `-R`         `!start`      \[_SEQ_]     Set start sequence.
      `-s`         `!stop`       \[_SEQ_]     Set one stop sequence.
      `-t`         `!temp`       \[_VAL_]     Set temperature.
      `-w`         `!rec`       \[_ARGS_]     Toggle Whisper. Optionally, set arguments.
      `-z`         `!tts`       \[_ARGS_]     Toggle TTS chat mode (speech out).
     `!ka`         `!keep-alive` \[_NUM_]     Set duration of model load in memory (Ollama).
    `!blk`         `!block`     \[_ARGS_]     Set and add custom options to JSON request.
        \-         `!multimodal`              Toggle model as multimodal.
 --------------    -----------------------    ------------------------------------------------

 Session           Management
 --------------    -------------------------------------    ------------------------------------------------------------
      `-H`         `!hist`                                  Edit history in editor.
      `-P`         `-HH`, `!print`                          Print session history.
      `-L`         `!log`       \[_FILEPATH_]               Save to log file.
     `!br`         `!break`, `!new`                         Start new session (session break).
     `!ls`         `!list`      \[_GLOB_]                   List History files with _name_ _glob_.
                                                              List prompts "_pr_", awesome "_awe_", or all files "_._".
   `!grep`         `!sub`       \[_REGEX_]                  Search sessions (for regex) and copy session to hist tail.
      `!c`         `!copy` \[_SRC_HIST_] \[_DEST_HIST_]     Copy session from source to destination.
      `!f`         `!fork`      \[_DEST_HIST_]              Fork current session to destination.
      `!k`         `!kill`      \[_NUM_]                    Comment out _n_ last entries in history file.
     `!!k`         `!!kill`     \[\[_0_]_NUM_]              Dry-run of command `!kill`.
      `!s`         `!session`   \[_HIST_FILE_]              Change to, search for, or create history file.
     `!!s`         `!!session`  \[_HIST_FILE_]              Same as `!session`, break session.
 --------------    -------------------------------------    ------------------------------------------------------------


| _:_ Commands with a *colon* have their output appended to the prompt.

| _‡_ Commands with *double dagger* may be invoked at the very end of the input prompt.

| E.g.: "`/temp` _0.7_", "`!mod`_gpt-4_", "`-p` _0.2_", "`/session` _HIST_NAME_", "\[_PROMPT_] `/pick`", and "\[_PROMPT_] `/sh`".


The "`/pick`" command opens a file picker (usually a command-line
file manager). The selected file's path will be appended to the
current prompt in editing mode.

The "`/pick`" and "`/sh`" commands may be run when typed at the end of
the current prompt, such as "\[_PROMPT_] `/sh`", which opens a new
shell instance to execute commands interactively. The output of these
commands is appended to the current prompt.

When the "`/pick`" command is run at the end of the prompt, the selected
file path is appended instead.

Command "`!block` \[_ARGS_]" may be run to set raw model options
in JSON syntax according to each API. Alternatively, set envar **$BLOCK_USR**.


#### 2.7 Session Management

The script uses a _TSV file_ to record entries, which is kept at the script
cache directory. A new history file can be created or an existing one
changed to with command "`/session` \[_HIST_FILE_]", in which _HIST_FILE_
is the file name of (with or without the _.tsv_ extension),
or path to, a history file.

When the first positional argument to the script is the command operator
forward slash followed by a history file name,
the command `/session` is assumed.

A history file can contain many sessions. The last one (the tail session)
is always loaded if the resume `option -C` is set.


#####  Copying and resuming older sessions

To continue from an old session, either **/sub** or **/fork.**
it as the current session. The shorthand for this feature is **/.**.

It is also possible to `/grep [regex]` for a session. This will fork
the selected session and resume it.

If "`/copy` _current_" is run, a selector is shown to choose and copy
a session to the tail of the current history file, and resume it.
This is equivalent to running "`/fork`". 

It is also possible to copy sessions of a history file to another file
when a second argument is given to the command with the history file name,
such as "`/copy` \[_SRC_HIST_FILE_] \[_DEST_HIST_FILE_]", and a dot
as file name means the current history file.


##### Changing session

To load an older session from a history file that is different from the
defaults, there are some options.

Change to it with command `!session [name]`, and then `!fork` the older
session to the active session.

Or, `!copy [orign] [dest]` the session from a history file to the current
or other history file.

In these cases, a pickup interface should open to let the user choose
the correct session from the history file.


##### History file editing

To change the chat context at run time, the history file may be
edited with the "`/hist`" command (also for context injection).
Delete history entries or comment them out with "`#`".


#### 2.8 Completion Preview / Regeneration

To preview a prompt completion before committing it to history,
append a forward slash "`/`" to the prompt as the last character.
Regenerate it again or flush/accept the prompt and response.

After a response has been written to the history file, **regenerate**
it with command "`!regen`" or type in a single exclamation mark or
forward slash "`/`" in the new empty prompt
(twice "`//`" for editing the prompt before new request).


### 3. Prompt Engineering and Design

Minimal **INSTRUCTION** to behave like a chatbot is given with
chat `options -cc`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, minimal instruction is given,
and some options auto set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of
text cmpls, such as Curie, the `best_of` option may be worth
setting (to 2 or 3).

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat cmpls models.

Certain prompts may return empty responses. Maybe the model has
nothing to further complete input or it expects more text. Try
trimming spaces, appending a full stop/ellipsis, resetting
temperature, or adding more text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing
spaces in its dictionary of tokens.

Note that the model's steering and capabilities require prompt
engineering to even know that it should answer the questions.

It is also worth trying to sample 3 - 5 times (increasing the number
of responses with option `-n 3`, for example) in order to obtain
a good response.

For more on prompt design, see:

 - <https://platform.openai.com/docs/guides/completion/prompt-design>
 - <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>


See detailed info on settings for each endpoint at:

 - <https://platform.openai.com/docs/>


<!--
### CODE COMPLETIONS _(discontinued)_

Codex models are discontinued. Use davinci or _gpt-3.5+ models_ for coding tasks.

-- 
Turn comments into code, complete the next line or function in
context, add code comments, and rewrite code for efficiency,
amongst other functions.
--

Start with a comment with instructions, data or code. To create
useful completions it's helpful to think about what information
a programmer would need to perform a task. 
-->


<!--
### TEXT EDITS  _(discontinued)_

--
This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify
a prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure
of text, or make targeted changes like fixing spelling. Edits
work well on empty prompts, thus enabling text generation similar
to the completions endpoint. 

Alternatively,
--

Use _gpt-4+ models_ and the right instructions.
-->


### ESCAPING NEW LINES AND TABS

Input sequences "_\\n_" and "_\\t_" are only treated specially
in restart, start and stop sequences!


### CUSTOM / AWESOME PROMPTS

When the argument to `option -S` starts with a full stop, such as
"`-S` `.`_my_prompt_", load, search for, or create _my_prompt_ prompt file.
If two full stops are prepended to the prompt name, load it silently.
If a comma is used instead, such as "`-S` `,`_my_prompt_", edit
the prompt file, and then load it.

When the argument to `option -S` starts with a backslash or a percent sign,
such as "`-S` `/`_linux_terminal_", search for an *awesome-chatgpt-prompt(-zh)*
(by Fatih KA and PlexPt). Set "`//`" or "`%%`" to refresh local cache.
Use with _davinci_ and _gpt-3.5+_ models.

These options also set corresponding history files automatically.

Please note and make sure to backup your important custom prompts!
They are located at "`~/.cache/chatgptsh/`" with the extension "_.pr_".


### IMAGES / DALL-E

### 1. Image Generations

An image can be created given a text prompt. A text PROMPT
of the desired image(s) is required. The maximum length is 1000
characters.


### 2. Image Variations

Variations of a given _IMAGE_ can be generated. The _IMAGE_ to use as
the basis for the variations must be a valid PNG file, less than
4MB and square.


### 3. Image Edits

To edit an _IMAGE_, a _MASK_ file may be optionally provided. If _MASK_
is not provided, _IMAGE_ must have transparency, which will be used
as the mask. A text prompt is required.

#### 3.1 ImageMagick

If **ImageMagick** is available, input _IMAGE_ and _MASK_ will be checked
and processed to fit dimensions and other requirements.

#### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with "`-@`\[_COLOUR_]" to create the
mask. Defaults=_black_.

By defaults, the _COLOUR_ must be exact. Use the `fuzz option` to match
colours that are close to the target colour. This can be set with
"`-@`\[_VALUE%_]" as a percentage of the maximum possible intensity,
for example "`-@`_10%black_".

See also:

 - <https://imagemagick.org/script/color.php>
 - <https://imagemagick.org/script/command-line-options.php#fuzz>

#### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image
with the set transparent colour (defaults to _black_). In this way,
it is easy to make a mask with any black and white image as a
template.

#### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this
script. Paint a portion of the outer area of an image with _alpha_,
or a defined _transparent_ _colour_ which will be used as the mask, and set the
same _colour_ in the script with `-@`. Choose the best result amongst
many results to continue the out-painting process step-wise.


### AUDIO / WHISPER

### 1. Transcriptions

Transcribes audio file or voice record into the set language.
Set a _two-letter_ _ISO-639-1_ language code (_en_, _es_, _ja_, or _zh_) as
the positional argument following the input audio file. A prompt
may also be set as last positional parameter to help guide the
model. This prompt should match the audio language.

If the last positional argument is "." or "last" exactly, it will
resubmit the last recorded audio input file from cache.

Note that if the audio language is different from the set language code,
output will be on the language code (translation).


### 2. Translations

Translates audio into **English**. An optional text to guide
the model's style or continue a previous audio segment is optional
as last positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.


### ENVIRONMENT

**BLOCK_USR**

**BLOCK_USR_TTS**

:    Extra options for the request JSON block
      (e.g. "_\"seed\": 33, \"dimensions\": 1024_").


**CACHEDIR**

:    Script cache directory base.


**CHATGPTRC**

:    Path to the user _configuration file_.

     Defaults=\"_~/.chatgpt.conf_\"


**FILECHAT**

:    Path to a history / session TSV file (script-formatted).


**INSTRUCTION**

:    Initial initial instruction or system message.


**INSTRUCTION_CHAT**

:    Initial initial instruction or system message for chat mode.


**MOD_CHAT**, **MOD_IMAGE**, **MOD_AUDIO**,

**MOD_SPEECH**, **MOD_LOCALAI**, **MOD_OLLAMA**,

**MOD_MISTRAL**, **MOD_GOOGLE**, **MOD_GROQ**,

**MOD_AUDIO_GROQ**

:    Set default model for each endpoint / integration.


**OPENAI_API_HOST**

**OPENAI_API_HOST_STATIC**

:    Custom host URL. The _STATIC_ parameter disables endpoint auto selection.


**PROVIDER_API_HOST**

:    API host URL for the providers
     _LOCALAI_, _OLLAMA_, _MISTRAL_, _GOOGLE_, and _GROQ_.


**OPENAI_API_KEY**

**PROVIDER_API_KEY**

:    Keys for OpenAI, GoogleAI, MistralAI, and Groq APIs.


**OUTDIR**

:    Output directory for received image and audio.


**RESTART**

**START**

:    Restart and start sequences. May be set to _null_.

     Restart="_\\nQ:\ _" Start=\"_\\nA:_\"  (chat mode)


**VISUAL**

**EDITOR**

:    Text editor for external prompt editing.

     Defaults=\"_vim_\"


**CLIP_CMD**

:    Clipboard set command, e.g. "_xsel_ _-b_", "_pbcopy_".


**PLAY_CMD**

:    Audio player command, e.g. "_mpv --no-video --vo=null_".


**REC_CMD**

:    Audio recorder command, e.g. "_sox -d_".


### COLOUR THEMES

The colour scheme may be customised. A few themes are available
in the template configuration file.

A small colour library is available for the user conf file to personalise
the theme colours.

The colour palette is composed of _\$Red_, _\$Green_, _\$Yellow_, _\$Blue_,
_\$Purple_, _\$Cyan_, _\$White_, _\$Inv_ (invert), and _\$Nc_ (reset) variables.

Bold variations are defined as _\$BRed_, _\$BGreen_, etc, and
background colours can be set with _\$On_Yellow_, _\$On_Blue_, etc.

Alternatively, raw escaped color sequences, such as
_\\e[0;35m_, and _\\e[1;36m_ may be set.

Theme colours are named variables from `Colour1` to about `Colour11`,
and may be set with colour-named variables or
raw escape sequences (these must not change cursor position).


### REQUIRED PACKAGES

- `Bash`
- `cURL`, and `JQ`


### OPTIONAL PACKAGES

Optional packages for specific features.

- `Base64` - Image endpoint, vision models
- `ImageMagick`/`fbida` - Image edits and variations
- `Python` - Modules tiktoken, markdown, bs4
- `mpv`/`SoX`/`Vlc`/`FFmpeg`/`afplay` - Play TTS output
- `SoX`/`Arecord`/`FFmpeg` - Record input (Whisper)
- `xdg-open`/`open`/`xsel`/`xclip`/`pbcopy` - Open images, set clipboard
- `W3M`/`Lynx`/`ELinks`/`Links` - Dump URL text
- `bat`/`Pygmentize`/`Glow`/`mdcat`/`mdless` - Markdown support
- `termux-api`/`termux-tools`/`play-audio` - Termux system
- `poppler`/`gs`/`abiword`/`ebook-convert` - Dump PDF as text
- `dialog`/`kdialog`/`zenity`/`osascript`/`termux-dialog` - File picker


### BUGS

Bash "read command" may not correctly display input buffers larger than
the TTY screen size during editing. However, input buffers remain
unaffected. Use the text editor interface for big prompt editing.

File paths containing spaces may not work correctly with some script features.

Bash truncates input on "\\000" (null).

Garbage in, garbage out. An idiot savant.

<!-- NOT ANYMORE
Input sequences _\\n_, and _\\t_ must be double escaped to be treated
literally, otherwise these will be interpreted as escaped newlines,
and horizontal tabs in JSON encoding. This is specially important when
input contains *software code*. -->

<!-- Changing models in the same session may generate token count errors
because the recorded token count may differ from model encoding to encoding.
Set `option -y` for accurate token counting. -->

<!-- With the exception of Davinci and newer base models, older models were designed
to be run as one-shot. -->

<!-- The script is expected to work with language models and inputs
up to 32k tokens. -->

<!-- OBVIOUSLY, ALREADY MENTIONED
Instruction prompts are required for the model to even know that
it should answer questions. -->

<!--
`Zsh` does not read history file in non-interactive mode.

`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.

`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->


### LIMITS

The script objective is to implement most features of OpenAI
API version 1 but not all endpoints or options will be covered.

This project _doesn't_ support "Function Calling" or "Structured Outputs".


### OPTIONS

#### Model Settings

**-\@**, **\--alpha**   \[\[_VAL%_]_COLOUR_]

:      Set transparent colour of image mask. Def=_black_.

       Fuzz intensity can be set with \[_VAL%_]. Def=_0%_.


**-Nill**

: Unset model max response (chat cmpls only).


**-NUM**

**-M**, **\--max**   \[_NUM_[_-NUM_]]

:     Set maximum number of _response tokens_. Def=_1024_.

      A second number in the argument sets model capacity.


**-N**, **\--modmax**   \[_NUM_]

: Set _model capacity_ tokens. Def=_auto_, Fallback=_4000_.


**-a**, **\--presence-penalty**   \[_VAL_]

: Set presence penalty  (cmpls/chat, -2.0 - 2.0).


**-A**, **\--frequency-penalty**   \[_VAL_]

: Set frequency penalty (cmpls/chat, -2.0 - 2.0).


**-b**, **\--best-of**   \[_NUM_]

: Set best of, must be greater than `option -n` (cmpls). Def=_1_.


**-B**, **\--logprobs**   \[_NUM_]

: Request log probabilities, also see -Z (cmpls, 0 - 5),


**-j**, **--seed**  \[_NUM_]

:     Set a seed for deterministic sampling (integer).


**-K**, **--top-k**     \[_NUM_]

: Set Top_k value (local-ai, ollama, google).


**\--keep-alive**, **\--ka**=\[_NUM_]

: Set how long the model will stay loaded into memory (ollama).


**-m**, **\--model**   \[_MODEL_]

:     Set language _MODEL_ name. Def=_gpt-3.5-turbo-instruct_, _gpt-4o_.

      Set _MODEL_ name as "_._" to pick from the list.


**\--multimodal**

: Set model as multimodal.


**-n**, **\--results**   \[_NUM_]

: Set number of results. Def=_1_.


**-p**, **\--top-p**   \[_VAL_]

: Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).


**-r**, **\--restart**   \[_SEQ_]

: Set restart sequence string (cmpls).


**-R**, **\--start**   \[_SEQ_]

: Set start sequence string (cmpls).


**-s**, **\--stop**   \[_SEQ_]

: Set stop sequences, up to 4. Def=\"_\<|endoftext|>_\".


**-S**, **\--instruction**   \[_INSTRUCTION_|_FILE_]

: Set an instruction text prompt. It may be a text file.


**-t**, **\--temperature**   \[_VAL_]

: Set temperature value (cmpls/chat/whisper), (0.0 - 2.0, whisper 0.0 - 1.0). Def=_0_.


#### Script Modes

**-c**, **\--chat**

: Chat mode in text completions (used with `options -wzvv`).


**-cc**

: Chat mode in chat completions (used with `options -wzvv`).


**-C**, **\--continue**, **\--resume**

: Continue from (resume) last session (cmpls/chat).
 
**-d**, **\--text**

: Start new multi-turn session in plain text completions.


**-e**, **\--edit**

: Edit first input from stdin or file (cmpls/chat).


**-E**, **-EE**, **\--exit**

: Exit on first run (even with options -cc).


**-g**, **\--stream**   (_defaults_)

: Set response streaming.


**-G**, **\--no-stream**

: Unset response streaming.


**-i**, **\--image**   \[_PROMPT_]

: Generate images given a prompt.
  Set _option -v_ to not open response.


**-i**   \[_PNG_]

: Create variations of a given image.


**-i**   \[_PNG_] \[_MASK_] \[_PROMPT_]

: Edit image with mask and prompt (required).


**-qq**, **\--insert**

:     Insert text rather than completing only. May be set twice
      for multi-turn.

      Use "_\[insert]_" to indicate where the language model
      should insert text (`instruct` and Mistral `code` models).


**-S** **.**\[_PROMPT_NAME_], **-..**\[_PROMPT_NAME_]

**-S** **,**\[_PROMPT_NAME_], **-,**\[_PROMPT_NAME_]

:     Load, search for, or create custom prompt.
      
      Set `.`\[_PROMPT_] to single-shot edit prompt.

      Set `..`\[_PROMPT_] to silently load prompt.
      
      Set `,`\[_PROMPT_] to edit a prompt file.
      
      Set `.`_?_, or `.`_list_ to list prompt template files.


**-S** **/**\[_AWESOME_PROMPT_NAME_]

**-S** **%**\[_AWESOME_PROMPT_NAME_ZH_]

:     Set or search for an *awesome-chatgpt-prompt(-zh)*. _Davinci_ and _gpt3.5+_ models.
      
      Set **//** or **%%** instead to refresh cache.


**-T**, **\--tiktoken**

**-TT**

**-TTT**

:     Count input tokens with python Tiktoken (ignores special tokens).

      Set twice to print tokens, thrice to available encodings.
      
      Set the model or encoding with `option -m`.
      
      It heeds `options -ccm`.


**-w**, **\--transcribe**   \[_AUD_] \[_LANG_] \[_PROMPT_]

:     Transcribe audio file into text. LANG is optional.
      A prompt that matches the audio language is optional.
      Audio will be transcribed or translated to the target LANG.
      
      Set twice to phrase or thrice for word-level timestamps (-www).

      With `options -vv`, stop voice recorder on silence auto detection.


**-W**, **\--translate**   \[_AUD_] \[_PROMPT-EN_]

:     Translate audio file into English text.
      
      Set twice to phrase or thrice for word-level timestamps (-WWW).


### Script Settings

**\--api-key**   \[_KEY_]

: Set OpenAI API key.


**-f**, **\--no-conf**

: Ignore user configuration file.


**-F**

:     Edit configuration file with text editor, if it exists.
      
      \$CHATGPTRC=\"_~/.chatgpt.conf_\".


**-FF**

: Dump template configuration file to stdout.


**\--fold** (_defaults_), **\--no-fold**

: Set or unset response folding (wrap at white spaces).


**\--google**

: Set Google Gemini integration (cmpls/chat).


**\--groq**

: Set Groq integration (chat).


**-h**, **\--help**

: Print the help page.


**-H**, **\--hist**   \[`/`_HIST_FILE_]

:     Edit history file with text editor or pipe to stdout.
      
      A history file name can be optionally set as argument.


**-P**, **-PP**, **\--print**   \[`/`_HIST_FILE_]

:     Print out last history session.
      
      Set twice to print commented out history entries, inclusive.
      Heeds `options -ccdrR`.

      These are aliases to **-HH** and **-HHH**, respectively.


**-k**, **\--no-colour**

: Disable colour output. Def=_auto_.


**-l**, **\--list-models**   \[_MODEL_]

: List models or print details of _MODEL_.


**-L**, **\--log**   \[_FILEPATH_]

: Set log file. _FILEPATH_ is required.


**\--localai**

: Set LocalAI integration (cmpls/chat).


**\--mistral**

: Set Mistral AI integration (chat).


**\--md**, **\--markdown**, **\--markdown**=\[_SOFTWARE_]

: Enable markdown rendering in response. Software is optional:
  _bat_, _pygmentize_, _glow_, _mdcat_, or _mdless_.


**\--no-md**, **\--no-markdown**

: Disable markdown rendering.


**-o**, **\--clipboard**

: Copy response to clipboard.


**-O**, **\--ollama**

: Set and make requests to Ollama server (cmpls/chat).


**-u**, **\--multiline**

: Toggle multiline prompter, \<_CTRL-D_> flush.


**-U**, **\--cat**

: Set cat prompter, \<_CTRL-D_> flush.


**-v**, **\--verbose**

:     Less verbose.

      Sleep after response in voice chat (`-vvccw`).

      With `options -ccwv`, sleep after response. With `options -ccwzvv`,
      stop recording voice input on silence detection and play TTS response
	  right away.

      May be set multiple times.


**-V**

:     Dump raw JSON request block (debug).


**\--version**

: Print script version.


**-x**, **\--editor**

: Edit prompt in text editor.


**-y**, **\--tik**

: Set tiktoken for token count (cmpls/chat, python).


**-Y**, **\--no-tik**   (_defaults_)

: Unset tiktoken use (cmpls/chat, python).


**-z**, **\--tts**   \[_OUTFILE_|_FORMAT_|_-_] \[_VOICE_] \[_SPEED_] \[_PROMPT_]

:     Synthesise speech from text prompt. Takes a voice name, speed and text prompt.

      Set _option -v_ to not play response.


**-Z**, **-ZZ**, **-ZZZ**, **\--last**

: Print JSON data of the last responses.


