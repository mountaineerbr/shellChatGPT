---
author:
- mountaineerbr
date: July 2024
title: CHATGPT.SH(1) v0.68.2 \| General Commands Manual
---

### NAME

   chatgpt.sh -- Wrapper for ChatGPT / DALL-E / Whisper / TTS

### SYNOPSIS

   **chatgpt.sh** \[`-cc`\|`-d`\|`-qq`\] \[`opt`..\]
\[*PROMPT*\|*TEXT_FILE*\|*PDF_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`..\] \[*X*\|*L*\|*P*\]\[*hd*\]
\[*PROMPT*\] \#Dall-E-3  
   **chatgpt.sh** `-i` \[`opt`..\] \[*S*\|*M*\|*L*\] \[*PROMPT*\]  
   **chatgpt.sh** `-i` \[`opt`..\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`..\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]
\[*MASK_FILE*\] \[*PROMPT*\]  
   **chatgpt.sh** `-w` \[`opt`..\] \[*AUDIO_FILE*\|*.*\] \[*LANG*\]
\[*PROMPT*\]  
   **chatgpt.sh** `-W` \[`opt`..\] \[*AUDIO_FILE*\|*.*\]
\[*PROMPT-EN*\]  
   **chatgpt.sh** `-z` \[`opt`..\] \[*OUTFILE*\|*FORMAT*\|*-*\]
\[*VOICE*\] \[*SPEED*\] \[*PROMPT*\]  
   **chatgpt.sh** `-ccWwz` \[`opt`..\] -- \[*PROMPT*\] --
\[`whisper_arg`..\] -- \[`tts_arg`..\]  
   **chatgpt.sh** `-l` \[*MODEL*\]  
   **chatgpt.sh** `-TTT` \[-v\] \[`-m`\[*MODEL*\|*ENCODING*\]\]
\[*INPUT*\|*TEXT_FILE*\|*PDF_FILE*\]  
   **chatgpt.sh** `-HHPP` \[`/`*HIST_FILE*\|*.*\]  
   **chatgpt.sh** `-HHPw`

### DESCRIPTION

With no options set, complete INPUT in single-turn mode of plain text
completions.

`Option -d` starts a multi-turn session in **plain text completions**.
This does not set further options automatically.

Set `option -c` to start a multi-turn chat mode via **text completions**
and record conversation. This option accepts davinci and lesser models,
defaults to *gpt-3.5-turbo-instruct* if none set. In chat mode, some
options are automatically set to un-lobotomise the bot. Set `option -E`
to exit on the first response.

Set `option -cc` to start the chat mode via **native chat completions**
and defaults to *gpt-4o*.

Set `option -C` to **resume** (continue from) last history session.

Set `option -q` for **insert mode**. The flag “*\[insert\]*” must be
present in the middle of the input prompt. Insert mode works completing
between the end of the text preceding the flag, and ends completion with
the succeeding text after the flag. Insert mode works with `instruct`
and Mistral `code` models.

Positional arguments are read as a single **PROMPT**. Model
**INSTRUCTION** is usually optional and can be set with `option -S`.

In multi-turn interactions, prompts prefixed with a single colon “*:*”
are appended to the current request buffer as user messages without
making a new API call. Conversely, prompts starting with double colons
“*::*” are appended as instruction / system messages. For text cmpls
only, triple colons append the text immediately to the previous prompt
without a restart sequence.

If a plain text or PDF file path is set as the first positional
argument, or as an argument to `option -S` (set instruction prompt), the
file is loaded as text PROMPT.

With **vision models**, insert an image to the prompt with chat command
“`!img` \[*url*\|*filepath*\]”. Image urls and files can also be
appended by typing the operator pipe and a valid input at the end of the
text prompt, such as “`|` \[*url*\|*filepath*\]”.

To create and reuse a custom prompt, set the prompt name as a command
line option, such as “`-S .[_prompt_name_]`” or
“`-S ..[_prompt_name_]`”. Note that loading a custom prompt will also
change to its respective history file.

Alternatively, set the first positional argument with the operator plus
the name, such as “`..[_prompt_]`”, unless instruction was set manually.

If the first positional argument of the script starts with the command
operator forward slash “`/`” and a history file name, the command
“`/session` \[*HIST_NAME*\]” is assumed. This will change to or create a
new history file (with `options -ccCdHH`).

Set model with “`-m` \[*MODEL*\]”, with *MODEL* as its name, or set it
as “*.*” to pick from the model list. List available models with
`option -l`.

