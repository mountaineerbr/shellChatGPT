---
author:
- mountaineerbr
date: July 2025
title: CHATGPT.SH(1) v0.106.2 \| General Commands Manual
---

# NAME

   chatgpt.sh -- Wrapper for ChatGPT / DALL-E / STT / TTS

# SYNOPSIS

   **chatgpt.sh** \[`-cc`\|`-dd`\|`-qq`\] \[`opt`..\]
\[*PROMPT*\|*TEXT_FILE*\|*PDF_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`..\] \[*S*\|*M*\|*L*\]\[*hd*\]
\[*PROMPT*\] \#dall-e-3  
   **chatgpt.sh** `-i` \[`opt`..\]
\[*X*\|*L*\|*P*\]\[*high*\|*medium*\|*low*\] \[*PROMPT*\] \#gpt-image  
   **chatgpt.sh** `-i` \[`opt`..\]
\[*X*\|*L*\|*P*\]\[*high*\|*medium*\|*low*\] \[*PNG_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`..\]
\[*X*\|*L*\|*P*\]\[*high*\|*medium*\|*low*\] \[*PNG_FILE*\]
\[*MASK_FILE*\] \[*PROMPT*\]  
   **chatgpt.sh** `-w` \[`opt`..\] \[*AUDIO_FILE*\|*.*\] \[*LANG*\]
\[*PROMPT*\]  
   **chatgpt.sh** `-W` \[`opt`..\] \[*AUDIO_FILE*\|*.*\]
\[*PROMPT-EN*\]  
   **chatgpt.sh** `-z` \[`opt`..\] \[*OUTFILE*\|*FORMAT*\|*-*\]
\[*VOICE*\] \[*SPEED*\] \[*PROMPT*\]  
   **chatgpt.sh** `-ccWwz` \[`opt`..\] -- \[*PROMPT*\] --
\[`stt_arg`..\] -- \[`tts_arg`..\]  
   **chatgpt.sh** `-l` \[*MODEL*\]  
   **chatgpt.sh** `-TTT` \[-v\] \[`-m`\[*MODEL*\|*ENCODING*\]\]
\[*INPUT*\|*TEXT_FILE*\|*PDF_FILE*\]  
   **chatgpt.sh** `-HPP` \[`/`*HIST_NAME*\|*.*\]  
   **chatgpt.sh** `-HPw`

# DESCRIPTION

This script acts as a wrapper for ChatGPT, DALL-E, STT (Whisper), and
TTS endpoints from OpenAI. Various service providers such as LocalAI,
Ollama, Anthropic, Mistral AI, GoogleAI, Groq AI, GitHub Models, Novita,
xAI, and DeepSeek APIs are supported.

With no options set, complete INPUT in single-turn mode of the native
chat completion.

Handles single-turn and multi-turn modes, pure text and native chat
completions, image generation and editing, speech-to-text, and
text-to-speech models.

Positional arguments are read as a single PROMPT. Some functions such as
Whisper (STT) and TTS may handle optional positional parameters before
the text prompt itself.

# OPTIONS

## Interface Modes

**-b**, **--responses**  
Responses API calls (may be used with `options -cc`). Limited support.
Set a valid model with “**--model** \[*name*\]”.

**-c**, **--chat**  
Chat mode in text completions (used with `options -wzvv`).

**-cc**  
Chat mode in chat completions (used with `options -wzvv`).

**-C**, **--continue**, **--resume**  
Continue from (resume) last session (cmpls/chat).

**-d**, **--text**  
Single-turn session of plain text completions.

**-dd**  
Multi-turn session of plain text completions with history support.

**-e**, **--edit**  
Edit first input from stdin or file (cmpls/chat).

With `options -eex`, edit last text editor buffer from cache.

**-E**, **-EE**, **--exit**  
Exit on first run (even with options -cc).

**-g**, **--stream** (*defaults*)  
Response streaming.

**-G**, **--no-stream**  
Unset response streaming.

**-i**, **--image** \[*PROMPT*\]  
Generate images given a prompt. Set *option -v* to not open response.

**-i** \[*PNG*\]  
Create variations of a given image.

**-i** \[*PNG*\] \[*MASK*\] \[*PROMPT*\]  
Edit image with mask and prompt (required).

**-q**, **-qq**, **--insert**  
Insert text rather than completing only. May be set twice for
multi-turn.

