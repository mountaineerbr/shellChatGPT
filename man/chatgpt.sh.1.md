% CHATGPT.SH(1) v0.20.1 | General Commands Manual
% mountaineerbr
% October 2023


### NAME

|    chatgpt.sh \-- Wrapper for ChatGPT / DALL-E / Whisper


### SYNOPSIS

|    **chatgpt.sh** \[`-c`|`-d`] \[`opt`] \[_PROMPT_|_TEXT_FILE_]
|    **chatgpt.sh** `-e` \[`opt`] \[_INSTRUCTION_] \[_INPUT_|_TEXT_FILE_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PROMPT_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PNG_FILE_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PNG_FILE_] \[_MASK_FILE_] \[_PROMPT_]
|    **chatgpt.sh** `-TTT` \[-v] \[`-m`\[_MODEL_|_ENCODING_]] \[_INPUT_|_TEXT_FILE_]
|    **chatgpt.sh** `-w` \[`opt`] \[_AUDIO_FILE_] \[_LANG_] \[_PROMPT_]
|    **chatgpt.sh** `-W` \[`opt`] \[_AUDIO_FILE_] \[_PROMPT-EN_]
|    **chatgpt.sh** `-ccw` \[`opt`] \[_LANG_]
|    **chatgpt.sh** `-ccW` \[`opt`]
|    **chatgpt.sh** `-HHH` \[`/`_HIST_FILE_]
|    **chatgpt.sh** `-l` \[_MODEL_]


### DESCRIPTION

With no options set, complete INPUT in single-turn mode of
plain text completions. 

`Option -d` starts a multi-turn session in **plain text completions**.
This does not set further options automatically.

Set `option -c` to start a multi-turn chat mode via **text completions**
and record conversation. This option accepts davinci and lesser models,
defaults to _text-davinci-003_ if none set. In chat mode, some options
are automatically set to un-lobotomise the bot.
Set `option -E` to exit on the first response.

Set `option -cc` to start the chat mode via **native chat completions**
and use _gpt-3.5+ models_.

Set `option -C` to **resume** (continue from) last history session.

Set `option -q` for **insert mode**. The flag "_[insert]_" must be present
in the middle of the input prompt. Insert mode works completing
between the end of the text preceding the flag, and ends completion
with the succeeding text after the flag.
Insert mode works with models `davinci`, `text-davinci-002`, `text-davinci-003`,
and the newer `gpt-3.5-turbo-instruct`.

Positional arguments are read as a single **PROMPT**. Model **INSTRUCTION**
is usually optional and can be set with `option -S`.

When **INSTRUCTION** is mandatory for a chosen model (such as edits models),
the first positional argument is read as INSTRUCTION, if none set,
and the following ones as **INPUT** or **PROMPT**.

If the first positional argument of the script starts with the
command operator and a history file name, the
command "`/session` \[_HIST_NAME_]" is assumed. This wil
change to or create a new history file (with `options -ccCdHH`).

Set model with "`-m` \[_NAME_]" (full model name).
List available models with `option -l`.

Set _maximum response tokens_ with `option` "`-`_NUM_" or "`-M` _NUM_".
This defaults to 512 tokens.

If a second _NUM_ is given to this option, _maximum model capacity_
will also be set. The option syntax takes the form of "`-`_NUM/NUM_",
and "`-M` _NUM-NUM_".

_Model capacity_ (maximum model tokens) can be set more intuitively with
`option` "`-N` _NUM_", otherwise model capacity is set automatically
for known models, or to _2048_ tokens as fallback.

If a plain text file path is set as the first positional argument
of the script, the file is loaded as text PROMPT (text cmpls, chat cmpls,
and text/code edits).

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for
text cmpls, chat cmpls, and text/code edits. A text file path
may be supplied as the single argument.
Also see *CUSTOM / AWESOME PROMPTS* section below.

`Option -e` sets the **text edits** endpoint. That endpoint requires
both INSTRUCTION and INPUT prompts. User may choose a model amongst
the _edit model family_. This endpoint is going \*deprecated\*.

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an _IMAGE_ file, then **generate variations** of
it. If the first positional argument is an _IMAGE_ file and the second
a _MASK_ file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** _IMAGE_ according to _MASK_ and PROMPT.
If _MASK_ is not provided, _IMAGE_ must have transparency.

