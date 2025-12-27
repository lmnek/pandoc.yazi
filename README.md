# pandoc.yazi

[Pandoc](https://github.com/jgm/pandoc) plugin for [Yazi](https://github.com/sxyazi/yazi) for converting the selected files to different markup files.

<a href="https://asciinema.org/a/NYrG2MzSXLrXXMmyzgmPHkRKQ" target="_blank"><img src="https://asciinema.org/a/NYrG2MzSXLrXXMmyzgmPHkRKQ.svg" /></a>

## Installation

```sh
ya pkg add lmnek/pandoc
```

## Usage

Add the following mappings to your `~/.config/yazi/keymap.toml`. Note that, the keybindings are just examples, please tune them up as needed to ensure they don't conflict with your other commands/plugins.

### Interactive conversion

By default, the plugin runs interactively. It detects your current state to provide the most relevant prompt:
- **Single** file focused: prompts for a specific output filename
- **Multiple** files selected: prompts for a target extension (e.g., pdf) and converts all selected files

```toml
[[manager.prepend_keymap]]
on   = [ "c", "p" ]
run  = "plugin pandoc"
desc = "Pandoc: Interactive Convert"
```

### Direct conversion

If you frequently convert to a specific format, use the `--to_ext` argument to bypass the interactive prompts.

```toml
[[manager.prepend_keymap]]
on   = [ "c", "m" ]
run  = "plugin pandoc -- --to_ext=md"
desc = "Pandoc: Convert to Markdown"
```

### Using pandoc defaults

You can further customize the conversion by passing names of Pandoc [default files](https://pandoc.org/MANUAL.html#defaults-files) , using the `--defaults` argument. This allows you to apply complex configurations (like LaTeX templates or bibliography settings). Currently, also specifying `--to_ext` is mandatory when passing a defaults file.

```toml
on   = [ "c", "M" ]
run  = "plugin pandoc -- --to_ext=md --defaults=academic"
desc = "Pandoc: Convert to Markdown (academic.yaml default file)"
```

