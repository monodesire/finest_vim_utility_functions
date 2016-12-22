" ##############################################################################
" SYNTAX FILE FOR MONODESIRE'S FINEST VIM UTILITY FUNCTIONS
"
" Description:  This is an optional syntax file to be used with the TagSearch()
"               function found in Monodesire's Finest Vim Utility Functions.
"               It works with files having the .fftags extension.
" Author:       Mats Lintonsson <mats.lintonsson@gmail.com>
" License:      MIT License
" Website:      https://github.com/monodesire/finest_vim_utility_functions/
" TODOs:        N/A
" ##############################################################################

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

hi def link fftagsLine Underlined
syn match fftagsLine /^>>>.*$/

hi def link fftagsComment Comment
syn match fftagsComment "#.*"

hi def link fftagsTodo Todo
syn keyword fftagsTodo TODO FIXME XXX DEBUG NOTE

let b:current_syntax = "fftags"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8
