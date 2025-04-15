vim9script

var threw_error: bool = false


# Check if 'path' is the same as 'marker', including any parent directories.
# Supports globbing.
export def MarkerIsPath(path: string, marker: string): bool
    var prevcwd: string = chdir(path)
    var next: string = trim(marker, '/', 2)

    # Go back a directory in 'path' for each directory in 'marker'
    while true
        var chret: string = chdir("..")

        if chret == "" || chret == "/"
            break
        endif

        var prevnext = next  # Handle absolute paths in case
        next = fnamemodify(next, ':h')

        if next == '.' || next ==# prevnext
            break
        endif
    endwhile

    var ret = false

    # Check if marker path exists relative to 'parent'
    if !empty(glob(marker, true))
        ret = true
    endif

    chdir(prevcwd)
    return ret
enddef

# Check if 'marker' is a descendant of 'path', supports globbing.
export def MarkerUnderPath(path: string, marker: string): bool
    var prevcwd: string = chdir(path)
    var ret: bool = false

    # glob() takes in consideration of trailing slash for directories
    ret = empty(glob(marker, true)) ? false : true

    chdir(prevcwd)
    return ret
enddef


# Check if 'marker' is an ancestor of 'path', supports globbing.
# 'dist' is the amount of directories away that the marker should be from the
# head of 'path'.
export def MarkerAbovePath(path: string, marker: string, dist: number): bool
    var prevcwd: string = chdir(path)
    var ret: bool = false
    var i: number = 0
    var prevpaths: list<string> = []

    # Go back a directory in 'path' until glob returns something
    while true
        var glob: list<string> = glob(marker, true, true)
        
        if !empty(glob)
            var slashed_path: string = path .. '/'
            # Check if glob matches are actually a part of 'path'
            for match in glob
                if stridx(slashed_path, '/' .. trim(match, '/') .. '/') != -1
                    ret = true
                    break
                endif
            endfor
            if ret
                # check if matched glob is at the correct distance away
                if fnamemodify(path, ":t") !=# 
                        prevpaths[min([len(prevpaths) - 1, dist])]
                    ret = false
                endif

                break
            endif
        endif

        var chret: string = chdir("..")
        prevpaths->insert(fnamemodify(chret, ":t"))
        if chret == "" || chret == "/"
            break
        endif
    endwhile

    chdir(prevcwd)
    return ret
enddef

# Print error message
export def Error(msg: string)
    if !threw_error
        echoerr msg
        threw_error = true
    endif
enddef
