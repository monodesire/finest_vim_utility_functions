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
    echo "FindHeaderFile: No corresponding header file was found.\n"

  elseif l:numberOfFiles == 1
    execute "split " . l:listOfFiles[0]

  else
    echo "FindHeaderFile: Multiple header files found:\n\n"

    let l:counter = 0
    for l:file in l:listOfFiles
      echo "(" . l:counter . ") " . l:file
      let l:counter += 1
    endfor

    let l:userInput = s:trimString(s:askForUserInput("\nSelect one to open (0-" . (l:numberOfFiles-1)  . "): "))

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
"              :call PerlGrep("for\\s*\\(.*index", 1)
"              :call PerlGrep("\\->.*\\->", 1)
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
"              directory) according to a search pattern given by the user. The
"              result of the file search ends up in quickfix.
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

" ------------------------------------------------------------------------------
" Function:    SelectBuffer(searchString)
" Description: Function that finds a buffer by a user-given search string. The
"              match is case insensitive. The search string may contain only a
"              part of a buffer name for a buffer to be found. This function
"              is heavily based on a function found here:
"                http://vim.wikia.com/wiki/Easier_buffer_switching
" Parameters:  searchString {String}: Search string.
" Returns:     0 = no errors during execution
" Examples:    :call SelectBuffer("vIm")
"                The above search string would find these buffers:
"                  (2) docs/vim/vimlazy.txt
"                  (4) .vimrc
"                  (5) vim/functions/finest_vim_utility_functions/functions.vim
"              :call SelectBuffer("func")
"                The above search string would find this buffer (notice that
"                the path of the file/buffer name is also included in the
"                search):
"                  (5) vim/functions/finest_vim_utility_functions/functions.vim
" ------------------------------------------------------------------------------
function! SelectBuffer(searchString)
  let l:lastBufferNumber = bufnr("$")
  let l:currentBufferNumber = 1
  let l:numberOfMatches = 0

  while l:currentBufferNumber <= l:lastBufferNumber
    if(bufexists(l:currentBufferNumber))
      let currentBufferName = bufname(l:currentBufferNumber)
      if(match(currentBufferName, '\c' . a:searchString) > -1)
        if l:numberOfMatches == 0
          echo "SelectBuffer: Buffers found:\n\n"
        endif

        echo "(" . l:currentBufferNumber . ") " . bufname(l:currentBufferNumber)

        let l:numberOfMatches += 1
      endif
    endif
    let l:currentBufferNumber += 1
  endwhile

  if(l:numberOfMatches == 0)
    echo "SelectBuffer: Didn't find any buffers that matches the given search string.\n"
  else
    let l:desiredBufferNumber = s:trimString(s:askForUserInput("\nSelect buffer number: "))
    if l:desiredBufferNumber =~# "[0-9]"
      if(bufexists(str2nr(l:desiredBufferNumber)))
        execute ":buffer " . l:desiredBufferNumber
      elseif str2nr(l:desiredBufferNumber) == 0
        echo "SelectBuffer: Error! Buffer 0 cannot be selected.\n"
        call s:pressAnyKeyToContinue()
      else
        echo "SelectBuffer: Error! Buffer " . l:desiredBufferNumber . " doesn't exist. Wrong buffer number given.\n"
        call s:pressAnyKeyToContinue()
      endif
    else
      echo "SelectBuffer: Error! Wrong input format. Only digits are accepted.\n"
      call s:pressAnyKeyToContinue()
    endif
  endif
endfunction

" ------------------------------------------------------------------------------
" Function:    ToggleFavouriteDirs(newFavouriteDir)
" Description: A function that changes the local directory for the current
"              window to the next pre-defined favourite directory. Those
"              favourite directories are pre-defined by the user in
"              g:fineFunc_favouriteDirs (global list variable) which is
"              preferably set in the .vimrc file. For each call to this
"              function, the function will pick up the next directory (since
"              it remembers the last one picked) in this list and change to
"              that directory (using :lcd). Thus, the purpose of this function
"              is to assist the user in quickly jumping between his/her
"              favourite dirs. A temporary directory may be added to the
"              favourite list via a parameter. The new directory will be added
"              to the end of the list and the current window will change into
"              that directory. However, none of the directories added in this
"              fashion will be remembered the next time Vim is started.
" Parameters:  newFavouriteDir {String}: A new favourite directory to
"                                        temporary add to the end of the
"                                        favourite list.
" Returns:     0 = no errors during execution
" Examples:    How to set the global list of favourite directories:
"                let g:fineFunc_favouriteDirs = ["/home/sunshine/rose/","/tmp/"]
"              How to map the function to e.g. F11:
"                map <F11> :call ToggleFavouriteDirs()<CR>
"              Add a new temporary favourite directory and jump to it:
"                :call ToggleFavouriteDirs("/some/nice/path/")
" ------------------------------------------------------------------------------
function! ToggleFavouriteDirs(...)
  if exists("g:fineFunc_favouriteDirs")
    if empty(g:fineFunc_favouriteDirs)
      echo "ToggleFavouriteDirs: Error! List variable g:fineFunc_favouriteDirs is empty.\n"
      echo "                            Set according to this example in your .vimrc:\n"
      echo "                            let g:fineFunc_favouriteDirs = [\"/home/sunshine/rose/\",\"/tmp/\"]\n"
      call s:pressAnyKeyToContinue()
    else
      if exists("g:fineFunc_favouriteDirsIndex")
        let g:fineFunc_favouriteDirsIndex += 1
        if g:fineFunc_favouriteDirsIndex >= len(g:fineFunc_favouriteDirs)
          let g:fineFunc_favouriteDirsIndex = 0
        endif
      else
        let g:fineFunc_favouriteDirsIndex = 0
      endif

      if a:0 > 0
        if type(a:1) == 1  " 1 means a variable of String type
          call add(g:fineFunc_favouriteDirs, a:1)
          let g:fineFunc_favouriteDirsIndex = len(g:fineFunc_favouriteDirs) - 1
        endif
      endif

      if isdirectory(g:fineFunc_favouriteDirs[g:fineFunc_favouriteDirsIndex])
        execute "lcd " . g:fineFunc_favouriteDirs[g:fineFunc_favouriteDirsIndex]
        echo "ToggleFavouriteDirs: Changed to directory: " . g:fineFunc_favouriteDirs[g:fineFunc_favouriteDirsIndex]
      else
        echo "ToggleFavouriteDirs: Error! This directory specified in g:fineFunc_favouriteDirs does not exist:\n"
        echo "                              " . g:fineFunc_favouriteDirs[g:fineFunc_favouriteDirsIndex]
        echo "                            Will remove it from the list.\n"
        call remove(g:fineFunc_favouriteDirs, g:fineFunc_favouriteDirsIndex)
        let g:fineFunc_favouriteDirsIndex = 0
        call s:pressAnyKeyToContinue()
      endif
    endif

  else
    echo "ToggleFavouriteDirs: Error! List variable g:fineFunc_favouriteDirs has not been set.\n"
    echo "                            Set according to this example in your .vimrc:\n"
    echo "                            let g:fineFunc_favouriteDirs = [\"/home/sunshine/rose/\",\"/tmp/\"]\n"
    call s:pressAnyKeyToContinue()
  endif
endfunction

" ------------------------------------------------------------------------------
" Function:    TagSearch(tag1, tag2, ...)
" Description: Function that finds user defined tags (more about the syntax of
"              those tags below) within the active buffer. The active buffer is
"              typically a text file (maybe a cheat sheet or a lazy dog, or
"              other type of file holding information of some kind) in which the
"              user has applied tags for marking important or interesting
"              sections, and then using this function to do a somewhat
"              intelligent search among those tags. The search result ends up
"              in quickfix.
"
"              * Tag syntax: Tags are listed on a single line, and that line
"              must start with ">>>". Tags are separated by a comma. (White
"              spaces between the commas are ignored.) A tag may contain a-z,
"              0-9 and underscore. (Upper case letters will be treated as lower
"              case.) Here are some tag lines examples:
"
"              >>> linux, network, routing, ipv6, ipv4
"
"                     Comment: All those five tags are valid.
"
"              >>> programming, c, loop, syntax
"
"                     Comment: All those four tags are valid.
"
"              >>> perl, regexp
"
"                     Comment: Both tags are valid.
"
"              >>> this_is_a_nonsense_tag, this_is_too_nonsense123, qwerty999
"
"                     Comment: All three tags are valid.
"
"              >>> asdf    ,   456 ,  sunny day   , heLLo, invalid-tag
"
"                     Comment: Here the "asdf", "456" and "heLLo" tags are
"                              valid. The "heLLo" tag will be treated as "hello"
"                              in searches. The tags "sunny day" and
"                              "invalid-tag" are invalid since they contain
"                              illegal characters (white space and dash
"                              respectively).
"
"              * Tag search: Searching for tags and combination of tags in the
"              active buffer is done via this function's arguments. Tags are
"              listed as strings, according to this example:
"
"              TagSearch("linux", "ipv6")
"
"                     Comment: This will find all tag lines containing the
"                              "linux" tag and the "ipv6" tag.
"
"              There are two operators that may optionally be used while
"              performing a tag seach - the AND (&) operator and the OR (|)
"              operator. If an AND operator is given together with a tag in a
"              tag search, that specific tag is required to be a part of the
"              tags on a tag line (for the search to be considered a hit). If
"              an OR operator is given, that tag is just optional to be
"              present in the line of tags. The operator is inserted as the
"              first character, before the actual tag name in the function
"              argument list. A tag without any operator, is considered to
"              have an AND operator in front of it. See these examples:
"
"              TagSearch("coffee", "&tea", "|water")
"
"                     Comment: This will find all tag lines containing both
"                              the "coffee" and "tea" tags. (A tag line
"                              containing just one of these tags with not be
"                              considered a hit, because both these tags are
"                              AND tags, thus both are required.) It will also
"                              find all tag lines containing the "water" tag,
"                              regardless of any other tags in the tag line or
"                              in the search itself (this because "water" is an
"                              OR tag).
"
"              * Additional functionality: If the TagSearch() function is
"              called with no arguments, the user will be presented with a
"              printed list of all (valid) tags found in the active buffer.
"              Duplicates will be removed in this printout (if a tag is found
"              in multiple places), and the list will be sorted alphabetic
"              order.
" Parameters:  See Description.
" Returns:     N/A
" Examples:    See Description.
" ------------------------------------------------------------------------------
function! TagSearch(...)
  " examine function arguments

  if a:0 == 0
    " no arguments given; list all tags found in the active buffer

    let l:orgCursorPosition = getpos(".")  " store the cursor's current position
    call cursor(1, 1)  " move cursor to the beginning of the first line of the buffer

    let l:tagsList = []

    while search("^>>>", "cW") > 0  " iterate over all >>> found in the active buffer
      let l:lineList = s:getAllTagsOnCurrentLine()
      let l:tagsList = l:tagsList + l:lineList

      let l:cursorPosition = getpos(".")  " get current cursor position
      let l:nextLine = l:cursorPosition[1] + 1  " go to the next line in the active buffer
      if l:nextLine > line('$')
        " we have reached the end of the buffer
        break
      endif
      call cursor(l:nextLine, 1)  " put cursor in column one
    endwhile

    call setpos('.', l:orgCursorPosition)  " restore cursor back to original position

    let l:tagsList = s:sortAndUniquifyList(l:tagsList)  " remove duplicates and sort the list of tags

    " print the result, i.e. all valid tags found in the active buffer

    echo "TagSearch: Tags found in active buffer:\n\n"

    for l:tag in l:tagsList
      echo l:tag
    endfor

    echo "\n"
    call s:pressAnyKeyToContinue()

  else
    " at least some arguments found; do a tag search

    let l:result = setqflist([])  " clear the current quickfix

    let l:orgCursorPosition = getpos(".")  " store the cursor's current position
    call cursor(1, 1)  " move cursor to the beginning of the first line of the buffer

    let l:numberOfSuccessfulMatches = 0

    while search("^>>>", "cW") > 0  " iterate over all >>> found in the active buffer
      let l:lineList = s:getAllTagsOnCurrentLine()

      " loop over the arguments (tags) given by the user;
      " see if there is match between the user given tags and the ones on the current line

      let l:fullTagsMatch = 0
      let l:numberOfAndTags = 0
      let l:numberOfAndMatches = 0

      for l:arg in a:000
        let l:userGivenTag = s:trimString(l:arg)  " remove leading and trailing whitespaces
        let l:userGivenTag = tolower(l:userGivenTag)  " make all characters into lower case
        let l:andMatch = 1  " default is an AND match

        " check if the user has given a "?" (AND) or "|" (OR) in the beginning of the tag

        if l:userGivenTag =~ "^\&"
          " AND
          let l:userGivenTag = strpart(l:userGivenTag, 1)
          let l:numberOfAndTags += 1
        elseif l:userGivenTag =~ "^|"
          " OR
          let l:andMatch = 0  " this means an OR match
          let l:userGivenTag = strpart(l:userGivenTag, 1)
        else
          " AND
          let l:numberOfAndTags += 1
        endif

        if l:userGivenTag =~ "^[a-z0-9_]*$" && l:userGivenTag != ""  " make sure the user given tag is valid (i.e. not containing unallowed characters)
          " ending up here means valid tag

          " compare current line tags with user given tags

          let l:tagMatch = 0
          for l:lineTag in l:lineList
            if l:userGivenTag == l:lineTag
              let l:tagMatch = 1
              break
            endif
          endfor

          if l:tagMatch == 1 && l:andMatch == 1  " an AND tag is matching
            let l:numberOfAndMatches += 1
          elseif l:tagMatch == 1 && l:andMatch == 0  " an OR tag is matching
            let l:fullTagsMatch = 1
            break
          endif
        endif
      endfor

      " check if we have a match or not

      let l:cursorPosition = getpos(".")  " get current cursor position

      if l:fullTagsMatch == 1 || l:numberOfAndTags == l:numberOfAndMatches
        " yes, we have a match; save this line to quickfix

        let l:filename = expand('%:p')  " filename (incl. full path) of active buffer
        let l:lineString = getline(".")  " get line under cursor

        call setqflist([{'filename': l:filename, 'lnum': l:cursorPosition[1], 'text': l:lineString}], 'a')

        let l:numberOfSuccessfulMatches += 1
      endif

      let l:nextLine = l:cursorPosition[1] + 1  " go to the next line in the active buffer
      if l:nextLine > line('$')
        " we have reached the end of the buffer
        break
      endif
      call cursor(l:nextLine, 1)  " put cursor in column one
    endwhile  " end iterating over all >>> found in the active buffer

    echo "TagSearch: Found " . l:numberOfSuccessfulMatches . " matching tag lines. Quickfix has been updated.\n"
    call s:pressAnyKeyToContinue()

    call setpos('.', l:orgCursorPosition)  " restore cursor back to original position
  endif
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

" ------------------------------------------------------------------------------
" Function:    s:pressAnyKeyToContinue()
" Description: Asks the user for any key press.
" Parameters:  N/A
" Returns:     0 = no errors during execution
" Examples:    N/A
" ------------------------------------------------------------------------------
function! s:pressAnyKeyToContinue()
  echo "Press any key to continue."
  let c = getchar()
endfunction

" ------------------------------------------------------------------------------
" Function:    s:trimString(stringToFix)
" Description: Removes leading and trailing whitespaces of a string.
" Parameters:  stringToFix {String}: The string to remove whitespaces from.
" Returns:     Same as stringToFix, but with no leading or trailing
"              whitespaces.
" Examples:    N/A
" ------------------------------------------------------------------------------
function! s:trimString(stringToFix)
  let l:fixedString = substitute(a:stringToFix, '^\s*\(.\{-}\)\s*$', '\1', '')
  return l:fixedString
endfunction

" ------------------------------------------------------------------------------
" Function:    s:sortAndUniquifyList(list)
" Description: Takes a list, removes duplicates, sorts it, and then returns
"              it.
" Parameters:  list {List}: The list to be fixed.
" Returns:     A sorted list with no duplicates.
" Examples:    N/A
" ------------------------------------------------------------------------------
function! s:sortAndUniquifyList(list)
  let l:dict = {}
  for l:listItem in a:list
    let l:dict[l:listItem] = ''
  endfor
  let l:uniqueList = keys(l:dict)
  let l:sortedList = sort(l:uniqueList)
  return l:sortedList
endfunction

" ------------------------------------------------------------------------------
" Function:    s:getAllTagsOnCurrentLine()
" Description: Extracts all tags found on the cursor's current line. This
"              function is to be used by external TagSearch() function. This
"              function assumes that the current line under the cursor is
"              starting ">>>", which is the character sequence indicating a tag
"              line.
" Parameters:  N/A
" Returns:     A list containing all tags found on the current line.
" Examples:    N/A
" ------------------------------------------------------------------------------
function! s:getAllTagsOnCurrentLine()
  let l:lineString = getline(".")  " get line under cursor
  let l:lineString = strpart(l:lineString, 3)  " grab characters to the right of the inital >>> sequence
  let l:lineString = s:trimString(l:lineString)  " remove leading and trailing whitespaces
  let l:lineString = tolower(l:lineString)  " make all characters into lower case
  let l:lineList = split(l:lineString, '\s*,\s*')  " a comma is used to split between tags
  call filter(l:lineList, 'v:val =~ "^[a-z0-9_]*$"')  " filter away crappy tags, those containing unallowed characters
  return l:lineList
endfunction