Optionally, size of output image may be set with "\[_S_]_mall_",
"\[_M_]_edium_" or "\[_L_]_arge_" as the first positional argument.
See **IMAGES section** below for more information on
**inpaint** and **outpaint**.

`Option -w` **transcribes audio** from _mp3_, _mp4_, _mpeg_, _mpga_,
_m4a_, _wav_, and _webm_ files.
First positional argument must be an _AUDIO_ file.
Optionally, set a _TWO-LETTER_ input language (_ISO-639-1_) as second
argument. A PROMPT may also be set to guide the model's style or continue
a previous audio segment. The prompt should match the audio language.

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional
argument.

Combine `-wW` **with** `-cc` to start **chat with voice input** (Whisper)
support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

`Option -y` sets python tiktoken instead of the default script hack
to preview token count. This option makes token count preview
accurate fast (we fork tiktoken as a coprocess for fast token queries).
Useful for rebuilding history context independently from the original
model used to generate responses.

Stdin is supported when there is no positional arguments left
after option parsing. Stdin input sets a single PROMPT.

While _cURL_ is in the middle of transmitting a request, or receiving
a response, \<_CTRL-C_\> may be pressed once to interrupt the call.

User configuration is kept at "_~/.chatgpt.conf_".
Script cache is kept at "_~/.cache/chatgptsh_".

A personal (free) OpenAI API is required, set it with `option -K`.
See also **ENVIRONMENT section**.

The moderation endpoint can be accessed by setting the model name
to _moderation_ (latest model).

See the online man page and script usage examples at:
<https://github.com/mountaineerbr/shellChatGPT/tree/main>.

For complete model and settings information, refer to OpenAI
API docs at <https://platform.openai.com/docs/>.


### TEXT / CHAT COMPLETIONS

#### 1. Text completions

Given a prompt, the model will return one or more predicted
completions. For example, given a partial input, the language
model will try completing it until probable "`<|endoftext|>`",
or other stop sequences (stops may be set with `-s`).

**Restart** and **start sequences** may be optionally set and are
always preceded by a new line.

To enable **multiline input**, set `option -u`. With this option set,
press \<_CTRL-D_> to flush input! This is useful to paste from clipboard.
Alternatively, set `option -U` to set _cat command_ as prompter.

Type in a backslash "_\\_" as the last character of the input line
to append a literal newline once and return to edition,
or press \<_CTRL-V_> _+_ \<_CTRL-J_>.

Language model **SKILLS** can activated, with specific prompts,
see <https://platform.openai.com/examples>.


#### 2. Chat Mode

##### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps
a history file, and keeps new questions in context. This works
with a variety of models. Set `option -E` to exit on response.

##### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. Turbo
models are also the best option for many non-chat use cases.

##### 2.3 Q & A Format

The defaults chat format is "**Q & A**". The **restart sequence**
"_\\n Q:\ _" and the **start text** "_\\n\ A:_" are injected
for the chat bot to work well with text cmpls.

In native chat completions, setting a prompt with "_:_" as the initial
character sets the prompt as a **SYSTEM** message. In text completions,
however, typing a colon "_:_" at the start of the prompt
causes the text following it to be appended immediately to the last
(response) prompt text.


##### 2.4 Chat Commands

