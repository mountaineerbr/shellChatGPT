# shellChatGPT
Shell wrapper for OpenAI's ChatGPT, DALL-E, STT (Whisper), and TTS. Features LocalAI, Ollama, Gemini, Mistral, and more service providers.


![Showing off Chat Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls.gif)

Chat completions with streaming by defaults.

<details>
  <summary>Expand Markdown Processing</summary>

Markdown processing on response is triggered automatically for some time now!

![Chat with Markdown rendering](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_md.gif)

Markdown rendering of chat response (_optional_).
</details>

<details>
  <summary>Expand Text Completions</summary>

![Plain Text Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/text_cpls.gif)

In pure text completions, start by typing some text that is going to be completed, such as news, stories, or poems.
</details>

<details>
  <summary>Expand Insert Mode</summary>

![Insert Text Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/text_insert.gif)

Add the insert tag `[insert]` where it is going to be completed.
Mistral `code models` work well with the insert / fill-in-the-middel (FIM) mode!
If no suffix is provided, it works as plain text completions.
</details>


## Index

<details>
  <summary>★ Click to expand! ★</summary>

- 1. [Index](#index)
- 2. [Features](#-features)
- 3. [Getting Started](#-getting-started)
  - 3.1 [Required Packages](#-required-packages)
  - 3.2 [Optional Packages](#optional-packages)
  - 3.3 [Installation](#-installation)
  - 3.4 [Usage Examples](#-usage-examples-)
- 4. [Script Operating Modes](#script-operating-modes)
- 5. [Native Chat Completions](#-native-chat-completions)
  - 5.1 [Reasoning and Thinking Models](#reasoning-and-thinking-models)
  - 5.2 [Vision and Multimodal Models](#vision-and-multimodal-models)
  - 5.3 [Text, PDF, Doc, and URL Dumps](#text-pdf-doc-and-url-dumps)
  - 5.4 [File Picker and Shell Dump](#file-picker-and-shell-dump)
  - 5.5 [Voice In and Out + Chat Completions](#voice-in-and-out-chat-completions)
  - 5.6 [Audio Models](#audio-models)
- 6. [Chat Mode of Text Completions](#chat-mode-of-text-completions)
- 7. [Text Completions](#-text-completions)
  - 7.1 [Insert Mode of Text Completions](#insert-mode-of-text-completions)
- 8. [Responses  API](#responses-api)
- 9. [Markdown](#markdown)
- 10. [Prompts](#-prompts)
  - 10.1 [Instruction Prompt](#instruction-prompt)
  - 10.2 [Custom Prompts](#-custom-prompts)
  - 10.3 [Awesome Prompts](#-awesome-prompts)
- 11. [Shell Completion](#shell-completion)
  - 11.1 [Bash](#bash)
  - 11.2 [Zsh](#zsh)
  - 11.3 [Troubleshoot](#troubleshoot-shell)
- 12. [Notes and Tips](#-notes-and-tips)
- 13. [Image Generations](#%EF%B8%8F-image-generations)
- 14. [Image Variations](#image-variations)
- 15. [Image Edits](#image-edits)
  - 15.1 [Outpaint - Canvas Extension](#outpaint---canvas-extension)
  - 15.2 [Inpaint - Fill in the Gaps](#inpaint---fill-in-the-gaps)
- 16. [Speech Transcriptions / Translations](#-speech-transcriptions--translations)
- 17. [Service Providers](#service-providers)
  - 17.1 [LocalAI](#localai)
    - 17.1.1 [LocalAI Server](#localai-server)
    - 17.1.2 [Tips](#tips)
    - 17.1.3 [Running the shell wrapper](#running-the-shell-wrapper)
    - 17.1.4 [Installing Models](#installing-models)
    - 17.1.5 [Host API Configuration](#base-url-configuration)
    - 17.1.6 [OpenAI Web Search](#openai-web-search)
  - 17.2 [Ollama](#ollama)
  - 17.3 [Google AI](#google-ai)
    - 17.3.1 [Google AI](#google-search)
  - 17.4 [Mistral AI](#mistral-ai)
  - 17.5 [Groq](#groq)
    - 17.5.1 [Groq Whisper](#groq-whisper-stt)
    - 17.5.2 [Groq TTS](#groq-tts)
  - 17.6 [Anthropic](#anthropic)
    - 17.6.1 [Anthropic Web Search](#anthropic-web-search)
  - 17.7 [GitHub Models](#github-models)
  - 17.8 [Novita AI](#novita-ai)
  - 17.9 [xAI](#xai)
    - 17.9.1 [xAI Live Search](#xai-live-search)
    - 17.9.2 [xAI Image Generation](#xai-image-generation)
  - 17.10 [DeepSeek](#deepseek)
- 18. [Arch Linux Users](#arch-linux-users)
- 19. [Termux Users](#termux-users)
  - 19.1 [Dependencies](#dependencies-termux)
  - 19.2 [TTS Chat - Removal of Markdown](#tts-chat---removal-of-markdown)
  - 19.3 [Tiktoken](#tiktoken)
  - 19.4 [Troubleshoot](#troubleshoot-termux)
- 20. [Project Objectives](#--project-objectives)
- 21. [Roadmap](#roadmap)
- 22. [Limitations](#%EF%B8%8F-limitations)
- 23. [Bug report](#bug-report)
- 24. [Help Pages](#-help-pages)
- 25. [Contributors](#-contributors)
- 26. [Acknowledgements](#acknowledgements)

<!-- - 9. [Local Cache Structure](#cache-structure) (prompts, sessions, and history files) -->

</details>


## 🚀 Features

- Text and chat completions.
- [Vision](#vision-models-gpt-4-vision), **reasoning** and [**audio models**](#audio-models)
- **Voice-in** (Whisper) plus **voice out** (TTS) [_chatting mode_](#voice-in-and-out--chat-completions) (`options -cczw`)
- **Text editor interface**, _Bash readline_, and _multiline/cat_ modes
- [**Markdown rendering**](#markdown) support in response
- Easily [**regenerate responses**](#--notes-and-tips)
- **Manage sessions**, _print out_ previous sessions
- Set [Custom Instruction prompts](#%EF%B8%8F--custom-prompts)
- Integration with [various service providers](#service-providers) and [custom BaseUrl](#base-url-configuration).
- Support for [awesome-chatgpt-prompts](#-awesome-prompts) & the
   [Chinese variant](https://github.com/PlexPt/awesome-chatgpt-prompts-zh)
- Stdin and text file input support
- Should™ work on Linux, FreeBSD, MacOS, and [Termux](#termux-users)
- **Fast** shell code for a responsive experience! ⚡️ 

<!-- _Tiktoken_ for accurate tokenization (optional) -->
<!-- _Follow up_ conversations, --> <!-- _continue_ from last session, --> 
<!-- - Write _multiline_ prompts, flush with \<ctrl-d> (optional), bracketed paste in bash -->
<!-- - Insert mode of text completions -->
<!--
- [Command line completion](#shell-completion) and [file picker](#file-picker-and-shell-dump) dialogs for a smoother experience 💻
- Colour scheme personalisation 🎨 and user configuration file
-->

<!--
### More Features

- [_Generate images_](#%EF%B8%8F-image-generations)
   from text input (`option -i`)
- [_Generate variations_](#image-variations) of images
- [_Edit images_](#image-edits),
   optionally edit with `ImageMagick` (generate alpha mask)
- [_Transcribe audio_](#-audio-transcriptions-translations)
   from various languages (`option -w`)
- _Translate audio_ into English text (`option -W`)
- _Text-to-speeech_ functionality (`option -z`)

-->


## ✨ Getting Started


### ✔️ Required Packages

- `Bash` and `readline`
- `cURL` and `JQ`


### Optional Packages 

Packages required for specific features.

<details>
  <summary>Click to expand!</summary>

- `Base64` - Image endpoint, multimodal models
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

</details>


### 💾 Installation

**A.** Download the stand-alone
[`chatgpt.sh` script](https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/chatgpt.sh)
and make it executable:

    wget https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/chatgpt.sh

    chmod +x ./chatgpt.sh


**B.** Or clone this repo:

    git clone https://gitlab.com/fenixdragao/shellchatgpt.git


**C.** Optionally, download and set the configuration file
[`~/.chatgpt.conf`](https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/.chatgpt.conf):

    #save configuration template:
    chatgpt.sh -FF  >> ~/.chatgpt.conf
    
    #edit:
    chatgpt.sh -F

    # Or
    nano ~/.chatgpt.conf


<!--
### 🔥 Usage

- Set your [OpenAI GPTChat key](https://platform.openai.com/account/api-keys)
   with the environment variable `$OPENAI_API_KEY`, or set `option --api-key [KEY]`, or set the configuration file.
- Just write your prompt as positional arguments after setting options!
- Chat mode may be configured with Instruction or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0).
- To set your model, set `option -m [MODEL_NAME]` or `option -mm` for a model picker dialogue.
- Run `chatgpt.sh -l` to list API provider models.
- Some models require a single `prompt` while others `instruction` and `input` prompts.
- To generate images, set `option -i` and write your prompt.
- Make a variation of an image, set -i and an image path for upload.
-->

### 🔥 Usage Examples 🔥

![Chat cmpls with prompt confirmation](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_verb.gif)


## Script Operating Modes

The `chatgpt.sh` script can be run in various modes by setting
**command-line options** at invocation. These are summarised bellow.
<!-- Table Overview -->


| Option | Description                                                                          |
|--------|--------------------------------------------------------------------------------------|
| `-b`   | [Responses API](#responses-api) / single-turn                                        |
| `-bb`  | [Responses API](#responses-api) / multi-turn                                         |
| `-c`   | [Text Chat Completions](#chat-mode-of-text-completions) / multi-turn                 |
| `-cc`  | [Chat Completions (Native)](#--native-chat-completions) / multi-turn                 |
| `-d`   | Text Completions / single-turn                                                       |
| `-dd`  | Text Completions / multi-turn                                                        |
| `-q`   | [Text Completions Insert Mode](#insert-mode-of-text-completions) (FIM) / single-turn |
| `-qq`  | Text Completions Insert Mode (FIM) / multi-turn                                      |


| Option  | Description  (all multi-turn)                                                   |
|---------|---------------------------------------------------------------------------------|
| `-cw`   | Text Chat Completions + voice-in                                                |
| `-cwz`  | Text Chat Completions + voice-in + voice-out                                    |
| `-ccw`  | Chat Completions + voice-in                                                     |
| `-ccwz` | [Chat Completions + voice-in + voice-out](#voice-in-and-out--chat-completions)  |

<!--
| `-bbw`  | Responses API + voice-in                                                        |
| `-bbwz` | Responses API + voice-in + voice-out                                            |
-->


| Option | Description   (independent modes)                                   |
|--------|---------------------------------------------------------------------|
| `-i`   | [Image generation and editing](#%EF%B8%8F-image-generations)        |
| `-w`   | [Speech-To-Text](#-speech-transcriptions--translations) (Whisper)   |
| `-W`   | Speech-To-Text (Whisper), translation to English                    |
| `-z`   | [Text-To-Speech](man/README.md#text-to-voice-tts) (TTS), text input |


## 💬  Native Chat Completions

With command line `options -cc`, some properties are set automatically to create a chat bot.
Start a new session in chat mode, and set a different temperature:

    chatgpt.sh -cc -t0.7


Change the **maximum response length** to 4k tokens:

    chatgpt.sh -cc -4000
    
    chatgpt.sh -cc -M 4000


And change **model token capacity** to 200k tokens:

    chatgpt.sh -cc -N 200000


Create **Marv, the sarcastic bot**:

    chatgpt.sh -512 -cc --frequency-penalty=0.7 --temp=0.8 --top_p=0.4 --restart-seq='\nYou: ' --start-seq='\nMarv:' --stop='You:' --stop='Marv:' -S'Marv is a factual chatbot that reluctantly answers questions with sarcastic responses.'

<!--
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "What's the capital of France?"}, {"role": "assistant", "content": "Paris, as if everyone doesn't know that already."}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "Who wrote 'Romeo and Juliet'?"}, {"role": "assistant", "content": "Oh, just some guy named William Shakespeare. Ever heard of him?"}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "How far is the Moon from Earth?"}, {"role": "assistant", "content": "Around 384,400 kilometers. Give or take a few, like that really matters."}]}
-->
<!-- https://platform.openai.com/docs/guides/fine-tuning/preparing-your-dataset -->

**Tip:** Easily set runtime options with chat command `!conf`!


Load the *custom-made unix* **instruction file** ("unix.pr") for a new session.
The command line syntaxes below are all aliases:


    chatgpt.sh -cc .unix
    
    chatgpt.sh -cc.unix
    
    chatgpt.sh -cc -.unix
    
    chatgpt.sh -cc -S .unix

**NOTE:**  In this case, the custom prompt will be loaded, and the history will be recorded in the corresponding "_unix.tsv_" file at the cache directory.

To **change the history file** in which the session will be recorded,
set the first positional argument in the command line with the operator forward slash "`/`"
and the name of the history file (this executes the `/session` command).

    
    chatgpt.sh -cc /test

    chatgpt.sh -cc /stest

    chatgpt.sh -cc "/session test"


<!--
The command below starts a chat session, loads the "unix" instruction, and changes to the defaults "chatgpt.tsv" history.


    chatgpt.sh -cc.unix /current

    chatgpt.sh -cc -S ".unix" /session current
-->


There is a **shortcut to load an older session** from the default (or current)
history file. This opens a basic interactive interface.

    chatgpt.sh -cc .

<!--
    chatgpt.sh -cc /sub

    chatgpt.sh -cc /.

    chatgpt.sh -cc /fork.

    chatgpt.sh -cc "/fork current"
-->

Technically, this copies an old session from the target history file to the tail of it, so we can resume the session.

<!--
In chat mode, simple run `!sub` or the equivalent command `!fork current`.
-->

<!--
To load an old session from a specific history,
there are some options. -->

In order to grep for sessions with a regex, it is easier to enter chat mode
and then type in the chat command `/grep [regex]`.

<!--
To only change to a specific history file, run command `!session [name]`. -->

<!--
To copy a previous session to the tail of the current history file, run `/sub` or `/grep [regex]` to load that session and resume from it.
-->

<!--
Optionally `!fork` the older session to the active session.

Or, `!copy [orign] [dest]` the session from a history file to the current one
or any other history file.

In these cases, a pickup interface should open to let the user choose
the correct session from the history file.
-->


Print out last session, optionally set the history name:

    chatgpt.sh -P

    chatgpt.sh -P /test


<!-- Mind that `option -P` heads `-ccdrR`! -->

<!-- The same as `chatgpt.sh -HH` -->


### Reasoning and Thinking Models

Some of our server integrations will not make a distinct separation
between reasoning and actual answers, which is unfortunate because it
becomes hard to know what is thinking and what is the actual answer as
they will be printed out without any visible separation!

This is mostly due to a limitation in how we use JQ to process the JSON
response from the APIs in the fastest way possible.

For Anthropic's `claude-3-7-sonnet` hybrid model thinking activation,
the user must specify either `--think [NUM]` (or `--effort [NUM]`)
command line option. To activate thinking during chat, use either
`!think`, `/think`, or `/effort` commands.


### Vision and Multimodal Models

To send an `image` / `url` to vision models, start the script interactively
and then either set the image with the `!img`.

Alternatively, set the image paths / URLs at the end of the prompt:


<!--
    chatgpt.sh -cc -m gpt-4-vision-preview '!img path/to/image.jpg'
    -->

    chatgpt.sh -cc -m gpt-4-vision-preview

    [...]
    Q: !img  https://i.imgur.com/wpXKyRo.jpeg
    
    Q: What can you see?  https://i.imgur.com/wpXKyRo.jpeg


**TIP:** Run command `!info` to check configuration!

**DEBUG:** Set `option -V` to see the raw JSON request body.


### Text, PDF, Doc, and URL Dumps

To make an easy workflow, the user may add a filepath or text URL at the end
of the prompt. The file is then read and the text content appended
to the user prompt.
This is a basic text feature that works with any model.

    chatgpt.sh -cc

    [...]
    Q: What is this page: https://example.com

    Q: Help me study this paper. ~/Downloads/Prigogine\ Perspective\ on\ Nature.pdf


In the **second example** above, the _PDF_ will be dumped as text.

For PDF text dump support, `poppler/abiword` is required.
For _doc_ and _odt_ files, `LibreOffice` is required.
See the [Optional Packages](#optional-packages) section.

Also note that file paths containing white spaces must be
**blackslash-escaped**, or the filepath must be preceded by a pipe `|` character.

    My text prompt. | path/to the file.jpg


Multiple images and audio files may be appended the prompt in this way!


### File Picker and Shell Dump

The `/pick` command opens a file picker (command-line or GUI
file manager). The selected file's path is then appended to the
current prompt.

The `/pick` and `/sh` commands may be run when typed at the end of
the current prompt, such as ---`[PROMPT] /pick`,

When the `/sh` command is run at the end of the prompt, a new
shell instance to execute commands interactively is opened.
The command dumps are appended to the current prompt.

_File paths_ that contain white spaces need backslash-escaping
in some functions.


### Voice In and Out + Chat Completions

🗣️ Chat completion with speech in and out (STT plus TTS):

    chatgpt.sh -ccwz

Chat in Portuguese with voice-in and set _onyx_ as the TTS voice-out:

    chatgpt.sh -ccwz -- pt -- onyx


**Chat mode** provides a conversational experience,
prompting the user to confirm each step.

For a more automated execution, set `option -v`,
or `-vv` for hands-free experience (_live chat_ with silence detection),
such as:

    chatgpt.sh -cc -w -z -v

    chatgpt.sh -cc -w -z -vv


### Audio Models

Audio models, such as `gpt-4o-audio`, deal with audio input and output directly, thus reducing latency in a conversation turn.

To activate the microphone recording function of the script, set command line `option -w`.

Otherwise, the audio model accepts any compatible audio file (such as **mp3**, **wav**, and **opus**).
These files can be added to be loaded at the very end of the user prompt
or added with chat command `/audio  path/to/file.mp3`.

To activate the audio output mode of an audio model, do set command line `option -z` to make sure the speech synthesis function is enabled!

    chatgpt.sh -cc -w -z -vv -m "gpt-4o-audio-preview"


Mind that this _does not_ implement the _realtime models_.


## Chat Mode of Text Completions

When text completions is set for chatting with `option -c`,
some properties are configured automatically to instruct the bot.


    chatgpt.sh -c "Hello there! What is your name?"


<!-- **TIP**: Set _-vv_ to have auto sleep for reading time of last response,
and less verbose in voice input chat! *Only without option -z!* -->


## 📜 Text Completions

This is the pure text completions endpoint. It is typically used to
complete input text, such as for completing part of an essay.

To complete text from the command line input prompt, either
set `option -d` or set a text completion model name.

    chatgpt.sh -128 -m gpt-3.5-turbo-instruct "Hello there! Your name is"
    
    chatgpt.sh -128 -d "The journalist loo"
 
The above examples also set maximum response value to 128 tokens.

Enter single-turn interactive mode:

    chatgpt.sh -d


**NOTE:** For multi-turn mode with history support, set `option -dd`.


A strong Instruction prompt may be needed for the language model to do what is required.

Set an instruction prompt for better results:
    
    chatgpt.sh -d -S 'The following is a newspaper article.' "It all starts when FBI agents arrived at the governor house and"

    chatgpt.sh -d -S'You are an AI assistant.'  "The list below contain the 10 biggest cities in the w"


### Insert Mode of Text Completions

Set `option -q` (or `-qq` for multiturn) to enable insert mode and add the
string `[insert]` where the model should insert text:

    chatgpt.sh -q 'It was raining when [insert] tomorrow.'


**NOTE:** This example works with _no instruction_ prompt!
An instruction prompt in this mode may interfere with insert completions.

**NOTE:** [Insert mode](https://openai.com/blog/gpt-3-edit-insert)
works with model `instruct models`.
<!-- `davinci`, `text-davinci-002`, `text-davinci-003`, and the newer -->

Mistral AI has a nice FIM (fill-in-the-middle) endpoint that works
with `code` models and is really good!


## Responses API

Responses API is a superset of Chat Completions API. Set command
line `option -b` (with `-cc`), or set `options -bb` for multiturn.

To activate it during multiturn chat, set `/responses [model]`,
where _model_ is the name of a model which works with the Responses API.
Aliased to `/resp [model]` and `-b [model]`. This can be toggled.

Limited support.


<!--
## Text Edits  _(discontinued)_

Choose an `edit` model or set `option -e` to use this endpoint.
Two prompts are accepted, an instruction prompt and
an input prompt (optional):

    chatgpt.sh -e "Fix spelling mistakes" "This promptr has spilling mistakes."

    chatgpt.sh -e "Shell code to move files to trash bin." ""

Edits works great with INSTRUCTION and an empty prompt (e.g. to create
some code based on instruction only).


Use _gpt-4+ models_ and the right instructions.

The last working shell script version that works with this endpoint
is [chatgpt.sh v23.16](https://gitlab.com/fenixdragao/shellchatgpt/-/tree/f82978e6f7630a3a6ebffc1efbe5a49b60bead4c).
-->


## Markdown

To enable markdown rendering of responses, set command line `option --markdown`,
or run `/md` in chat mode. To render last response in markdown once,
run `//md`.

The markdown option uses `bat` as it has line buffering on by default,
however other software is supported.
Set the software of choice such as `--markdown=glow` or `/md mdless`.

Type in any of the following markdown software as argument to the option:
`bat`, `pygmentize`, `glow`, `mdcat`, or `mdless`.


## ⚙️ Prompts

Unless the chat `option -c` or `-cc` are set, _no instruction_ is
given to the language model. On chat mode, if no instruction is set,
minimal instruction is given, and some options set, such as increasing
temperature and presence penalty, in order to un-lobotomise the bot.

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat completions models.

The model steering and capabilities require prompt engineering
to even know that it should answer the questions.

<!--
**NOTE:** Heed your own instruction (or system prompt), as it
may refer to both *user* and *assistant* roles.
-->


### Instruction Prompt

When the script is run in **chat mode**, the instruction is set
automatically if none explicitly set by the user on invocation.

The chat instruction will be updated according to the user locale
after reading envar `$LANG`. <!-- and `$LC_ALL`. -->

Translations are available for the languages: `en`, `pt`, `es`, `it`,
`fr`, `de`, `ru`, `ja`, `zh`, `zh_TW`, and `hi`.


To run the script with the Hindi prompt, for example, the user may execute:

    chatgpt.sh -cc .hi
    
    LANG=hi_IN.UTF-8 chatgpt.sh -cc


Note: custom prompts with colliding names such as "hi"
have precedence over this feature.


### ⌨️  Custom Prompts

Set a one-shot instruction prompt with `option -S`:

    chatgpt.sh -cc -S 'You are a PhD psycologist student.' 

    chatgpt.sh -ccS'You are a professional software programmer.'


To create or load a prompt template file, set the first positional argument
as `.prompt_name` or `,prompt_name`.
In the second case, load the prompt and single-shot edit it.

    chatgpt.sh -cc .psycologist 

    chatgpt.sh -cc ,software_programmer


Alternatively, set `option -S` with the operator and the name of
the prompt as an argument:

    chatgpt.sh -cc -S .psycologist 

    chatgpt.sh -cc -S,software_programmer


This will load the custom prompt or create it if it does not yet exist.
In the second example, single-shot editing will be available after
loading prompt _software_programmer_.

Please note and make sure to backup your important custom prompts!
They are located at "`~/.cache/chatgptsh/`" with the extension "_.pr_".


### 🔌 Awesome Prompts

Set a prompt from [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
or [awesome-chatgpt-prompts-zh](https://github.com/PlexPt/awesome-chatgpt-prompts-zh),
(use with davinci and gpt-3.5+ models):

    chatgpt.sh -cc -S /linux_terminal
    
    chatgpt.sh -cc -S /Relationship_Coach 

    chatgpt.sh -cc -S '%担任雅思写作考官'


<!--
_TIP:_ When using Ksh, press the up arrow key once to edit the _full prompt_
(see note on [shell interpreters](#shell-interpreters)).
-->


## Shell Completion

This project includes shell completions to enhance the user command-line experience.

### Bash

**Install** following one of the methods below.

**System-wide**

```
sudo cp comp/bash/chatgpt.sh /usr/share/bash-completion/completions/
```

**User-specific**

```
mkdir -p ~/.local/share/bash-completion/completions/
cp comp/bash/chatgpt.sh ~/.local/share/bash-completion/completions/
```

Visit the [bash-completion repository](https://github.com/scop/bash-completion).


### Zsh

**Install** at the **system location**

```
sudo cp comp/zsh/_chatgpt.sh /usr/share/zsh/site-functions/
```


**User-specific** location

To set **user-specific** completion, make sure to place the completion
script under a directory in the `$fpath` array.

The user may create the `~/.zfunc/` directory, for example, and
add the following lines to her `~/.zshrc`:


```
[[ -d ~/.zfunc ]] && fpath=(~/.zfunc $fpath)

autoload -Uz compinit
compinit
```

Make sure `compinit` is run **after setting `$fpath`**!

Visit the [zsh-completion repository](https://github.com/zsh-users/zsh-completions).


### Troubleshoot Shell

Bash and Zsh completions should be active in new terminal sessions.
If not, ensure your `~/.bashrc` and `~/.zshrc` source
the completion files correctly.


## 💡  Notes and Tips

- The YouTube feature will get YouTube video heading title and its transcripts information only (when available).

- The PDF support feature extracts PDF text ([_no images_](https://docs.anthropic.com/en/docs/build-with-claude/pdf-support#how-pdf-support-works)) and appends it to the user request.

- Run chat commands with either _operator_ `!` or `/`.

- Edit live history entries with command `!hist` (comment out entries or context injection).

<!-- (_discontinued_)
- Add operator forward slash `/` to the end of prompt to trigger **preview mode**. -->

- One can **regenerate a response** by typing in a new prompt a single slash `/`,
or `//` to have last prompt edited before the new request.

<!--
- There is a [Zsh point release branch](https://gitlab.com/fenixdragao/shellchatgpt/-/tree/zsh),
  but it will not be updated.
-->
<!--
- Generally, my evaluation on models prefers using `davinci` or
`text-davinci-003` for less instruction intensive tasks, such as
brainstorming. The newer models, `gpt-3.5-turbo-instruct`, may be
better at following instructions, is cheap and much faster, but seems
more censored.

- On chat completions, the _launch version_ of the models seem to
be more creative and better at tasks at general, than
newer iterations of the same models. So, that is why we default to
`gpt-3.5-turbo-0301`, and, reccomend the model `gpt-4-0314`.


https://www.refuel.ai/blog-posts/gpt-3-5-turbo-model-comparison
https://www.reddit.com/r/ChatGPT/comments/14u51ug/difference_between_gpt432k_and_gpt432k0314/
https://www.reddit.com/r/ChatGPT/comments/14km5xy/anybody_else_notice_that_gpt40314_was_replaced_by/
https://www.reddit.com/r/ChatGPT/comments/156drme/gpt40314_is_better_than_gpt40613_at_generating/
https://stackoverflow.com/questions/75810740/openai-gpt-4-api-what-is-the-difference-between-gpt-4-and-gpt-4-0314-or-gpt-4-0


- The original base models `davinci` and `curie`,
and to some extent, their forks `text-davinci-003` and `text-curie-001`,
generate very interesting responses (good for
[brainstorming](https://github.com/mountaineerbr/shellChatGPT/discussions/16#discussioncomment-5811670]))!

- Write your customised instruction as plain text file and set that file
name as the instruction prompt.
-->


## 🖼️ Image Generations

Currently, the scripts defaults to the **gpt-image** model. The user must
[verify his OpenAI organisation](https://platform.openai.com/settings/organization/general)
before before granted access to this model! Otherwise, please
specify positional arguments `-i -m dall-e-3` or `-i -m dall-e-2`
to select other models for image endpoints.

Generate image according to prompt:

    chatgpt.sh -i "Dark tower in the middle of a field of red roses."

    chatgpt.sh -i "512x512" "A tower."


This script also supports xAI `grok-2-image-1212` image model:

    chatgpt.sh --xai -i -m grok-2-image-1212 "A black tower surrounded by red roses."


## Image Variations

Generate image variation:

    chatgpt.sh -i path/to/image.png


## Image Edits

    chatgpt.sh -i path/to/image.png path/to/mask.png "A pink flamingo."


### Outpaint - Canvas Extension

![Displaying Image Edits - Extending the Canvas](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits.gif)

In this example, a mask is made from the white colour.


### Inpaint - Fill in the Gaps

![Showing off Image Edits - Inpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits2.gif)
<!-- ![Inpaint, steps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits_steps.png) -->

Adding a bat in the night sky.


## 🔊 Speech Transcriptions / Translations

Generate transcription from audio file speech. A prompt to guide the model's style is optional.
The prompt should match the speech language:

    chatgpt.sh -w path/to/audio.mp3

    chatgpt.sh -w path/to/audio.mp3 "en" "This is a poem about X."


**1.** Generate transcription from voice recording, set Portuguese as the language to transcribe to:

    chatgpt.sh -w pt


This also works to transcribe from one language to another.


**2.** Transcribe any language speech input **to Japanese** (_prompt_ should be in
the same language as the input audio language, preferably):

    chatgpt.sh -w ja "A job interview is currently being done."


**3.1** Translate English speech input to Japanese, and generate speech output from the text response.

    chatgpt.sh -wz ja "Getting directions to famous places in the city."


**3.2** Also doing it conversely, this gives an opportunity to (manual)
conversation turns of two speakers of different languages. Below,
a Japanese speaker can translate its voice and generate audio in the target language.

    chatgpt.sh -wz en "Providing directions to famous places in the city."


**4.** Translate speech from any language to English:

    chatgpt.sh -W [speech_file]

    chatgpt.sh -W


To retry with the last microphone recording saved in the cache, set
_speech_file_ as `last` or `retry`.

**NOTE:** Generate **phrasal-level timestamps** double setting `option -ww` or `option -WW`.
For **word-level timestamps**, set option `-www` or `-WWW`.


![Transcribe speech with timestamps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_trans.png)


<!-- 
### Code Completions (Codex, _discontinued_)

Codex models are discontinued. Use models davinci or gpt-3.5+.

Start with a commented out code or instruction for the model,
or ask it in comments to optimise the following code, for example.
-->


## Service Providers

Other than [Ollama](#ollama) and [LocalAI](#localai) local servers,
the free service providers are
[GitHub Models](#github-models),
[Google Vertex](#google-ai), and 
[Groq](#groq).


### LocalAI

#### LocalAI Server

Make sure you have got [mudler's LocalAI](https://github.com/mudler/LocalAI),
server set up and running.

The server can be run as a docker container or a
[binary can be downloaded](https://github.com/mudler/LocalAI/releases).

Check LocalAI tutorials
[Container Images](https://localai.io/basics/getting_started/#container-images),
and [Run Models Manually](https://localai.io/docs/getting-started/manual)
for an idea on how to [download and install](https://localai.io/models/#how-to-install-a-model-from-the-repositories)
a model and set it up.

<!--
     ┌───────────────────────────────────────────────────┐
     │                   Fiber v2.50.0                   │
     │               http://127.0.0.1:8080               │
     │       (bound on host 0.0.0.0 and port 8080)       │
     │                                                   │
     │ Handlers ............. 1  Processes ........... 1 │
     │ Prefork ....... Disabled  PID ..................1 │
     └───────────────────────────────────────────────────┘
-->


#### Tips

*1.* Download a binary of `localai` for your system from [Mudler's release GitHub repo](https://github.com/mudler/LocalAI/releases).

*2.* Run `localai run --help` to check comamnd line options and environment variables.

*3.* Set up `$GALLERIES` before starting up the server:

    export GALLERIES='[{"name":"localai", "url":"github:mudler/localai/gallery/index.yaml"}]'  #default

    export GALLERIES='[{"name":"model-gallery", "url":"github:go-skynet/model-gallery/index.yaml"}]'

    export GALLERIES='[{"name":"huggingface", "url": "github:go-skynet/model-gallery/huggingface.yaml"}]'


<!-- broken huggingface gallery: https://github.com/mudler/LocalAI/issues/2045 -->


*4.* Install the model named `phi-2-chat` from a `yaml` file manually, while the server is running:

    curl -L http://localhost:8080/models/apply -H "Content-Type: application/json" -d '{ "config_url": "https://raw.githubusercontent.com/mudler/LocalAI/master/embedded/models/phi-2-chat.yaml" }'


#### Running the shell wrapper

Finally, when running `chatgpt.sh`, set the model name:

    chatgpt.sh --localai -cc -m luna-ai-llama2


Setting some stop sequences may be needed to prevent the
model from generating text past context:

    chatgpt.sh --localai -cc -m luna-ai-llama2  -s'### User:'  -s'### Response:'


Optionally set restart and start sequences for text completions
endpoint (`option -c`), such as `-s'\n### User: '  -s'\n### Response:'`
(do mind setting newlines *\n and whitespaces* correctly).

And that's it!


#### Installing Models

Model names may be printed with `chatgpt.sh -l`. A model may be
supplied as argument, so that only that model details are shown.


**NOTE:** Model management (downloading and setting up) must follow
the LocalAI and Ollama projects guidelines and methods.

<!--
For image generation, install Stable Diffusion from the URL
`github:go-skynet/model-gallery/stablediffusion.yaml`,
and for speech transcription, download Whisper from the URL
`github:go-skynet/model-gallery/whisper-base.yaml`. -->
<!-- LocalAI was only tested with text and chat completion models (vision) -->

<!--
Install models with `option -l` or chat command `/models`
and the `install` keyword.

Also supply a [model configuration file URL](https://localai.io/models/#how-to-install-a-model-without-a-gallery),
or if LocalAI server is configured with Galleries,
set "_\<GALLERY>_@_\<MODEL_NAME>_".
Gallery defaults to [HuggingFace](https://huggingface.co/).

    # List models
    chatgpt.sh -l

    # Install
    chatgpt.sh -l install huggingface@TheBloke/WizardLM-13B-V1-0-Uncensored-SuperHOT-8K-GGML/wizardlm-13b-v1.0-superhot-8k.ggmlv3.q4_K_M.bin

* NOTE: *  I reccomend using LocalAI own binary to install the models!
-->


#### BASE URL Configuration

If the service provider Base URL is different from defaults,
these tips may help make the script work with your API.

The environment variable `$OPENAI_BASE_URL` is read at invocation.

    export OPENAI_BASE_URL="http://127.0.0.1:8080/v1"

    chatgpt.sh -c -m luna-ai-llama2


To set it a in a more permanent fashion, edit the script
configuration file `.chatgpt.conf`.

Use vim:

    vim ~/.chatgpt.conf


Or edit the configuration with a command line option.

    chatgpt.sh -F


And set the following variable:

    # ~/.chatgpt.conf
    
    OPENAI_BASE_URL="http://127.0.0.1:8080/v1"


#### OpenAI Web Search

Use the in-house solution with chat command "`/g [prompt]`" or "`//g [prompt]`"
to ground the prompt, or select models with **search** in the name,
such as "gpt-4o-search-preview".

Running "`//g [prompt]`" will always use the in-house solution instead of
any service provider specific web search tool.

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

Check more search parameters at the [OpenAI API documentation](https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses).
<https://platform.openai.com/docs/guides/tools-web-search?api-mode=chat>.
-->


### Ollama

Visit [Ollama repository](https://github.com/ollama/ollama/),
and follow the instructions to install, download models, and set up
the server.

After having Ollama server running, set `option -O` (`--ollama`),
and the name of the model in `chatgpt.sh`:

    chatgpt.sh -cc -O -m llama2


If Ollama server URL is not the default `http://localhost:11434`,
edit `chatgpt.sh` configuration file, and set the following variable:

    # ~/.chatgpt.conf
    
    OLLAMA_BASE_URL="http://192.168.0.3:11434"


### Google AI

Get a free [API key for Google](https://gemini.google.com/) to be able to
use Gemini and vision models. Users have a free bandwidth of 60 requests per minute, and the script offers a basic implementation of the API.

Set the environment variable `$GOOGLE_API_KEY` and run the script
with `option --google`, such as:

    chatgpt.sh --google -cc -m gemini-pro-vision


*OBS*: Google Gemini vision models _are not_ enabled for multiturn at the API side, so we hack it.

To list all available models, run `chatgpt.sh --google -l`.


#### Google Search

To enable live search in the API, use chat command `/g [prompt]` or `//g [prompt]`,
or set `$BLOCK_CMD` envar.

```
export BLOCK_CMD='"tools": [ { "google_search": {} } ]'

chatgpt.sh --goo -cc -m gemini-2.5-flash-preview-05-20
```

Check more web search parameters at [Google AI API docs](https://ai.google.dev/gemini-api/docs/grounding?lang=rest).


### Mistral AI

Set up a [Mistral AI account](https://mistral.ai/),
declare the environment variable `$MISTRAL_API_KEY`,
and run the script with `option --mistral` for complete integration.
<!-- $MISTRAL_BASE_URL -->


### Groq

Sign in to [Groq](https://console.groq.com/playground).
Create a new API key or use an existing one to set
the environmental variable `$GROQ_API_KEY`.
Run the script with `option --groq`.


#### Groq Whisper STT

Groq API has got the speech-to-text model "whisper-large-v3",
which can be used in the stand-alone STT mode  with command line option -w,
or as the default STT engine in chat mode.

Check the [configuration file](.chatgpt.conf) to set Groq Whisper STT.


#### Groq TTS

Groq also offers the text-to-speech model "playai-tts". This model
can be used in the stand-alone TTS mode of command line option -z,
or set up as the preferred chat TTS engine.

Check the [configuration file](.chatgpt.conf) to set Groq TTS.


### Anthropic

Sign in to [Antropic AI](https://docs.anthropic.com/).
Create a new API key or use an existing one to set
the environmental variable `$ANTHROPIC_API_KEY`.
Run the script with `option --anthropic` or `--ant`.

Check the **Claude-3** models! Run the script as:

```
chatgpt.sh --anthropic -cc -m claude-3-5-sonnet-20240620
```


The script also works on **text completions** with models such as
`claude-2.1`, although the API documentation flags it as deprecated.

Try:

```
chatgpt.sh --ant -c -m claude-2.1
```


#### Anthropic Web Search

To enable live search in the API, use chat command `/g [prompt]` or `//g [prompt]`,
or set `$BLOCK_USR` envar.

```
export BLOCK_USR='"tools": [{
  "type": "web_search_20250305",
  "name": "web_search",
  "max_uses": 5
}]'

chatgpt.sh --ant -cc -m claude-opus-4-0
```

Check more web search parameters at [Anthropic API docs](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking).


### GitHub Models

GitHub has partnered with Azure to use its infrastructure.

As a GitHub user, join the [wait list](https://github.com/marketplace/models/waitlist/join)
and then generate a [personal token](https://github.com/settings/tokens).
Set the environmental variable `$GITHUB_TOKEN` and run the
script with `option --github` or `--git`.

Check the [on-line model list](https://github.com/marketplace/models)
or list the available models and their original names with `chatgpt.sh --github -l`.


```
chatgpt.sh --github -cc -m Phi-3-small-8k-instruct
```

<!--
See also the [GitHub Model Catalog - Getting Started](https://techcommunity.microsoft.com/t5/educator-developer-blog/github-model-catalog-getting-started/ba-p/4212711) page.
-->


### Novita AI

Novita AI offers a range of LLM models at exceptional value.

Create an API key as per the
[Quick Start Guide](https://novita.ai/docs/get-started/quickstart.html)
and export your key as `$NOVITA_API_KEY` to your environment.

Next, run the script such as `chatgpt.sh --novita -cc`.

Check the [model list web page](https://novita.ai/model-api/product/llm-api)
and the [price of each model](https://novita.ai/model-api/pricing).

To list all available models, run `chatgpt.sh --novita -l`. Optionally set a model name with `option -l` to dump model details.

Some models work with the `/completions` endpoint, while others
work with the `/chat/completions` endpoint, so the script _does not set the endpoint automatically_! Check model details and web pages to understand their capabilities, and then either run the script with `option -c` (**text completions**) or `options -cc` (**chat completions**).

This service provider _feature is curently_ **legacy**.

---

As an exercise,
set Novita AI integration manually instead:


```
export OPENAI_API_KEY=novita-api-key
export OPENAI_BASE_URL="https://api.novita.ai/v3/openai"

chatgpt.sh -cc -m meta-llama/llama-3.3-70b-instruct
```

We are grateful to Novita AI for their support and collaboration. For more
information, visit [Novita AI](https://novita.ai/).


### xAI

Visit [xAI Grok](https://docs.x.ai/docs/quickstart#creating-api-key)
to generate an API key (environment `$XAI_API_KEY`).

Run the script with `option --xai` and also with `option -cc` (chat completions.).

Some models also work with native text completions. For that,
set command-line `option -c` instead.


#### xAI Live Search

To enable live search in the API, use chat command `/g [prompt]`
or `//g [prompt]`,
or to keep live search enabled for all prompts, set `$BLOCK_USR`
environment variable before running the script such as:

```
export BLOCK_USR='"search_parameters": {
  "mode": "auto",
  "max_search_results": 10
}'

chatgpt.sh --xai -cc -m grok-3-latest 
```

Check more live search parameters at [xAI API docs](https://docs.x.ai/docs/guides/live-search).


#### xAI Image Generation

The model `grok-2-image-1212` is supported for image generation with
invocation `chatgpt.sh --xai -i -m grok-2-image-1212 "[prompt]"`.


### DeepSeek

Visit [DeepSeek Webpage](https://platform.deepseek.com/api_keys) to get
an API key and set envar `$DEEPSEEK_API_KEY`.

Run the script with `option --deepseek`.
It works with chat completions  (`option -cc`) and text completions (`option -c`) modes.


<!--
## 🌎 Environment

- Set `$OPENAI_API_KEY` with your OpenAI API key.

- Optionally, set `$CHATGPTRC` with path to the configuration file (run
`chatgpt.sh -FF` to download a template configuration file.
Default location = `~/.chatgpt.conf`.
-->

<!--
## 🐚 Shell Interpreters

The script can be run with either Bash or Zsh.

There should be equivalency of features under Bash, and Zsh.

Zsh is faster than Bash in respect to some features.

Although it should be noted that I test the script under Ksh and Zsh,
and it is almost never tested under Bash, but so far, Bash seems to be
a little more polished than the other shells [AFAIK](https://github.com/mountaineerbr/shellChatGPT/discussions/13),
specially with interactive features.

Ksh truncates input at 80 chars when re-editing a prompt. A workaround
with this script is to press the up-arrow key once to edit the full prompt.

Ksh will mangle multibyte characters when re-editing input. A workaround
is to move the cursor and press the up-arrow key once to unmangle the input text.

Zsh cannot read/load a history file in non-interactive mode,
so only commands of the running session are available for retrieval in
new prompts (with the up-arrow key).

See [BUGS](https://github.com/mountaineerbr/shellChatGPT/tree/main/man#bugs)
in the man page.
-->
<!-- [Ksh93u+](https://github.com/ksh93/ksh) (~~_avoid_ Ksh2020~~), -->


## Arch Linux Users

This project PKGBUILD is available at the
[Arch Linux User Repository (*AUR*)](https://aur.archlinux.org/packages/chatgpt.sh)
to install the software in Arch Linux and derivative distros.

To install the programme from the AUR, you can use an *AUR helper*
like `yay` or `paru`. For example, with `yay`:

    yay -S chatgpt.sh


<!--
There is a [*PKGBUILD*](pkg/PKGBUILD) file available to install
the script and documentation at the right directories
in Arch Linux and derivative distros.

This PKGBUILD generates the package `chatgpt.sh-git`.
Below is an installation example with just the PKGBUILD.

    cd $(mktemp -d)
    
    wget https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/pkg/PKGBUILD
     
    makepkg
        
    pacman -U chatgpt.sh-git*.pkg.tar.zst

-->


## Termux Users

### Dependencies Termux

Install the `Termux` and `Termux:API` apps from the *F-Droid store*.

Give all permissions to `Termux:API` in your phone app settings.

We reccommend to also install `sox`, `ffmpeg`, `pulseaudio`, `imagemagick`, and `vim` (or `nano`).

Remember to execute `termux-setup-storage` to set up access to the phone storage.

In Termux proper, install the `termux-api` and `termux-tools` packages (`pkg install termux-api termux-tools`).

When recording audio (STT, Whisper, `option -w`),
if `pulseaudio` is configured correctly,
the script uses `sox`, `ffmpeg` or other competent software,
otherwise it defaults to `termux-microphone-record`

Likewise, when playing audio (TTS, `option -z`),
depending on `pulseaudio` configuration use `sox`, `mpv` or
fallback to termux wrapper playback (`play-audio` is optional).

To set the clipboard, it is required `termux-clipboard-set` from the `termux-api` package.

In order to dump YouTube captions, `yt-dlp` is required.


### TTS Chat - Removal of Markdown

*Markdown in TTS input* may stutter the model speech generation a little.
If `python` modules `markdown` and `bs4` are available, TTS input will
be converted to plain text. As fallback, `pandoc` is used if present
(chat mode only).


### Tiktoken

Under Termux, make sure to have your system updated and installed with
`python`, `rust`, and `rustc-dev` packages for building `tiktoken`.

    pkg update
    
    pkg upgrade
    
    pkg install python rust rustc-dev
    
    pip install tiktoken


### Troubleshoot Termux

In order to set Termux access to recording the microphone and playing audio
(with `sox` and `ffmpeg`), follow the instructions below.

**A.** Set `pulseaudio` one time only, execute:

    pulseaudio -k
    pulseaudio -L "module-sles-source" -D


**B.** To set a permanent configuration:

1. Kill the process with `pulseaudio -k`.
2. Add `load-module module-sles-source` to _one of the files_:

```
~/.config/pulse/default.pa
/data/data/com.termux/files/usr/etc/pulse/default.pa
   ```

3. Restart the server with `pulseaudio -D`.


**C.** To create a new user `~/.config/pulse/default.pa`, you may start with the following template:

    #!/usr/bin/pulseaudio -nF
     
    .include /data/data/com.termux/files/usr/etc/pulse/default.pa
    load-module module-sles-source


<!--
#### File Access

To access your Termux files using Android's file manager, install a decent file manager such as `FX File Explorer` from a Play Store and configure it, or run the following command in your Termux terminal:

    am start -a android.intent.action.VIEW -d "content://com.android.externalstorage.documents/root/primary"


Source: <https://www.reddit.com/r/termux/comments/182g7np/where_do_i_find_my_things_that_i_downloaded/> -->


<!--
Users of Termux may have some difficulty compiling the original Ksh93 under Termux.
As a workaround, use Ksh emulation from Zsh. To make Zsh emulate Ksh, simply
add a symlink to `zsh` under your path with the name `ksh`.

After installing Zsh in Termux, create a symlink with:

````
ln -s /data/data/com.termux/files/usr/bin/zsh /data/data/com.termux/files/usr/bin/ksh
````
-->


## 🎯  Project Objectives

- Main focus on **chat models** (multi-turn, text, image, and audio).

- Implementation of selected features from **OpenAI API version 1**.
  As text is the only universal interface, voice and image features
  will only be partially supported.

- Provide the closest API defaults and let the user customise settings.


<!--
- Première of `chatgpt.sh version 1.0` should occur at the time
  when OpenAI launches its next major API version update.
  -->

<!--  I think Ksh developers used to commonly say invalid options were "illegal" because they developed software a little like games, so the user ought to follow the rules right, otherwise he would incur in an illegal input or command. That seems fairly reasonable to me!  -->


## Roadmap

- We shall decrease development frequency in 2025, hopefully. <!-- LLM models
in general are not really worth developer efforts sometimes, it is frustating!
-->

- We plan to gradually wind down development of new features in the near future.
The project will enter a maintenance phase from 2025 onwards, focusing primarily
on bug fixes and stability.

- We may only partially support the _image generation_ and _image editing_
specific OpenAI endpoints.

- Text completions endpoint is planned to be deprecated when there are
no models compatible with this endpoint anymore.

- The warper is deemed finished in the sense any further updates must
not change the user interface significantly.


<!--

    Portability across LLM providers is impractical anyways!
    Even switching models within OpenAI (e.g., gpt-4o to gpt-4.1)
    can alter behavior, and different providers require unique
    optimizations and careful prompt refining.

-->

<!-- in these poor circumstances. The models are not worth the value or expectations. -->
<!--
- We expect to **go apoptosis**.

Every project, much like living organisms, follows a lifecycle.
As this initiative reaches its natural maturity, we are prepared
to fail as gracefully as we can. Major usage breaks should follow
new and backward-incompatible API changes (incompatible models).
-->

<!--
Merry 2024 [Grav Mass!](https://stallman.org/grav-mass.html)


![Newton](https://stallman.org/grav-mass.png)
-->

<!--
## Distinct Features

- **Run as single** or **multi-turn**, response streaming on by default.

- **Text editor interface**, and **multiline prompters**. 

- **Manage sessions** and history files.

- Hopefully, default colours are colour-blind friendly.

- **Colour themes** and customisation.

_For a simple python wrapper for_ **tiktoken**,
_see_ [tkn-cnt.py](https://github.com/mountaineerbr/scripts/blob/main/tkn-cnt.py).
-->


## ⚠️ Limitations

- OpenAI **API version 1** is the focus of the present project implementation.
Only selected features of the API will be covered.

- The script _will not execute commands_ on behalf of users.

- This project _doesn't_ support "Function Calling", "Structured Outputs", "Agents/Operators", nor "MCP Servers".

- We _will not support_ "Real-Time" chatting, or video generation / editing.

- Support for "Responses API" is limited and experimental for now.

- Bash shell truncates input on `\000` (null).

- Bash "read command" may not correctly display input buffers larger than
the TTY screen size during editing. However, input buffers remain
unaffected. Use the text editor interface for big prompt editing.

- Garbage in, garbage out. An idiot savant.

- The script logic resembles a bowl of spaghetti code after a cat fight.

- See _LIMITS AND BUGS_ section in the [man page](man/README.md#bugs).

<!--
- User input must double escape `\n` and `\t` to have them as literal sequences.
  **NO LONGER the case as of v0.18**  -->


## Bug report

Please leave bug reports at the
[GitHub issues page](https://github.com/mountaineerbr/shellChatGPT/issues).


## 📖 Help Pages 

Read the online [**man page here**](man/README.md).

Alternatively, a help page snippet can be printed with `chatgpt.sh -h`.


## 💪 Contributors

***Many Thanks*** to everyone who contributed to this project.


- [edshamis](https://www.github.com/edshamis)
- [johnd0e](https://github.com/johnd0e)
- [Novita AI's GTM Leo](https://novita.ai/model-api/product/llm-api)
  <!-- Growth Tech Market -->


<br />

Everyone is [welcome to submit issues, PRs, and new ideas](https://github.com/mountaineerbr/shellChatGPT/discussions/1)!

## Acknowledgements

The following projects are worth remarking.
They were studied during development of this script and used as referencial code sources.

1. [Claude Code](https://github.com/anthropics/claude-code)
2. [Gemini CLI](https://github.com/google-gemini/gemini-cli)
3. [OpenAI Codex CLI](https://github.com/openai/codex)
4. [sigoden's aichat](https://github.com/sigoden/aichat)
5. [xenodium's chatgpt-shell](https://github.com/xenodium/chatgpt-shell)
6. [andrew's tgpt](https://github.com/aandrew-me/tgpt)
7. [TheR1D's shell_gpt](https://github.com/TheR1D/shell_gpt/)
8. [ErikBjare's gptme](https://github.com/ErikBjare/gptme)
9. [llm-workflow-engine](https://github.com/llm-workflow-engine/llm-workflow-engine)
10. [0xacx's chatGPT-shell-cli](https://github.com/0xacx/chatGPT-shell-cli)
11. [mudler's LocalAI](https://github.com/mudler/LocalAI)
12. [Ollama](https://github.com/ollama/ollama/)
13. [Google Gemini](https://gemini.google.com/)
14. [Groq](https://console.groq.com/docs/api-reference)
15. [Antropic AI](https://docs.anthropic.com/)
16. [Novita AI](https://novita.ai/)
17. [xAI](https://docs.x.ai/docs/quickstart)
18. [f's awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
19. [PlexPt's awesome-chatgpt-prompts-zh](https://github.com/PlexPt/awesome-chatgpt-prompts-zh)
<!-- 17. [Kardolu's chatgpt-cli](https://github.com/kardolus/chatgpt-cli) -->


<!--
NOTES

Issue: provide basic chat interface
https://github.com/mudler/LocalAI/issues/1535


Issue: OpenAI compatibility: Images edits and variants #921
Now that the groundwork for diffusers support has been done, this is a tracker for implementing variations and edits of the OpenAI spec:

    https://platform.openai.com/docs/guides/images/variations
    https://platform.openai.com/docs/guides/images/edits

Variations can be likely guided by prompt with img2img and https://github.com/LambdaLabsML/lambda-diffusers#stable-diffusion-image-variations

Edits can be implemented with huggingface/diffusers#1825
https://github.com/mudler/LocalAI/issues/921


-->


--- 

<br />

**[The project home is at GitLab](https://gitlab.com/fenixdragao/shellchatgpt)**

<https://gitlab.com/fenixdragao/shellchatgpt>

<br />

_Mirror_

<https://github.com/mountaineerbr/shellChatGPT>


<br />
<a href="https://gitlab.com/fenixdragao/shellchatgpt"><p align="center">
  <img width="128" height="128" alt="ChatGPT by DALL-E, link to GitLab Repo"
  src="https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/dalle_out20b.png">
</p></a>

<!--
## Version History

This is the version number history recorded throughout the script evolution over time.

The lowest record is **0.06.04** at _3/Mar/2023_ and the highest is **0.57.01** at _May/2024_.

<br />
<a href="https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chatgpt.sh_version_evol.png"><p align="center">
  <img width="386" height="290" alt="Graph generated by a list of sorted version numbers and through GNUPlot." src="https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chatgpt.sh_version_evol_small.png">
</p></a>
-->
<!--
Graph generated by the following ridiculously convoluted command for some fun!

```
git rev-list --all | xargs git grep -e by\ mountaineerbr | grep chatgpt\.sh: |
while IFS=:$IFS read com var ver; do ver=${ver##\# v}; printf "%s %s\\n" "$(git log -1 --format="%ci" $com)" "${ver%% *}"; done |
uniq | sed 's/ /T/; s/ //' | sed 's/\(.*\.\)\([0-9]\)\(\..*\)/\10\2\3/' | sed 's/\(.*\.\)\([0-9]\)$/\10\2/' |
sed 's/\(.*\..*\)\.\(.*\)/\1\2/' | sort -n | grep -v -e'[+-]$' -e 'beta' |
gnuplot -p -e 'set xdata time' -e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' -e 'plot "-" using 1:2 with lines notitle'
```
-->

<!--
# How many functions are there in the script and their function code line numbers (v0.61.3):

```
% grep -ce\^function bin/chatgpt.sh                                                                                                                  22:03
126

% sed -n '/^function /,/^}/ p ' ~/bin/chatgpt.sh | test.sh | SUM
Sum     : 2477 lines in functions
Min     : 1 line
Max     : 473 lines
Average : 21 lines per func
Median  : 7 lines per func
Values  : 118+8 functions (one-liner functions not computed)
```
-->

<!--
## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=mountaineerbr/shellChatGPT&type=Date)](https://star-history.com/#mountaineerbr/shellChatGPT&Date)
-->

<!-- Estimated value of the project if commissioned: ~$1500 over one year (2023-2024).
-->

