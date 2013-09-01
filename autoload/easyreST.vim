" easyreST		is a reStructuredText auto-complete plugin
" Author:		float
" HomePage:		https://github.com/float-tw/easyreST
" Readme:		https://github.com/float-tw/easyreST/blob/master/README.rst
" License:		CC BY-SA
" 				http://creativecommons.org/licenses/by-sa/3.0/tw/legalcode
" 				http://creativecommons.org/licenses/by-sa/3.0/legalcode
" Version:		Beta

" check python support
if !has('python')
echo "Error: Required vim compiled with +python"
	finish
endif

let g:reST_header = {
			\ "h1": "=",
			\ "h2": "-",
			\ "h3": "^"
			\ }

let g:reST_image = [
			\ "img",
			\ "image",
			\ ]

inoremap <silent> <buffer> <Tab> 
		\<C-R>=<SID>reST_complete()<CR>

function! s:reST_complete()
	let s:line = getline(line('.'))
	for s:keyword in keys(g:reST_header)
		if s:line == s:keyword
			return <SID>header_complete(g:reST_header[s:keyword])
		endif
	endfor

	for s:keyword in g:reST_image
		if s:line == s:keyword
			return <SID>image_complete()
		endif
	endfor

	if s:link_complete() == 0
		return ''
	endif

	return "\t"
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

function! s:image_complete()
	call setline(line('.'), "")
	let s:line_num = line('.')
	let s:image_text =
				\".. image:: \n".
				\"   :alt: \n".
				\"   :height: \n".
				\"   :width: \n".
				\"   :scale: \n".
				\"   :align: \n".
				\"   :target: \n"

	put! = s:image_text
	call cursor(s:line_num, strwidth(getline(s:line_num)) + 1)
	return ""
endfunction

function! s:link_complete()
	let s:line = getline('.')
	let s:cursor_col = col('.')
	let s:link_regex = '`\(.*\)`_'			" `hyper link`_
	let s:target_regex = '\.\.\ _\(.*\)\ :'	" .. _hyper link: url

	let s:link_start = match(s:line, s:link_regex)
	let s:link_name = matchlist(s:line, s:link_regex)
	let s:link_end = matchend(s:line, s:link_regex)
	" this line have a link
	while s:link_start != -1
		" cursor at link
		if s:link_start <= s:cursor_col && s:link_end + 1 >= s:cursor_col
			let s:target_line = search(s:target_regex, 'W')
			if s:target_line == 0
				call append(line('.'), '.. _' . s:link_name[1] . ' : ')
				call append(line('.'), '')
				+2
			endif
			call search('\(:\ \)\@<=', 'We')
			return 0
		endif
		let s:link_start = match(s:line, s:link_regex, s:link_end)
		let s:link_name = matchlist(s:line, s:link_regex, s:link_end)
		let s:link_end = matchend(s:line, s:link_regex, s:link_end)
	endwhile

	" at target
	if match(s:line, s:target_regex) != -1
		let s:target_name = matchlist(s:line, s:target_regex)
		if search('`' . s:target_name[1] . '`_', 'Wbe') != 0
			return 0
		endif
	endif

	return 1
endfunction