While in chat mode, the following commands can be typed in the
new prompt to set a new parameter. The command operator
may be either "`!`", or "`/`".


  Misc        Commands
  --------    -----------------------    -------------------------------------------------------
      `-z`    `!last`                    Print last response json.
      `!i`    `!info`                    Information on model and session settings.
      `!j`    `!jump`                    Jump to request, append start seq primer (text cmpls).
     `!!j`    `!!jump`                   Jump to request, no response priming.
     `!sh`    `!shell`     \[_CMD_]      Run command, grab and edit output.
    `!!sh`    `!!shell`                  Open an interactive shell and exit.
  --------    -----------------------    -------------------------------------------------------

  Script      Settings
  --------    -----------------------    -------------------------------------------------------
      `-g`    `!stream`                  Toggle response streaming.
      `-l`    `!models`                  List language model names.
      `-o`    `!clip`                    Copy responses to clipboard.
      `-u`    `!multi`                   Toggle multiline prompter, \<_CTRL-D_> flush.
      `-U`    `!cat`                     Toggle cat prompter, \<_CTRL-D_> flush.
      `-V`    `!context`                 Print context before request (see `option -HH`).
     `-VV`    `!debug`                   Dump raw request block and confirm.
      `-v`    `!ver`                     Toggle verbose modes.
      `-x`    `!ed`                      Toggle text editor interface.
     `-xx`    `!!ed`                     Single-shot text editor.
      `-y`    `!tik`                     Toggle python tiktoken use.
      `!q`    `!quit`                    Exit. Bye.
      `!r`    `!regen`                   Regenerate last response.
      `!?`    `!help`                    Print a help snippet.
  --------    -----------------------    -------------------------------------------------------

  Model       Settings
  --------    -----------------------    --------------------------------------------
   `-Nill`    `!Nill`                    Unset model max response (chat cmpls).
      `-M`    `!NUM` `!max` \[_NUM_]     Set maximum response tokens.
      `-N`    `!modmax`    \[_NUM_]      Set model token capacity.
      `-a`    `!pre`       \[_VAL_]      Set presence penalty.
      `-A`    `!freq`      \[_VAL_]      Set frequency penalty.
      `-b`    `!best`      \[_NUM_]      Set best-of n results.
      `-m`    `!mod`       \[_MOD_]      Set model by name.
      `-n`    `!results`   \[_NUM_]      Set number of results.
      `-p`    `!top`       \[_VAL_]      Set top_p.
      `-r`    `!restart`   \[_SEQ_]      Set restart sequence.
      `-R`    `!start`     \[_SEQ_]      Set start sequence.
      `-s`    `!stop`      \[_SEQ_]      Set one stop sequence.
      `-t`    `!temp`      \[_VAL_]      Set temperature.
      `-w`    `!rec`                     Start audio record chat mode.
  --------    -----------------------    --------------------------------------------

  Session     Management
  --------    -------------------------------------    -----------------------------------------------------------
      `-`     `!list`                                  List history files (_tsv_).
      `-`     `!sub`       \[_REGEX_]                  Search sessions (for regex) and copy session to hist tail.
      `-c`    `!new`                                   Start new session.
      `-H`    `!hist`                                  Edit history in editor.
     `-HH`    `!req`                                   Print context request immediately (see `option -V`).
      `-L`    `!log`       \[_FILEPATH_]               Save to log file.
      `!c`    `!copy` \[_SRC_HIST_] \[_DEST_HIST_]     Copy session from source to destination.
      `!f`    `!fork`      \[_DEST_HIST_]              Fork current session to destination.
      `!k`    `!kill`      \[_NUM_]                    Comment out _n_ last entries in history file.
     `!!k`    `!!kill`     \[\[_0_]_NUM_]              Dry-run of command `!kill`.
      `!s`    `!session`   \[_HIST_FILE_]              Change to, search for, or create history file.
     `!!s`    `!!session`  \[_HIST_FILE_]              Same as `!session`, break session.
  --------    -------------------------------------    -----------------------------------------------------------


| E.g.: "`/temp` _0.7_", "`!mod`_gpt-4_", "`-p` _0.2_", and "`/s` _hist_name_".


###### 2.4.1 Session Management

The script uses a _TSV file_ to record entries, which is kept at the script
cache directory. A new history file can be created, or an existing one
changed to with command "`/session` \[_HIST_FILE_]", in which _HIST_FILE_
is the file name of (with or without the _.tsv_ extension),
or path to, a history file.

When the first postional argument to the script is the command operator
forward slash followed by a history file name,
the command `/session` is assumed.

A history file can contain many sessions. The last one (the tail session)
is always read if the resume `option -C` is set.

If "`/copy` _current_" is run, a selector is shown to choose and copy
a session to the tail of the current history file, and resume it.
This is equivalent to running "`/fork`". 

It is also possible to copy sessions of a history file to another file
when a second argument is given to the command with the history file name,
such as "`/copy` \[_SRC_HIST_FILE_] \[_DEST_HIST_FILE_]".

