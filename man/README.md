---
author:
- mountaineerbr
date: October 2023
title: CHATGPT.SH(1) v0.20.1 \| General Commands Manual
---

### NAME

   chatgpt.sh -- Wrapper for ChatGPT / DALL-E / Whisper

### SYNOPSIS

   **chatgpt.sh** \[`-c`\|`-d`\] \[`opt`\] \[*PROMPT*\|*TEXT_FILE*\]  
   **chatgpt.sh** `-e` \[`opt`\] \[*INSTRUCTION*\]
\[*INPUT*\|*TEXT_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PROMPT*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]
\[*MASK_FILE*\] \[*PROMPT*\]  
   **chatgpt.sh** `-TTT` \[-v\] \[`-m`\[*MODEL*\|*ENCODING*\]\]
\[*INPUT*\|*TEXT_FILE*\]  
   **chatgpt.sh** `-w` \[`opt`\] \[*AUDIO_FILE*\] \[*LANG*\]
\[*PROMPT*\]  
   **chatgpt.sh** `-W` \[`opt`\] \[*AUDIO_FILE*\] \[*PROMPT-EN*\]  
   **chatgpt.sh** `-ccw` \[`opt`\] \[*LANG*\]  
   **chatgpt.sh** `-ccW` \[`opt`\]  
   **chatgpt.sh** `-HHH` \[`/`*HIST_FILE*\]  
   **chatgpt.sh** `-l` \[*MODEL*\]

### DESCRIPTION

With no options set, complete INPUT in single-turn mode of plain text
completions.

`Option -d` starts a multi-turn session in **plain text completions**.
This does not set further options automatically.

Set `option -c` to start a multi-turn chat mode via **text completions**
and record conversation. This option accepts davinci and lesser models,
defaults to *text-davinci-003* if none set. In chat mode, some options
are automatically set to un-lobotomise the bot. Set `option -E` to exit
on the first response.

Set `option -cc` to start the chat mode via **native chat completions**
and use *gpt-3.5+ models*.

Set `option -C` to **resume** (continue from) last history session.

Set `option -q` for **insert mode**. The flag “*\[insert\]*” must be
present in the middle of the input prompt. Insert mode works completing
between the end of the text preceding the flag, and ends completion with
the succeeding text after the flag. Insert mode works with models
`davinci`, `text-davinci-002`, `text-davinci-003`, and the newer
`gpt-3.5-turbo-instruct`.

Positional arguments are read as a single **PROMPT**. Model
**INSTRUCTION** is usually optional and can be set with `option -S`.

When **INSTRUCTION** is mandatory for a chosen model (such as edits
models), the first positional argument is read as INSTRUCTION, if none
set, and the following ones as **INPUT** or **PROMPT**.

If the first positional argument of the script starts with the command
operator and a history file name, the command “`/session`
\[*HIST_NAME*\]” is assumed. This wil change to or create a new history
file (with `options -ccCdHH`).

Set model with “`-m` \[*NAME*\]” (full model name). List available
models with `option -l`.

Set *maximum response tokens* with `option` “`-`*NUM*” or “`-M` *NUM*”.
This defaults to 512 tokens.

If a second *NUM* is given to this option, *maximum model capacity* will
also be set. The option syntax takes the form of “`-`*NUM/NUM*”, and
“`-M` *NUM-NUM*”.

*Model capacity* (maximum model tokens) can be set more intuitively with
`option` “`-N` *NUM*”, otherwise model capacity is set automatically for
known models, or to *2048* tokens as fallback.

If a plain text file path is set as the first positional argument of the
script, the file is loaded as text PROMPT (text cmpls, chat cmpls, and
text/code edits).

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text
cmpls, chat cmpls, and text/code edits. A text file path may be supplied
as the single argument. Also see *CUSTOM / AWESOME PROMPTS* section
below.

