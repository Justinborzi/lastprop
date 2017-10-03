# CONTRIBUTING GUIDE LINES: 
If you interested in contributing, please use standard lua (meaning no c style comments or operators) and space your code correctly. I should really write a guideline and will soon, but this is fine for now.

Formatting
----------
* Delete trailing whitespace.
* Don't use C style comments `//`, `/* */`, use (`--` and `--[[ ]]--`).
* Don't use C style operators `!`, `!=`, `&&`, `||`, use `not`, `~=`, `and` and `or`.
* Use apostrophe (`'`) quotes.
* Add spaces before and after `..`.
* Don't include spaces after `{`, `(`, `[` or before `]`, `)`, `}`.
* Don't misspell.
* Don't vertically align tokens on consecutive lines.
* Use 4 space indentation (no tabs).
* Use spaces after commas, after colons and semicolons, around `{` and before `}`.
* Use [Unix-style line endings][newline explanation] (`\n`).

[newline explanation]: http://unix.stackexchange.com/questions/23903/should-i-end-my-text-script-files-with-a-newline

Naming
------
* Avoid abbreviations.
* Avoid object types in names (`user_array`, `email_method` `CalculatorClass`, `ReportModule`).
* Use [camel case][camelcase explanation] for variables.
* Use [upper camel case][upper camelcase explanation] for functions.
* Use UPPERCASE for globals and constants.

[camelcase explanation]: https://en.wikipedia.org/wiki/Camel_case
[upper camelcase explanation]: http://wiki.c2.com/?UpperCamelCase

Recommended editor is [VS Code](https://code.visualstudio.com/), with the following plugins:
* [Bracket Pair Colorizer](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer)
* [glua](https://marketplace.visualstudio.com/items?itemName=aStonedPenguin.glua)
* [lua-luachecker](https://marketplace.visualstudio.com/items?itemName=jjkim.lua-luachecker)
* [Lua](https://marketplace.visualstudio.com/items?itemName=keyring.Lua)