Set *maximum response tokens* with `option` “`-`*NUM*” or “`-M` *NUM*”.
This defaults to *1024* tokens.

If a second *NUM* is given to this option, *maximum model capacity* will
also be set. The option syntax takes the form of “`-`*NUM/NUM*”, and
“`-M` *NUM-NUM*”.

*Model capacity* (maximum model tokens) can be set more intuitively with
`option` “`-N` *NUM*”, otherwise model capacity is set automatically for
known models, or to *2048* tokens as fallback.

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text
cmpls, and chat cmpls. A text file path may be supplied as the single
argument. Also see *CUSTOM / AWESOME PROMPTS* section below.

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an *IMAGE* file, then **generate variations** of
it. If the first positional argument is an *IMAGE* file and the second a
*MASK* file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** *IMAGE* according to *MASK* and PROMPT. If
*MASK* is not provided, *IMAGE* must have transparency.

The **size of output images** may be set as the first positional
parameter in the command line: “*256x256*” (*S*), “*512x512*” (*M*),
“*1024x1024*” (*L*), “*1792x1024*” (*X*), and “*1024x1792*” (*P*).

The parameter “*hd*” may also be set for image quality (*Dall-E-3*),
such as “*Xhd*”, or “*1792x1024hd*”. Defaults=*1024x1024*.

See **IMAGES section** below for more information on **inpaint** and
**outpaint**.

`Option -w` **transcribes audio** from *mp3*, *mp4*, *mpeg*, *mpga*,
*m4a*, *wav*, *webm*, *flac* and *ogg* files. First positional argument
must be an *AUDIO* file. Optionally, set a *TWO-LETTER* input language
(*ISO-639-1*) as the second argument. A PROMPT may also be set to guide
the model’s style, or continue a previous audio segment. The text prompt
should match the audio language.

Note that `option -w` can also be set to **translate audio** input to
any text language to the target language.

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional argument.

Set these options twice to have phrasal-level timestamps, options -ww
and -WW. Set thrice for word-level timestamps.

Combine `options -wW` **with** `options -cc` to start **chat with voice
input** (Whisper) support. Additionally, set `option -z` to enable
**text-to-speech** (TTS) models and voice out.

`Option -z` synthesises voice from text (TTS models). Set a *voice* as
the first positional parameter (“*alloy*”, “*echo*”, “*fable*”,
“*onyx*”, “*nova*”, or “*shimmer*”). Set the second positional parameter
as the *voice speed* (*0.25* - *4.0*), and, finally the *output file
name* or the *format*, such as “*./new_audio.mp3*” (“*mp3*”, “*opus*”,
“*aac*”, and “*flac*”), or “*-*” for stdout. Set `options -vz` to *not*
play received output.

`Option -y` sets python tiktoken instead of the default script hack to
preview token count. This option makes token count preview accurate fast
(we fork tiktoken as a coprocess for fast token queries). Useful for
rebuilding history context independently from the original model used to
generate responses.

The moderation endpoint can be accessed by setting the model name to
*text-moderation-latest*.

Stdin text is appended to PROMPT, to set a single PROMPT.

While *cURL* is in the middle of transmitting a request, or receiving a
response, \<*CTRL-C*\> may be pressed once to interrupt the call.

Press \<*CTRL-X* *CTRL-E*\> to edit command line in text editor
(readline).

Press \<*CTRL-J*\> or \<*CTRL-V* *CTRL-J*\> for newline (readline).

Press \<*CTRL-\\*\> to exit from the script, even if recording,
requesting, or playing TTS.