Use “*\[insert\]*” to indicate where the language model should insert
text (\`instruct’ and Mistral \`code models’).

**-S** **.**\[*PROMPT_NAME*\], **-.**\[*PROMPT_NAME*\]

**-S** **,**\[*PROMPT_NAME*\], **-,**\[*PROMPT_NAME*\]  
Load, search for, or create custom prompt.

Set `.`\[*PROMPT*\] to load prompt silently.

Set `,`\[*PROMPT*\] to single-shot edit prompt.

Set `,,`\[*PROMPT*\] to edit the prompt template file.

Set `.`*?*, or `.`*list* to list all prompt files.

**-S**, **–awesome** **/**\[*AWESOME_PROMPT_NAME*\]

**-S**, **–awesome-zh** **%**\[*AWESOME_PROMPT_NAME_ZH*\]  
Set or search for an *awesome-chatgpt-prompt(-zh)*.

Set **//** or **%%** instead to refresh cache.

**-T**, **--tiktoken**

**-TT**, **-TTT**  
Count input tokens with python Tiktoken (ignores special tokens).

Set twice to print tokens, thrice to available encodings.

Set the model or encoding with `option -m`.

It heeds `options -ccm`.

**-w**, **--transcribe** \[*AUD*\] \[*LANG*\] \[*PROMPT*\]  
Transcribe audio file speech into text. LANG is optional. A prompt that
matches the speech language is optional. Speech will be transcribed or
translated to the target LANG.

Set twice to phrase or thrice for word-level timestamps (-www).

With `options -vv`, stop voice recorder on silence auto detection.

**-W**, **--translate** \[*AUD*\] \[*PROMPT-EN*\]  
Translate audio file speech into English text.

Set twice to phrase or thrice for word-level timestamps (-WWW).

**-z**, **--tts** \[*OUTFILE*\|*FORMAT*\|*-*\] \[*VOICE*\] \[*SPEED*\] \[*PROMPT*\]  
Synthesise speech from text prompt. Takes a voice name, speed and text
prompt.

Set `option -v` to not play response automatically.

## Input Modes

**-u**, **--multiline**  
Toggle multiline prompter, \<*CTRL-D*\> flush.

**-U**, **--cat**  
Cat prompter, \<*CTRL-D*\> flush.

**-x**, **-xx**, **--editor**  
Edit prompt in text editor.

Set twice to run the text editor interface a single time for the first
user input.

Set `options -eex` to edit last buffer from cache.

## Model Settings

**-@**, **--alpha** \[\[*VAL%*\]*COLOUR*\]  
Transparent colour of image mask. Def=*black*.

Fuzz intensity can be set with \[*VAL%*\]. Def=*0%*.

**-Nill**  
Unset model max response tokens (chat cmpls only).

**-NUM**

**-M**, **--max** \[*NUM*\[*-NUM*\]\]  
Maximum number of *response tokens*. Def=*4096*.

A second number in the argument sets model capacity.

**-N**, **--modmax** \[*NUM*\]  
*Model capacity* token value. Def=*auto*, Fallback=*8000*.

**-a**, **--presence-penalty** \[*VAL*\]  
Presence penalty (cmpls/chat, -2.0 - 2.0).

**-A**, **--frequency-penalty** \[*VAL*\]  
Frequency penalty (cmpls/chat, -2.0 - 2.0).

**--best-of** \[*NUM*\]  
Best of results, must be greater than `option -n` (cmpls). Def=*1*.

**--effort** \[*high*\|*medium*\|*low*\] (OpenAI)

**--think** \[*token_num*\] (Anthropic / Google)  
Amount of effort in reasoning models.

**--format** \[*mp3*\|*wav*\|*flac*\|*opus*\|*aac*\|*pcm16*\|*mulaw*\|*ogg*\]  
TTS out-file format. Def= *mp3*.

**--interactive**, **--no-interactive**  
Reasoning model output style (OpenAI).

**-j**, **--seed** \[*NUM*\]  
Seed for deterministic sampling (integer).

**-K**, **--top-k** \[*NUM*\]  
Top_k value (local-ai, ollama, google).

**--keep-alive**, **--ka**=\[*NUM*\]  
How long the model will stay loaded into memory (Ollama).

**-m**, **--model** \[*MODEL*\]  
Language *MODEL* name. Def=*gpt-3.5-turbo-instruct*/*gpt-4o*.

Set *MODEL* name as “*.*” to pick from the list.

**--multimodal**, **--vision**, **--audio**  
Model multimodal model type.

**-n**, **--results** \[*NUM*\]  
Number of results. Def=*1*.

**-p**, **--top-p** \[*VAL*\]  
Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).

**-r**, **--restart** \[*SEQ*\]  
Restart sequence string (cmpls).

**-R**, **--start** \[*SEQ*\]  
Start sequence string (cmpls).

**-s**, **--stop** \[*SEQ*\]  
Stop sequences, up to 4. Def="*\<\|endoftext\|\>*".

**-S**, **--instruction** \[*INSTRUCTION*\|*FILE*\]  
Set an instruction text prompt. It may be a text file.

**--time**, **--no-time**  
Prepend the current date and time (timestamp) to the instruction prompt.

**-t**, **--temperature** \[*VAL*\]  
Temperature value (cmpls/chat/stt), (0.0 - 2.0, stt 0.0 - 1.0). Def=*0*.

**--voice** \[*alloy*\|*fable*\|*onyx*\|*nova*\|*shimmer*\|*ash*\|*ballad*\|*coral*\|*sage*\|*verse*\|*Adelaide-PlayAI*\|*Angelo-PlayAI*\|*Arista-PlayAI..*\]  
TTS voice name. OpenAI or PlayAI (Groq) voice names. Def=*echo*,
*Aaliyah-PlayAI*.

## Session and History Files

**-H**, **--hist** \[`/`*HIST_NAME*\]  
Edit history file with text editor or pipe to stdout.

A history file name can be optionally set as argument.

**-P**, **-PP**, **--print** \[`/`*HIST_NAME*\]  
Print out last history session.

Set twice to print commented out history entries, inclusive. Heeds
`options -ccdrR`.

These are aliases to **-HH** and **-HHH**, respectively.

## Configuration File

**-f**, **--no-conf**  
Ignore user configuration file.

**-F**  
Edit configuration file with text editor, if it exists.

\$CHATGPTRC="*~/.chatgpt.conf*".

**-FF**  
Dump template configuration file to stdout.

## Service Providers

**--anthropic**, **--ant**  
Anthropic integration (cmpls/chat). Also see **--think**.

**--deepseek**, **--deep**  
DeepSeek integration (cmpls/chat).

**--github**, **--git**  
GitHub Models integration (chat).

**--google**, **-goo**  
Google Gemini integration (cmpls/chat).

**--groq**  
Groq AI integration (chat).

**--localai**  
LocalAI integration (cmpls/chat).

**--mistral**  
Mistral AI integration (chat).

**--novita**  
Novita AI integration (cmpls/chat).

**--openai**  
Reset service integrations.

**-O**, **--ollama**  
Ollama server integration (cmpls/chat).

**--xai**  
xAI’s Grok integration (cmpls/chat).

## Miscellaneous Settings

**--api-key** \[*KEY*\]  
The API key to use.

**--fold** (*defaults*), **--no-fold**  
Set or unset response folding (wrap at white spaces).

**-h**, **--help**  
Print the help page.

**--info**  
Print OpenAI usage status (requires envar `$OPENAI_ADMIN_KEY`).

**-k**, **--no-colour**  
Disable colour output. Def=*auto*.

**-l**, **--list-models** \[*MODEL*\]  
List models or print details of *MODEL*.

**-L**, **--log** \[*FILEPATH*\]  
Log file. *FILEPATH* is required.

**--md**, **--markdown**, **--markdown**=\[*SOFTWARE*\]  
Enable markdown rendering in response. Software is optional: *bat*,
*pygmentize*, *glow*, *mdcat*, or *mdless*.

**--no-md**, **--no-markdown**  
Disable markdown rendering.

**-o**, **--clipboard**  
Copy response to clipboard.

**-v**, **--verbose**  
Less verbose.

Sleep after response in voice chat (`-vvccw`).

With `options -ccwv`, sleep after response. With `options -ccwzvv`, stop
recording voice input on silence detection and play TTS response right
away.

May be set multiple times.

**-V**  
Dump raw JSON request block (debug).

**--version**  
Print script version.

**-y**, **--tik**  
Tiktoken for token count (cmpls/chat, python).

**-Y**, **--no-tik** (*defaults*)  
Unset tiktoken use (cmpls/chat, python).

**-Z**, **-ZZ**, **-ZZZ**, **--last**  
Print JSON data of the last responses.

# CHAT COMPLETION MODE

Set `option -c` to start a multi-turn chat mode via **text completions**
with history support. This option works with instruct models, defaults
to *gpt-3.5-turbo-instruct* if none set.

Set `options -cc` to start the chat mode via **native chat
completions**. This mode defaults to the *gpt-4o* model, which is
optimised to follow instructions. Try *chatgpt-4o-latest* for a model
optimised for chatting.

In chat mode, some options are automatically set to un-lobotomise the
bot.

While using other providers, mind that `options -c` and `-cc` set
different endpoints! This setting must be set according to the model
capabilities!

Set `option -C` to **resume** (continue from) last history session, and
set `option -E` to exit on the first response (even in multi turn mode).

# TEXT COMPLETION MODE

`Option -d` starts a single-turn session in **plain text completions**,
no history support. This does not set further options automatically,
such as instruction or temperature.

To run the script in text completion in multi-turn mode and history
support, set command line `options -dd`.

Set text completion models such as *gpt-3.5-turbo-instruct*.

# INSERT MODE (Fill-In-the-Middle)

Set `option -q` for **insert mode** in single-turn and `option -qq` for
multiturn. The flag “*\[insert\]*” must be present in the middle of the
input prompt. Insert mode works completing between the end of the text
preceding the flag, and ends completion with the succeeding text after
the flag.

Insert mode works with \`instruct’ and Mistral \`code’ models.

# RESPONSES API

Responses API is a superset of Chat Completions API. Set command line
`option -b` (with `-cc`), or set `options -bb` for multiturn.

To activate it during multiturn chat, set `/responses [model]`, where
*model* is the name of a model which works with the Responses API.
Aliased to `/resp [model]` and `-b [model]`. This can be toggled.

Limited support.

# INSTRUCTION PROMPTS

The SYSTEM INSTRUCTION prompt may be set with `option -S` or via envars
`$INSTRUCTION` and `$INSTRUCTION_CHAT`.

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text
cmpls, and chat cmpls. A text file path may be supplied as the single
argument. Also see *CUSTOM / AWESOME PROMPTS* section below.

To create and reuse a custom prompt, set the prompt name as a command
line option, such as “`-S .[_prompt_name_]`” or “`-S ,[_prompt_name_]`”.

When the operator is a comma “*,*”, single-shot editing will be
available after loading the prompt text. Use double “*,,*” to actually
edit the template file itself!

Note that loading a custom prompt will also change to its
respectively-named history file.

Alternatively, set the first positional argument with the operator and
the prompt name after any command line options, such as
“`chatgpt;sh -cc .[_prompt_name_]`”. This loads the prompt file unless
instruction was set with command line options.

To prepend the current date and time to the instruction prompt, set
command line `option --time`.

For TTS *gpt-4o-tts* model type instructions, set command line option
`-S "[instruction]"` when invoking the script with `option -z` only
(stand-alone TTS mode). Alternatively, set envar `$INSTRUCTION_SPEECH`.

Note that for audio models such as `gpt-4o-audio`, the user can control
tone and accent of the rendered voice output with a robust
\`INSTRUCTION’ as usual.

## Prompt Engineering and Design

Minimal **INSTRUCTION** to behave like a chatbot is given with chat
`options -cc`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, minimal instruction is given,
and some options auto set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of text
cmpls, such as Curie, the \`best_of’ option may be worth setting (to 2
or 3).

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

<!--
It is also worth trying to sample 3 - 5 times (increasing the number
of responses with \`option -n 3', for example) in order to obtain
a good response.
-->
<!--
For more on prompt design, see:
&#10; - <https://platform.openai.com/docs/guides/completion/prompt-design>
 - <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>
&#10;
See detailed info on settings for each endpoint at:
&#10; - <https://platform.openai.com/docs/>
 -->

# MODEL AND CAPACITY

Set model with “`-m` \[*MODEL*\]”, with *MODEL* as its name, or set it
as “*.*” to pick from the model list.

List models with `option -l` or run `/models` in chat mode.

Set *maximum response tokens* with `option` “`-`*NUM*” or “`-M` *NUM*”.
This defaults to *4096* tokens and *25000* for reasoning models, or
disabled when running on chat completions and responses endpoints.

If a second *NUM* is given to this option, *maximum model capacity* will
also be set. The option syntax takes the form of “`-`*NUM/NUM*”, and
“`-M` *NUM-NUM*”.

*Model capacity* (maximum model tokens) can be set more intuitively with
`option` “`-N` *NUM*”, otherwise model capacity is set automatically for
known models or to *8000* tokens as fallback.

`Option -y` sets python tiktoken instead of the default script hack to
preview token count. This option makes token count preview accurate and
fast (we fork tiktoken as a coprocess for fast token queries). Useful
for rebuilding history context independently from the original model
used to generate responses.

<!--
Install models with `option -l` or command `/models`
and the `install` keyword.
&#10;Also supply a _model configuration file URL_ or,
if LocalAI server is configured with Galleries,
set "_\<GALLERY>_@_\<MODEL_NAME>_".
Gallery defaults to HuggingFace.
&#10;* NOTE: *  I recommend using LocalAI own binary to install the models!
-->
<!-- LocalAI only tested with text and chat completion models (vision) -->

# SPEECH-TO-TEXT (Whisper)

`Option -w` **transcribes audio speech** from *mp3*, *mp4*, *mpeg*,
*mpga*, *m4a*, *wav*, *webm*, *flac* and *ogg* files. First positional
argument must be an *AUDIO/VOICE* file. Optionally, set a *TWO-LETTER*
input language (*ISO-639-1*) as the second argument. A PROMPT may also
be set to guide the model’s style, or continue a previous audio segment.
The text prompt should match the speech language.

Note that `option -w` can also be set to **translate speech** input to
any text language to the target language.

`Option -W` **translates speech** stream to **English text**. A PROMPT
in English may be set to guide the model as the second positional
argument.

Set these options twice to have phrasal-level timestamps, options -ww
and -WW. Set thrice for word-level timestamps.

Combine `options -wW` **with** `options -cc` to start **chat with voice
input** (Whisper) support. Additionally, set `option -z` to enable
**text-to-speech** (TTS) models and voice out.

# TEXT-TO-VOICE (TTS)

`Option -z` synthesises voice from text (TTS models). Set a *voice* as
the first positional parameter (“*alloy*”, “*echo*”, “*fable*”,
“*onyx*”, “*nova*”, or “*shimmer*”). Set the second positional parameter
as the *voice speed* (*0.25* - *4.0*), and, finally the *output file
name* or the *format*, such as “*./new_audio.mp3*” (“*mp3*”, “*wav*”,
“*flac*”, “*opus*”, “*aac*”, or “*pcm16*”); or set “*-*” for stdout.

Do mind that PlayAI (supported by Groq AI) has different output formats
such as “*mulaw*” and “*ogg*”, as well as different voice names such as
Aaliyah-PlayAI, Adelaide-PlayAI, Angelo-PlayAI, etc.

Set `options -zv` to *not* play received output.

# MULTIMODAL AUDIO MODELS

Audio models, such as *gpt-4o-audio*, deal with audio input and output
directly.

To activate the microphone recording function of the script, set command
line `option -w`.

Otherwise, the audio model accepts any compatible audio file (such as
**mp3**, **wav**, and **opus**). These files can be added to be loaded
at the very end of the user prompt or added with chat command “`/audio`
*path/to/file.mp3*”.

To activate the audio synthesis output mode of an audio model, make sure
to set command line `option -z`!

# IMAGE GENERATIONS AND EDITS (Dall-E)

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an *IMAGE* file, then **generate variations** of
it. If the first positional argument is an *IMAGE* file and the second a
*MASK* file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** *IMAGE* according to *MASK* and PROMPT. If
*MASK* is not provided, *IMAGE* must have transparency.

The **size of output images** may be set as the first positional
parameter in the command line:

    gpt-imge: "_1024x1024_" (_L_, _Large_, _Square_), "_1536x1024_" (_X_, _Landscape_), or "_1024x1536_" (_P_, _Portrait_).

    dall-e-3: "_1024x1024_" (_L_, _Large_, _Square_), "_1792x1024_" (_X_, _Landscape_), or "_1024x1792_" (_P_, _Portrait_).

    dall-e-2: "_256x256_" (_Small_), "_512x512_" (_M_, _Medium_), or "_1024x1024_" (_L_, _Large_).

A parameter “*high*”, “*medium*”, “*low*”, or “*auto*” may also be
appended to the size parameter to set image quality with gpt-image, such
as “*Xhigh*” or “*1563x1024high*”. Defaults=*1024x1024auto*.

The parameter “*hd*” or “*standard*” may also be set for image quality
with dall-e-3.

For dall-e-3, optionally set the generation style as either “*natural*”
or “*vivid*” as one of the first positional parameters at command line
invocation.

Note that the user needs to verify his organisation to use *gpt-image*
models!

See **IMAGES section** below for more information on **inpaint** and
**outpaint**.

# TEXT / CHAT COMPLETIONS

## 1. Text Completion

Given a prompt, the model will return one or more predicted completions.
For example, given a partial input, the language model will try
completing it until probable “`<|endoftext|>`”, or other stop sequences
(stops may be set with `-s "\[stop-seq]"`).

**Restart** and **start sequences** may be optionally set. Restart and
start sequences are not set automatically if the chat mode of text
completions is not activated with `option -c`.

Readline is set to work with **multiline input** and pasting from the
clipboard. Alternatively, set `option -u` to enable pressing
\<*CTRL-D*\> to flush input! Or set `option -U` to set *cat command* as
input prompter.

Bash bracketed paste is enabled, meaning multiline input may be pasted
or typed, even without setting `options -uU` (*v25.2+*).

Language model **SKILLS** can be activated with specific prompts, see
<https://platform.openai.com/examples>.

## 2. Interactive Conversations

### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps a
history file, and keeps new questions in context. This works with a
variety of models. Set `option -E` to exit on response.

### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. More recent
models are also the best option for many non-chat use cases.

### 2.3 Q & A Format

The defaults chat format is “**Q & A**”. The **restart sequence**
“*\nQ: *” and the **start text** “*\nA:*” are injected for the chat bot
to work well with text cmpls.

In multi-turn interactions, prompts prefixed with double colons “*:*”
are prepended to the current request buffer as a **USER MESSAGE**
without incurring an API call. Conversely, prompts starting with two
double colons “*::*” are added as a **INSTRUCTION / SYSTEM MESSAGE**.

### 2.4 Voice input (STT), and voice output (TTS)

The `options -ccwz` may be combined to have voice recording input and
synthesised voice output, specially nice with chat modes. When setting
`flag -w` or `flag -z`, the first positional parameters are read as STT
or TTS arguments. When setting both `flags -wz`, add a double hyphen to
set first STT, and then TTS arguments.

Set chat mode, plus voice-in transcription language code and text
prompt, and the TTS voice-out option argument:

    chatgpt.sh -ccwz  en 'transcription prompt'  --  nova

### 2.5 Vision and Multimodal Models

To send an *image* or *url* to **vision models**, either set the image
with the “`!img`” command with one or more *filepaths* / *urls*.

    chatgpt.sh -cc -m gpt-4-vision-preview '!img path/to/image.jpg'

Alternatively, set the *image paths* / *urls* at the end of the text
prompt interactively:

    chatgpt.sh -cc -m gpt-4-vision-preview

    [...]
    Q: In this first user prompt, what can you see?  https://i.imgur.com/wpXKyRo.jpeg

Make sure file paths containing spaces are backslash-escaped!

### 2.6 Text, PDF, Doc, and URL Dumps

The user may add a *filepath* or *URL* to the end of the prompt. The
file is then read and the text content added to the user prompt. This is
a basic text feature that works with any model.

    chatgpt.sh -cc

    [...]
    Q: What is this page: https://example.com

    Q: Help me study this paper. ~/Downloads/Prigogine\ Perspective\ on\ Nature.pdf

In the second example, the *PDF* will be dumped as text.

For PDF text dump support, `poppler/abiword` is required. For *doc* and
*odt* files, `LibreOffice` is required. See the **Optional Packages**
section.

Also note that *file paths* containing white spaces must be
**blackslash-escaped**, or the *file path* must be preceded by a pipe
\`\|’ character.

Multiple images and audio files may be added to the request in this way!

# COMMAND LIST

While in chat mode, the following commands can be invoked in the new
prompt to change parameters and manage sessions. Command operators “`!`”
or “`/`” are equivalent.

| Misc      | Commands                        |                                                         |
|:----------|:--------------------------------|---------------------------------------------------------|
| `-S`      | `:`, `::` \[*PROMPT*\]          | Add user or system prompt to request buffer.            |
| `-S.`     | `-.` \[*NAME*\]                 | Load and edit custom prompt.                            |
| `-S/`     | `!awesome` \[*NAME*\]           | Load and edit awesome prompt (english).                 |
| `-S%`     | `!awesome-zh` \[*NAME*\]        | Load and edit awesome prompt (chinese).                 |
| `-Z`      | `!last`                         | Print last response JSON.                               |
| `!#`      | `!save` \[*PROMPT*\]            | Save current prompt to shell history. *‡*               |
| `!`       | `!r`, `!regen`                  | Regenerate last response.                               |
| `!!`      | `!rr`                           | Regenerate response, edit prompt first.                 |
| `!g:`     | `!!g:` \[*PROMPT*\]             | Ground user prompt with web search results. *‡*         |
| `!i`      | `!info`                         | Information on model and session settings.              |
| `!!i`     | `!!info`                        | Monthly usage stats (OpenAI).                           |
| `!j`      | `!jump`                         | Jump to request, append start seq primer (text cmpls).  |
| `!!j`     | `!!jump`                        | Jump to request, no response priming.                   |
| `!cat`    | \-                              | Cat prompter as one-shot, \<*CTRL-D*\> flush.           |
| `!cat`    | `!cat:` \[*TXT*\|*URL*\|*PDF*\] | Cat *text*, *PDF* file, or dump *URL*.                  |
| `!dialog` | \-                              | Toggle the “dialog” interface.                          |
| `!img`    | `!media` \[*FILE*\|*URL*\]      | Add image, media, or URL to prompt.                     |
| `!md`     | `!markdown` \[*SOFTW*\]         | Toggle markdown rendering in response.                  |
| `!!md`    | `!!markdown` \[*SOFTW*\]        | Render last response in markdown.                       |
| `!rep`    | `!replay`                       | Replay last TTS audio response.                         |
| `!res`    | `!resubmit`                     | Resubmit last STT recorded audio in cache.              |
| `!p`      | `!pick` \[*PROPMT*\]            | File picker, appends filepath to user prompt. *‡*       |
| `!pdf`    | `!pdf:` \[*FILE*\]              | Convert PDF and dump text.                              |
| `!photo`  | `!!photo` \[*INDEX*\]           | Take a photo, optionally set camera index (Termux). *‡* |
| `!sh`     | `!shell` \[*CMD*\]              | Run shell *command* and edit stdout (make request). *‡* |
| `!sh:`    | `!shell:` \[*CMD*\]             | Same as `!sh` and insert stdout into current prompt.    |
| `!!sh`    | `!!shell` \[*CMD*\]             | Run interactive shell *command* and return.             |
| `!url`    | `!url:` \[*URL*\]               | Dump URL text or YouTube transcript text.               |

| Script  | Settings and UX      |                                                          |
|:--------|:---------------------|----------------------------------------------------------|
| `!fold` | `!wrap`              | Toggle response wrapping.                                |
| `-F`    | `!conf`              | Runtime configuration form TUI.                          |
| `-g`    | `!stream`            | Toggle response streaming.                               |
| `-h`    | `!help` \[*REGEX*\]  | Print help or grep help for regex.                       |
| `-l`    | `!models` \[*NAME*\] | List language models or show model details.              |
| `-o`    | `!clip`              | Copy responses to clipboard.                             |
| `-u`    | `!multi`             | Toggle multiline prompter. \<*CTRL-D*\> flush.           |
| `-uu`   | `!!multi`            | Multiline, one-shot. \<*CTRL-D*\> flush.                 |
| `-U`    | `-UU`                | Toggle cat prompter or set one-shot. \<*CTRL-D*\> flush. |
| `-V`    | `!debug`             | Dump raw request block and confirm.                      |
| `-v`    | `!ver`               | Toggle verbose modes.                                    |
| `-x`    | `!ed`                | Toggle text editor interface.                            |
| `-xx`   | `!!ed`               | Single-shot text editor.                                 |
| `-y`    | `!tik`               | Toggle python tiktoken use.                              |
| `!q`    | `!quit`              | Exit. Bye.                                               |

| Model          | Settings                |                                                  |
|:---------------|:------------------------|--------------------------------------------------|
| `!Nill`        | `-Nill`                 | Unset max response tkns (chat cmpls).            |
| `!NUM`         | `-M` \[*NUM*\]          | Maximum response tokens.                         |
| `!!NUM`        | `-N` \[*NUM*\]          | Model token capacity.                            |
| `-a`           | `!pre` \[*VAL*\]        | Presence penalty.                                |
| `-A`           | `!freq` \[*VAL*\]       | Frequency penalty.                               |
| `-b`           | `!responses` \[*MOD*\]  | Responses API request (experimental).            |
| `best`         | `!best-of` \[*NUM*\]    | Best-of n results.                               |
| `-j`           | `!seed` \[*NUM*\]       | Seed number (integer).                           |
| `-K`           | `!topk` \[*NUM*\]       | Top_k.                                           |
| `-m`           | `!mod` \[*MOD*\]        | Model by name, empty to pick from list.          |
| `-n`           | `!results` \[*NUM*\]    | Number of results.                               |
| `-p`           | `!topp` \[*VAL*\]       | Top_p.                                           |
| `-r`           | `!restart` \[*SEQ*\]    | Restart sequence.                                |
| `-R`           | `!start` \[*SEQ*\]      | Start sequence.                                  |
| `-s`           | `!stop` \[*SEQ*\]       | One stop sequence.                               |
| `-t`           | `!temp` \[*VAL*\]       | Temperature.                                     |
| `-w`           | `!rec` \[*ARGS*\]       | Toggle voice-in STT. Optionally, set arguments.  |
| `-z`           | `!tts` \[*ARGS*\]       | Toggle TTS chat mode (speech out).               |
| `!blk`         | `!block` \[*ARGS*\]     | Set and add custom options to JSON request.      |
| `!effort`      | \- \[*MODE*\]           | Reasoning effort: high, medium, or low (OpenAI). |
| `!think`       | \- \[*NUM*\]            | Thinking budget: max tokens (Anthropic).         |
| !interactive\` | \-                      | Toggle reasoning interactive mode.               |
| `!ka`          | `!keep-alive` \[*NUM*\] | Set duration of model load in memory (Ollama).   |
| `!vision`      | `!audio`, `!multimodal` | Toggle multimodality type.                       |

| Session | Management                             |                                                                                              |
|:--------|:---------------------------------------|----------------------------------------------------------------------------------------------|
| `-C`    | \-                                     | Continue current history session (see `!break`).                                             |
| `-H`    | `!hist`                                | Edit history in editor.                                                                      |
| `-P`    | `-HH`, `!print`                        | Print session history.                                                                       |
| `-L`    | `!log` \[*FILEPATH*\]                  | Save to log file.                                                                            |
| `!c`    | `!copy` \[*SRC_HIST*\] \[*DEST_HIST*\] | Copy session from source to destination.                                                     |
| `!f`    | `!fork` \[*DEST_HIST*\]                | Fork current session and continue from destination.                                          |
| `!k`    | `!kill` \[*NUM*\]                      | Comment out *n* last entries in history file.                                                |
| `!!k`   | `!!kill` \[\[*0*\]*NUM*\]              | Dry-run of command `!kill`.                                                                  |
| `!s`    | `!session` \[*HIST_NAME*\]             | Change to, search for, or create history file.                                               |
| `!!s`   | `!!session` \[*HIST_NAME*\]            | Same as `!session`, break session.                                                           |
| `!u`    | `!unkill` \[*NUM*\]                    | Uncomment *n* last entries in history file.                                                  |
| `!!u`   | `!!unkill` \[\[*0*\]*NUM*\]            | Dry-run of command `!unkill`.                                                                |
| `!br`   | `!break`, `!new`                       | Start new session (session break).                                                           |
| `!ls`   | `!list` \[*GLOB*\|*.*\|*pr*\|*awe*\]   | List history files with “*glob*” in *name*; Files: “*.*”; Prompts: “*pr*”; Awesome: “*awe*”. |
| `!grep` | `!sub` \[*REGEX*\]                     | Grep sessions and copy session to hist tail.                                                 |

*:* Commands with *double colons* have their output added to the current
prompt.

*‡* Commands with *double dagger* may be invoked at the very end of the
input prompt (preceded by space).

Examples:

  “`/temp` *0.7*”, “`!mod`*gpt-4*”, “`-p` *0.2*”

  “`/session` *HIST_NAME*”, “\[*PROMPT*\] `/pick`”,

  “\[*PROMPT*\] `/sh`”.

To **regenerate response**, type in the command “`!regen`” or a single
exclamation mark or forward slash in the new empty prompt. In order to
edit the prompt before the request, try “`!!`” (or “`//`”).

The “`/pick`” command opens a file picker (usually a command-line file
manager). The selected file’s path will be appended to the current
prompt in editing mode.

The “`/sh`” and “`/pick`” commands may be run when typed at the end of
the current prompt, such as “\[*PROMPT*\] `/sh`”, which opens a new
shell instance to execute commands interactively. The shell command dump
or file path is appended to the current prompt.

Command “`!block` \[*ARGS*\]” may be run to set raw model options in
JSON syntax according to each API. Alternatively, set envar
**\$BLOCK_USR**.

Any “`!CMD`” not matching a chat command is executed by the shell as an
alias for “`!sh CMD`”. Note that this shortcut only works with operator
exclamation mark.

# Session Management

A history file can hold a single session or multiple sessions. When it
holds a single session, the name of the history file and the session are
the same. However, in case the user breaks a session, the last one (the
tail session) of that history file is always loaded when the resume
`option -C` is set.

The script uses a *TSV file* to record entries, which is kept at the
script cache directory (“`~/.cache/chatgptsh/`”). The **tail session**
of the history file can always be read and resumed.

Run command “`/list [glob]`” with optional “*glob*” to list session /
history “*tsv*” files. When glob is “*.*” list all files in the cache
directory; when “*pr*” list all instruction prompt files; and when
“*awe*” list all awesome prompts.

## Changing Session

A new history file can be created or changed to with command “`/session`
\[*HIST_NAME*\]”, in which *HIST_NAME* is the file name or path of a
history file.

On invocation, when the first positional argument to the script follows
the syntax “`/`\[*HIST_NAME*\]”, the command “`/session`” is assumed
(with `options -ccCdPP`).

## Resuming and Copying Sessions

To continue from an old session type in a dot “`.`” or “`/.`” as the
first positional argument from the command line on invocation.

The above command is a shortcut of “`/copy` *current* *current*”. In
fact, there are multiple commands to copy and resume from an older
session (the dot means *current session*): “`/copy . .`”, “`/fork.`”,
“`/sub`”, and “`/grep` \[*REGEX*\]”.

From the command line on invocation, simply type “`.`” as the first
positional argument.

It is possible to copy sessions of a history file to another file when a
second argument is given to the “`/copy`” command.

Mind that forking a session will change to the destination history file
and resume from it as opposed to just copying it.

<!--
If "`/copy` _current_" is run, a selector is shown to choose and copy
a session to the tail of the current history file, and resume it.
This is equivalent to running "`/fork`". -->
<!--
Change to a history file with command "`!session` \[_NAME_]",
and then "`!fork`" the older session to the active session. -->
<!--
Or, "`!copy` \[_ORIGN_] \[_DEST_]" the session from a history file to the current
or other history file.
&#10;In these cases, a pickup interface should open to let the user choose
the correct session from the history file. -->

## History File Editing

To edit chat context at run time, the history file may be modified with
the “`/hist`” command (also good for context injection).

Delete history entries or comment them out with “\#”.

<!--
# CODE COMPLETIONS _(discontinued)_
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
# TEXT EDITS  _(discontinued)_
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

# CUSTOM / AWESOME PROMPTS

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

# IMAGES / DALL-E

## 1. Image Generations

An image can be created given a text prompt. A text PROMPT of the
desired image(s) is required. The maximum length is 1000 characters.

This script also supports xAI image generation model with invocation
“`chatgpt.sh --xai -i -m grok-2-image-1212 "[prompt]"`”.

## 2. Image Variations

Variations of a given *IMAGE* can be generated. The *IMAGE* to use as
the basis for the variations must be a valid PNG file, less than 4MB and
square.

## 3. Image Edits

To edit an *IMAGE*, a *MASK* file may be optionally provided. If *MASK*
is not provided, *IMAGE* must have transparency, which will be used as
the mask. A text prompt is required.

### 3.1 ImageMagick

If **ImageMagick** is available, input *IMAGE* and *MASK* will be
checked and processed to fit dimensions and other requirements.

### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with “`-@`\[*COLOUR*\]” to create the
mask. Defaults=*black*.

By defaults, the *COLOUR* must be exact. Use the \`fuzz option’ to match
colours that are close to the target colour. This can be set with
“`-@`\[*VALUE%*\]” as a percentage of the maximum possible intensity,
for example “`-@`*10%black*”.

See also:

- <https://imagemagick.org/script/color.php>
- <https://imagemagick.org/script/command-line-options.php#fuzz>

### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image with
the set transparent colour (defaults to *black*). In this way, it is
easy to make a mask with any black and white image as a template.

### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this script.
Paint a portion of the outer area of an image with *alpha*, or a defined
*transparent* *colour* which will be used as the mask, and set the same
*colour* in the script with `option -@`. Choose the best result amongst
many results to continue the out-painting process step-wise.

# STT / VOICE-IN / WHISPER

## Transcriptions

Transcribes audio file or voice record into the set language. Set a
*two-letter* *ISO-639-1* language code (*en*, *es*, *ja*, or *zh*) as
the positional argument following the input audio file. A prompt may
also be set as last positional parameter to help guide the model. This
prompt should match the audio language.

If the last positional argument is “.” or “last” exactly, it will
resubmit the last recorded audio input file from cache.

Note that if the audio language is different from the set language code,
output will be on the language code (translation).

## Translations

Translates audio into **English**. An optional text to guide the model’s
style or continue a previous audio segment is optional as last
positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.

# PROVIDER INTEGRATIONS

For LocalAI integration, run the script with `option --localai`, or set
environment **\$OPENAI_BASE_URL** with the server Base URL.

For Mistral AI set environment variable **\$MISTRAL_API_KEY**, and run
the script with `option --mistral` or set **\$OPENAI_BASE_URL** to
“https://api.mistral.ai/”. Prefer setting command line
`option --mistral` for complete integration.
<!-- also see: \$MISTRAL_BASE_URL -->

For Ollama, set `option -O` (`--ollama`), and set **\$OLLAMA_BASE_URL**
if the server URL is different from the defaults.

Note that model management (downloading and setting up) must follow the
Ollama project guidelines and own methods.

For Google Gemini, set environment variable **\$GOOGLE_API_KEY**, and
run the script with the command line `option --google`.

For Groq, set the environmental variable `$GROQ_API_KEY`. Run the script
with `option --groq`. Transcription (Whisper) endpoint available.

For Anthropic, set envar `$ANTHROPIC_API_KEY` and run the script with
command line `option --anthropic`.

For GitHub Models, `$GITHUB_TOKEN` and invoke the script with
`option --github`.

For Novita AI integration, set the environment variable
`$NOVITA_API_KEY` and use the `--novita` option. Novita AI offers a
range of LLM models, including the highly recommended **Llama 3.1**
model. For an uncensored model, consider **sao10k/l3-70b-euryale-v2.1**
or **cognitivecomputations/dolphin-mixtral-8x22b**.

Likewise, for xAI’s Grok, set environment `$XAI_API_KEY` with its API
key.

And for DeepSeek API, set environment `$DEEPSEEK_API_KEY` with its API
key.

Run the script with `option --xai` and also with `option -cc` (chat
completions.).

Some models also work with native text completions. For that, set
command-line `option -c` instead.

# ENVIRONMENT

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
Initial initial instruction message.

**INSTRUCTION_CHAT**  
Initial initial instruction or system message in chat mode.

**INSTRUCTION_SPEECH**  
TTS transcription model instruction (gpt-4o-tts models).

**LC_ALL**

**LANG**  
Default instruction language in chat mode.
<!-- and Whisper language. -->

**MOD_CHAT**, **MOD_IMAGE**, **MOD_AUDIO**,

**MOD_SPEECH**, **MOD_LOCALAI**, **MOD_OLLAMA**,

**MOD_MISTRAL**, **MOD_AUDIO_MISTRAL**, **MOD_GOOGLE**,

**MOD_GROQ**, **MOD_AUDIO_GROQ**, **MOD_SPEECH_GROQ**,

**MOD_ANTHROPIC**, **MOD_GITHUB**, **MOD_NOVITA**,

**MOD_XAI**, **MOD_DEEPSEEK**  
Set default model for each endpoint / provider.

**OPENAI_BASE_URL**

**OPENAI_URL_PATH**  
Main Base URL setting. Alternatively, provide a *URL_PATH* parameter
with the full url path to disable endpoint auto selection.

**PROVIDER_BASE_URL**  
Base URLs for each service provider: *LOCALAI*, *OLLAMA*, *MISTRAL*,
*GOOGLE*, *ANTHROPIC*, *GROQ*, *GITHUB*, *NOVITA*, *XAI*, and
*DEEPSEEK*.

**OPENAI_API_KEY**

**PROVIDER_API_KEY**

**GITHUB_TOKEN**  
Keys for OpenAI, Gemini, Mistral, Groq, Anthropic, GitHub Models,
Novita, xAI, and DeepSeek APIs.

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

# Web Search

## Simple Search Dump

To ground a user prompt with search results, run chat command
“`/g [prompt]`”.

Default search provider is Google. To select a different search
provider, run “`//g [prompt]`” and choose amongst *Google*,
*DuckDuckGo*, or *Brave*.

Running “`//g [prompt]`” will always use the in-house solution instead
of any service provider specific web search tool.

A cli-browser is required, such as **w3m**, **elinks, **links**, or
**lynx\*\*.

## OpenAI Web Search

Use the in-house solution above, or select models with “search” in the
name, such as “gpt-4o-search-preview”.

<!--
To enable live search in the API, run chat command `/g [prompt]` or
`//g [prompt]` (to use the fallback mechanism) as usual;
or to keep live search enabled for all prompts, set `$BLOCK_USR`
environment variable before running the script such as:
&#10;```
export BLOCK_USR='"tools": [{
  "type": "web_search_preview",
  "search_context_size": "medium"
}]'
&#10;chatgpt.sh -cc -m gpt-4.1-2025-04-14
```
&#10;Check more search parameters at the OpenAI API documentation:
<https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses>.
<https://platform.openai.com/docs/guides/tools-web-search?api-mode=chat>.
-->

## xAI Live Search

    export BLOCK_USR='"search_parameters": {
      "mode": "auto",
      "max_search_results": 10
    }'

    chatgpt.sh --xai -cc -m grok-3-latest 

Check more search parameters at the xAI API documentation:
<https://docs.x.ai/docs/guides/live-search>.

## Anthropic Web Search

    export BLOCK_USR='"tools": [{
      "type": "web_search_20250305",
      "name": "web_search",
      "max_uses": 5
    }]'

    chatgpt.sh --ant -cc -m claude-opus-4-0

Check more web search parameters at Anthropic API docs:
<https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking>.

## Google Search

    export BLOCK_CMD='"tools": [ { "google_search": {} } ]'

    chatgpt.sh --goo -cc -m gemini-2.5-flash-preview-05-20

Check more web search parameters at Google AI API docs:
<https://ai.google.dev/gemini-api/docs/grounding?lang=rest>.

# COLOR THEMES

The colour scheme may be customised. A few themes are available in the
template configuration file.

A small colour library is available for the user conf file to
personalise the theme colours.

The colour palette is composed of *\$Red*, *\$Green*, *\$Yellow*,
*\$Blue*, *\$Purple*, *\$Cyan*, *\$White*, *\$Inv* (invert), and *\$Nc*
(reset) variables.

Bold variations are defined as *\$BRed*, *\$BGreen*, etc, and background
colours can be set with *\$On_Yellow*, *\$On_Blue*, etc.

Alternatively, raw escaped color sequences, such as *\u001b\[0;35m*, and
*\u001b\[1;36m* may be set.

Theme colours are named variables from `Colour1` to about `Colour11`,
and may be set with colour-named variables or raw escape sequences
(these must not change cursor position).

# CONFIGURATION AND CACHE FILES

User configuration is stored in **~/.chatgpt.conf**. Its path location
can be set with envar **\$CHATGPTRC**.

The script’s cache directory is **~/.cache/chatgptsh/** and may contain
the following file types:

- **Session Records (tsv):** Tab-separated value files storing session
  history. The default session record is **chatgpt.tsv**.
- **Prompt Files (pr):** Files storing user-defined custom instructions
  (initial prompts).
- **Command History (history_bash):** Bash command-line input history.
  This file is trimmed according to the **\$HISTSIZE** setting in the
  configuration file. While it improves session recall, a large
  **history_bash** file can slow down script startup. It can be safely
  removed if necessary.
- **Temporary Buffers:** Various files holding temporary text and data.
  These files are safe to remove and are not intended for backup.

**Backup Recommendation:** It is strongly recommended to back up session
record files (tsv) and prompt files (pr), as well as the configuration
file (chatgpt.sh) to preserve session history, custom promptsnd
settings.

# NOTES

Stdin text is appended to any existing command line PROMPT.

Input sequences “*\n*” and “*\t*” are only treated specially (as escaped
new lines and tabs) in restart, start and stop sequences!

The moderation endpoint can be accessed by setting the model name to
*omni-moderation-latest* (or *text-moderation-latest*).

Press \<*CTRL-X* *CTRL-E*\> to edit command line in text editor from
readline.

Press \<*CTRL-J*\> or \<*CTRL-V* *CTRL-J*\> for newline in readline.

Press \<*CTRL-L*\> to redraw readline buffer (user input) on screen.

During *cURL* requests, press \<*CTRL-C*\> once to interrupt the call.

Press \<*CTRL-\\*\> to exit from the script (send *QUIT* signal), or
“*Q*” in user confirmation prompts.

For complete model and settings information, refer to OpenAI API docs at
<https://platform.openai.com/docs/>.

See the online man page and `chatgpt.sh` usage examples at:
<https://gitlab.com/fenixdragao/shellchatgpt>.

# REQUIRED PACKAGES

- `Bash` shell
- `cURL` and `JQ`

# OPTIONAL PACKAGES

Optional packages for specific features.

- `Base64` - Image endpoint, vision models
- `Python` - Modules tiktoken, markdown, bs4
- `ImageMagick`/`fbida` - Image edits and variations
- `SoX`/`Arecord`/`FFmpeg` - Record input (STT, Whisper)
- `mpv`/`SoX`/`Vlc`/`FFplay`/`afplay` - Play TTS output
- `xdg-open`/`open`/`xsel`/`xclip`/`pbcopy` - Open images, set clipboard
- `W3M`/`Lynx`/`ELinks`/`Links` - Dump URL text
- `bat`/`Pygmentize`/`Glow`/`mdcat`/`mdless` - Markdown support
- `termux-api`/`termux-tools`/`play-audio` - Termux system
- `poppler`/`gs`/`abiword`/`ebook-convert`/`LibreOffice` - Dump PDF or
  Doc as text
- `dialog`/`kdialog`/`zenity`/`osascript`/`termux-dialog` - File picker
- `yt-dlp` - Dump YouTube captions

# CAVEATS

The script objective is to implement some of the features of OpenAI API
version 1. As text is the only universal interface, voice and image
features will only be partially supported, and not all endpoints or
options will be covered.

This project *doesn’t support* “Function Calling”, “Structured Outputs”,
“Real-Time Conversations”, “Agents/Operators”, “MCP Servers”, nor “video
generation / editing” capabilities.

Support for “Responses API” is limited and experimental at this point.

# BUGS

Reasoning (thinking) and answers from certain API services may not have
a distinct separation of output due to JSON processing constraints.

Bash “read command” may not correctly display input buffers larger than
the TTY screen size during editing. However, input buffers remain
unaffected. Use the text editor interface for big prompt editing.

If readline screws up your currrent input buffer, try pressing
\<*CTRL-L*\> to force it to redisplay and refresh the prompt properly on
screen.

File paths containing spaces may not work correctly in the chat
interface. Make sure to backslash-escape filepaths with white spaces.

Folding the response at white spaces may not worked correctly if the
user has changed his terminal tabstop setting. Reset it with command
“tabs -8” or “reset” before starting the script, or set one of these in
the script configuration file.

If folding does not work well at all, try exporting envar `$COLUMNS`
before script execution.

Bash truncates input on “\000” (null).

Garbage in, garbage out. An idiot savant.

The script logic resembles a bowl of spaghetti code after a cat fight.

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
<!--
# EXAMPLES -->
