vim9script

var threw_error: bool = false
export var pathsep: string = has('win32') ? '\' : '/'

# Check if 'path' is the same as 'marker', including any parent directories.
export def MarkerIsPath(path: string, marker: string): bool
    var rgx: string = (marker[0] == pathsep ? '' : '*') ..  trim(marker, pathsep, 2)
    return path =~# glob2regpat(rgx)
enddef

# Check if 'marker' is a descendant of 'path'
export def MarkerUnderPath(path: string, marker: string): bool
     return !empty(globpath(escape(path, '?*[]'), marker, true, true))
enddef

# Check if 'marker' is an ancestor of 'path'
export def MarkerAbovePath(path: string, marker: string): bool
    return path =~# glob2regpat((marker[0] == pathsep ? '' : '*' .. pathsep)
        .. marker .. pathsep .. '*')
enddef

# Print error message
export def Error(msg: string)
    if !threw_error
        echoerr msg
        threw_error = true
    endif
enddef

export def Msg(msg: string)
    echom msg
enddef

# vim: sw=4 tw=4 et
