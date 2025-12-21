# pandoc.yazi

[Pandoc](https://github.com/jgm/pandoc) plugin for [Yazi](https://github.com/sxyazi/yazi) for converting the selected files to different markup files.

<a href="https://asciinema.org/a/NYrG2MzSXLrXXMmyzgmPHkRKQ" target="_blank"><img src="https://asciinema.org/a/NYrG2MzSXLrXXMmyzgmPHkRKQ.svg" /></a>

## Installation

```sh
ya pkg add lmnek/pandoc
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on   = [ "e", "p" ]
run  = "plugin pandoc"
desc = "Convert with Pandoc"
```

Note that, the keybindings above are just examples, please tune them up as needed to ensure they don't conflict with your other commands/plugins.
