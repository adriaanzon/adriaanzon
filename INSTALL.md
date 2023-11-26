# Installation

## How to install the dotfiles on a new machine

Run the following commands:

```fish
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install chezmoi 1password 1password-cli
chezmoi init git@github.com:adriaanzon/adriaanzon.git --apply
```

## Restart the computer or load services

After installing the dotfiles, not all settings take effect immediately. Either restart the computer, or load the services as needed. The services can be started by running:

```
launchctl load -w ~/Library/LaunchAgents/<name>.plist
```

## Manual configuration

Next up are some instructions to follow when setting up a new Mac, for options that are easier to configure manually through the UI than to store them in a dotfiles repo.

### Keyboard shortcuts

1. Open System Preferences > Keyboard > Keyboard Shortcuts...
2. Under "Services", disable the Command-Shift-A and Command-Shift-M shortcuts.

### iTerm2

1. Download the Nord theme using this command, then open it to install:
   ```sh
   curl -Lo ~/Downloads/Nord.itermcolors https://raw.githubusercontent.com/arcticicestudio/nord-iterm2/develop/src/xml/Nord.itermcolors
   ```
2. Import the [iTerm Keymap](.Default.itermkeymap). Go to iTerm2 > Preferences... > Profiles > Keys > Key Mappings > Presets > Import... > Go to `~/.local/share/chezmoi` > Show hidden files using Shift-Command-Period (.) and select `.Default.itermkeymap`.
3. Do some manual configuration:
    * General > Window > Make sure all boxes are ticked
    * Appearance > Dimming > Dimming Amount: set slider to about 10%
    * Appearance > General > Theme: Minimal
    * Keys > Hotkey > Show/hide all windows with a system-wide hotkey > Control-Backtick (\`)
    * Keys > Key Bindings > Add new > Control-Command-F: Toggle Fullscreen
    * Profiles > General > Command: Custom Shell, /opt/homebrew/bin/fish
    * Profiles > General > Working Directory: Reuse previous session's directory
    * Profiles > Window > Settings for New Windows: 110 columns, 30 rows (or 132x48 for a setup with a large display)
    * Profiles > Keys > Left Option Key: Esc+
    * Advanced > Search for "swipe" > Set to No
4. Go to Scripts > AutoLaunch and click one of the scripts to install the Python runtime and enable the scripting API.
5. Restart iTerm so all AutoLaunch scripts are started.
