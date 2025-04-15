vim9script

if exists("g:loaded_saveroot")
    finish
endif

g:loaded_saveroot = true
:lockvar g:loaded_saveroot

import autoload "saveroot.vim"

if !exists("g:saveroot_markers")
    g:saveroot_markers = [
        # '>.projectroot', '>.git', '>.hg', '>.bzr', '>.svn'
        "=vim"
    ]
endif

if !exists("g:saveroot_paths")
    g:saveroot_paths = [
        '/', '*'
    ]
endif

if !exists("g:saveroot_nomatch")
    g:saveroot_nomatch = 'none'
endif

if !exists("g:saveroot_auto")
    g:saveroot_auto = true
endif

command SRCD saveroot.GotoRoot()

augroup Saveroot
    au!
    au BufEnter * {
        if g:saveroot_auto
            saveroot.GotoRoot()
        endif
    }
augroup END

# vim: sw=4 tw=4 et