`Option -e` sets the **text edits** endpoint. That endpoint requires
both INSTRUCTION and INPUT prompts. User may choose a model amongst the
*edit model family*. This endpoint is going \*deprecated\*.

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an *IMAGE* file, then **generate variations** of
it. If the first positional argument is an *IMAGE* file and the second a
*MASK* file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** *IMAGE* according to *MASK* and PROMPT. If
*MASK* is not provided, *IMAGE* must have transparency.

Optionally, size of output image may be set with “\[*S*\]*mall*”,
“\[*M*\]*edium*” or “\[*L*\]*arge*” as the first positional argument.
See **IMAGES section** below for more information on **inpaint** and
**outpaint**.

`Option -w` **transcribes audio** from *mp3*, *mp4*, *mpeg*, *mpga*,
*m4a*, *wav*, and *webm* files. First positional argument must be an
*AUDIO* file. Optionally, set a *TWO-LETTER* input language
(*ISO-639-1*) as second argument. A PROMPT may also be set to guide the
model’s style or continue a previous audio segment. The prompt should
match the audio language.

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional argument.

Combine `-wW` **with** `-cc` to start **chat with voice input**
(Whisper) support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

`Option -y` sets python tiktoken instead of the default script hack to
preview token count. This option makes token count preview accurate fast
(we fork tiktoken as a coprocess for fast token queries). Useful for
rebuilding history context independently from the original model used to
generate responses.

Stdin is supported when there is no positional arguments left after
option parsing. Stdin input sets a single PROMPT.

While *cURL* is in the middle of transmitting a request, or receiving a
response, \<*CTRL-C*\> may be pressed once to interrupt the call.

User configuration is kept at “*~/.chatgpt.conf*”. Script cache is kept
at “*~/.cache/chatgptsh*”.

A personal (free) OpenAI API is required, set it with `option -K`. See
also **ENVIRONMENT section**.

The moderation endpoint can be accessed by setting the model name to
*moderation* (latest model).

See the online man page and script usage examples at:
<https://github.com/mountaineerbr/shellChatGPT/tree/main>.

For complete model and settings information, refer to OpenAI API docs at
<https://platform.openai.com/docs/>.

### TEXT / CHAT COMPLETIONS

#### 1. Text completions

Given a prompt, the model will return one or more predicted completions.
For example, given a partial input, the language model will try
completing it until probable “`<|endoftext|>`”, or other stop sequences
(stops may be set with `-s`).

**Restart** and **start sequences** may be optionally set and are always
preceded by a new line.

To enable **multiline input**, set `option -u`. With this option set,
press \<*CTRL-D*\> to flush input! This is useful to paste from
clipboard. Alternatively, set `option -U` to set *cat command* as
prompter.

Type in a backslash “*\\*” as the last character of the input line to
append a literal newline once and return to edition, or press
\<*CTRL-V*\> *+* \<*CTRL-J*\>.

Language model **SKILLS** can activated, with specific prompts, see
<https://platform.openai.com/examples>.

#### 2. Chat Mode

##### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps a
history file, and keeps new questions in context. This works with a
variety of models. Set `option -E` to exit on response.

##### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. Turbo models
are also the best option for many non-chat use cases.

##### 2.3 Q & A Format

The defaults chat format is “**Q & A**”. The **restart sequence** “*\n
Q: *” and the **start text** “*\n A:*” are injected for the chat bot to
work well with text cmpls.

In native chat completions, setting a prompt with “*:*” as the initial
character sets the prompt as a **SYSTEM** message. In text completions,
however, typing a colon “*:*” at the start of the prompt causes the text
following it to be appended immediately to the last (response) prompt
text.

##### 2.4 Chat Commands

While in chat mode, the following commands can be typed in the new
prompt to set a new parameter. The command operator may be either “`!`”,
or “`/`”.

| Misc   | Commands           |                                                        |
|:-------|:-------------------|--------------------------------------------------------|
| `-z`   | `!last`            | Print last response json.                              |
| `!i`   | `!info`            | Information on model and session settings.             |
| `!j`   | `!jump`            | Jump to request, append start seq primer (text cmpls). |
| `!!j`  | `!!jump`           | Jump to request, no response priming.                  |
| `!sh`  | `!shell` \[*CMD*\] | Run command, grab and edit output.                     |
| `!!sh` | `!!shell`          | Open an interactive shell and exit.                    |

