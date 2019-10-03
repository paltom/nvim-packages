function! health#feature_terminal#check()
  call health_helpers#check_submodules_initialized(g:feature#terminal#plugins)
  call s:check_terminal_directory_change()
endfunction

function! s:check_terminal_directory_change()
  call health#report_start("Check changing directory on terminal start")
  execute "Tnew"
  let l:tid = t:neoterm_id
  let l:buf_id = g:neoterm.instances[l:tid].buffer_id
  sleep 1
  let l:lines = filter(getbufline(l:buf_id, 0, "$"), 'v:val != ""')
  let [l:cd_cmd, l:pos, _, _] = matchstrpos(l:lines, '[>$]\s*cd .*$')
  if empty(l:cd_cmd)
    call health#report_error("Changing directory didn't happen",
          \["Check Tnew command"])
  else
    let l:next_line = l:lines[l:pos]
    let l:target_dir = matchstr(l:cd_cmd, '[>$]\s*cd \zs.*')
    if has("unix")
      let l:target_dir = substitute(l:target_dir, $HOME, '~', '')
    endif
    let l:next_dir = matchstr(l:next_line, escape(l:target_dir, '\').'\ze\s*[>$]')
    if empty(l:next_dir)
      call health#report_error("Directory was not changed successfully",
            \["Check Tnew command",
            \ "(Windows) Check newline character being added"])
    else
      call health#report_ok("Changing directory on terminal start")
    endif
  endif
  execute l:tid."T exit"
endfunction