In order to change the chat context at run time, the history file may be
edited with the "`/hist`" command (also for context injection).
Delete history entries or comment them out with "`#`".


##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before committing it to history,
append a forward slash "`/`" to the prompt as the last character.
Regenerate it again or flush/accept the prompt and response.

After a response has been written to the history file, **regenerate**
it with command "`!regen`" or type in a single forward slash in the
new empty prompt.


#### 3. Prompt Engineering and Design

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


### CODE COMPLETIONS

Codex models are discontinued. Use davinci or _gpt-3.5+ models_ for coding tasks.

Turn comments into code, complete the next line or function in
context, add code comments, and rewrite code for efficiency,
amongst other functions.

Start with a comment with instructions, data or code. To create
useful completions it's helpful to think about what information
a programmer would need to perform a task. 


### TEXT EDITS  _(deprecated)_

This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify
a prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure
of text, or make targeted changes like fixing spelling. Edits
work well on empty prompts, thus enabling text generation similar
to the completions endpoint. 

Alternatively, use _gpt-4+ models_.


### ESCAPING NEW LINES AND TABS

As of _v0.18_, sequences "_\\n_" and "_\\t_" are only treated specially
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


### IMAGES / DALL-E

#### 1. Image Generations

An image can be created given a text prompt. A text PROMPT
of the desired image(s) is required. The maximum length is 1000
characters.


#### 2. Image Variations

Variations of a given _IMAGE_ can be generated. The _IMAGE_ to use as
the basis for the variations must be a valid PNG file, less than
4MB and square.


#### 3. Image Edits

To edit an _IMAGE_, a _MASK_ file may be optionally provided. If _MASK_
is not provided, _IMAGE_ must have transparency, which will be used
as the mask. A text prompt is required.

##### 3.1 ImageMagick

If **ImageMagick** is available, input _IMAGE_ and _MASK_ will be checked
and processed to fit dimensions and other requirements.

##### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with "`-@`\[_COLOUR_]" to create the
mask. Defaults=_black_.

By defaults, the _COLOUR_ must be exact. Use the `fuzz option` to match
colours that are close to the target colour. This can be set with
"`-@`\[_VALUE%_]" as a percentage of the maximum possible intensity,
for example "`-@`_10%black_".

See also:

 - <https://imagemagick.org/script/color.php>
 - <https://imagemagick.org/script/command-line-options.php#fuzz>

##### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image
with the set transparent colour (defaults to _black_). In this way,
it is easy to make a mask with any black and white image as a
template.

##### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this
script. Paint a portion of the outer area of an image with _alpha_,
or a defined _transparent_ _colour_ which will be used as the mask, and set the
same _colour_ in the script with `-@`. Choose the best result amongst
many results to continue the out-painting process step-wise.


Optionally, for all image generations, variations, and edits,
set **size of output image** with "_256x256_" ("_Small_"), "_512x512_" ("_Medium_"),
or "_1024x1024_" ("_Large_") as the first positional argument. Defaults=_512x512_.


### AUDIO / WHISPER

#### 1. Transcriptions

Transcribes audio file or voice record into the input language.
Set a _two-letter_ _ISO-639-1_ language code (_en_, _es_, _ja_, or _zh_) as
the positional argument following the input audio file. A prompt
may also be set as last positional parameter to help guide the
model. This prompt should match the audio language.


#### 2. Translations

Translates audio into **English**. An optional text to guide
the model's style or continue a previous audio segment is optional
as last positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.


### ENVIRONMENT

**APIURL**

:   Base API URL, along with endpoint. Note that this disables the script
    setting an endpoint automatically. <!-- By defaults, the endpoint is automatically set based on model name. -->

    To change only the base API URL, set **$APIURLBASE** instead.

    Defaults=\"_https://api.openai.com/v1/_**chat/completions**\"


**CHATGPTRC**

**CONFFILE**

:    Path to user _chatgpt.sh configuration_.

    Defaults=\"_~/.chatgpt.conf_\"


**FILECHAT**

: Path to a history / session TSV file (script-formatted).


**INSTRUCTION**