| Script | Settings   |                                                  |
|:-------|:-----------|--------------------------------------------------|
| `-g`   | `!stream`  | Toggle response streaming.                       |
| `-l`   | `!models`  | List language model names.                       |
| `-o`   | `!clip`    | Copy responses to clipboard.                     |
| `-u`   | `!multi`   | Toggle multiline prompter, \<*CTRL-D*\> flush.   |
| `-U`   | `!cat`     | Toggle cat prompter, \<*CTRL-D*\> flush.         |
| `-V`   | `!context` | Print context before request (see `option -HH`). |
| `-VV`  | `!debug`   | Dump raw request block and confirm.              |
| `-v`   | `!ver`     | Toggle verbose modes.                            |
| `-x`   | `!ed`      | Toggle text editor interface.                    |
| `-xx`  | `!!ed`     | Single-shot text editor.                         |
| `-y`   | `!tik`     | Toggle python tiktoken use.                      |
| `!q`   | `!quit`    | Exit. Bye.                                       |
| `!r`   | `!regen`   | Regenerate last response.                        |
| `!?`   | `!help`    | Print a help snippet.                            |

| Model   | Settings                |                                        |
|:--------|:------------------------|----------------------------------------|
| `-Nill` | `!Nill`                 | Unset model max response (chat cmpls). |
| `-M`    | `!NUM` `!max` \[*NUM*\] | Set maximum response tokens.           |
| `-N`    | `!modmax` \[*NUM*\]     | Set model token capacity.              |
| `-a`    | `!pre` \[*VAL*\]        | Set presence penalty.                  |
| `-A`    | `!freq` \[*VAL*\]       | Set frequency penalty.                 |
| `-b`    | `!best` \[*NUM*\]       | Set best-of n results.                 |
| `-m`    | `!mod` \[*MOD*\]        | Set model by name.                     |
| `-n`    | `!results` \[*NUM*\]    | Set number of results.                 |
| `-p`    | `!top` \[*VAL*\]        | Set top_p.                             |
| `-r`    | `!restart` \[*SEQ*\]    | Set restart sequence.                  |
| `-R`    | `!start` \[*SEQ*\]      | Set start sequence.                    |
| `-s`    | `!stop` \[*SEQ*\]       | Set one stop sequence.                 |
| `-t`    | `!temp` \[*VAL*\]       | Set temperature.                       |
| `-w`    | `!rec`                  | Start audio record chat mode.          |

| Session | Management                             |                                                            |
|:--------|:---------------------------------------|------------------------------------------------------------|
| `-`     | `!list`                                | List history files (*tsv*).                                |
| `-`     | `!sub` \[*REGEX*\]                     | Search sessions (for regex) and copy session to hist tail. |
| `-c`    | `!new`                                 | Start new session.                                         |
| `-H`    | `!hist`                                | Edit history in editor.                                    |
| `-HH`   | `!req`                                 | Print context request immediately (see `option -V`).       |
| `-L`    | `!log` \[*FILEPATH*\]                  | Save to log file.                                          |
| `!c`    | `!copy` \[*SRC_HIST*\] \[*DEST_HIST*\] | Copy session from source to destination.                   |
| `!f`    | `!fork` \[*DEST_HIST*\]                | Fork current session to destination.                       |
| `!k`    | `!kill` \[*NUM*\]                      | Comment out *n* last entries in history file.              |
| `!!k`   | `!!kill` \[\[*0*\]*NUM*\]              | Dry-run of command `!kill`.                                |
| `!s`    | `!session` \[*HIST_FILE*\]             | Change to, search for, or create history file.             |
| `!!s`   | `!!session` \[*HIST_FILE*\]            | Same as `!session`, break session.                         |

