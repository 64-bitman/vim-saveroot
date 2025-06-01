vim9script

if exists("g:loaded_saveroot")
    finish
endif

g:loaded_saveroot = true
:lockvar g:loaded_saveroot

import autoload "saveroot.vim"
import autoload "save.vim"
import autoload "util.vim"

if !exists("g:saveroot_markers")
    g:saveroot_markers = [
        '>.projectroot', '>.git', '>.hg', '>.bzr', '>.svn'
    ]
    g:__saveroot_markers = copy(g:saveroot_markers)
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

if !exists("g:saveroot_cd")
    g:saveroot_cd = 'lcd'
endif

if !exists("g:saveroot_dir")
    g:saveroot_dir = $MYVIMDIR
endif

def DoGoto()
    var filename = expand("%:p")

    if empty(filename)
        saveroot.GotoRoot(getcwd(0, 0))
    else
        saveroot.GotoRoot(filename)
    endif
enddef

def Reload()
    save.ReloadFile()
    g:__saveroot_markers = copy(g:saveroot_markers)
    g:__saveroot_markers += save.GetSavedMarkers()
enddef

def g:SaverootFindRoot(start: string, markers: list<any>): list<string>
    return saveroot.FindRoot(start, markers)
enddef

command -nargs=0 SRcd {
    DoGoto()
}
command -bang -nargs=1 -complete=file SRsave {
    var actual: string = fnamemodify(<q-args>[1 :], ":p")
    var comb: string = <q-args>[0] .. actual

    if !filereadable(actual) && !isdirectory(actual) && "<bang>" != '!'
        util.Msg("File/directory does not exist, use ! to override")
    else
        if save.SaveMarker(comb)
            add(g:__saveroot_markers, comb)
            DoGoto()
        endif
    endif
}
command -nargs=1 -complete=file SRdel {
    var actual: string = fnamemodify(<q-args>[1 :], ":p")
    var comb: string = <q-args>[0] .. actual

    if save.RemoveMarker(comb)
        remove(g:__saveroot_markers, index(g:__saveroot_markers, comb))
        DoGoto()
    endif
}
command -nargs=0 SRreload Reload()

Reload()

if g:saveroot_auto
    augroup Saveroot
        au!
        au BufEnter * {
            b:saveroot_marker = ""
            b:saveroot_root = ""

            if &buftype == ""
                DoGoto()
                doautocmd User SaverootCD
            endif
        }
    augroup END
endif

# vim: sw=4 tw=4 et
