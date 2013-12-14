syn region  rstCodeBlock         matchgroup=rstDelimiter
      \ start='.. code-block::.*\_s*\n\ze\z(\s\+\)' skip='^$' end='^\z1\@!'
      \ contains=@NoSpell

hi def link rstCodeBlock                 String
