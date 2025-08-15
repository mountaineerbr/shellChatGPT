% CHATGPT.SH(1) v0.113.1 | General Commands Manual
% mountaineerbr
% August 2025


# NAME

|    chatgpt.sh \-- Wrapper for ChatGPT / DALL-E / STT / TTS


# SYNOPSIS

|    **chatgpt.sh** \[`-cc`|`-dd`|`-qq`] \[`opt`..] \[_PROMPT_|_TEXT_FILE_|_PDF_FILE_]
|    **chatgpt.sh** `-i` \[`opt`..] \[_S_|_M_|_L_]\[_hd_] \[_PROMPT_]  #dall-e-3
|    **chatgpt.sh** `-i` \[`opt`..] \[_X_|_L_|_P_]\[_high_|_medium_|_low_] \[_PROMPT_]  #gpt-image
|    **chatgpt.sh** `-i` \[`opt`..] \[_X_|_L_|_P_]\[_high_|_medium_|_low_] \[_PNG_FILE_]
|    **chatgpt.sh** `-i` \[`opt`..] \[_X_|_L_|_P_]\[_high_|_medium_|_low_] \[_PNG_FILE_] \[_MASK_FILE_] \[_PROMPT_]
|    **chatgpt.sh** `-w` \[`opt`..] \[_AUDIO_FILE_|_._] \[_LANG_] \[_PROMPT_]
|    **chatgpt.sh** `-W` \[`opt`..] \[_AUDIO_FILE_|_._] \[_PROMPT-EN_]
|    **chatgpt.sh** `-z` \[`opt`..] \[_OUTFILE_|_FORMAT_|_-_] \[_VOICE_] \[_SPEED_] \[_PROMPT_]
|    **chatgpt.sh** `-ccWwz` \[`opt`..] \-- \[_PROMPT_] \-- \[`stt_arg`..] \-- \[`tts_arg`..] 
|    **chatgpt.sh** `-l` \[_MODEL_]
|    **chatgpt.sh** `-TTT` \[-v] \[`-m`\[_MODEL_|_ENCODING_]] \[_INPUT_|_TEXT_FILE_|_PDF_FILE_]
|    **chatgpt.sh** `-HPP` \[`/`_HIST_NAME_|_._]
|    **chatgpt.sh** `-HPw`


# DESCRIPTION

This script acts as a wrapper for ChatGPT, DALL-E, STT (Whisper), and TTS
endpoints from OpenAI. Various service providers such as LocalAI,
Ollama, Anthropic, Mistral AI, GoogleAI, Groq AI, GitHub Models, Novita,
xAI, and DeepSeek APIs are supported.

With no options set, complete INPUT in single-turn mode of
the native chat completion.

Handles single-turn and multi-turn modes, pure text and native chat completions,
image generation and editing, speech-to-text, and text-to-speech models.

Positional arguments are read as a single PROMPT. Some functions
such as Whisper (STT) and TTS may handle optional positional parameters
before the text prompt itself.


# OPTIONS

## Interface Modes

**-b**, **\--responses**

: Responses API calls (may be used with `options -cc`). Limited support.
  Set a valid model with "**\--model** \[_name_]".


**-c**, **\--chat**

: Chat mode in text completions (used with `options -wzvv`).


**-cc**

: Chat mode in chat completions (used with `options -wzvv`).


**-C**, **\--continue**, **\--resume**

: Continue from (resume) last session (cmpls/chat).
 
**-d**, **\--text**

: Single-turn session of plain text completions.


**-dd**

: Multi-turn session of plain text completions with history support.


**-e**, **\--edit**

:     Edit first input from stdin or file (cmpls/chat).

      With `options -eex`, edit last text editor buffer from cache.


**-E**, **-EE**, **\--exit**

: Exit on first run (even with options -cc).


**-g**, **\--stream**   (_defaults_)

: Response streaming.


**-G**, **\--no-stream**

: Unset response streaming.


**-i**, **\--image**   \[_PROMPT_]

: Generate images given a prompt.
  Set _option -v_ to not open response.


**-i**   \[_PNG_]

: Create variations of a given image.


**-i**   \[_PNG_] \[_MASK_] \[_PROMPT_]

: Edit image with mask and prompt (required).


**-q**, **-qq**, **\--insert**