User configuration is kept at “*~/.chatgpt.conf*”. Script cache is kept
at “*~/.cache/chatgptsh/*”.

A personal OpenAI API is required, set it with `option --api-key`. See
also **ENVIRONMENT section**.

This script also supports warping LocalAI, Ollama, Gemini and Mistral
APIs.

For LocalAI integration, run the script with `option --localai`, or set
environment **\$OPENAI_API_HOST** with the server URL.

For Mistral AI set environment variable **\$MISTRAL_API_KEY**, and run
the script with `option --mistral` or set **\$OPENAI_API_HOST** to
“https://api.mistral.ai/”. Prefer setting command line
`option --mistral` for complete integration.
<!-- also see: \$MISTRAL_API_HOST -->

And for Groq, set the environmental variable `$GROQ_API_KEY`. Run the
script with `option --groq`. Whisper endpoint available.

List models with `option -l`, or run `/models` in chat mode.

<!--
Install models with `option -l` or chat command `/models`
and the `install` keyword.
&#10;Also supply a _model configuration file URL_ or,
if LocalAI server is configured with Galleries,
set "_\<GALLERY>_@_\<MODEL_NAME>_".
Gallery defaults to HuggingFace.
&#10;* NOTE: *  I recommend using LocalAI own binary to install the models!
-->
<!-- LocalAI only tested with text and chat completion models (vision) -->

For Ollama, set `option -O` (`--ollama`), and set **\$OLLAMA_API_HOST**
if the server URL is different from the defaults.

Note that model management (downloading and setting up) must follow the
Ollama project guidelines and own methods.

For Google Gemini, set environment variable **\$GOOGLE_API_KEY**, and
run the script with the command line `option --google`.

Command “`!block` \[*args*\]” may be run to set raw model options in
JSON syntax according to each API. Alternatively, set envar
**\$BLOCK_USR**.

For complete model and settings information, refer to OpenAI API docs at
<https://platform.openai.com/docs/>.

See the online man page and `chatgpt.sh` usage examples at:
<https://gitlab.com/fenixdragao/shellchatgpt>.

### TEXT / CHAT COMPLETIONS

### 1. Text completions

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

<!--  [DISABLED]
Type in a backslash "_\\_" as the last character of the input line
to append a literal newline once and return to edition,
or press \<_CTRL-V_ _CTRL-J_>.
-->

Bash bracketed paste is enabled, meaning multiline input may be pasted
or typed, even without setting `options -uU` (*v25.2+*).

Language model **SKILLS** can activated, with specific prompts, see
<https://platform.openai.com/examples>.

### 2. Chat Mode

#### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps a
history file, and keeps new questions in context. This works with a
variety of models. Set `option -E` to exit on response.

#### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. Turbo models
are also the best option for many non-chat use cases.

#### 2.3 Q & A Format

The defaults chat format is “**Q & A**”. The **restart sequence**
“*\nQ: *” and the **start text** “*\nA:*” are injected for the chat bot
to work well with text cmpls.

In native chat completions, setting a prompt with “*:*” as the initial
character sets the prompt as a **SYSTEM** message. In text completions,
however, typing a colon “*:*” at the start of the prompt causes the text
following it to be appended immediately to the last (response) prompt
text.

#### 2.4 Voice input (Whisper), and voice output (TTS)

The `options -ccwz` may be combined to have voice recording input and
synthesised voice output, specially nice with chat modes. When setting
`flag -w`, or `flag -z`, the first positional parameters are read as
Whisper, or TTS arguments. When setting both `flags -wz`, add a double
hyphen to set first Whisper, and then TTS arguments.

Set chat mode, plus Whisper language and prompt, and the TTS voice
option argument:

    chatgpt.sh -ccwz  en 'whisper prompt'  --  nova

#### 2.5 GPT-4-Vision

To send an *image*, or *url* to **vision models**, either set the image
with the `!img` chat command with one or more *filepaths* / *urls*
separated by the operator pipe *\|*.

    chatgpt.sh -cc -m gpt-4-vision-preview '!img path/to/image.jpg'

Alternatively, set the *image paths* / *urls* at the end of the text
prompt interactively:

    chatgpt.sh -cc -m gpt-4-vision-preview

    [...]
    Q: In this first user prompt, what can you see? | https://i.imgur.com/wpXKyRo.jpeg

#### 2.6 Chat Commands

While in chat mode, the following commands can be typed in the new
prompt to set a new parameter. The command operator may be either “`!`”,
or “`/`”.

| Misc      | Commands                        |                                                         |
|:----------|:--------------------------------|---------------------------------------------------------|
| `-S`      | `:`, `::` \[*PROMPT*\]          | Append user or system prompt to request buffer.         |
| `-S.`     | `-.` \[*NAME*\]                 | Load and edit custom prompt.                            |
| `-S/`     | `-S%` \[*NAME*\]                | Load and edit awesome prompt (zh).                      |
| `-Z`      | `!last`                         | Print last response JSON.                               |
| `!#`      | `!save` \[*PROMPT*\]            | Save current prompt to shell history. *‡*               |
| `!`       | `!r`, `!regen`                  | Regenerate last response.                               |
| `!!`      | `!rr`                           | Regenerate response, edit prompt first.                 |
| `!i`      | `!info`                         | Information on model and session settings.              |
| `!j`      | `!jump`                         | Jump to request, append start seq primer (text cmpls).  |
| `!!j`     | `!!jump`                        | Jump to request, no response priming.                   |
| `!md`     | `!markdown` \[*SOFTW*\]         | Toggle markdown rendering in response.                  |
| `!!md`    | `!!markdown` \[*SOFTW*\]        | Render last response in markdown.                       |
| `!rep`    | `!replay`                       | Replay last TTS audio response.                         |
| `!res`    | `!resubmit`                     | Resubmit last TTS recorded input from cache.            |
| `!cat`    | \-                              | Cat prompter as one-shot, \<*CTRL-D*\> flush.           |
| `!cat`    | `!cat:` \[*TXT*\|*URL*\|*PDF*\] | Cat *text* or *PDF* file, or dump *URL*.                |
| `!dialog` | \-                              | Toggle the “dialog” interface.                          |
| `!img`    | `!media` \[*FILE*\|*URL*\]      | Append image, media, or URL to prompt.                  |
| `!p`      | `!pick`, \[*PROPMT*\]           | File picker, appends filepath to user prompt. *‡*       |
| `!pdf`    | `!pdf:` \[*FILE*\]              | Convert PDF and dump text.                              |
| `!photo`  | `!!photo` \[*INDEX*\]           | Take a photo, optionally set camera index (Termux). *‡* |
| `!sh`     | `!shell` \[*CMD*\]              | Run shell, or *command*, and edit output.               |
| `!sh:`    | `!shell:` \[*CMD*\]             | Same as `!sh` but apppend output as user.               |
| `!!sh`    | `!!shell` \[*CMD*\]             | Run interactive shell (with *command*) and exit.        |
| `!url`    | `!url:` \[*URL*\]               | Dump URL text.                                          |

| Script  | Settings and UX      |                                                           |
|:--------|:---------------------|-----------------------------------------------------------|
| `!fold` | `!wrap`              | Toggle response wrapping.                                 |
| `-g`    | `!stream`            | Toggle response streaming.                                |
| `-h`    | `!help` \[*REGEX*\]  | Print help snippet or grep help for regex.                |
| `-l`    | `!models` \[*NAME*\] | List language models or show model details.               |
| `-o`    | `!clip`              | Copy responses to clipboard.                              |
| `-u`    | `!multi`             | Toggle multiline prompter. \<*CTRL-D*\> flush.            |
| `-uu`   | `!!multi`            | Multiline, one-shot. \<*CTRL-D*\> flush.                  |
| `-U`    | `-UU`                | Toggle cat prompter, or set one-shot. \<*CTRL-D*\> flush. |
| `-V`    | `!debug`             | Dump raw request block and confirm.                       |
| `-v`    | `!ver`               | Toggle verbose modes.                                     |
| `-x`    | `!ed`                | Toggle text editor interface.                             |
| `-xx`   | `!!ed`               | Single-shot text editor.                                  |
| `-y`    | `!tik`               | Toggle python tiktoken use.                               |
| `!q`    | `!quit`              | Exit. Bye.                                                |

| Model   | Settings                |                                                |
|:--------|:------------------------|------------------------------------------------|
| `-Nill` | `!Nill`                 | Toggle model max response (chat cmpls).        |
| `-M`    | `!NUM` `!max` \[*NUM*\] | Set maximum response tokens.                   |
| `-N`    | `!modmax` \[*NUM*\]     | Set model token capacity.                      |
| `-a`    | `!pre` \[*VAL*\]        | Set presence penalty.                          |
| `-A`    | `!freq` \[*VAL*\]       | Set frequency penalty.                         |
| `-b`    | `!best` \[*NUM*\]       | Set best-of n results.                         |
| `-K`    | `!topk` \[*NUM*\]       | Set top_k.                                     |
| `-m`    | `!mod` \[*MOD*\]        | Set model by name, empty to pick from list.    |
| `-n`    | `!results` \[*NUM*\]    | Set number of results.                         |
| `-p`    | `!topp` \[*VAL*\]       | Set top_p.                                     |
| `-r`    | `!restart` \[*SEQ*\]    | Set restart sequence.                          |
| `-R`    | `!start` \[*SEQ*\]      | Set start sequence.                            |
| `-s`    | `!stop` \[*SEQ*\]       | Set one stop sequence.                         |
| `-t`    | `!temp` \[*VAL*\]       | Set temperature.                               |
| `-w`    | `!rec` \[*ARGS*\]       | Toggle Whisper. Optionally, set arguments.     |
| `-z`    | `!tts` \[*ARGS*\]       | Toggle TTS chat mode (speech out).             |
| `!ka`   | `!keep-alive` \[*NUM*\] | Set duration of model load in memory (Ollama). |
| `!blk`  | `!block` \[*ARGS*\]     | Set and add custom options to JSON request.    |
| \-      | `!multimodal`           | Toggle model as multimodal.                    |

| Session | Management                             |                                                            |
|:--------|:---------------------------------------|------------------------------------------------------------|
| `-H`    | `!hist`                                | Edit history in editor.                                    |
| `-P`    | `-HH`, `!print`                        | Print session history.                                     |
| `-L`    | `!log` \[*FILEPATH*\]                  | Save to log file.                                          |
| `!br`   | `!break`, `!new`                       | Start new session (session break).                         |
| `!ls`   | `!list` \[*GLOB*\]                     | List History files with *name* *glob*.                     |
|         |                                        | List prompts “*pr*”, awesome “*awe*”, or all files “*.*”.  |
| `!grep` | `!sub` \[*REGEX*\]                     | Search sessions (for regex) and copy session to hist tail. |
| `!c`    | `!copy` \[*SRC_HIST*\] \[*DEST_HIST*\] | Copy session from source to destination.                   |
| `!f`    | `!fork` \[*DEST_HIST*\]                | Fork current session to destination.                       |
| `!k`    | `!kill` \[*NUM*\]                      | Comment out *n* last entries in history file.              |
| `!!k`   | `!!kill` \[\[*0*\]*NUM*\]              | Dry-run of command `!kill`.                                |
| `!s`    | `!session` \[*HIST_FILE*\]             | Change to, search for, or create history file.             |
| `!!s`   | `!!session` \[*HIST_FILE*\]            | Same as `!session`, break session.                         |

*:* Commands followed by a colon will append command output to prompt.

*‡* Commands with double dagger may be invoked at the end of the input
prompt.

E.g.: “`/temp` *0.7*”, “`!mod`*gpt-4*”, “`-p` *0.2*”, and “`/s`
*hist_name*”.

#### 2.7 Session Management

The script uses a *TSV file* to record entries, which is kept at the
script cache directory. A new history file can be created, or an
existing one changed to with command “`/session` \[*HIST_FILE*\]”, in
which *HIST_FILE* is the file name of (with or without the *.tsv*
extension), or path to, a history file.

When the first positional argument to the script is the command operator
forward slash followed by a history file name, the command `/session` is
assumed.

A history file can contain many sessions. The last one (the tail
session) is always loaded if the resume `option -C` is set.

To copy a previous session, run `/sub`, or `/grep [regex]` to copy that
session to tail and resume from it.

If “`/copy` *current*” is run, a selector is shown to choose and copy a
session to the tail of the current history file, and resume it. This is
equivalent to running “`/fork`”.

It is also possible to copy sessions of a history file to another file
when a second argument is given to the command with the history file
name, such as “`/copy` \[*SRC_HIST_FILE*\] \[*DEST_HIST_FILE*\]”.

To load an older session from a history file that is different from the
defaults, there are some options.

Change to it with command `!session [name]`, and then `!fork` the older
session to the active session.

Or, `!copy [orign] [dest]` the session from a history file to the
current oneor any other history file.

In these cases, a pickup interface should open to let the user choose
the correct session from the history file.

To change the chat context at run time, the history file may be edited
with the “`/hist`” command (also for context injection). Delete history
entries or comment them out with “`#`”.

#### 2.8 Completion Preview / Regeneration

To preview a prompt completion before committing it to history, append a
forward slash “`/`” to the prompt as the last character. Regenerate it
again or flush/accept the prompt and response.

After a response has been written to the history file, **regenerate** it
with command “`!regen`” or type in a single exclamation mark or forward
slash “`/`” in the new empty prompt (twice “`//`” for editing the prompt
before new request).

### 3. Prompt Engineering and Design

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

<!--
### CODE COMPLETIONS _(discontinued)_
&#10;Codex models are discontinued. Use davinci or _gpt-3.5+ models_ for coding tasks.
&#10;-- 
Turn comments into code, complete the next line or function in
context, add code comments, and rewrite code for efficiency,
amongst other functions.
--
&#10;Start with a comment with instructions, data or code. To create
useful completions it's helpful to think about what information
a programmer would need to perform a task. 
-->
<!--
### TEXT EDITS  _(discontinued)_
&#10;--
This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify
a prompt and the prompt proper.
&#10;The edits endpoint can be used to change the tone or structure
of text, or make targeted changes like fixing spelling. Edits
work well on empty prompts, thus enabling text generation similar
to the completions endpoint. 
&#10;Alternatively,
--
&#10;Use _gpt-4+ models_ and the right instructions.
-->

### ESCAPING NEW LINES AND TABS

Input sequences “*\n*” and “*\t*” are only treated specially in restart,
start and stop sequences!

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

Please note and make sure to backup your important custom prompts! They
are located at “`~/.cache/chatgptsh/`” with the extension “*.pr*”.

### IMAGES / DALL-E

### 1. Image Generations

An image can be created given a text prompt. A text PROMPT of the
desired image(s) is required. The maximum length is 1000 characters.

### 2. Image Variations

Variations of a given *IMAGE* can be generated. The *IMAGE* to use as
the basis for the variations must be a valid PNG file, less than 4MB and
square.

### 3. Image Edits

To edit an *IMAGE*, a *MASK* file may be optionally provided. If *MASK*
is not provided, *IMAGE* must have transparency, which will be used as
the mask. A text prompt is required.

#### 3.1 ImageMagick

If **ImageMagick** is available, input *IMAGE* and *MASK* will be
checked and processed to fit dimensions and other requirements.

#### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with “`-@`\[*COLOUR*\]” to create the
mask. Defaults=*black*.

By defaults, the *COLOUR* must be exact. Use the `fuzz option` to match
colours that are close to the target colour. This can be set with
“`-@`\[*VALUE%*\]” as a percentage of the maximum possible intensity,
for example “`-@`*10%black*”.

See also:

- <https://imagemagick.org/script/color.php>
- <https://imagemagick.org/script/command-line-options.php#fuzz>

#### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image with
the set transparent colour (defaults to *black*). In this way, it is
easy to make a mask with any black and white image as a template.

#### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this script.
Paint a portion of the outer area of an image with *alpha*, or a defined
*transparent* *colour* which will be used as the mask, and set the same
*colour* in the script with `-@`. Choose the best result amongst many
results to continue the out-painting process step-wise.

### AUDIO / WHISPER

### 1. Transcriptions

Transcribes audio file or voice record into the set language. Set a
*two-letter* *ISO-639-1* language code (*en*, *es*, *ja*, or *zh*) as
the positional argument following the input audio file. A prompt may
also be set as last positional parameter to help guide the model. This
prompt should match the audio language.

If the last positional argument is “.” or “last” exactly, it will
resubmit the last recorded audio input file from cache.

Note that if the audio language is different from the set language code,
output will be on the language code (translation).

### 2. Translations

Translates audio into **English**. An optional text to guide the model’s
style or continue a previous audio segment is optional as last
positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.

### ENVIRONMENT

**BLOCK_USR**

**BLOCK_USR_TTS**  
Extra options for the request JSON block (e.g. “*"seed": 33,
"dimensions": 1024*”).

**CACHEDIR**  
Script cache directory base.

**CHATGPTRC**  
Path to the user *configuration file*.

Defaults="*~/.chatgpt.conf*"

**FILECHAT**  
Path to a history / session TSV file (script-formatted).

**INSTRUCTION**  
Initial initial instruction, or system message.

**INSTRUCTION_CHAT**  
Initial initial instruction, or system message for chat mode.

**MOD_CHAT**

**MOD_IMAGE**

**MOD_AUDIO**

**MOD_SPEECH**

**MOD_LOCALAI**

**MOD_OLLAMA**

**MOD_MISTRAL**

**MOD_GOOGLE**

**MOD_GROQ**

**MOD_AUDIO_GROQ**  
Set default model for each endpoint / integration.

**OPENAI_API_HOST**

**OPENAI_API_HOST_STATIC**  
Custom host URL. The *STATIC* parameter disables endpoint auto
selection.

**PROVIDER_API_HOST**  
API host URL for the providers *LOCALAI*, *OLLAMA*, *MISTRAL*, *GOOGLE*,
and *GROQ*.

**OPENAI_API_KEY**

**PROVIDER_API_KEY**  
Keys for OpenAI, GoogleAI, MistralAI, and Groq APIs.

**OUTDIR**  
Output directory for received image and audio.

**RESTART**

**START**  
Restart and start sequences. May be set to *null*.

Restart=“*\nQ: *” Start="*\nA:*" (chat mode)

**VISUAL**

**EDITOR**  
Text editor for external prompt editing.

Defaults="*vim*"

**CLIP_CMD**  
Clipboard set command, e.g. “*xsel* *-b*”, “*pbcopy*”.

**PLAY_CMD**  
Audio player command, e.g. “*mpv –no-video –vo=null*”.

**REC_CMD**  
Audio recorder command, e.g. “*sox -d*”.

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
- `termux-api`/`play-audio`/`termux-microphone-record`/`termux-clipboard-set` -
  Termux system
- `poppler`/`gs`/`abiword`/`ebook-convert` - Dump PDF as text
- `dialog`/`kdialog`/`zenity`/`osascript`/`termux-dialog` - File picker

### BUGS

Bash “read command” may not correctly display input buffers larger than
the TTY screen size during editing. However, input buffers remain
unaffected. Use the text editor interface for big prompt editing.

File paths containing spaces may not work correctly with some script
features.

Bash truncates input on “\000” (null).

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
&#10;`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.
&#10;`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->

### LIMITS

The script objective is to implement most features of OpenAI API version
1 but not all endpoints, or options will be covered.

### OPTIONS

#### Model Settings

**-@**, **--alpha** \[\[*VAL%*\]*COLOUR*\]  
Set transparent colour of image mask. Def=*black*.

Fuzz intensity can be set with \[*VAL%*\]. Def=*0%*.

**-Nill**  
Unset model max response (chat cmpls only).

**-NUM**

**-M**, **--max** \[*NUM*\[*-NUM*\]\]  
Set maximum number of *response tokens*. Def=*1024*.

A second number in the argument sets model capacity.

**-N**, **--modmax** \[*NUM*\]  
Set *model capacity* tokens. Def=*auto*, Fallback=*4000*.

**-a**, **--presence-penalty** \[*VAL*\]  
Set presence penalty (cmpls/chat, -2.0 - 2.0).

**-A**, **--frequency-penalty** \[*VAL*\]  
Set frequency penalty (cmpls/chat, -2.0 - 2.0).

**-b**, **--best-of** \[*NUM*\]  
Set best of, must be greater than `option -n` (cmpls). Def=*1*.

**-B**, **--logprobs** \[*NUM*\]  
Request log probabilities, also see -Z (cmpls, 0 - 5),

**-K**, **–top-k** \[*NUM*\]  
Set Top_k value (local-ai, ollama, google).

**--keep-alive**, **--ka**=\[*NUM*\]  
Set how long the model will stay loaded into memory (ollama).

**-m**, **--model** \[*MODEL*\]  
Set language *MODEL* name. Def=*gpt-3.5-turbo-instruct*, *gpt-4o*.

Set *MODEL* name as “*.*” to pick from the list.

**--multimodal**  
Set model as multimodal.

**-n**, **--results** \[*NUM*\]  
Set number of results. Def=*1*.

**-p**, **--top-p** \[*VAL*\]  
Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).

**-r**, **--restart** \[*SEQ*\]  
Set restart sequence string (cmpls).

**-R**, **--start** \[*SEQ*\]  
Set start sequence string (cmpls).

**-s**, **--stop** \[*SEQ*\]  
Set stop sequences, up to 4. Def="*\<\|endoftext\|\>*".

**-S**, **--instruction** \[*INSTRUCTION*\|*FILE*\]  
Set an instruction text prompt. It may be a text file.

**-t**, **--temperature** \[*VAL*\]  
Set temperature value (cmpls/chat/whisper), (0.0 - 2.0, whisper 0.0 -
1.0). Def=*0*.

#### Script Modes

**-c**, **--chat**  
Chat mode in text completions, session break.

**-cc**  
Chat mode in chat completions, session break.

**-C**, **--continue**, **--resume**  
Continue from (resume) last session (cmpls/chat).

**-d**, **--text**  
Start new multi-turn session in plain text completions.

**-e**, **--edit**  
Edit first input from stdin, or file read (cmpls/chat).

**-E**, **-EE**, **--exit**  
Exit on first run (even with options -cc).

**-g**, **--stream** (*defaults*)  
Set response streaming.

**-G**, **--no-stream**  
Unset response streaming.

**-i**, **--image** \[*PROMPT*\]  
Generate images given a prompt. Set *option -v* to not open response.

**-i** \[*PNG*\]  
Create variations of a given image.

**-i** \[*PNG*\] \[*MASK*\] \[*PROMPT*\]  
Edit image with mask and prompt (required).

**-qq**, **--insert**  
Insert text rather than completing only. May be set twice for
multi-turn.

Use “*\[insert\]*” to indicate where the language model should insert
text (`instruct` and Mistral `code` models).

**-S** **.**\[*PROMPT_NAME*\], **-..**\[*PROMPT_NAME*\]

**-S** **,**\[*PROMPT_NAME*\], **-,**\[*PROMPT_NAME*\]  
Load, search for, or create custom prompt.

Set `.`\[*PROMPT*\] to single-shot edit prompt.

Set `..`\[*PROMPT*\] to silently load prompt.

Set `,`\[*PROMPT*\] to edit a prompt file.

Set `.`*?*, or `.`*list* to list prompt template files.

**-S** **/**\[*AWESOME_PROMPT_NAME*\]

