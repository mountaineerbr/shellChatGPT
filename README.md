# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT, DALL-E, and Whisper.


![Showing off Chat Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls.gif)

Chat completions with streaming.


## 🚀 Features

- Text and chat completions
- _Multiline_ prompt, flush input with \<ctrl-d> (optional)
- _Follow up_ conversations, _preview/regenerate_ responses
- Manage _sessions_, _continue_ from last session, _print out_ session
- Custom prompts, easily create prompts and re-use them!
- Integration with [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts) and [awesome-chatgpt-prompts-zh](https://github.com/PlexPt/awesome-chatgpt-prompts-zh)
- Insert mode of text completions <!-- _(deprecated)_ -->
- Fast and accurately count chat tokens with _tiktoken_ (requires python)
- Personalise colour scheme
- _Generate images_ from text input
- _Generate variations_ of images
- _Edit images_, easily generate an alpha mask
- _Transcribe audio_ from various languages
- _Translate audio_ into English text
- Record prompt voice, hear the answer back from the AI (pipe to voice synthesiser)
- Choose amongst all available models
- Lots of command line options
- Converts response base64 JSON data to PNG image locally
- Should™ work on Linux, FreeBSD, MacOS, and [Termux](#termux-users).


## ✨ Getting Started

### 💾 Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.


### ✔️ Required packages

- Free [OpenAI GPTChat key](https://platform.openai.com/account/api-keys)
- Bash <!-- [Ksh93u+](https://github.com/ksh93/ksh), Bash or Zsh -->
- cURL, and JQ
- Imagemagick (optional)
- Base64 (optional)
- Sox/Arecord/FFmpeg (optional)


### 🔥 Usage

- Set your OpenAI API key with the environment variable `$OPENAI_API_KEY`,
  or set `option -K [KEY]`, or set the conf file.
- Just write your prompt as positional arguments after setting options!
- Chat mode may be configured with Instruction or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set `option -m [MODEL_NAME]`.
- Some models require a single `prompt` while others `instruction` and `input` prompts.
- To generate images, set `option -i` and write your prompt.
- Make a variation of an image, set -i and an image path for upload.


## Script Modes and Examples

![Chat cmpls with prompt confirmation](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_verb.gif)


### Chat Mode of Text Completions

With `option -c`, some options are set automatically to create a chat bot with text completions.

    chatgpt.sh -c "Hello there! What is your name?"


Create **Marv, the sarcastic bot** manually:

    chatgpt.sh -60 -c --frequency-penalty=0.5 --temp=0.5 --top_p=0.3 --restart-seq='\nYou: ' --start-seq='\nMarv:' --stop='You:' --stop='Marv:' -S'Marv is a chatbot that reluctantly answers questions with sarcastic responses:'

**TIP:** Set **response streaming** with `option -g`,
or set `$STREAM=1` in the configuration file.

**TIP:** Set `option -VV` to see the raw request body, or run chat command
`!info` to check model configuration!


Complete text in multi-turn:

    chatgpt.sh -d -S'The following is a newspaper article.' "It all starts when FBI agents arrived at the governor house and"


### 💬  Native Chat Completions

Start a new session in chat mode, and set a different temperature (*gpt-3.5 and gpt-4+ models*):

    chatgpt.sh -cc -t0.7

Chat mode in text editor (visual) mode. Edit initial input:

    chatgpt.sh -ccx "Complete the story: Alice visits Bob. John arrives .."


### 🗣️ Voice + Chat Completions

Chat completion with **voice as input**:

    chatgpt.sh -ccw

Chat in Portuguese with voice in and out (pipe output to voice synthesiser):

    chatgpt.sh -ccw pt | espeakng -v pt-br

    chatgpt.sh -ccw pt | termux-tts-speak -l pt -n br


**TIP**: Set _-vv_ to have auto sleep for reading time of last response,
and less verbose in voice input chat!


### 📜 Text Completions

One-shot text completion:

    chatgpt.sh "Hello there! What is your name?"

Multi-turn text completion with Curie model:

    chatgpt.sh -d -m'text-curie-001' "Hello there! What is your name?"

    chatgpt.sh -d -m1 "List biggest cities in the world."

_For better results,_ ***set an instruction/system prompt***:
    
    chatgpt.sh -d -S'You are an AI assistant.'  "List biggest cities in the world."


### Insert Mode of Text Completions  <!-- _(deprecated)_ -->

Set `option -q` to enable insert mode and add the
string `[insert]` where the model should insert text:

    chatgpt.sh -q 'It was raining when [insert] tomorrow.'


**NOTE:** This example works with _no intruction_ prompt set!
An instruction prompt in this mode may interferre with insert completions.

**NOTE:** [Insert mode](https://openai.com/blog/gpt-3-edit-insert)
works with models `davinci`, `text-davinci-002`, `text-davinci-003`,
and the newer `gpt-3.5-turbo-instruct`.


### Text Edits  _(deprecated)_

Choose an `edit` model or set `option -e` to use this endpoint.
Two prompts are accepted, an instruction prompt and
an input prompt (optional):

    chatgpt.sh -e "Fix spelling mistakes" "This promptr has spilling mistakes."

    chatgpt.sh -e "Shell code to move files to trash bin." ""

Edits works great with INSTRUCTION and an empty prompt (e.g. to create
some code based on instruction only).


## ⚙️ Prompts

Unless the chat `option -c` or `-cc` are set, _no_ instruction is
given to the language model. On chat mode, if no instruction is set,
minimal instruction is given, and some options set, such as increasing
temp and presence penalty, in order to un-lobotomise the bot.

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat completions models.

Note that the model's steering and capabilities require prompt engineering
to even know that it should answer the questions.


### ⌨️  Custom Prompts

Set a one-shot instruction prompt with `option -S`:


    chatgpt.sh -cc -S 'You are a PhD psicologist student.' 

    chatgpt.sh -ccS'You are a professional software programmer.'


To create or load a personal prompt template file,
set `option -S` with the operator comma and the name of the prompt
as argument:


    chatgpt.sh -cc -S.psicologist 

    chatgpt.sh -cc -S.software_programmer


This will load the custom prompt, or create it if it does not yet exist.

<!--
**Obs:** heed your own instruction (or system prompt), as it
may refer to both *user* and *assistant* roles.
-->


### 🔌 Awesome Prompts

Set a prompt from [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
or [awesome-chatgpt-prompts-zh](https://github.com/PlexPt/awesome-chatgpt-prompts-zh),
(use with davinci and gpt-3.5+ models):

    chatgpt.sh -cc -S /linux_terminal
    
    chatgpt.sh -cc -S /Relationship_Coach 

    chatgpt.sh -cc -S %担任雅思写作考官


<!--
_TIP:_ When using Ksh, press the up arrow key once to edit the _full prompt_
(see note on [shell interpreters](#shell-interpreters)).
-->


## 💡  Tips

- The original models `davinci` and `curie`, and to some extent,
their forks `text-davinci-003` and `text-curie-001`,
generate very interesting responses (good for
[brainstorming](https://github.com/mountaineerbr/shellChatGPT/discussions/16#discussioncomment-5811670]))!

- Write your customised instruction as plain text file and set that file
name as the instruction prompt.

- When instruction and/or first prompt are the name of file, the file
will be read and its contents set as input, accordingly.

- Run chat commands with either _operator_ `!` or `/`.

- Edit live history entries with command `!hist`, for context injection.

- Add operator forward slash `/` to the end of prompt to trigger **preview mode**.

- One can regenerate a response typing in a new prompt a single slash `/`.

- Set clipboard with the latest response with `option -o`.

- Create a new session (in the history file) named **computing**,
optionally set instruction for the new session:

    ```
    chatgpt.sh -cc  /computing

    chatgpt.sh -cc -S'You are a professional software developer.' /computing
    ```

  This will create a history file named `computing.tsv` in the cache directory.


## More Script Modes and Examples

### 🖼️ Image Generations

Generate image according to prompt:

    chatgpt.sh -i "Dark tower in the middle of a field of red roses."

    chatgpt.sh -i "512x512" "A tower."


### Image Variations

Generate image variation:

    chatgpt.sh -i path/to/image.png


### Image Edits

    chatgpt.sh -i path/to/image.png path/to/mask.png "A pink flamingo."


#### Outpaint - make a mask from the black colour:

![Showing off Image Edits - Outpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits.gif)


#### Inpaint - add a bat in the night sky:

![Showing off Image Edits - Inpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits2.gif)

![Inpaint, steps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits_steps.png)


### 🔊 Audio Transcriptions / Translations

Generate transcription from audio file. A prompt to guide the model's style is optional.
The prompt should match the audio language:

    chatgpt.sh -w path/to/audio.mp3

    chatgpt.sh -w path/to/audio.mp3 "en" "This is a poem about X."


Generate transcription from voice recording, set Portuguese as the language to transcribe to:

    chatgpt.sh -w pt


Also works to transcribe from one language to another.

Transcribe any language audio **to japanese** (_prompt_ must be in
the same language as the input audio language):

    chatgpt.sh -w ja "An interview."


Translate audio file or voice recording in any language to English:

    chatgpt.sh -W [audio_file]

    chatgpt.sh -W


Transcribe audio and print timestamps `option -ww`:

    chatgpt.sh -ww pt audio_in.mp3


![Transcribe audio with timestamps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_trans.png)


### Code Completions (Codex)

Codex models are discontinued. Use davinci models or gpt-3.5+.

Start with a commented out code or instruction for the model,
or ask it in comments to optimise the following code, for example.


## 🌎 Environment

- Set `$OPENAI_API_KEY` with your OpenAI API key.

- Optionally, set `$CHATGPTRC` with path to the configuration file (run
`chatgpt.sh -F` to generate a template configuration file.
Defaults location = `~/.chatgpt.conf`.


## Configuration File

To save and then edit the template configuration file, run:


```
    #save a copy of the conf file:
    chatgpt.sh -F > ~/.chatgpt.conf
    
    #edit with text editor or simply:
    chatgpt.sh -F
```


<!--
## 🐚 Shell Interpreters

The script can be run with either Bash, or Zsh.

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

See [BUGS](https://github.com/mountaineerbr/shellChatGPT/tree/main/man#bugs-and-limits)
in the man page.
-->
<!-- [Ksh93u+](https://github.com/ksh93/ksh) (~~_avoid_ Ksh2020~~), -->


## Arch Linux Users

There is a [*PKGBUILD*](PKGBUILD) file available to install
the script and documentation at the right directories
in Arch Linux and derivative distros.

This PKGBUILD generates the package `chatgpt.sh-git`.
Below is an installation example with just the PKGBUILD.


```
cd $(mktemp -d)

wget https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/PKGBUILD

makepkg

pacman -U chatgpt.sh-git*.pkg.tar.zst
```

<!--
There is a [*PKGBUILD*](https://aur.archlinux.org/packages/chatgpt.sh) entry available to install the package
in Arch Linux and derivative distros.
-->


## Tiktoken and Termux Users

To run `tiktoken` with `options -T -y`, be sure to have your system
updated and installed with `python`, `rust`, and `rustc-dev` packages
for building python `tiktoken`.

```
pkg update

pkg upgrade

pkg install python rust rustc-dev

pip install tiktoken
```

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

- Implement most nice features from OpenAI API.

- Provide the closest API defaults.

- Let the user customise defaults (as homework).

<!--
## Distinct Features

- **Run as single** or **multi-turn**, optional response streaming.

- **Text editor interface**, and **multiline prompters**. 

- **Manage sessions** and history files.

- Hopefully, default colours are colour-blind friendly.

- **Colour themes** and customisation.

_For a simple python wrapper for_ **tiktoken**,
_see_ [tkn-cnt.py](https://github.com/mountaineerbr/scripts/blob/main/tkn-cnt.py).
-->


## ⚠️ Limitations

- OpenAI **API v1** is the focus of the present project implementation.

- See _BUGS AND LIMITS_ section in the [man page](man/README.md).

<!--
- User input must double escape `\n` and `\t` to have them as literal sequences.
  **NO LONGER the case as of v.018**  -->


## 📖 Help Pages 

Read the markdown [**man page here**](man/README.md).

Alternatively, a help page snippet can be printed with `chatgpt.sh -h`.


## 💪 Contributors

***Many Thanks*** to all that contributed to this project.


[edshamis](https://www.github.com/edshamis)


<br />

Everyone is [welcome to submit issues, PRs, and new ideas](https://github.com/mountaineerbr/shellChatGPT/discussions/1)!

--- 

<br />

**[The project home is at GitLab](https://gitlab.com/fenixdragao/shellchatgpt)**

<https://gitlab.com/fenixdragao/shellchatgpt>

<br />

_Mirror_

<https://github.com/mountaineerbr/shellChatGPT>

<br />
<p align="center">
  <img width="128" height="128" alt="ChatGPT by DALL-E" src="https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/dalle_out20b.png">
</p>

