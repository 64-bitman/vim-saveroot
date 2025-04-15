vim9script

import autoload "util.vim"

# If given directory is under the paths we are configured to find the root for
def DirAllowed(path: string): bool
    if !isdirectory(path)
        return false
    endif
    for pattern in g:saveroot_paths
        if path =~# glob2regpat(pattern)
            if path[0] == '!'
                return false
            else
                return true
            endif
        endif
    endfor
    
    return false
enddef

# Find marker that is a match for path, and return it
def GetMarker(path: string): string
    var match: bool = false
    var ret: string = ""

    for marker in g:saveroot_markers
        var mtype: number = type(marker)
        var actual: string = ""

        if mtype == v:t_string
            actual = marker[1 :]

            if marker[0] == '='
                match = util.MarkerIsPath(path, actual)
            elseif marker[0] == '<'
                match = util.MarkerAbovePath(path, actual, 100)
            elseif marker[0] == '>'
                match = util.MarkerUnderPath(path, actual)
            else
                util.Error("Invalid marker: " .. marker)
                return ""
            endif

        elseif mtype == v:t_list
            # If marker is a list then first element is the marker, after are args
            actual = marker[0][1 :]

            if marker[0][0] == '<'
                # first is distance and second is the actual marker
                match = util.MarkerAbovePath(path, actual, marker[1])
            else
                util.Error("Invalid type and marker: " .. marker)
            endif
        else
            util.Error("Invalid type for marker: ", string(marker))
            return ""
        endif

        if match
            ret = actual
            break
        endif
    endfor

    return ret
enddef

# Returns absolute path of the root for the given directory.
# Returns list in format of [<root>, <marker matched>].
# If there is no match found then return value depends on g:saveroot_nomatch
export def FindRoot(start: string): list<string>
    var dir: string = start

    while true
        var marker: string = GetMarker(dir)

        if marker != ""
            return [dir, marker]
        endif

        var next: string = fnamemodify(dir, ":h")
        if dir ==# next
            break
        endif
        dir = next
    endwhile

    if g:saveroot_nomatch == "none"
        return ["", ""]
    elseif g:saveroot_nomatch == "current"
        return [start, ""]
    elseif g:saveroot_nomatch[0] == "/"
        return [g:saveroot_nomatch, ""]
    else
        util.Error("Invalid value for g:saveroot_nomatch -> " .. 
            g:saveroot_nomatch)
        return ["", ""]
    endif
enddef

export def GotoRoot(): void
    if &buftype != ""
        b:saveroot_marker = ""
        b:saveroot_root = ""
        return
    endif

    var dir: string = expand("%:p:h")
    var root: string = ""
    var marker: string = ""

    if DirAllowed(dir)
        [root, marker] = FindRoot(dir)

        if root != ""
            b:saveroot_marker = marker
            b:saveroot_root = root

            execute("lcd " .. root)
        endif
    endif
enddef

# vim: sw=4 tw=4 et
