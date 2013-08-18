" check python support
if !has('python')
echo "Error: Required vim compiled with +python"
	finish
endif

let g:reST_header = {
			\ "h1": "=",
			\ "h2": "-"
			\ }

inoremap <silent> <buffer> <Tab> 
		\<C-R>=<SID>reST_complete()<CR>

function! s:reST_complete()
	let s:line = getline(line('.'))
	for s:keyword in keys(g:reST_header)
		if s:line == s:keyword
			return <SID>header_complete(g:reST_header[s:keyword])
		endif
	endfor
endfunction

function! Test()
python << EOF
import vim
vim.command("let line_len = strdisplaywidth(getline({}))".format(vim.current.window.cursor[0]))
vim.command("let pre_line_len = strdisplaywidth(getline({}))".format(vim.current.window.cursor[0]-1))
del vim.current.buffer[:]
vim.current.buffer[0] = 80*"-"
EOF
endfunction

function! Test2()
python << EOF
import vim
#print vim.current.window.cursor
#print "echo strdisplaywidth(getline({}))".format(vim.current.window.cursor[0])
vim.command("echo strdisplaywidth(getline({}))".format(vim.current.window.cursor[0]))
b = vim.current.buffer
b.append("")
b[15:] = b[14:-1]
EOF
endfunction

function! Test3()
	if line('.') == 1
		return "\t"
	endif
	let s:line_len = strdisplaywidth(getline(line('.')))
	let s:pre_line_len = strdisplaywidth(getline(line('.') - 1))
	return repeat(getline(line('.'))[col('.') - 2], s:pre_line_len - s:line_len)
endfunction

function! s:header_complete(symbal)
	if line('.') == 1
		return "\t"
	endif
	call setline(line('.'), "")
	let s:pre_line_len = strdisplaywidth(getline(line('.') - 1))
	return repeat(a:symbal, s:pre_line_len)
endfunction