**-S** **%**\[*AWESOME_PROMPT_NAME_ZH*\]  
Set or search for an *awesome-chatgpt-prompt(-zh)*. *Davinci* and
*gpt3.5+* models.

Set **//** or **%%** instead to refresh cache.

**-T**, **--tiktoken**

**-TT**

**-TTT**  
Count input tokens with python Tiktoken (ignores special tokens).

Set twice to print tokens, thrice to available encodings.

Set the model or encoding with `option -m`.

It heeds `options -ccm`.

**-w**, **--transcribe** \[*AUD*\] \[*LANG*\] \[*PROMPT*\]  
Transcribe audio file into text. LANG is optional. A prompt that matches
the audio language is optional. Audio will be transcribed or translated
to the target LANG.

Set twice to phrase or thrice for word-level timestamps (-www).

**-W**, **--translate** \[*AUD*\] \[*PROMPT-EN*\]  
Translate audio file into English text.

Set twice to phrase or thrice for word-level timestamps (-WWW).

### Script Settings

**--api-key** \[*KEY*\]  
Set OpenAI API key.

**-f**, **--no-conf**  
Ignore user configuration file.

**-F**  
Edit configuration file with text editor, if it exists.

\$CHATGPTRC="*~/.chatgpt.conf*".

**-FF**  
Dump template configuration file to stdout.

