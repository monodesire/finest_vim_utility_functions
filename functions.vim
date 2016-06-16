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
" Function:    FindHeaderFile()
" Description: For C programmers. Searches recursively (starting from the
"              current working directory) for a header file (.h) of the active
"              buffer (which is presumably a .c file). If found, the header file
"              will be opened in a new split window. If multiple header files
"              are found, a list will be presented with all of them and the
"              user will be able to select which one to open.
" Parameters:  N/A
" Returns:     0 = no errors during execution
"              1 = errors during execution
" Examples:    N/A
" ------------------------------------------------------------------------------
function! FindHeaderFile()
  let l:filename = expand('%:t:r')
  let l:extension = expand('%:e')
  let l:path = expand('%:p:h') . "/"

  if l:extension !=? "c"
    echo "FindHeaderFile: Error! Active buffer is not a .c file.\n"
    return 1
  endif

  let l:fileSearch = globpath(getcwd(), '**/' . l:filename . '.h')
  let l:listOfFiles = split(l:fileSearch)
  let l:numberOfFiles = len(l:listOfFiles)

  if l:numberOfFiles == 0
    echo "FindHeaderFile: Info! No corresponding header file was found.\n"

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
      echo "FindHeaderFile: Error! Invalid input.\n"
      return 1
    endif
  endif
endfunction


" ------------------------------------------------------------------------------
" Function:    PerlGrep(pattern, ignoreCase)
" Description: Function that greps in files (starting from the current working
"              directory) for a pattern using the Perl regular expression style.
"              Relies on a system grep that has support for the --perl-regexp
"              parameter. Assumes the Vim internal variable 'grepprg' has its
"              default value. The result of the grep ends up in quickfix.
" Parameters:  pattern {String}: Grep pattern. Perl regexp is accepted.
"              ignoreCase {Integer} (optional): 0 = match case (default)
"                                               1 = ignore case
" Returns:     0 = no errors during execution
"              1 = errors during execution
" Examples:    :call PerlGrep("green:\\s+.*parrot.*talks", 1)
" ------------------------------------------------------------------------------
function! PerlGrep(...)
  let l:pattern = ""
  let l:ignoreCase = ""
  let l:argumentError = 0

  if a:0 == 0
    echo "PerlGrep: Error! Missing arguments.\n"
    let l:argumentError = 1

  elseif a:0 > 0
    let l:pattern = a:1

    if a:0 == 2
      if a:2 =~# "[0-9]"
        if a:2 == 1
          let l:ignoreCase = "--ignore-case"
        endif
      else
        echo "PerlGrep: Error! Second argument must be numerical.\n"
        let l:argumentError = 1
      endif
    elseif a:0 > 2
      echo "PerlGrep: Error! Too many arguments.\n"
      let l:argumentError = 1
    endif

  endif

  if l:argumentError == 1
    echo "Usage: PerlGrep(pattern, [ignoreCase])"
    echo "         pattern {String}: Grep pattern"
    echo "         ignoreCase {Integer} (optional): 0 = match case (default)"
    echo "                                          1 = ignore case"
    return 1
  else
    execute "grep! --recursive --binary-files=without-match --no-messages --perl-regexp " . l:ignoreCase . " \"" . l:pattern . "\" *"
  endif
endfunction


" ------------------------------------------------------------------------------
" Function:    FindFiles(pattern)
" Description: Function that find files (starting from the current working
"              directory) according to a search pattern given by the user.
" Parameters:  pattern {String}: Search pattern. Asterisks are accepted.
" Returns:     0 = no errors during execution
" Examples:    :call FindFiles("TC_Test.*")
"              :call FindFiles("*Test*")
" ------------------------------------------------------------------------------
function! FindFiles(pattern)
  let l:result = setqflist([])
  let l:fileSearch = globpath(getcwd(), '**/' . a:pattern)
  let l:listOfFiles = split(l:fileSearch)

  for l:file in l:listOfFiles
    call setqflist([{'filename': l:file, 'lnum': 1}], 'a')
  endfor

  echo "FindFiles: Found " . len(l:listOfFiles) . " file(s) matching the search pattern.\n"
endfunction


" ==============================================================================
" LOCAL FUNCTIONS
" ==============================================================================

" ------------------------------------------------------------------------------
" Function:    s:askForUserInput(question)
" Description: Asks the user for input via the keyboard.
" Parameters:  question {String}: A string that will be presented to user, for
"                                 example "What's your name?".
" Returns:     The user input.
" Examples:    N/A
" ------------------------------------------------------------------------------
function! s:askForUserInput(question)
  let l:curline = getline('.')
  call inputsave()
  let l:userInput = input(a:question)
  call inputrestore()
  return l:userInput
endfunction
