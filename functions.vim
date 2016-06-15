" ##############################################################################
" MONODESIRE'S FINEST VIM UTILITY FUNCTIONS
"
" Description:  Collection of helpful Vim functions.
" Author:       Mats Lintonsson <mats.lintonsson@gmail.com>
" License:      MIT License
" Website:      https://github.com/monodesire/finest_vim_utility_functions/
" ##############################################################################


" ==============================================================================
" EXTERNAL FUNCTIONS
" ==============================================================================

" ------------------------------------------------------------------------------
" Function:    FindHeaderFile
" Description: Searches recursively (starting from the current working directory
"              for a header file (.h) of the active buffer (which is presumably
"              a .c file). If found, the header file will be opened in a new
"              split window.
" ------------------------------------------------------------------------------
function! FindHeaderFile()

  let l:filename = expand('%:t:r')
  let l:path = expand('%:p:h') . "/"

  let l:fileSearch = globpath(getcwd(), '**/' . l:filename . '.h')
  let l:listOfFiles = split(l:fileSearch)
  let l:numberOfFiles = len(l:listOfFiles)

  if l:numberOfFiles == 0
    echo "FindHeaderFile: No corresponding header file was found."

  elseif l:numberOfFiles == 1
    execute "split " . l:listOfFiles[0]

  else
    echo "FindHeaderFile: Multiple header files found:\n\n"

    let l:counter = 0
    for l:file in l:listOfFiles
      echo "(" . l:counter . ") " . l:file
      let l:counter += 1
    endfor

    let l:userInput = s:askForUserInput("\nSelect one to open (0-" . (l:numberOfFiles-1)  . "): ")

    if l:userInput =~# "[0-9]" && l:userInput >= 0 && l:userInput < l:numberOfFiles
      execute "split " . l:listOfFiles[l:userInput]
    else
      echo "FindHeaderFile: Invalid input."
      return
    endif
  endif
endfunction


" ==============================================================================
" LOCAL FUNCTIONS
" ==============================================================================

" ------------------------------------------------------------------------------
" Function:    s:askForUserInput
" Description: Asks the user for input via the keyboard.
" ------------------------------------------------------------------------------
function! s:askForUserInput(question)
  let l:curline = getline('.')
  call inputsave()
  let l:userInput = input(a:question)
  call inputrestore()
  return l:userInput
endfunction