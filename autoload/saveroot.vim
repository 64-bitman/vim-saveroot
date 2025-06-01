vim9script

import autoload "util.vim"

def FindMarker(path: string, markers: list<any>): string
    for marker in markers
        var found: bool = false
        var exclude: bool = false
        var actual: string = marker

        if actual[0] == '!'
            exclude = true
            actual = actual[1 :]
        endif

        if actual[0] == '='
            found = util.MarkerIsPath(path, actual[1 :])
        elseif actual[0] == '>'
            found = util.MarkerUnderPath(path, actual[1 :])
        elseif actual[0] == '<'
            found = util.MarkerAbovePath(path, actual[1 :])
        else
            util.Error('Invalid marker: ' .. marker)
        endif

        if found
            if exclude
                break
            else
                return actual
            endif
        endif
    endfor
    return ""
enddef

export def FindRoot(start: string, markers: list<any>): list<string>
    var next: string = fnamemodify(start, ':p:h')

    while true
        var marker: string = FindMarker(next, markers)

        if marker != ""
            return [next, marker]
        endif

        var prev: string = next
        next = fnamemodify(next, ':h')

        if next == '.' || prev == next
            break
        endif
    endwhile

    return null_list
enddef

def PathAllowed(path: string): bool
    if (!isdirectory(path) && !filereadable(path)) || empty(path)
        return false
    endif

    for p in g:saveroot_paths
        var actual: string = p
        var exclude: bool = false

        if actual[0] == '!'
            exclude = true
            actual = actual[1 :]
        endif

        if path =~# glob2regpat(actual)
            return !exclude
        endif
    endfor

    return true
enddef

export def GotoRoot(path: string): void
    if PathAllowed(path)
        var ret: list<string> = FindRoot(path, g:__saveroot_markers)

        if ret != null_list
            execute(g:saveroot_cd .. ' ' .. ret[0])

            b:saveroot_root = ret[0]
            b:saveroot_marker = ret[1]
        else
            if g:saveroot_nomatch == 'none'
            elseif g:saveroot_nomatch == 'current'
                execute(g:saveroot_cd .. ' ' .. fnamemodify(path, ':p:h'))
            elseif g:saveroot_nomatch[0] == '/'
                execute(g:saveroot_cd .. ' ' .. g:saveroot_match)
            endif
        endif
    endif
enddef

# vim: sw=4 tw=4 et