E.g.: “`/temp` *0.7*”, “`!mod`*gpt-4*”, “`-p` *0.2*”, and “`/s`
*hist_name*”.

###### 2.4.1 Session Management

The script uses a *TSV file* to record entries, which is kept at the
script cache directory. A new history file can be created, or an
existing one changed to with command “`/session` \[*HIST_FILE*\]”, in
which *HIST_FILE* is the file name of (with or without the *.tsv*
extension), or path to, a history file.

When the first postional argument to the script is the command operator
forward slash followed by a history file name, the command `/session` is
assumed.

A history file can contain many sessions. The last one (the tail
session) is always read if the resume `option -C` is set.

If “`/copy` *current*” is run, a selector is shown to choose and copy a
session to the tail of the current history file, and resume it. This is
equivalent to running “`/fork`”.

It is also possible to copy sessions of a history file to another file
when a second argument is given to the command with the history file
name, such as “`/copy` \[*SRC_HIST_FILE*\] \[*DEST_HIST_FILE*\]”.

In order to change the chat context at run time, the history file may be
edited with the “`/hist`” command (also for context injection). Delete
history entries or comment them out with “`#`”.

##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before committing it to history, append a
forward slash “`/`” to the prompt as the last character. Regenerate it
again or flush/accept the prompt and response.

After a response has been written to the history file, **regenerate** it
with command “`!regen`” or type in a single forward slash in the new
empty prompt.

#### 3. Prompt Engineering and Design

Minimal **INSTRUCTION** to behave like a chatbot is given with chat
`options -cc`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, minimal instruction is given,
and some options auto set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of text
cmpls, such as Curie, the `best_of` option may be worth setting (to 2 or
3).

Prompt engineering is an art on itself. Study carefully how to craft the
best prompts to get the most out of text, code and chat cmpls models.

Certain prompts may return empty responses. Maybe the model has nothing
to further complete input or it expects more text. Try trimming spaces,
appending a full stop/ellipsis, resetting temperature, or adding more
text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing spaces in
its dictionary of tokens.

Note that the model’s steering and capabilities require prompt
engineering to even know that it should answer the questions.

It is also worth trying to sample 3 - 5 times (increasing the number of
responses with option `-n 3`, for example) in order to obtain a good
response.

For more on prompt design, see:

- <https://platform.openai.com/docs/guides/completion/prompt-design>
- <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>

See detailed info on settings for each endpoint at:

- <https://platform.openai.com/docs/>

### CODE COMPLETIONS

Codex models are discontinued. Use davinci or *gpt-3.5+ models* for
coding tasks.

Turn comments into code, complete the next line or function in context,
add code comments, and rewrite code for efficiency, amongst other
functions.

Start with a comment with instructions, data or code. To create useful
completions it’s helpful to think about what information a programmer
would need to perform a task.

### TEXT EDITS *(deprecated)*

This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify a
prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure of text,
or make targeted changes like fixing spelling. Edits work well on empty
prompts, thus enabling text generation similar to the completions
endpoint.

Alternatively, use *gpt-4+ models*.

### ESCAPING NEW LINES AND TABS

As of *v0.18*, sequences “*\n*” and “*\t*” are only treated specially in
restart, start and stop sequences!

### CUSTOM / AWESOME PROMPTS

When the argument to `option -S` starts with a full stop, such as “`-S`
`.`*my_prompt*”, load, search for, or create *my_prompt* prompt file. If
two full stops are prepended to the prompt name, load it silently. If a
comma is used instead, such as “`-S` `,`*my_prompt*”, edit the prompt
file, and then load it.

When the argument to `option -S` starts with a backslash or a percent
sign, such as “`-S` `/`*linux_terminal*”, search for an
*awesome-chatgpt-prompt(-zh)* (by Fatih KA and PlexPt). Set “`//`” or
“`%%`” to refresh local cache. Use with *davinci* and *gpt-3.5+* models.

These options also set corresponding history files automatically.

