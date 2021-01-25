# Theme Palettes

Themes follow the rules established by the [base16](http://chriskempson.com/projects/base16/) project, but slightly customized (since that project appears to have been abandoned).

There are 16 total colors, represented by hexadecimal byte values:

- 00-07 are background colors, and should go from darkest to lightest (for dark themes) or lightest to darkest (for light themes).
- 08-0F are foreground colors, representing specific concepts.

## Background colors

- **base00** - **Default** background
- **base01** - Lighter background (status bars, line numbers, folding marks, etc)
- **base02** - Selection background
- **base03** - Comments, invisibles, line highlighting
- **base04** - Dark foreground (status bars)
- **base05** - **Default** foreground, caret, delimiters, operators
- **base06** - Light foreground (not often used)
- **base07** - Light background (not often used)

## Foreground colors

| Color      | Code                         | Markup                 | Diff     | Other                  |
| ---------- | ---------------------------- | ---------------------- | -------- | ---------------------- |
| **base08** | variables                    | tags, link text, lists | deleted  |                        |
| **base09** | numbers, booleans, constants | attributes, link URLs  |          |                        |
| **base0A** | types                        | bold                   |          | Search text background |
| **base0B** | strings                      | code                   | inserted |                        |
| **base0C** | support, regex, escape chars | quotes                 |          |                        |
| **base0D** | functions                    | attribute IDs          |          | headings               |
| **base0E** | keywords, storage, selector  | italic                 | changed  |                        |
| **base0F** | deprecated                   | value                  |          | embedded language tags |
