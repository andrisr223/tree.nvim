function! Tree_display(translations) abort
  let content = s:buildContent(a:translations)
  let max_height =
    \ g:vtm_popup_max_height == v:null
    \ ? float2nr(0.6*&lines)
    \ : float2nr(g:vtm_popup_max_height)
  let max_width =
    \ g:vtm_popup_max_width == v:null
    \ ? float2nr(0.6*&columns)
    \ : float2nr(g:vtm_popup_max_width)
  let [width, height] = s:winSize(content, max_width, max_height)
  let [row, col, vert, hor] = s:winPos(width, height)

  for i in range(len(content))
    let line = content[i]
  endfor

  if has('nvim') && exists('*nvim_win_set_config')
    let vtm_window_type = 'floating'
  elseif has('textprop')
    let vtm_window_type = 'popup'
  else
    let vtm_window_type = 'preview'
  endif

  if vtm_window_type == 'floating'
    " `width + 2`? ==> set foldcolumn=1
    let options = {
      \ 'relative': 'cursor',
      \ 'anchor': vert . hor,
      \ 'row': row,
      \ 'col': col,
      \ 'width': width + 2,
      \ 'height': height,
      \ }
    call nvim_open_win(bufnr('%'), v:true, options)
    call s:onOpenFloating(content)
  elseif vtm_window_type == 'popup'
    let vert = vert == 'N' ? 'top' : 'bot'
    let hor = hor == 'W' ? 'left' : 'right'
    let line = vert == 'top' ? 'cursor+1' : 'cursor-1'

    let options = {
      \ 'pos': vert . hor,
      \ 'line': line,
      \ 'col': 'cursor',
      \ 'moved': 'any',
      \ 'padding': [0, 1, 0, 1],
      \ 'maxwidth': width,
      \ 'minwidth': width,
      \ 'maxheight': height,
      \ 'minheight': height
      \ }
    let winid = popup_create('', options)
    call s:onOpenPopup(winid, content)
  else
    let curr_pos = getpos('.')
    execute 'noswapfile bo pedit!'
    call setpos('.', curr_pos)
    wincmd P
    execute height+1 . 'wincmd _'
    call s:onOpenPreview(content)
  endif
endfunction

function! s:buildContent(translations)
  let paraphrase_marker = '🌀 '
  let phonetic_marker = '🔉 '
  let explain_marker = '📝 '

  let content = []
  call add(content, '@ ' . a:translations['text'] . ' @' )

  for t in a:translations['results']
    call add(content, '')
    call add(content, '------' . t['engine'] . '------')

    if len(t['paraphrase'])
      let paraphrase = paraphrase_marker . t['paraphrase']
      call add(content, paraphrase)
    endif

    if len(t['phonetic'])
      let phonetic = phonetic_marker . '[' . t['phonetic'] . ']'
      call add(content, phonetic)
    endif

  endfor

  return content
endfunction

function! s:onOpenFloating(translation)
  enew!
  call append(0, a:translation)
  normal gg
  nmap <silent> <buffer> q :close<CR>

  setlocal foldcolumn=1
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal signcolumn=no
  setlocal filetype=vtm
  setlocal noautoindent
  setlocal nosmartindent
  setlocal wrap
  setlocal nobuflisted
  setlocal noswapfile
  setlocal nocursorline
  setlocal nonumber
  setlocal norelativenumber
  setlocal nospell
  " only available in nvim
  if has('nvim')
    setlocal winhighlight=Normal:vtmFloatingNormal
    setlocal winhighlight=FoldColumn:vtmFloatingNormal
  endif

  noautocmd wincmd p

  augroup TreeClosePopup
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:closePopup()
  augroup END
endfunction

function! s:onOpenPopup(winid, translation)
  let bufnr = winbufnr(a:winid)
  for l in range(1, len(a:translation))
    call setbufline(bufnr, l, a:translation[l-1])
  endfor
  call setbufvar(bufnr, '&filetype', 'vtm')
  call setbufvar(bufnr, '&spell', 0)
  call setbufvar(bufnr, '&wrap', 1)
  call setbufvar(bufnr, '&number', 1)
  call setbufvar(bufnr, '&relativenumber', 0)
  call setbufvar(bufnr, '&foldcolumn', 0)
endfunction

function! s:onOpenPreview(translation)
  call s:onOpenFloating(a:translation)
endfunction

function! s:winSize(translation, max_width, max_height) abort
  let width = 0
  let height = 0

  for line in a:translation
    let line_width = strdisplaywidth(line)
    if line_width > a:max_width
      let width = a:max_width
      let height += line_width / a:max_width + 1
    else
      let width = max([line_width, width])
      let height += 1
    endif
  endfor

  if height > a:max_height
    let height = a:max_height
  endif
  return [width, height]
endfunction

function! s:winPos(width, height) abort
  let bottom_line = line('w0') + winheight(0) - 1
  let curr_pos = getpos('.')
  let rownr = curr_pos[1]
  let colnr = curr_pos[2]
  " a long wrap line
  if colnr > &columns
    let colnr = colnr % &columns
    let rownr += colnr / &columns
  endif

  if rownr + a:height <= bottom_line
    let vert = 'N'
    let row = 1
  else
    let vert = 'S'
    let row = 0
  endif

  if colnr + a:width <= &columns
    let hor = 'W'
    let col = 0
  else
    let hor = 'E'
    let col = 1
  endif

  return [row, col, vert, hor]
endfunction

function! s:closePopup() abort
  for winnr in range(1, winnr('$'))
    if getbufvar(winbufnr(winnr), '&filetype') == 'vtm'
      execute winnr . 'wincmd c'
      autocmd! VtmClosePopup * <buffer>
      return
    endif
  endfor
endfunction
