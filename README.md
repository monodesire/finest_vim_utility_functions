# Monodesire's finest Vim utility functions

Collection of helpful Vim functions.

## Compatibility

The functions have been tested in Vim 7.3 and in a typical/modern Linux environment. Function PerlGrep() was tested with "grep (GNU grep) 2.20".

## How to use

Source functions.vim in your .vimrc file like this:

`:so functions.vim`

Then it's just to call a function like this (example) from within Vim:

`:call FindHeaderFile()`

## Description of functions

In general, more detailed information is availble in the actual functions.vim file. What is presented here is just a brief description of each function.

### FindHeaderFile()
For C programmers. Searches recursively for a header file (.h) of the active buffer (which is presumably a .c file). If found, the header file will be opened in a new split window.

### PerlGrep()
Function that greps in files for a pattern using the Perl regular expression style. The result of the grep ends up in quickfix.

### FindFiles()
Function that find files according to a search pattern given by the user.