:     Insert text rather than completing only. May be set twice
      for multi-turn.

      Use "_\[insert]_" to indicate where the language model
      should insert text (\`instruct' and Mistral \`code models').


**-S** **.**\[_PROMPT_NAME_], **-.**\[_PROMPT_NAME_]

**-S** **,**\[_PROMPT_NAME_], **-,**\[_PROMPT_NAME_]

:     Load, search for, or create custom prompt.
      
      Set `.`\[_PROMPT_] to load prompt silently.
      
      Set `,`\[_PROMPT_] to single-shot edit prompt.

      Set `,,`\[_PROMPT_] to edit the prompt template file.
      
      Set `.`_?_, or `.`_list_ to list all prompt files.


**-S**, **--awesome**  **/**\[_AWESOME_PROMPT_NAME_]

**-S**, **--awesome-zh**  **%**\[_AWESOME_PROMPT_NAME_ZH_]

:     Set or search for an *awesome-chatgpt-prompt(-zh)*.
      
      Set **//** or **%%** instead to refresh cache.


**-T**, **\--tiktoken**

**-TT**, **-TTT**

:     Count input tokens with python Tiktoken (ignores special tokens).

      Set twice to print tokens, thrice to available encodings.
      
      Set the model or encoding with `option -m`.
      
      It heeds `options -ccm`.


**-w**, **\--transcribe**   \[_AUD_] \[_LANG_] \[_PROMPT_]

:     Transcribe audio file speech into text. LANG is optional.
      A prompt that matches the speech language is optional.
      Speech will be transcribed or translated to the target LANG.
      
      Set twice to phrase or thrice for word-level timestamps (-www).

      With `options -vv`, stop voice recorder on silence auto detection.


**-W**, **\--translate**   \[_AUD_] \[_PROMPT-EN_]

:     Translate audio file speech into English text.
      
      Set twice to phrase or thrice for word-level timestamps (-WWW).


**-z**, **\--tts**   \[_OUTFILE_|_FORMAT_|_-_] \[_VOICE_] \[_SPEED_] \[_PROMPT_]

:     Synthesise speech from text prompt. Takes a voice name, speed and text prompt.

      Set `option -v` to not play response automatically.


## Input Modes

**-u**, **\--multiline**

: Toggle multiline prompter, \<_CTRL-D_> flush.


**-U**, **\--cat**

: Cat prompter, \<_CTRL-D_> flush.


**-x**, **-xx**, **\--editor**

:     Edit prompt in text editor.
  
      Set twice to run the text editor interface a single time
      for the first user input.

      Set `options -eex` to edit last buffer from cache.


## Model Settings

**-\@**, **\--alpha**   \[\[_VAL%_]_COLOUR_]

:      Transparent colour of image mask. Def=_black_.

       Fuzz intensity can be set with \[_VAL%_]. Def=_0%_.


**-Nill**

: Unset model max response tokens (chat cmpls only).


**-NUM**

**-M**, **\--max**   \[_NUM_[_-NUM_]]

:     Maximum number of _response tokens_. Def=_4096_.

      A second number in the argument sets model capacity.


**-N**, **\--modmax**   \[_NUM_]

: _Model capacity_ token value. Def=_auto_, Fallback=_8000_.


**-a**, **\--presence-penalty**   \[_VAL_]

: Presence penalty  (cmpls/chat, -2.0 - 2.0).


**-A**, **\--frequency-penalty**   \[_VAL_]

: Frequency penalty (cmpls/chat, -2.0 - 2.0).


**\--best-of**   \[_NUM_]

: Best of results, must be greater than `option -n` (cmpls). Def=_1_.


**\--effort**  \[_high_|_medium_|_low_|_minimal_]  (OpenAI)

**\--think**   \[_token_num_]            (Anthropic / Google)

: Amount of effort in reasoning models.


**\--format**  \[_mp3_|_wav_|_flac_|_opus_|_aac_|_pcm16_|_mulaw_|_ogg_]

: TTS out-file format. Def= _mp3_.


**-j**, **\--seed**  \[_NUM_]

: Seed for deterministic sampling (integer).


**-K**, **\--top-k**     \[_NUM_]

: Top_k value (local-ai, ollama, google).


**\--keep-alive**, **\--ka**=\[_NUM_]

: How long the model will stay loaded into memory (Ollama).


**-m**, **\--model**   \[_MODEL_]

:     Language _MODEL_ name. Def=_gpt-3.5-turbo-instruct_/_gpt-4o_.

      Set _MODEL_ name as "_._" to pick from the list.


**\--multimodal**, **\--vision**, **\--audio**

: Model multimodal model type.


**-n**, **\--results**   \[_NUM_]

: Number of results. Def=_1_.


**-p**, **\--top-p**   \[_VAL_]

: Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).


**-r**, **\--restart**   \[_SEQ_]

: Restart sequence string (cmpls).


**-R**, **\--start**   \[_SEQ_]

: Start sequence string (cmpls).


**-s**, **\--stop**   \[_SEQ_]

: Stop sequences, up to 4. Def=\"_\<|endoftext|>_\".


**-S**, **\--instruction**   \[_INSTRUCTION_|_FILE_]

: Set an instruction text prompt. It may be a text file.


**\--time**, **\--no-time**

: Prepend the current date and time (timestamp) to the instruction prompt.


**-t**, **\--temperature**   \[_VAL_]

: Temperature value (cmpls/chat/stt), (0.0 - 2.0, stt 0.0 - 1.0). Def=_0_.


**\--no-truncation**

: Unset context truncation parameter (Responses API).


**\--verbosity**, **\--verb**  \[_high_|_medium_|_low_]

**\--no-verbosity**

: Model response verbosity level (OpenAI).


**\--voice**  [_alloy_|_fable_|_onyx_|_nova_|_shimmer_|_ash_|_ballad_|_coral_|_sage_|_verse_|_Adelaide-PlayAI_|_Angelo-PlayAI_|_Arista-PlayAI.._]

: TTS voice name. OpenAI or PlayAI (Groq) voice names. Def=_echo_, _Aaliyah-PlayAI_.


## Session and History Files

**-H**, **\--hist**   \[`/`_HIST_NAME_]

:     Edit history file with text editor or pipe to stdout.
      
      A history file name can be optionally set as argument.


**-P**, **-PP**, **\--print**   \[`/`_HIST_NAME_]

:     Print out last history session.
      
      Set twice to print commented out history entries, inclusive.
      Heeds `options -ccdrR`.

      These are aliases to **-HH** and **-HHH**, respectively.


## Configuration File

**-f**, **\--no-conf**

: Ignore user configuration file.


**-F**

:     Edit configuration file with text editor, if it exists.
      
      \$CHATGPTRC=\"_~/.chatgpt.conf_\".


**-FF**

: Dump template configuration file to stdout.


## Service Providers

**\--anthropic**, **\--ant**

: Anthropic integration (cmpls/chat). Also see **\--think**.


**\--deepseek**, **\--deep**

: DeepSeek integration (cmpls/chat).


**\--github**, **\--git**

: GitHub Models integration (chat).


**\--google**, **\-goo**

: Google Gemini integration (cmpls/chat).


**\--groq**

: Groq AI integration (chat).


**\--localai**

: LocalAI integration (cmpls/chat).


**\--mistral**

: Mistral AI integration (chat).


**\--novita**  (**legacy**)

: Novita AI integration (cmpls/chat).


**\--openai**

: Reset service integrations.


**-O**, **\--ollama**

: Ollama server integration (cmpls/chat).


**\--xai**

: xAI's Grok integration (cmpls/chat).


## Miscellaneous Settings

**\--api-key**   \[_KEY_]

: The API key to use.


**\--fold** (_defaults_), **\--no-fold**

: Set or unset response folding (wrap at white spaces).


**-h**, **\--help**

: Print the help page.


**\--info**

: Print OpenAI usage status (requires envar `$OPENAI_ADMIN_KEY`).


**-k**, **\--no-colour**

: Disable colour output. Def=_auto_.


**-l**, **\--list-models**   \[_MODEL_]

: List models or print details of _MODEL_.


**-L**, **\--log**   \[_FILEPATH_]

: Log file. _FILEPATH_ is required.


**\--md**, **\--markdown**, **\--markdown**=\[_SOFTWARE_]

: Enable markdown rendering in response. Software is optional:
  _bat_, _pygmentize_, _glow_, _mdcat_, or _mdless_.


**\--no-md**, **\--no-markdown**

: Disable markdown rendering.


**-o**, **\--clipboard**

: Copy response to clipboard.


**-v**, **-vv**  <!-- verbose -->

:     Less interface verbosity.

      Sleep after response in voice chat (`-vvccw`).

      With `options -ccwv`, sleep after response. With `options -ccwzvv`,
      stop recording voice input on silence detection and play TTS response
	  right away.

      May be set multiple times.


**-V**

:     Dump raw JSON request block (debug).


**\--version**

: Print script version.


**-y**, **\--tik**

: Tiktoken for token count (cmpls/chat, python).


**-Y**, **\--no-tik**   (_defaults_)

: Unset tiktoken use (cmpls/chat, python).


**-Z**, **-ZZ**, **-ZZZ**, **\--last**

: Print JSON data of the last responses.


# CHAT COMPLETION MODE
	
Set `option -c` to start a multi-turn chat mode via **text completions**
with history support. This option works with instruct models,
defaults to _gpt-3.5-turbo-instruct_ if none set.

Set `options -cc` to start the chat mode via **native chat completions**.
This mode defaults to the _gpt-4o_ model, which is optimised to follow
instructions. Try _chatgpt-4o-latest_ for a model optimised for chatting.

In chat mode, some options are automatically set to un-lobotomise the bot.

While using other providers, mind that `options -c` and `-cc` set different
endpoints! This setting must be set according to the model capabilities!

Set `option -C` to **resume** (continue from) last history session, and
set `option -E` to exit on the first response (even in multi turn mode).


# TEXT COMPLETION MODE  <!-- legacy -->

`Option -d` starts a single-turn session in **plain text completions**,
no history support. This does not set further options automatically,
such as instruction or temperature.

To run the script in text completion in multi-turn mode and history support,
set command line `options -dd`.

Set text completion models such as _gpt-3.5-turbo-instruct_.


# INSERT MODE (Fill-In-the-Middle)

Set `option -q` for **insert mode** in single-turn and `option -qq` for multiturn.
The flag "_[insert]_" must be present in the middle of the input prompt.
Insert mode works completing between the end of the text preceding the flag,
and ends completion with the succeeding text after the flag.

Insert mode works with \`instruct' and Mistral \`code' models.


# RESPONSES API

Responses API is a superset of Chat Completions API. Set command
line `option -b` (with `-cc`), or set `options -bb` for multiturn.

To activate it during multiturn chat, set `/responses [model]`,
where _model_ is the name of a model which works with the Responses API.
Aliased to `/resp [model]` and `-b [model]`. This can be toggled.

Limited support.


# INSTRUCTION PROMPTS

The SYSTEM INSTRUCTION prompt may be set with `option -S` or via
envars `$INSTRUCTION` and `$INSTRUCTION_CHAT`.

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text cmpls,
and chat cmpls. A text file path may be supplied as the single argument.
Also see *CUSTOM / AWESOME PROMPTS* section below.

To create and reuse a custom prompt, set the prompt name as a command
line option, such as "`-S .[_prompt_name_]`" or "`-S ,[_prompt_name_]`".

When the operator is a comma "_,_", single-shot editing will be available after
loading the prompt text. Use double "_,,_" to actually edit the template file itself!

Note that loading a custom prompt will also change to its respectively-named
history file.

Alternatively, set the first positional argument with the operator
and the prompt name after any command line options, such as
"`chatgpt;sh -cc .[_prompt_name_]`". This loads the prompt file unless instruction
was set with command line options.

To prepend the current date and time to the instruction prompt, set
command line `option --time`.

For TTS _gpt-4o-tts_ model type instructions, set command line option
`-S "[instruction]"` when invoking the script with `option -z` only
(stand-alone TTS mode). Alternatively, set envar `$INSTRUCTION_SPEECH`.

Note that for audio models such as `gpt-4o-audio`, the user can
control tone and accent of the rendered voice output with a
robust \`INSTRUCTION' as usual.


## Prompt Engineering and Design

Minimal **INSTRUCTION** to behave like a chatbot is given with
chat `options -cc`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, minimal instruction is given,
and some options auto set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of
text cmpls, such as Curie, the \`best_of' option may be worth
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

<!--
It is also worth trying to sample 3 - 5 times (increasing the number
of responses with \`option -n 3', for example) in order to obtain
a good response.
-->

<!--
For more on prompt design, see:

 - <https://platform.openai.com/docs/guides/completion/prompt-design>
 - <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>
 -->


# MODEL AND CAPACITY

Set model with "`-m` \[_MODEL_]", with _MODEL_ as its name,
or set it as "_._" to pick from the model list.

List models with `option -l` or run `/models` in chat mode.

Set _maximum response tokens_ with `option` "`-`_NUM_" or "`-M` _NUM_".
This defaults to _4096_ tokens and _25000_ for reasoning models, or
disabled when running on chat completions and responses endpoints.

If a second _NUM_ is given to this option, _maximum model capacity_
will also be set. The option syntax takes the form of "`-`_NUM/NUM_",
and "`-M` _NUM-NUM_".

_Model capacity_ (maximum model tokens) can be set more intuitively with
`option` "`-N` _NUM_", otherwise model capacity is set automatically
for known models or to _8000_ tokens as fallback.

`Option -y` sets python tiktoken instead of the default script hack
to preview token count. This option makes token count preview
accurate and fast (we fork tiktoken as a coprocess for fast token queries).
Useful for rebuilding history context independently from the original
model used to generate responses.

<!-- LocalAI only tested with text and chat completion models (vision) -->


# SPEECH-TO-TEXT (Whisper)

`Option -w` **transcribes audio speech** from _mp3_, _mp4_, _mpeg_, _mpga_, _m4a_,
_wav_, _webm_, _flac_ and _ogg_ files. First positional argument must be
an _AUDIO/VOICE_ file. Optionally, set a _TWO-LETTER_ input language (_ISO-639-1_)
as the second argument. A PROMPT may also be set to guide the model's style,
or continue a previous audio segment. The text prompt should match the speech language.

Note that `option -w` can also be set to **translate speech** input to any
text language to the target language.

`Option -W` **translates speech** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional
argument.

Set these options twice to have phrasal-level timestamps, options -ww and -WW.
Set thrice for word-level timestamps.

Combine `options -wW` **with** `options -cc` to start **chat with voice input**
(Whisper) support.
Additionally, set `option -z` to enable **text-to-speech** (TTS) models and voice out.


# TEXT-TO-VOICE (TTS)

`Option -z` synthesises voice from text (TTS models). Set a _voice_ as
the first positional parameter ("_alloy_", "_echo_", "_fable_", "_onyx_",
"_nova_", or "_shimmer_"). Set the second positional parameter as the
_voice speed_ (_0.25_ - _4.0_), and, finally the _output file name_ or
the _format_, such as "_./new_audio.mp3_" ("_mp3_", "_wav_", "_flac_",
"_opus_", "_aac_", or "_pcm16_"); or set "_-_" for stdout.

Do mind that PlayAI (supported by Groq AI) has different
output formats such as "_mulaw_" and "_ogg_", as well as different
voice names such as Aaliyah-PlayAI, Adelaide-PlayAI, Angelo-PlayAI, etc.

Set `options -zv` to _not_ play received output.


# MULTIMODAL AUDIO MODELS

Audio models, such as _gpt-4o-audio_, deal with audio input and output directly.

To activate the microphone recording function of the script, set command line `option -w`.

Otherwise, the audio model accepts any compatible audio file (such as **mp3**, **wav**, and **opus**).
These files can be added to be loaded at the very end of the user prompt
or added with chat command "`/audio` _path/to/file.mp3_".

To activate the audio synthesis output mode of an audio model, make sure to set command line `option -z`!


# IMAGE GENERATIONS AND EDITS (Dall-E)

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an _IMAGE_ file, then **generate variations** of
it. If the first positional argument is an _IMAGE_ file and the second
a _MASK_ file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** _IMAGE_ according to _MASK_ and PROMPT.
If _MASK_ is not provided, _IMAGE_ must have transparency.

The **size of output images** may be set as the first positional parameter
in the command line:

    gpt-imge: "_1024x1024_" (_L_, _Large_, _Square_), "_1536x1024_" (_X_, _Landscape_), or "_1024x1536_" (_P_, _Portrait_).

    dall-e-3: "_1024x1024_" (_L_, _Large_, _Square_), "_1792x1024_" (_X_, _Landscape_), or "_1024x1792_" (_P_, _Portrait_).

    dall-e-2: "_256x256_" (_Small_), "_512x512_" (_M_, _Medium_), or "_1024x1024_" (_L_, _Large_).


A parameter "_high_", "_medium_", "_low_", or "_auto_" may also be appended
to the size parameter to set image quality with gpt-image, such as
"_Xhigh_" or "_1563x1024high_". Defaults=_1024x1024auto_.

The parameter "_hd_" or "_standard_" may also be set for image quality with dall-e-3.

For dall-e-3, optionally set the generation style as either "_natural_"
or "_vivid_" as one of the first  positional parameters at command line invocation.

Note that the user needs to verify his organisation to use _gpt-image_ models!

See **IMAGES section** below for more information on **inpaint** and **outpaint**.


# TEXT / CHAT COMPLETIONS

## 1. Text Completion

Given a prompt, the model will return one or more predicted
completions. For example, given a partial input, the language
model will try completing it until probable "`<|endoftext|>`",
or other stop sequences (stops may be set with `-s "\[stop-seq]"`).

**Restart** and **start sequences** may be optionally set. Restart and start
sequences are not set automatically if the chat mode of text completions
is not activated with `option -c`.

Readline is set to work with **multiline input** and pasting from the
clipboard. Alternatively, set `option -u` to enable pressing \<_CTRL-D_>
to flush input! Or set `option -U` to set _cat command_ as input prompter.

Bash bracketed paste is enabled, meaning multiline input may be
pasted or typed, even without setting `options -uU` (_v25.2+_).

Language model **SKILLS** can be activated with specific prompts,
see <https://platform.openai.com/examples>.


## 2. Interactive Conversations


### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps
a history file, and keeps new questions in context. This works
with a variety of models. Set `option -E` to exit on response.


### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. More recent
models are also the best option for many non-chat use cases.


### 2.3 Q & A Format

The defaults chat format is "**Q & A**". The **restart sequence**
"_\\nQ:\ _" and the **start text** "_\\nA:_" are injected
for the chat bot to work well with text cmpls.

In multi-turn interactions, prompts prefixed with colons "_:_"
are buffered to be prepended to the user prompt (**USER MESSAGE**)
without incurring an API call. Conversely, prompts starting with double colons
"_::_" are prepended to the instruction prompt (**INSTRUCTION / SYSTEM MESSAGE**).

Entering exactly triple colons "_:::_" reinjects a system instruction
prompt into the current request. This is useful to reinforce the instruction
when the model's context has been truncated.


### 2.4 Voice input (STT), and voice output (TTS)

The `options -ccwz` may be combined to have voice recording input and
synthesised voice output, specially nice with chat modes.
When setting `flag -w` or `flag -z`, the first positional parameters are read as
STT or TTS  arguments. When setting both `flags -wz`,
add a double hyphen to set first STT, and then TTS arguments.

Set chat mode, plus voice-in transcription language code and text prompt,
and the TTS voice-out option argument:

    chatgpt.sh -ccwz  en 'transcription prompt'  --  nova


### 2.5 Vision and Multimodal Models

To send an _image_ or _url_ to **vision models**, either set the image
with the "`!img`" command with one or more _filepaths_ / _urls_.

    chatgpt.sh -cc -m gpt-4-vision-preview '!img path/to/image.jpg'


Alternatively, set the _image paths_ / _urls_ at the end of the
text prompt interactively:

    chatgpt.sh -cc -m gpt-4-vision-preview

    [...]
    Q: In this first user prompt, what can you see?  https://i.imgur.com/wpXKyRo.jpeg

Make sure file paths containing spaces are backslash-escaped!


### 2.6 Text, PDF, Doc, and URL Dumps

The user may add a _filepath_ or _URL_ to the end of the prompt.
The file is then read and the text content added to the user prompt.
This is a basic text feature that works with any model.


    chatgpt.sh -cc

    [...]
    Q: What is this page: https://example.com

    Q: Help me study this paper. ~/Downloads/Prigogine\ Perspective\ on\ Nature.pdf


In the second example, the _PDF_ will be dumped as text.

For PDF text dump support, `poppler/abiword` is required.
For _doc_ and _odt_ files, `LibreOffice` is required.
See the **Optional Packages** section.

Also note that _file paths_ containing white spaces must be
**blackslash-escaped**, or the _file path_ must be preceded
by a pipe \`|' character.

Multiple images and audio files may be added to the request in this way!


# COMMAND LIST

While in chat mode, the following commands can be invoked in the
new prompt to change parameters and manage sessions.
Command operators "`!`" or "`/`" are equivalent.


## Command Tables

 Misc              Commands
 --------------    ------------------------------    -------------------------------------------------------------
       `-S`                     \[_PROMPT_]          Overwrite the system prompt.
     ` -S:`        `:`          \[_PROMPT_]          Prepend to current user prompt.
     `-S::`        `::`         \[_PROMPT_]          Prepend to system prompt.
    `-S:::`        `:::`                             Reset (inject) system prompt into request.
      `-S.`        `-.`          \[_NAME_]           Load and edit custom prompt.
      `-S/`        `!awesome`    \[_NAME_]           Load and edit awesome prompt (english).
      `-S%`        `!awesome-zh` \[_NAME_]           Load and edit awesome prompt (chinese).
       `-Z`        `!last`                           Print last raw JSON or the processed text response.
       `!#`        `!save`      \[_PROMPT_]          Save current prompt to shell history. _‡_
        `!`        `!r`, `!regen`                    Regenerate last response.
       `!!`        `!rr`                             Regenerate response, edit prompt first.
      `!g:`        `!!g:`       \[_PROMPT_]          Ground user prompt with web search results. _‡_
       `!i`        `!info`      \[_REGEX_]           Information on model and session settings.
      `!!i`        `!!info`                          Monthly usage stats (OpenAI).
       `!j`        `!jump`                           Jump to request, append start seq primer (text cmpls).
      `!!j`        `!!jump`                          Jump to request, no response priming.
     `!cat`         \-                               Cat prompter as one-shot, \<_CTRL-D_> flush.
     `!cat`        `!cat:` \[_TXT_|_URL_|_PDF_]      Cat _text_, _PDF_ file, or dump _URL_.
    `!clot`        `!!clot`                          Flood the TTY with patterns, as visual separator.
  `!dialog`         \-                               Toggle the "dialog" interface.
     `!img`        `!media` \[_FILE_|_URL_]          Add image, media, or URL to prompt.
      `!md`        `!markdown`  \[_SOFTW_]           Toggle markdown rendering in response.
     `!!md`        `!!markdown` \[_SOFTW_]           Render last response in markdown.
     `!rep`        `!replay`                         Replay last TTS audio response.
     `!res`        `!resubmit`                       Resubmit last STT recorded audio in cache.
       `!p`        `!pick`      \[_PROPMT_]          File picker, appends filepath to user prompt. _‡_
     `!pdf`        `!pdf:`      \[_FILE_]            Convert PDF and dump text.
   `!photo`        `!!photo`   \[_INDEX_]            Take a photo, optionally set camera index (Termux). _‡_
      `!sh`        `!shell`      \[_CMD_]            Run shell _command_ and edit stdout (make request). _‡_
     `!sh:`        `!shell:`     \[_CMD_]            Same as `!sh` and insert stdout into current prompt.
     `!!sh`        `!!shell`     \[_CMD_]            Run interactive shell _command_ and return.
     `!url`        `!url:`       \[_URL_]            Dump URL text or YouTube transcript text.
 --------------    ------------------------------    -------------------------------------------------------------

 Script            Settings and UX
 --------------    -----------------------    ----------------------------------------------------------
   `!fold`         `!wrap`                    Toggle response wrapping.
      `-F`         `!conf`                    Runtime configuration form TUI.
      `-g`         `!stream`                  Toggle response streaming.
      `-h`         `!help`     \[_REGEX_]     Print help or grep help for regex.
      `-l`         `!models`    \[_NAME_]     List language models or show model details.
      `-o`         `!clip`                    Copy responses to clipboard.
      `-u`         `!multi`                   Toggle multiline prompter. \<_CTRL-D_> flush.
     `-uu`         `!!multi`                  Multiline, one-shot. \<_CTRL-D_> flush.
      `-U`         `-UU`                      Toggle cat prompter or set one-shot. \<_CTRL-D_> flush.
      `-V`         `!debug`                   Dump raw request block and confirm.
      `-v`          \-                        Toggle interface verbose modes.
      `-x`         `!ed`                      Toggle text editor interface.
     `-xx`         `!!ed`                     Single-shot text editor.
      `-y`         `!tik`                     Toggle python tiktoken use.
      `!q`         `!quit`                    Exit. Bye.
 --------------    -----------------------    ----------------------------------------------------------

 Model             Settings
 --------------    ------------------------    ------------------------------------------------------------
   `!Nill`         `-Nill`                     Unset max response tkns (chat cmpls).
    `!NUM`         `-M`          \[_NUM_]      Maximum response tokens.
   `!!NUM`         `-N`          \[_NUM_]      Model token capacity.
      `-a`         `!pre`        \[_VAL_]      Presence penalty.
      `-A`         `!freq`       \[_VAL_]      Frequency penalty.
      `-b`         `!responses`  \[_MOD_]      Responses API request (experimental). 
    `best`         `!best-of`    \[_NUM_]      Best-of n results.
      `-j`         `!seed`       \[_NUM_]      Seed number (integer).
      `-K`         `!topk`       \[_NUM_]      Top_k.
      `-m`         `!mod`        \[_MOD_]      Model by name, empty to pick from list.
      `-n`         `!results`    \[_NUM_]      Number of results.
      `-p`         `!topp`       \[_VAL_]      Top_p.
      `-r`         `!restart`    \[_SEQ_]      Restart sequence.
      `-R`         `!start`      \[_SEQ_]      Start sequence.
      `-s`         `!stop`       \[_SEQ_]      One stop sequence.
      `-t`         `!temp`       \[_VAL_]      Temperature.
      `-w`         `!rec`       \[_ARGS_]      Toggle voice-in STT. Optionally, set arguments.
      `-z`         `!tts`       \[_ARGS_]      Toggle TTS chat mode (speech out).
    `!blk`         `!block`     \[_ARGS_]      Set and add custom options to JSON request.
 `!effort`          \-          \[_MODE_]      Reasoning effort: minimal, high, medium, or low (OpenAI).
  `!think`          \-           \[_NUM_]      Thinking budget: tokens (Anthropic).
     `!ka`         `!keep-alive` \[_NUM_]      Set duration of model load in memory (Ollama).
   `!verb`         `!verbosity` \[_MODE_]      Model verbosity level (high, medium, or low).
  `!vision`        `!audio`, `!multimodal`     Toggle multimodality type.
 --------------    ------------------------    ------------------------------------------------------------

 Session           Management
 --------------    --------------------------------------    ---------------------------------------------------------------------------------------------------
      `-C`          \-                                       Continue current history session (see `!break`).
      `-H`         `!hist`       \[_NUM_]                    Edit history in editor or print the last _n_ history entries.
      `-P`         `-HH`, `!print`                           Print session history.
      `-L`         `!log`       \[_FILEPATH_]                Save to log file.
      `!c`         `!copy`  \[_SRC_HIST_] \[_DEST_HIST_]     Copy session from source to destination.
      `!f`         `!fork`      \[_DEST_HIST_]               Fork current session and continue from destination.
      `!k`         `!kill`      \[_NUM_]                     Comment out _n_ last entries in history file.
     `!!k`         `!!kill`     \[\[_0_]_NUM_]               Dry-run of command `!kill`.
      `!s`         `!session`   \[_HIST_NAME_]               Change to, search for, or create history file.
     `!!s`         `!!session`  \[_HIST_NAME_]               Same as `!session`, break session.
      `!u`         `!unkill`    \[_NUM_]                     Uncomment _n_ last entries in history file.
     `!!u`         `!!unkill`   \[\[_0_]_NUM_]               Dry-run of command `!unkill`.
     `!br`         `!break`, `!new`                          Start new session (session break).
     `!ls`         `!list`      \[_GLOB_|_._|_pr_|_awe_]     List history files with "_glob_" in _name_; Files: "_._"; Prompts: "_pr_"; Awesome: "_awe_".
   `!grep`         `!sub`       \[_REGEX_]                   Grep sessions and copy session to hist tail.
 --------------    --------------------------------------    ---------------------------------------------------------------------------------------------------


| _:_ Commands with *colons* have their output added to the current prompt buffer.

| _‡_ Commands with *double dagger* may be invoked at the very end of the input prompt (preceded by space).

---


Examples

|   "`/temp` _0.7_",  "`!mod`_gpt-4_",  "`-p` _0.2_"

|   "`/session` _HIST_NAME_",  "\[_PROMPT_] `/pick`"

|   "\[_PROMPT_] `/sh`"

---


Some options can be disabled and excluded from the request by setting
a "_-1_" as argument (bypass with "_-1.0_")

|   "`!presence` _-1_",  "`-a` _-1_", "`-t`_-1_"

---


## Response Regeneration

To **regenerate response**, type in the command "`!regen`" or a single
exclamation mark or forward slash in the new empty prompt. In order
to edit the prompt before the request, try "`!!`" (or "`//`").


## Shell and File Integration

The "`/pick`" command opens a file picker (usually a command-line
file manager). The selected file's path will be appended to the
current prompt in editing mode.

The "`/sh`" and "`/pick`" commands may be run when typed at the end of
the current prompt, such as "\[_PROMPT_] `/sh`", which opens a new
shell instance to execute commands interactively. The shell command dump
or file path is appended to the current prompt.

Any "`!CMD`" not matching a chat command is executed by the shell
as an alias for "`!sh CMD`".
Note that this shortcut only works with operator exclamation mark.


## API Parameter Injection

Envar **$BLOCK_USR** can be set to raw model options in JSON syntax,
according to each API, to be injected in the request block.
Alternatively, run command "`!block` \[_ARGS_]" during chat mode.


# Session Management

A history file can hold a single session or multiple sessions.
When it holds a single session, the name of the history file and the
session are the same. However, in case the user breaks a session,
the last one (the tail session) of that history file is always loaded
when the resume `option -C` is set.

The script uses a _TSV file_ to record entries, which is kept at the script
cache directory ("`~/.cache/chatgptsh/`"). The **tail session** of the
history file can always be read and resumed.

Run command "`/list [glob]`" with optional "_glob_" to list session / history "_tsv_" files.
When glob is "_._" list all files in the cache directory;
when "_pr_" list all instruction prompt files;
and when "_awe_" list all awesome prompts.


## Changing Session

A new history file can be created or changed to with command
"`/session` \[_HIST_NAME_]", in which _HIST_NAME_
is the file name or path of a history file.

On invocation, when the first positional argument to the script follows
the syntax "`/`[_HIST_NAME_]", the command "`/session`" is assumed
(with `options -ccCdPP`).


## Resuming and Copying Sessions

To continue from an old session type in a dot "`.`"  or "`/.`"
as the first positional argument from the command line on invocation.

The above command is a shortcut of "`/copy` _current_ _current_".
In fact, there are multiple commands to copy and resume from
an older session (the dot means _current session_):
"`/copy . .`", "`/fork.`", "`/sub`", and "`/grep` \[_REGEX_]".

From the command line on invocation, simply type "`.`" as
the first positional argument.

It is possible to copy sessions of a history file to another file
when a second argument is given to the "`/copy`" command.

Mind that forking a session will change to the destination
history file and resume from it as opposed to just copying it.


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

In these cases, a pickup interface should open to let the user choose
the correct session from the history file. -->


## History File Editing

To edit chat context at run time, the history file may be
modified with the "`/hist`" command (also good for context injection).

Delete history entries or comment them out with "#".


<!--
# CODE COMPLETIONS _(discontinued)_

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
# TEXT EDITS  _(discontinued)_

--
This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify
a prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure
of text, or make targeted changes like fixing spelling. Edits
work well on empty prompts, thus enabling text generation similar
to the completions endpoint. 

--

Alternatively, use _gpt-4+ models_ and the right instructions.
-->


# CUSTOM / AWESOME PROMPTS

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


# IMAGES / DALL-E

## 1. Image Generations

An image can be created given a text prompt. A text PROMPT
of the desired image(s) is required. The maximum length is 1000
characters.

This script also supports xAI image generation model
with invocation "`chatgpt.sh --xai -i -m grok-2-image-1212 "[prompt]"`".


## 2. Image Variations

Variations of a given _IMAGE_ can be generated. The _IMAGE_ to use as
the basis for the variations must be a valid PNG file, less than
4MB and square.


## 3. Image Edits

To edit an _IMAGE_, a _MASK_ file may be optionally provided. If _MASK_
is not provided, _IMAGE_ must have transparency, which will be used
as the mask. A text prompt is required.

### 3.1 ImageMagick

If **ImageMagick** is available, input _IMAGE_ and _MASK_ will be checked
and processed to fit dimensions and other requirements.

### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with "`-@`\[_COLOUR_]" to create the
mask. Defaults=_black_.

By defaults, the _COLOUR_ must be exact. Use the \`fuzz option' to match
colours that are close to the target colour. This can be set with
"`-@`\[_VALUE%_]" as a percentage of the maximum possible intensity,
for example "`-@`_10%black_".

See also:

 - <https://imagemagick.org/script/color.php>
 - <https://imagemagick.org/script/command-line-options.php#fuzz>

### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image
with the set transparent colour (defaults to _black_). In this way,
it is easy to make a mask with any black and white image as a
template.

### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this
script. Paint a portion of the outer area of an image with _alpha_,
or a defined _transparent_ _colour_ which will be used as the mask, and set the
same _colour_ in the script with `option -@`. Choose the best result amongst
many results to continue the out-painting process step-wise.


# STT / VOICE-IN / WHISPER

## Transcriptions

Transcribes audio file or voice record into the set language.
Set a _two-letter_ _ISO-639-1_ language code (_en_, _es_, _ja_, or _zh_) as
the positional argument following the input audio file. A prompt
may also be set as last positional parameter to help guide the
model. This prompt should match the audio language.

If the last positional argument is "." or "last" exactly, it will
resubmit the last recorded audio input file from cache.

Note that if the audio language is different from the set language code,
output will be on the language code (translation).


## Translations

Translates audio into **English**. An optional text to guide
the model's style or continue a previous audio segment is optional
as last positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.


# PROVIDER INTEGRATIONS

For LocalAI integration, run the script with `option --localai`,
or set environment **$OPENAI_BASE_URL** with the server Base URL.

For Mistral AI set environment variable **\$MISTRAL_API_KEY**,
and run the script with `option --mistral` or set **$OPENAI_BASE_URL**
to "https://api.mistral.ai/".
Prefer setting command line `option --mistral` for complete integration.
<!-- also see: \$MISTRAL_BASE_URL -->

For Ollama, set `option -O` (`--ollama`), and set **$OLLAMA_BASE_URL**
if the server URL is different from the defaults.

Note that model management (downloading and setting up) must
follow the Ollama project guidelines and own methods.

For Google Gemini, set environment variable **$GOOGLE_API_KEY**, and
run the script with the command line `option --google`.

For Groq, set the environmental variable `$GROQ_API_KEY`.
Run the script with `option --groq`.
Transcription (Whisper) endpoint available.

For Anthropic, set envar `$ANTHROPIC_API_KEY` and run the script
with command line `option --anthropic`.

For GitHub Models, `$GITHUB_TOKEN` and invoke the script
with `option --github`.

For Novita AI integration, set the environment variable `$NOVITA_API_KEY` and
use the `--novita` option (**legacy**).

Likewise, for xAI's Grok, set environment `$XAI_API_KEY` with its API key.

And for DeepSeek API, set environment `$DEEPSEEK_API_KEY` with its API key.

Run the script with `option --xai` and also with `option -cc` (chat completions.).

Some models also work with native text completions. For that,
set command-line `option -c` instead.


# ENVIRONMENT

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

:    Initial initial instruction message.


**INSTRUCTION_CHAT**

:    Initial initial instruction or system message in chat mode.


**INSTRUCTION_SPEECH**

:    TTS transcription model instruction (gpt-4o-tts models).


**LC_ALL**

**LANG**

:   Default instruction language in chat mode. <!-- and Whisper language. -->


**MOD_CHAT**, **MOD_IMAGE**, **MOD_AUDIO**,

**MOD_SPEECH**, **MOD_LOCALAI**, **MOD_OLLAMA**,

**MOD_MISTRAL**, **MOD_AUDIO_MISTRAL**, **MOD_GOOGLE**,

**MOD_GROQ**, **MOD_AUDIO_GROQ**, **MOD_SPEECH_GROQ**,

**MOD_ANTHROPIC**, **MOD_GITHUB**, **MOD_NOVITA**,

**MOD_XAI**, **MOD_DEEPSEEK**

:    Set default model for each endpoint / provider.


**OPENAI_BASE_URL**

**OPENAI_URL_PATH**

:    Main Base URL setting. Alternatively, provide a _URL_PATH_ parameter with the full url path to disable endpoint auto selection.


**PROVIDER_BASE_URL**

:    Base URLs for each service provider:
     _LOCALAI_, _OLLAMA_, _MISTRAL_, _GOOGLE_, _ANTHROPIC_, _GROQ_, _GITHUB_, _NOVITA_, _XAI_, and _DEEPSEEK_.


**OPENAI_API_KEY**

**PROVIDER_API_KEY**

**GITHUB_TOKEN**

:    Keys for OpenAI, Gemini, Mistral, Groq, Anthropic, GitHub Models, Novita, xAI, and DeepSeek APIs.


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


# Web Search

## Simple Search Dump

To ground a user prompt with search results, run chat command "`/g [prompt]`".

Default search provider is Google. To select a different search provider,
run "`//g [prompt]`" and choose amongst _Google_, _DuckDuckGo_, or _Brave_.

Running "`//g [prompt]`" will always use the in-house solution instead of
any service provider specific web search tool.

A cli-browser is required, such as **w3m**, **elinks, **links**,
or **lynx**.


## OpenAI Web Search

Use the in-house solution above, or select models with "search" in the name,
such as "gpt-4o-search-preview".

<!--
To enable live search in the API, run chat command `/g [prompt]` or
`//g [prompt]` (to use the fallback mechanism) as usual;
or to keep live search enabled for all prompts, set `$BLOCK_USR`
environment variable before running the script such as:

```
export BLOCK_USR='"tools": [{
  "type": "web_search_preview",
  "search_context_size": "medium"
}]'

chatgpt.sh -cc -m gpt-4.1-2025-04-14
```

Check more search parameters at the OpenAI API documentation:
<https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses>.
<https://platform.openai.com/docs/guides/tools-web-search?api-mode=chat>.
-->


## xAI Live Search

```
export BLOCK_USR='"search_parameters": {
  "mode": "auto",
  "max_search_results": 10
}'

chatgpt.sh --xai -cc -m grok-3-latest 
```

Check more search parameters at the xAI API documentation:
<https://docs.x.ai/docs/guides/live-search>.


## Anthropic Web Search

```
export BLOCK_USR='"tools": [{
  "type": "web_search_20250305",
  "name": "web_search",
  "max_uses": 5
}]'

chatgpt.sh --ant -cc -m claude-opus-4-0
```

Check more web search parameters at Anthropic API docs:
<https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking>.


## Google Search

```
export BLOCK_CMD='"tools": [ { "google_search": {} } ]'

chatgpt.sh --goo -cc -m gemini-2.5-flash-preview-05-20
```

Check more web search parameters at Google AI API docs:
<https://ai.google.dev/gemini-api/docs/grounding?lang=rest>.


# COLOR THEMES

The colour scheme may be customised. A few themes are available
in the template configuration file.

A small colour library is available for the user conf file to personalise
the theme colours.

The colour palette is composed of _\$Red_, _\$Green_, _\$Yellow_, _\$Blue_,
_\$Purple_, _\$Cyan_, _\$White_, _\$Inv_ (invert), and _\$Nc_ (reset) variables.

Bold variations are defined as _\$BRed_, _\$BGreen_, etc, and
background colours can be set with _\$On_Yellow_, _\$On_Blue_, etc.

Alternatively, raw escaped color sequences, such as
_\\u001b[0;35m_, and _\\u001b[1;36m_ may be set.

Theme colours are named variables from `Colour1` to about `Colour11`,
and may be set with colour-named variables or
raw escape sequences (these must not change cursor position).


# CONFIGURATION AND CACHE FILES

User configuration is stored in **~/.chatgpt.conf**. Its path location
can be set with envar **$CHATGPTRC**.

The script's cache directory is **~/.cache/chatgptsh/** and
may contain the following file types:

*   **Session Records (tsv):** Tab-separated value files storing session history.  The default session record is **chatgpt.tsv**.
*   **Prompt Files (pr):** Files storing user-defined custom instructions (initial prompts).
*   **Command History (history_bash):**  Bash command-line input history.  This file is trimmed according to the **$HISTSIZE** setting in the configuration file.  While it improves session recall, a large **history_bash** file can slow down script startup. It can be safely removed if necessary.
*   **Temporary Buffers:** Various files holding temporary text and data. These files are safe to remove and are not intended for backup.

**Backup Recommendation:**  It is strongly recommended to back up 
session record files (tsv) and prompt files (pr), as well as the
configuration file (chatgpt.sh)
to preserve session history, custom promptsnd settings.


# KEYBINDINGS

Press \<_CTRL-X_ _CTRL-E_> to edit command line in text editor from readline.

Press \<_CTRL-J_> or \<_CTRL-V_ _CTRL-J_> for newline in readline.

Press \<_CTRL-L_> to redraw readline buffer (user input) on screen.

During _cURL_ requests, press \<_CTRL-C_> once to interrupt the call.

Press \<_CTRL-\\_> to exit from the script (send _QUIT_ signal),
or "_Q_" in user confirmation prompts.


# NOTES

Stdin text is appended to any existing command line PROMPT.

Input sequences "_\\n_" and "_\\t_" are only treated specially
(as escaped new lines and tabs) in restart, start and stop sequences!

The moderation endpoint can be accessed by setting the model name
to _omni-moderation-latest_ (or _text-moderation-latest_).

For complete model and settings information, refer to OpenAI
API docs at <https://platform.openai.com/docs/>.

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
- `poppler`/`gs`/`abiword`/`ebook-convert`/`LibreOffice` - Dump PDF or Doc as text
- `dialog`/`kdialog`/`zenity`/`osascript`/`termux-dialog` - File picker
- `yt-dlp` - Dump YouTube captions


# CAVEATS

The script objective is to implement some of the features of OpenAI
API version 1. As text is the only universal interface, voice and image
features will only be partially supported, and not all endpoints or
options will be covered.

This project _doesn't support_ "Function Calling", "Structured Outputs",
"Real-Time Conversations", "Agents/Operators", "MCP Servers", nor "video generation / editing"
capabilities.

Support for "Responses API" is limited and experimental at this point.


# BUGS

Reasoning (thinking) and answers from certain API services may not have a
distinct separation of output due to JSON processing constraints.

Bash "read command" may not correctly display input buffers larger than
the TTY screen size during editing. However, input buffers remain
unaffected. Use the text editor interface for big prompt editing.

If readline screws up your currrent input buffer, try pressing \<_CTRL-L_>
to force it to redisplay and refresh the prompt properly on screen.

File paths containing spaces may not work correctly in the chat interface.
Make sure to backslash-escape filepaths with white spaces.

Folding the response at white spaces may not worked correctly if the user
has changed his terminal tabstop setting. Reset it with command "tabs -8"
or "reset" before starting the script, or set one of these in the
script configuration file.

If folding does not work well at all, try exporting envar `$COLUMNS`
before script execution.

Bash truncates input on "\\000" (null).

Garbage in, garbage out. An idiot savant.

The script logic resembles a bowl of spaghetti code after a cat fight.

<!-- Changing models in the same session may generate token count errors
because the recorded token count may differ from model encoding to encoding.
Set `option -y` for accurate token counting. -->

<!-- With the exception of Davinci and newer base models, older models were designed
to be run as one-shot. -->

<!--
`Zsh` does not read history file in non-interactive mode.

`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.

`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->

<!--
# EXAMPLES -->

