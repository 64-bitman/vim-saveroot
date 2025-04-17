vim9script

import autoload 'util.vim'

var lines: list<string> = null_list

def GetFile(): void
    if lines == null_list
        lines = readfile(g:saveroot_dir .. '/saveroot.txt')
        sort(lines)
    endif
enddef

def UnloadFile(): void
    lines = null_list
enddef

export def ReloadFile(): void
    UnloadFile()
    GetFile()
enddef

export def GetSavedMarkers(): list<string>
    GetFile()
    return lines
enddef

def WriteFile(l: list<string>, overwrite: bool): void
    if writefile(l, g:saveroot_dir .. '/saveroot.txt',
            (overwrite ? '' : 'a')) == -1
        util.Msg("Failed writing to database file")
    endif
enddef

def MarkerExists(marker: string): bool
    GetFile()

    return index(lines, marker) != -1
enddef

def CleanDuplicates(): void
    GetFile()
    uniq(lines)

    WriteFile(lines, true)
enddef

export def SaveMarker(marker: string): bool
    if marker[0] !~# '[=<>]'
        util.Msg("Invalid marker: " .. marker)
        return false
    endif

    if MarkerExists(marker)
        util.Msg("Marker already saved")
        return false
    endif

    add(lines, marker)
    WriteFile([marker], false)
    CleanDuplicates()
    return true
enddef

export def RemoveMarker(marker: string): bool
    if !MarkerExists(marker)
        util.Msg("Marker is not already saved")
        return false
    endif

    remove(lines, index(lines, marker))
    WriteFile(lines, true)
    CleanDuplicates()
    return true
enddef
