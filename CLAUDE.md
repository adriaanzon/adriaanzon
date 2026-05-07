This repo is managed by [Chezmoi](https://www.chezmoi.io/), a dotfiles manager. Chezmoi keeps the canonical source of dotfiles here and applies them to the home directory.

- Source files use Chezmoi naming conventions: `dot_` prefix replaces `.`, `executable_` prefix sets the executable bit, `modify_` prefix runs the script as a modifier on the existing target file, etc.
- To apply a single file after editing: `chezmoi apply --source-path <path>` (where `<path>` is the source path in this repo).
- Do not edit files directly in `~/.config/`, `~/.claude/`, etc. — edit the source here and apply.