:    Initial initial instruction, or system message.


**INSTRUCTION_CHAT**

:    Initial initial instruction, or system message for chat mode.


**OPENAI_API_KEY**

**OPENAI_KEY**

:    Set your personal (free) OpenAI API key.


**REC_CMD**

:    Audio recording command (with `options -ccw` and `-Ww`), e.g. _sox_.


**VISUAL**

**EDITOR**

:    Text editor for external prompt editing.

     Defaults=\"_vim_\"


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


### BUGS AND LIMITS

<!-- NOT ANYMORE
Input sequences _\\n_, and _\\t_ must be double escaped to be treated
literally, otherwise these will be interpreted as escaped newlines,
and horizontal tabs in JSON encoding. This is specially important when
input contains *software code*. -->

<!-- Changing models in the same session may generate token count errors
because the recorded token count may differ from model encoding to encoding.
Set `option -y` for accurate token counting. -->

With the exception of Davinci models, older models were designed
to be run as one-shot.

The script is expected to work with language models and inputs
up to 32k tokens.

<!-- OBVIOUSLY, ALREADY MENTIONED
Instruction prompts are required for the model to even know that
it should answer questions. -->

Garbage in, garbage out. An idiot savant.

<!--
`Zsh` does not read history file in non-interactive mode.

`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.

`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->


### REQUIREMENTS

A free OpenAI **API key**. `Bash`, `cURL`, and `JQ`.

`ImageMagick`, and `Sox`/`Alsa-tools`/`FFmpeg` are optionally required.


### OPTIONS

#### Model Settings

**-\@** \[\[_VAL%_]_COLOUR_], **\--alpha**=\[\[_VAL%_]_COLOUR_]

:      Set transparent colour of image mask. Def=_black_.

       Fuzz intensity can be set with [VAL%]. Def=_0%_.


**-Nill**

:     Unset model max response (chat cmpls only).


**-NUM**

**-M** \[_NUM_[_/NUM_]], **\--max**=\[_NUM_[_-NUM_]]

:     Set maximum number of _response tokens_. Def=_512_.

      A second number in the argument sets model capacity.


**-N** \[_NUM_], **\--modmax**=\[_NUM_]

:     Set _model capacity_ tokens. Def=_auto_, fallback=_2048_.


**-a** \[_VAL_], **\--presence-penalty**=\[_VAL_]

: Set presence penalty  (cmpls/chat, -2.0 - 2.0).


**-A** \[_VAL_], **\--frequency-penalty**=\[_VAL_]

: Set frequency penalty (cmpls/chat, -2.0 - 2.0).


**-b** \[_NUM_], **\--best-of**=\[_NUM_]

: Set best of, must be greater than `option -n` (cmpls). Def=_1_.


**-B** \[_NUM_], **\--log-prob=\[_NUM_]**

: Request log probabilities, also see -z (cmpls, 0 - 5),


**-m** \[_MOD_], **\--model**=\[_MOD_]

: Set language MODEL name.


**-n** \[_NUM_], **\--results**=\[_NUM_]

: Set number of results. Def=_1_.


**-p** \[_VAL_], **\--top-p**=\[_VAL_]

: Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).


**-r** \[_SEQ_], **\--restart**=\[_SEQ_]

: Set restart sequence string (cmpls).


**-R** \[_SEQ_], **\--start**=\[_SEQ_]

: Set start sequence string (cmpls).


**-s** \[_SEQ_], **\--stop**=\[_SEQ_]

: Set stop sequences, up to 4. Def=\"_\<|endoftext|>_\".


**-S** \[_INSTRUCTION_|_FILE_], **\--instruction**=\[_STRING_]

: Set an instruction prompt. It may be a text file.


**-t** \[_VAL_], **\--temperature**=\[_VAL_]

: Set temperature value (cmpls/chat/edits/audio), (0.0 - 2.0, whisper 0.0 - 1.0). Def=_0_.


#### Script Modes

**-c**, **\--chat**

: Chat mode in text completions, session break.


**-cc**

: Chat mode in chat completions, session break.


**-C**, **\--continue**, **\--resume**

: Continue from (resume) last session (cmpls/chat).
 
