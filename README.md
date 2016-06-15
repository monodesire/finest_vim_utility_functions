# Monodesire's finest Vim utility functions

Collection of helpful Vim functions.

## How to use

Source functions.vim in your .vimrc file like this:

`:so functions.vim`

Then it's just to call a function like this (example) from within Vim:

`:call FindHeaderFile()`

## Description of functions

### FindHeaderFile()
Searches recursively (starting from the current working directory) for a header file (.h) of the active buffer (which is presumably a .c file). If found, the header file will be opened in a new split window.