**--fold** (*defaults*), **--no-fold**  
Set or unset response folding (wrap at white spaces).

**--google**  
Set Google Gemini integration (cmpls/chat).

**--groq**  
Set Groq integration (chat).

**-h**, **--help**  
Print the help page.

**-H**, **--hist** \[`/`*HIST_FILE*\]  
Edit history file with text editor or pipe to stdout.

A history file name can be optionally set as argument.

**-P**, **-PP**, **--print** \[`/`*HIST_FILE*\]  
Print out last history session.

Set twice to print commented out history entries, inclusive. Heeds
`options -ccdrR`.

These are aliases to **-HH** and **-HHH**, respectively.

**-k**, **--no-colour**  
Disable colour output. Def=*auto*.

**-l**, **--list-models** \[*MODEL*\]  
List models or print details of *MODEL*.

**-L**, **--log** \[*FILEPATH*\]  
Set log file. *FILEPATH* is required.

**--localai**  
Set LocalAI integration (cmpls/chat).

**--mistral**  
Set Mistral AI integration (chat).

**--md**, **--markdown**, **--markdown**=\[*SOFTWARE*\]  
Enable markdown rendering in response. Software is optional: *bat*,
*pygmentize*, *glow*, *mdcat*, or *mdless*.

**--no-md**, **--no-markdown**  
Disable markdown rendering.

**-o**, **--clipboard**  
Copy response to clipboard.

**-O**, **--ollama**  
Set and make requests to Ollama server (cmpls/chat).

**-u**, **--multiline**  
Toggle multiline prompter, \<*CTRL-D*\> flush.

**-U**, **--cat**  
Set cat prompter, \<*CTRL-D*\> flush.

**-v**, **--verbose**  
Less verbose.

Sleep after response in voice chat (`-vvccw`).

May be set multiple times.

**-V**  
Dump raw JSON request block (debug).

**-x**, **--editor**  
Edit prompt in text editor.

**-y**, **--tik**  
Set tiktoken for token count (cmpls/chat, python).

**-Y**, **--no-tik** (*defaults*)  
Unset tiktoken use (cmpls/chat, python).

**-z**, **--tts** \[*OUTFILE*\|*FORMAT*\|*-*\] \[*VOICE*\] \[*SPEED*\] \[*PROMPT*\]  
Synthesise speech from text prompt. Takes a voice name, speed and text
prompt. Set *option -v* to not play response.

**-Z**, **--last**  
Print last response JSON data.