**-d**, **\--text**

: Start new multi-turn session in plain text completions.


**-e** \[_INSTRUCTION_] \[_INPUT_], **\--edit**

: Set Edit mode. Model def=_text-davinci-edit-001_.


**-E**, **--exit**

: Exit on first run (even with options -cc).


**-g**, **\--stream**

: Set response streaming.


**-G**, **\--no-stream**

: Unset response streaming.


**-i** \[_PROMPT_], **\--image**

: Generate images given a prompt.


**-i** \[_PNG_]

: Create variations of a given image.


**-i** \[_PNG_] \[_MASK_] \[_PROMPT_]

: Edit image with mask and prompt (required).


**-q**, **\--insert**  <!-- _(deprecated)_ -->

:     Insert text rather than completing only. 

      Use "_\[insert]_" to indicate where the language model
      should insert text (only with some models of text cmpls).


**-S** `.`[_PROMPT_NAME_], **-,**\[_PROMPT_NAME_]

**-S** `,`[_PROMPT_NAME_], **-,**\[_PROMPT_NAME_]

:     Load, search for, or create custom prompt.

      Set `..`[_PROMPT_] to silently load prompt.
      
      Set `.`_?_, or `.`_list_ to list prompt template files.

      Set `,`[_PROMPT_] to edit a prompt file.


**-S** `/`[_AWESOME_PROMPT_NAME_]

**-S** `%`[_AWESOME_PROMPT_NAME_ZH_]

:     Set or search for an *awesome-chatgpt-prompt(-zh)*. _Davinci_ and _gpt3.5+_ models.
      
      Set `//` or `%%` instead to refresh cache.


**-T**, **\--tiktoken**

**-TT**

**-TTT**

:     Count input tokens with python tiktoken (ignores special tokens). It heeds `options -ccm`.

      Set twice to print tokens, thrice to available encodings.
      
      Set model or encoding with `option -m`.


**-w** \[_AUD_] \[_LANG_] \[_PROMPT_], **\--transcribe**

:     Transcribe audio file into text. LANG is optional.
      A prompt that matches the audio language is optional.
      
      Set twice to get phrase-level timestamps.


**-W** \[_AUD_] \[_PROMPT-EN_], **\--translate**

:     Translate audio file into English text.
      
      Set twice to get phrase-level timestamps.


### Script Settings

**-f**, **\--no-conf**

: Ignore user configuration file and environment.


**-F**

: Edit configuration file with text editor, if it exists.


**-FF**

: Dump template configuration file to stdout.


**-h**, **\--help**

: Print the help page.


**-H** \[`/`_HIST_FILE_], **\--hist**

:     Edit history file with text editor or pipe to stdout.
      
      A history file name can be optionally set as argument.


**-HH** \[`/`_HIST_FILE_], **-HHH**

:     Pretty print last history session to stdout.
      
      Heeds `options -ccdrR` to print with the specified restart and start sequences.

      Set thrice to print commented out hist entries, inclusive.


**-k**, **\--no-colour**

: Disable colour output. Def=_auto_.


**-K** \[_KEY_], **\--api-key**=\[_KEY_]

: Set OpenAI API key.


**-l** \[_MOD_], **\--list-models**

: List models or print details of _MODEL_.


**-L** \[_FILEPATH_], **\--log**=\[_FILEPATH_]

: Set log file. _FILEPATH_ is required.


**-o**, **\--clipboard**

: Copy response to clipboard.


**-u**, **\--multi**

: Toggle multiline prompter, \<_CTRL-D_> flush.


**-U**, **\--cat**

: Set cat prompter, \<_CTRL-D_> flush.


**-v**, **\--verbose**

:     Less verbose.

:     Sleep after response in voice chat (`-vvccw`).

:     May be set multiple times.


**-V**

**-VV**

:     Pretty-print context before request.
      
      Set twice to dump raw request block (debug).


**-x**, **\--editor**

: Edit prompt in text editor.


**-y**, **\--tik**

: Set tiktoken for token count (cmpls, chat, python).


**-Y**, **--no-tik**

: Unset tiktoken use (cmpls, chat, python).

**-z**, **\--last**

: Print last response JSON data.