### IMAGES / DALL-E

#### 1. Image Generations

An image can be created given a text prompt. A text PROMPT of the
desired image(s) is required. The maximum length is 1000 characters.

#### 2. Image Variations

Variations of a given *IMAGE* can be generated. The *IMAGE* to use as
the basis for the variations must be a valid PNG file, less than 4MB and
square.

#### 3. Image Edits

To edit an *IMAGE*, a *MASK* file may be optionally provided. If *MASK*
is not provided, *IMAGE* must have transparency, which will be used as
the mask. A text prompt is required.

##### 3.1 ImageMagick

If **ImageMagick** is available, input *IMAGE* and *MASK* will be
checked and processed to fit dimensions and other requirements.

##### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with “`-@`\[*COLOUR*\]” to create the
mask. Defaults=*black*.

By defaults, the *COLOUR* must be exact. Use the `fuzz option` to match
colours that are close to the target colour. This can be set with
“`-@`\[*VALUE%*\]” as a percentage of the maximum possible intensity,
for example “`-@`*10%black*”.

See also:

- <https://imagemagick.org/script/color.php>
- <https://imagemagick.org/script/command-line-options.php#fuzz>

##### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image with
the set transparent colour (defaults to *black*). In this way, it is
easy to make a mask with any black and white image as a template.

##### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this script.
Paint a portion of the outer area of an image with *alpha*, or a defined
*transparent* *colour* which will be used as the mask, and set the same
*colour* in the script with `-@`. Choose the best result amongst many
results to continue the out-painting process step-wise.

Optionally, for all image generations, variations, and edits, set **size
of output image** with “*256x256*” (“*Small*”), “*512x512*”
(“*Medium*”), or “*1024x1024*” (“*Large*”) as the first positional
argument. Defaults=*512x512*.

### AUDIO / WHISPER

#### 1. Transcriptions

Transcribes audio file or voice record into the input language. Set a
*two-letter* *ISO-639-1* language code (*en*, *es*, *ja*, or *zh*) as
the positional argument following the input audio file. A prompt may
also be set as last positional parameter to help guide the model. This
prompt should match the audio language.

#### 2. Translations

Translates audio into **English**. An optional text to guide the model’s
style or continue a previous audio segment is optional as last
positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.

### ENVIRONMENT

**APIURL**  
Base API URL, along with endpoint. Note that this disables the script
setting an endpoint automatically.
<!-- By defaults, the endpoint is automatically set based on model name. -->

To change only the base API URL, set **\$APIURLBASE** instead.

Defaults="*https://api.openai.com/v1/***chat/completions**"

**CHATGPTRC**

**CONFFILE**  
Path to user *chatgpt.sh configuration*.

Defaults="*~/.chatgpt.conf*"

**FILECHAT**  
Path to a history / session TSV file (script-formatted).

**INSTRUCTION**  
Initial initial instruction, or system message.

**INSTRUCTION_CHAT**  
Initial initial instruction, or system message for chat mode.

**OPENAI_API_KEY**

**OPENAI_KEY**  
Set your personal (free) OpenAI API key.

**REC_CMD**  
Audio recording command (with `options -ccw` and `-Ww`), e.g. *sox*.

**VISUAL**

**EDITOR**  
Text editor for external prompt editing.

Defaults="*vim*"

### COLOUR THEMES

The colour scheme may be customised. A few themes are available in the
template configuration file.

A small colour library is available for the user conf file to
personalise the theme colours.

The colour palette is composed of *\$Red*, *\$Green*, *\$Yellow*,
*\$Blue*, *\$Purple*, *\$Cyan*, *\$White*, *\$Inv* (invert), and *\$Nc*
(reset) variables.

Bold variations are defined as *\$BRed*, *\$BGreen*, etc, and background
colours can be set with *\$On_Yellow*, *\$On_Blue*, etc.

