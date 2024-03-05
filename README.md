# shellChatGPT
Shell wrapper for OpenAI's ChatGPT, DALL-E, Whisper, and TTS. Features LocalAI, Ollama, Gemini and Mistral integration.


![Showing off Chat Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls.gif)

Chat completions with streaming by defaults.

![Chat with Markdown rendering](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_md.gif)

Markdown rendering of chat response (_optional_).


## 🚀 Features

- Text and chat completions with [**gtp-4-vision** support](#vision-models-gpt-4-vision)
- **Text editor interface**, _Bash readline_, and _cat_ input modes
- [**Markdown rendering**](#markdown) support in response
- **Preview**, and  [**regenerate responses**](#--notes-and-tips)
- **Manage sessions**, _print out_ previous sessions
- [Instruction prompt manager](#%EF%B8%8F--custom-prompts),
   easily create and set the initial system prompt
- Voice in (**Whisper**) and voice out (**TTS**) _chat / REPL mode_ (`options -cczw`)
- Integration with [awesome-chatgpt-prompts](#-awesome-prompts) and
   [Chinese awesome-chatgpt-prompts-zh](https://github.com/PlexPt/awesome-chatgpt-prompts-zh),
   [mudler's LocalAI](#localai), [Ollama](#ollama), [Google AI](#google-ai), and [Mistral AI](#mistral-ai).
- _Tiktoken_ for accurate tokenization (optional)
- Colour scheme personalisation, and a configuration file
- Stdin and text file input support
- Should™ work on Linux, FreeBSD, MacOS, and [Termux](#termux-users).

<!-- _Follow up_ conversations, --> <!-- _continue_ from last session, --> 
<!-- - Write _multiline_ prompts, flush with \<ctrl-d> (optional), bracketed paste in bash -->
<!-- - Insert mode of text completions --> <!-- _(deprecated ?)_ -->
<!-- - Choose amongst all available models from a pick list (`option -m.`) -->
<!-- - *Lots of* command line options -->
<!-- - Converts response base64 JSON data to PNG image locally -->


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


## ✨ Getting Started


### ✔️ Required Packages

- `Bash` <!-- [Ksh93u+](https://github.com/ksh93/ksh), Bash or Zsh -->
- `cURL`, and `JQ`


### Optional Packages 

These are required for specific features.

- `Base64` - Image endpoint, vision models
- `ImageMagick` - Image edits and variations
- `Python` - Tiktoken
- `mpv`/`SoX`/`Vlc`/`FFmpeg`/`afplay`/`play-audio` (Termux) - Play TTS output
- `SoX`/`Arecord`/`FFmpeg`/`termux-microphone-record` - Record input (Whisper)
- `xdg-open`/`open`/`xsel`/`xclip`/`pbcopy`/`termux-clipboard-set` - Open images, set clipboard
- `W3M`/`Lynx`/`ELinks`/`Links` - Dump URL text
- `bat`/`Pygmentize`/`Glow`/`mdcat`/`mdless`/`Pandoc` - Markdown support


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
    chatgpt.sh -FF >> ~/.chatgpt.conf
    
    #edit:
    chatgpt.sh -F

    # Or
    vim ~/.chatgpt.conf


<!--
### 🔥 Usage

- Set your [OpenAI GPTChat key](https://platform.openai.com/account/api-keys)
   with the environment variable `$OPENAI_API_KEY`, or set `option --api-key [KEY]`, or set the configuration file.
- Just write your prompt as positional arguments after setting options!
- Chat mode may be configured with Instruction or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set `option -m [MODEL_NAME]`.
- Some models require a single `prompt` while others `instruction` and `input` prompts.
- To generate images, set `option -i` and write your prompt.
- Make a variation of an image, set -i and an image path for upload.
-->

### 🔥 Usage Examples 🔥

![Chat cmpls with prompt confirmation](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_verb.gif)


### 💬  Native Chat Completions

With command line `options -cc`, some properties are set automatically to create a chat bot.
Start a new session in chat mode, and set a different temperature (*gpt-3.5 and gpt-4+ models*):

    chatgpt.sh -cc -t0.7


Create **Marv, the sarcastic bot** manually:

    chatgpt.sh -60 -cc --frequency-penalty=0.5 --temp=0.5 --top_p=0.3 --restart-seq='\nYou: ' --start-seq='\nMarv:' --stop='You:' --stop='Marv:' -S'Marv is a factual chatbot that reluctantly answers questions with sarcastic responses:'

<!--
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "What's the capital of France?"}, {"role": "assistant", "content": "Paris, as if everyone doesn't know that already."}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "Who wrote 'Romeo and Juliet'?"}, {"role": "assistant", "content": "Oh, just some guy named William Shakespeare. Ever heard of him?"}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "How far is the Moon from Earth?"}, {"role": "assistant", "content": "Around 384,400 kilometers. Give or take a few, like that really matters."}]}
-->
<!-- https://platform.openai.com/docs/guides/fine-tuning/preparing-your-dataset -->


#### Vision Models (GPT-4-Vision)

To send an `image` / `url` to vision models, start the script and then either
set the image with the `!img` chat command with one or more filepaths / URLs
separated by the operator pipe **|**.


    chatgpt.sh -cc -m gpt-4-vision-preview '!img path/to/image.jpg'


Alternatively, set the image paths / URLs at the end of the prompt interactively:

    chatgpt.sh -cc -m gpt-4-vision-preview

    [...]
    Q: In this first user prompt, what can you see? | https://i.imgur.com/wpXKyRo.jpeg


**TIP:** Run chat command `!info` to check model configuration!

**DEBUG:** Set `option -VV` to see the raw JSON request body.


#### Voice In and Out + Chat Completions

🗣️ Chat completion with **Whisper**:

    chatgpt.sh -ccw

Chat in Portuguese with voice in and out:

    chatgpt.sh -cczw pt


### Chat Mode of Text Completions

When text completions is set for chatting with `option -c`,
some properties are configured automatically to instruct the bot.


    chatgpt.sh -c "Hello there! What is your name?"


<!-- **TIP**: Set _-vv_ to have auto sleep for reading time of last response,
and less verbose in voice input chat! *Only without option -z!* -->

<!--
Generate some unexpected use cases if chatgpt.sh.

Certainly! Here are some unexpected use cases of the `chatgpt.sh` script:

1. Creative Writing Assistant: Use the script to generate story prompts or brainstorm ideas for your creative writing projects.

2. Virtual Therapist: Have a chat session with the script as a virtual therapist, sharing your thoughts and feelings.

3. Language Learning Partner: Practice your language skills by having conversations with the script in your target language.

4. Coding Assistance: Use the script to help you with coding tasks by providing code snippets or answering programming-related questions.

5. Artistic Collaboration: Collaborate with the script to co-create art pieces, coming up with unique concepts and ideas.

6. Songwriting Inspiration: Get inspired by having a chat session with the script and use its responses as prompts for songwriting.

7. Historical Simulation: Have a conversation with the script as a historical figure or simulate historical events by interacting with the script.

8. Technical Support: Use the script to troubleshoot technical issues or provide instructions for using specific software or tools.

9. Game Master Assistant: Use the script to assist you in running tabletop role-playing game sessions by generating NPCs, locations, and plot ideas.

10. Virtual Travel Guide: Have a chat session with the script to get travel recommendations, learn about different destinations, and plan your next trip.

These unexpected use cases demonstrate the versatility of the `chatgpt.sh` script and how it can be utilized beyond its traditional applications. Have fun exploring and discovering new ways to interact with it!
-->


### 📜 Text Completions

This is the pure text completions endpoint. It is typically used to
complete input text, such as for completing part of an essay.

One-shot text completion:

    chatgpt.sh "Hello there! What is your name?"


**NOTE:** For multiturn, set `option -d`.


A strong Instruction prompt may be needed for the language model to do what is required.

Set an instruction prompt for better results:
    
    chatgpt.sh -d -S 'The following is a newspaper article.' "It all starts when FBI agents arrived at the governor house and"

    chatgpt.sh -d -S'You are an AI assistant.'  "The list below contain the 10 biggest cities in the w"


#### Insert Mode of Text Completions  <!-- _(deprecated)_ -->

Set `option -q` to enable insert mode and add the
string `[insert]` where the model should insert text:

    chatgpt.sh -q 'It was raining when [insert] tomorrow.'


**NOTE:** This example works with _no instruction_ prompt!
An instruction prompt in this mode may interfere with insert completions.

**NOTE:** [Insert mode](https://openai.com/blog/gpt-3-edit-insert)
works with model `gpt-3.5-turbo-instruct`. This endpoint _may deprecate_.
<!-- `davinci`, `text-davinci-002`, `text-davinci-003`, and the newer -->


<!--
### Text Edits  _(discontinued)_

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

The markdown option uses `bat` as it has line buffering on by defaults,
however other software is supported.
Set it such as `--markdown=glow` or `/md mdless` on chat mode.

Type in any of the following markdown software as argument to the option:
`bat`, `pygmentize`, `glow`, `mdcat`, `mdless`, or `pandoc`.


## ⚙️ Prompts

Unless the chat `option -c` or `-cc` are set, _no instruction_ is
given to the language model. On chat mode, if no instruction is set,
minimal instruction is given, and some options set, such as increasing
temp and presence penalty, in order to un-lobotomise the bot.

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat completions models.

The model steering and capabilities require prompt engineering
to even know that it should answer the questions.

<!--
**NOTE:** Heed your own instruction (or system prompt), as it
may refer to both *user* and *assistant* roles.
-->


### ⌨️  Custom Prompts

Set a one-shot instruction prompt with `option -S`:

    chatgpt.sh -cc -S 'You are a PhD psycologist student.' 

    chatgpt.sh -ccS'You are a professional software programmer.'


To create or load a prompt template file, set `option -S` with the
operator dot and the name of the prompt as argument:

    chatgpt.sh -cc -S.psycologist 

    chatgpt.sh -cc -S..software_programmer


This will load the custom prompt, or create it if it does not yet exist.
In the second example, single-shot editing will be skipped after loading
prompt _software_programmer_.


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


## 💡  Notes and Tips

- Run chat commands with either _operator_ `!` or `/`.

- Edit live history entries with command `!hist`, for context injection.

- Add operator forward slash `/` to the end of prompt to trigger **preview mode**.

- One can regenerate a response typing in a new prompt a single slash `/`,
or `//` to have last prompt edited before new request.

<!--
- There is a [Zsh point release branch](https://gitlab.com/fenixdragao/shellchatgpt/-/tree/zsh),
  but it will not be updated.
-->
<!--
- Generally, my evaluation on models prefers using `davinci`, or
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

- When instruction and/or first prompt are the name of file, the file
will be read and its contents set as input, accordingly.

- Set clipboard with the latest response with `option -o`.

- Create a new session (in the history file) named **computing**,
optionally set instruction for the new session:

    ```
    chatgpt.sh -cc  /computing

    chatgpt.sh -cc -S'You are a professional software developer.' /computing
    ```

  This will create a history file named `computing.tsv` in the cache directory.
-->


## More Examples and Script Modes (Endpoints)

### 🖼️ Image Generations

Generate image according to prompt:

    chatgpt.sh -i "Dark tower in the middle of a field of red roses."

    chatgpt.sh -i "512x512" "A tower."


### Image Variations

Generate image variation:

    chatgpt.sh -i path/to/image.png


### Image Edits

    chatgpt.sh -i path/to/image.png path/to/mask.png "A pink flamingo."


#### Outpaint - Canvas Extension

![Displaying Image Edits - Extending the Canvas](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits.gif)

In this example, a mask is made from the white colour.


#### Inpaint - Fill in the Gaps

![Showing off Image Edits - Inpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits2.gif)
<!-- ![Inpaint, steps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits_steps.png) -->

Adding a bat in the night sky.


### 🔊 Audio Transcriptions / Translations

Generate transcription from audio file. A prompt to guide the model's style is optional.
The prompt should match the audio language:

    chatgpt.sh -w path/to/audio.mp3

    chatgpt.sh -w path/to/audio.mp3 "en" "This is a poem about X."


**1.** Generate transcription from voice recording, set Portuguese as the language to transcribe to:

    chatgpt.sh -w pt


This also works to transcribe from one language to another.


**2.** Transcribe any language audio input **to Japanese** (_prompt_ should be in
the same language as the input audio language, preferably):

    chatgpt.sh -w ja "A job interview is currently being done."


**3.1** Translate English audio input to Japanese, and generate audio output from text.

    chatgpt.sh -wz ja "Getting directions to famous places in the city."


**3.2** Also doing it conversely, this gives an opportunity to (manual)
conversation turns of two speakers of different languages. Below,
a Japanese speaker can translate its voice and generate audio in the target language.

    chatgpt.sh -wz en "Providing directions to famous places in the city."


**4.** Translate audio file or voice recording from any language to English:

    chatgpt.sh -W [audio_file]

    chatgpt.sh -W


**NOTE:** Generate phrasal-level timestamps double setting `option -ww`, or `option -WW`.


![Transcribe audio with timestamps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_trans.png)


<!-- 
### Code Completions (Codex, _discontinued_)

Codex models are discontinued. Use models davinci, or gpt-3.5+.

Start with a commented out code or instruction for the model,
or ask it in comments to optimise the following code, for example.
-->


## LocalAI

### LocalAI Server

Make sure you have got [mudler's LocalAI](https://github.com/mudler/LocalAI),
server set up and running.

The server can be run as a docker container or a
[binary can be downloaded](https://github.com/mudler/LocalAI/releases).
Check LocalAI tutorials
[Container Images](https://localai.io/basics/getting_started/#container-images),
and [Run Models Manually](https://localai.io/docs/getting-started/manual)
for an idea on how to install, download a model and set it up.

     ┌───────────────────────────────────────────────────┐
     │                   Fiber v2.50.0                   │
     │               http://127.0.0.1:8080               │
     │       (bound on host 0.0.0.0 and port 8080)       │
     │                                                   │
     │ Handlers ............. 1  Processes ........... 1 │
     │ Prefork ....... Disabled  PID ..................1 │
     └───────────────────────────────────────────────────┘


### Running

Finally, when running `chatgpt.sh`, set the model name:

    chatgpt.sh --localai -cc -m luna-ai-llama2


Setting some stop sequences may be needed to prevent the
model from generating text past context:

    chatgpt.sh --localai -cc -m luna-ai-llama2  -s'### User:'  -s'### Response:'


Optionally set restart and start sequences for text completions
endpoint (`option -c`), such as `-s'\n### User: '  -s'\n### Response:'`
(do mind setting newlines *\n and whitespaces* correctly).

And that's it!


### Installing Models

Model names may be printed with `chatgpt.sh -l`. A model may be
supplied as argument, so that only that model details are shown.


**NOTE:** Model management (downloading and setting up) must follow
the LocalAI and Ollama projects guidelines and methods.

For image generation, install Stable Diffusion from the URL
`github:go-skynet/model-gallery/stablediffusion.yaml`,
and for audio transcription, download Whisper from the URL
`github:go-skynet/model-gallery/whisper-base.yaml`.
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


### API Host Configuration

If the host address is different from the defaults, we need editing
the script configuration file `.chatgpt.conf`.

    vim ~/.chatgpt.conf

    # Or

    chatgpt.sh -F


Set the following variable:

    # ~/.chatgpt.conf
    
    OPENAI_API_HOST="http://127.0.0.1:8080"


_Alternatively_, set `$OPENAI_API_HOST` on invocation:

    OPENAI_API_HOST="http://127.0.0.1:8080" chatgpt.sh -c -m luna-ai-llama2


## Ollama

Visit [Ollama repository](https://github.com/ollama/ollama/),
and follow the instructions to install, download models, and set up
the server.

After having Ollama server running, set `option -O` (`--ollama`),
and the name of the model in `chatgpt.sh`:

    chatgpt.sh -cc -O -m llama2


If Ollama server URL is not the defaults `http://localhost:11434`,
edit `chatgpt.sh` configuration file, and set the following variable:

    # ~/.chatgpt.conf
    
    OLLAMA_API_HOST="http://192.168.0.3:11434"


## Google AI

Get a free [API key for Google](https://gemini.google.com/) to be able to
use Gemini and vision models. Users have a free bandwidth of 60 requests per minute, and the script offers a basic implementation of the API.

Set the enviroment variable `$GOOGLE_API_KEY` and run the script
with `option --google`, such as:

    chatgpt.sh --google -cc -m gemini-pro-vision


*OBS*: Google Gemini vision models _are not_ enabled for multiturn at the API side yet.

To list all available models, run `chatgpt.sh --google -l`.


## Mistral AI

Set up a [Mistral AI account](https://mistral.ai/),
declare the enviroment variable `$MISTRAL_API_KEY`,
and run the script with `option --mistral` for complete integration.
<!-- $MISTRAL_API_HOST -->


<!--
## 🌎 Environment

- Set `$OPENAI_API_KEY` with your OpenAI API key.

- Optionally, set `$CHATGPTRC` with path to the configuration file (run
`chatgpt.sh -FF` to download a template configuration file.
Defaults location = `~/.chatgpt.conf`.
-->

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


This project PKGBUILD is available at the
[Arch Linux User Repository (*AUR*)](https://aur.archlinux.org/packages/chatgpt.sh)
to install the software in Arch Linux and derivative distros.

To install the programme from the AUR, you can use an *AUR helper*
like `yay` or `paru`. For example, with `yay`:

    yay -S chatgpt.sh


<!--
There is a [*PKGBUILD*](PKGBUILD) file available to install
the script and documentation at the right directories
in Arch Linux and derivative distros.

This PKGBUILD generates the package `chatgpt.sh-git`.
Below is an installation example with just the PKGBUILD.

    cd $(mktemp -d)
    
    wget https://gitlab.com/fenixdragao/shellchatgpt/-/raw/main/PKGBUILD
     
    makepkg
        
    pacman -U chatgpt.sh-git*.pkg.tar.zst

-->


## Termux Users

### Optional Dependencies

For recording audio (Whisper, `option -w`), we recommend `termux-microphone-record`, and
for playing audio (TTS, `option -z`), install `play-audio`.

To set the clipboard, it is required `termux-clipboard-set`.


### Tiktoken

Under Termux, make sure to have your system updated and installed with
`python`, `rust`, and `rustc-dev` packages for building `tiktoken`.

    pkg update
    
    pkg upgrade
    
    pkg install python rust rustc-dev
    
    pip install tiktoken


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

- Implement nice features from OpenAI API version 1.

- Provide the closest API defaults.

- Let the user customise defaults (as homework).


<!--
## Distinct Features

- **Run as single** or **multi-turn**, response streaming on by defaults.

- **Text editor interface**, and **multiline prompters**. 

- **Manage sessions** and history files.

- Hopefully, default colours are colour-blind friendly.

- **Colour themes** and customisation.

_For a simple python wrapper for_ **tiktoken**,
_see_ [tkn-cnt.py](https://github.com/mountaineerbr/scripts/blob/main/tkn-cnt.py).
-->


## ⚠️ Limitations

- OpenAI **API version 1** is the focus of the present project implementation.
Not all features of the API will be covered.

- See _BUGS AND LIMITS_ section in the [man page](man/README.md).

- Bash shell truncates input on `\000` (null).

- Bash "read command" may not correctly display input buffers larger than
the TTY screen size during editing. However, input buffers remain
unaffected. Use the text editor interface for big prompt editing.

- Garbage in, garbage out. An idiot savant.


<!--
- User input must double escape `\n` and `\t` to have them as literal sequences.
  **NO LONGER the case as of v.018**  -->


## 📖 Help Pages 

Read the online [**man page here**](man/README.md).

Alternatively, a help page snippet can be printed with `chatgpt.sh -h`.


## 💪 Contributors

***Many Thanks*** to all that contributed to this project.


[edshamis](https://www.github.com/edshamis)


## Acknowledgements

The following projects are worth remarking.
They were studied during development of this script and used as referencial code sources.

1. [TheR1D's shell_gpt](https://github.com/TheR1D/shell_gpt/)
2. [xenodium's chatgpt-shell](https://github.com/xenodium/chatgpt-shell)
3. [llm-workflow-engine](https://github.com/llm-workflow-engine/llm-workflow-engine)
4. [0xacx's chatGPT-shell-cli](https://github.com/0xacx/chatGPT-shell-cli)
5. [mudler's LocalAI](https://github.com/mudler/LocalAI)
6. [Ollama](https://github.com/ollama/ollama/)
7. [Google Gemini](https://gemini.google.com/)
8. [f's awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
9. [PlexPt's awesome-chatgpt-prompts-zh](https://github.com/PlexPt/awesome-chatgpt-prompts-zh)
<!-- https://huggingface.co/ -->


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


<br />

Everyone is [welcome to submit issues, PRs, and new ideas](https://github.com/mountaineerbr/shellChatGPT/discussions/1)!

--- 

<br />

**[The project home is at GitLab](https://gitlab.com/fenixdragao/shellchatgpt)**

<https://gitlab.com/fenixdragao/shellchatgpt>

<br />

_Mirror_

<https://github.com/mountaineerbr/shellChatGPT>

<!--
## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=mountaineerbr/shellChatGPT&type=Date)](https://star-history.com/#mountaineerbr/shellChatGPT&Date)
-->

<!-- Estimated value of the project if commissioned: ~$1500 over one year (2023-2024).
-->

<br />
<p align="center">
  <img width="128" height="128" alt="ChatGPT by DALL-E" src="https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/dalle_out20b.png">
</p>

