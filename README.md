# Monodesire's finest Vim utility functions

Collection of helpful Vim functions.

## Compatibility

The functions have been tested in Vim 7.3 and in a typical/modern Linux environment.

## How to use

Source functions.vim in your .vimrc file like this:

`:so functions.vim`

Then it's just to call a function like this (example) from within Vim:

`:call FindHeaderFile()`

## Description of functions

### FindHeaderFile()
For C programmers. Searches recursively (starting from the current working directory) for a header file (.h) of the active buffer (which is presumably a .c file). If found, the header file will be opened in a new split window. If multiple header files are found, a list will be presented with all of them and the user will be able to select which one to open.