Alternatively, raw escaped color sequences, such as *\e\[0;35m*, and
*\e\[1;36m* may be set.

Theme colours are named variables from `Colour1` to about `Colour11`,
and may be set with colour-named variables or raw escape sequences
(these must not change cursor position).

### BUGS AND LIMITS

<!-- NOT ANYMORE
Input sequences _\\n_, and _\\t_ must be double escaped to be treated
literally, otherwise these will be interpreted as escaped newlines,
and horizontal tabs in JSON encoding. This is specially important when
input contains *software code*. -->
<!-- Changing models in the same session may generate token count errors
because the recorded token count may differ from model encoding to encoding.
Set `option -y` for accurate token counting. -->

With the exception of Davinci models, older models were designed to be
run as one-shot.

The script is expected to work with language models and inputs up to 32k
tokens.

<!-- OBVIOUSLY, ALREADY MENTIONED
Instruction prompts are required for the model to even know that
it should answer questions. -->

Garbage in, garbage out. An idiot savant.

<!--
`Zsh` does not read history file in non-interactive mode.
&#10;`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.
&#10;`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->

### REQUIREMENTS

A free OpenAI **API key**. `Bash`, `cURL`, and `JQ`.

`ImageMagick`, and `Sox`/`Alsa-tools`/`FFmpeg` are optionally required.

### OPTIONS

#### Model Settings

**-@** \[\[*VAL%*\]*COLOUR*\], **--alpha**=\[\[*VAL%*\]*COLOUR*\]  
Set transparent colour of image mask. Def=*black*.

Fuzz intensity can be set with \[VAL%\]. Def=*0%*.

**-Nill**  
Unset model max response (chat cmpls only).

**-NUM**

**-M** \[*NUM*\[*/NUM*\]\], **--max**=\[*NUM*\[*-NUM*\]\]  
Set maximum number of *response tokens*. Def=*512*.

A second number in the argument sets model capacity.

**-N** \[*NUM*\], **--modmax**=\[*NUM*\]  
Set *model capacity* tokens. Def=*auto*, fallback=*2048*.

**-a** \[*VAL*\], **--presence-penalty**=\[*VAL*\]  
Set presence penalty (cmpls/chat, -2.0 - 2.0).

**-A** \[*VAL*\], **--frequency-penalty**=\[*VAL*\]  
Set frequency penalty (cmpls/chat, -2.0 - 2.0).

**-b** \[*NUM*\], **--best-of**=\[*NUM*\]  
Set best of, must be greater than `option -n` (cmpls). Def=*1*.

**-B** \[*NUM*\], **--log-prob=\[*NUM*\]**  
Request log probabilities, also see -z (cmpls, 0 - 5),

**-m** \[*MOD*\], **--model**=\[*MOD*\]  
Set language MODEL name.

**-n** \[*NUM*\], **--results**=\[*NUM*\]  
Set number of results. Def=*1*.

**-p** \[*VAL*\], **--top-p**=\[*VAL*\]  
Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).

**-r** \[*SEQ*\], **--restart**=\[*SEQ*\]  
Set restart sequence string (cmpls).

**-R** \[*SEQ*\], **--start**=\[*SEQ*\]  
Set start sequence string (cmpls).

**-s** \[*SEQ*\], **--stop**=\[*SEQ*\]  
Set stop sequences, up to 4. Def="*\<\|endoftext\|\>*".

**-S** \[*INSTRUCTION*\|*FILE*\], **--instruction**=\[*STRING*\]  
Set an instruction prompt. It may be a text file.

**-t** \[*VAL*\], **--temperature**=\[*VAL*\]  
Set temperature value (cmpls/chat/edits/audio), (0.0 - 2.0, whisper
0.0 - 1.0). Def=*0*.

#### Script Modes

**-c**, **--chat**  
Chat mode in text completions, session break.

**-cc**  
Chat mode in chat completions, session break.

**-C**, **--continue**, **--resume**  
Continue from (resume) last session (cmpls/chat).

**-d**, **--text**  
Start new multi-turn session in plain text completions.

**-e** \[*INSTRUCTION*\] \[*INPUT*\], **--edit**  
Set Edit mode. Model def=*text-davinci-edit-001*.

**-E**, **–exit**  
Exit on first run (even with options -cc).

**-g**, **--stream**  
Set response streaming.

**-G**, **--no-stream**  
Unset response streaming.

**-i** \[*PROMPT*\], **--image**  
Generate images given a prompt.

**-i** \[*PNG*\]  
Create variations of a given image.

**-i** \[*PNG*\] \[*MASK*\] \[*PROMPT*\]  
Edit image with mask and prompt (required).

**-q**, **--insert** <!-- _(deprecated)_ -->  
Insert text rather than completing only.

Use “*\[insert\]*” to indicate where the language model should insert
text (only with some models of text cmpls).

**-S** `.`\[*PROMPT_NAME*\], **-,**\[*PROMPT_NAME*\]

**-S** `,`\[*PROMPT_NAME*\], **-,**\[*PROMPT_NAME*\]  
Load, search for, or create custom prompt.

Set `..`\[*PROMPT*\] to silently load prompt.

Set `.`*?*, or `.`*list* to list prompt template files.

Set `,`\[*PROMPT*\] to edit a prompt file.

**-S** `/`\[*AWESOME_PROMPT_NAME*\]

**-S** `%`\[*AWESOME_PROMPT_NAME_ZH*\]  
Set or search for an *awesome-chatgpt-prompt(-zh)*. *Davinci* and
*gpt3.5+* models.

Set `//` or `%%` instead to refresh cache.

**-T**, **--tiktoken**

**-TT**

**-TTT**  
Count input tokens with python tiktoken (ignores special tokens). It
heeds `options -ccm`.

Set twice to print tokens, thrice to available encodings.

Set model or encoding with `option -m`.

**-w** \[*AUD*\] \[*LANG*\] \[*PROMPT*\], **--transcribe**  
Transcribe audio file into text. LANG is optional. A prompt that matches
the audio language is optional.

Set twice to get phrase-level timestamps.

**-W** \[*AUD*\] \[*PROMPT-EN*\], **--translate**  
Translate audio file into English text.

Set twice to get phrase-level timestamps.

### Script Settings

**-f**, **--no-conf**  
Ignore user configuration file and environment.

**-F**  
Edit configuration file with text editor, if it exists.

**-FF**  
Dump template configuration file to stdout.

**-h**, **--help**  
Print the help page.

**-H** \[`/`*HIST_FILE*\], **--hist**  
Edit history file with text editor or pipe to stdout.

A history file name can be optionally set as argument.

**-HH** \[`/`*HIST_FILE*\], **-HHH**  
Pretty print last history session to stdout.

Heeds `options -ccdrR` to print with the specified restart and start
sequences.

Set thrice to print commented out hist entries, inclusive.

**-k**, **--no-colour**  
Disable colour output. Def=*auto*.

**-K** \[*KEY*\], **--api-key**=\[*KEY*\]  
Set OpenAI API key.

**-l** \[*MOD*\], **--list-models**  
List models or print details of *MODEL*.

**-L** \[*FILEPATH*\], **--log**=\[*FILEPATH*\]  
Set log file. *FILEPATH* is required.

**-o**, **--clipboard**  
Copy response to clipboard.

**-u**, **--multi**  
Toggle multiline prompter, \<*CTRL-D*\> flush.

**-U**, **--cat**  
Set cat prompter, \<*CTRL-D*\> flush.

**-v**, **--verbose**  
Less verbose.

Sleep after response in voice chat (`-vvccw`).

May be set multiple times.

**-V**

**-VV**  
Pretty-print context before request.

Set twice to dump raw request block (debug).

**-x**, **--editor**  
Edit prompt in text editor.

**-y**, **--tik**  
Set tiktoken for token count (cmpls, chat, python).

**-Y**, **–no-tik**  
Unset tiktoken use (cmpls, chat, python).

**-z**, **--last**  
Print last response JSON data.