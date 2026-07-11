local p = premake

p.tools.q3lcc = {}
local q3lcc = p.tools.q3lcc

q3lcc.dirpath = path.join(_MAIN_SCRIPT_DIR, "q3lccBin")
q3lcc.tempdirpath = path.join(q3lcc.dirpath, "temp")

-- temp directory is required for q3lcc
os.mkdir(q3lcc.tempdirpath)

q3lcc.cppflags = {}

function q3lcc.getcppflags(cfg)
    local flags = p.config.mapFlags(cfg, q3lcc.cppflags)

    return flags
end

q3lcc.defaultcflags = {
    "-Wo-lccdir=" .. q3lcc.dirpath,
    "-tempdir=" .. q3lcc.tempdirpath,
    "-DQ3_VM",
    "-S",
    "-Wf-target=bytecode",
    "-Wf-g"
}

-- q3lcc doesn't need any additional cflags at least for now
q3lcc.cflags = {}

function q3lcc.getcflags(cfg)
    local cflags = p.config.mapFlags(cfg, q3lcc.cflags)
    local flags = table.join(q3lcc.defaultcflags, cflags)

    return flags
end

-- q3lcc doesn't support c++
function q3lcc.getcxxflags(cfg)
    return {}
end

function q3lcc.getdefines(defines, cfg)
    local result = {}

    for _, define in ipairs(defines) do
        table.insert(result, '-D' .. p.esc(define))
    end

    return result
end

function q3lcc.getundefines(undefines)
    local result = {}

    for _, undefine in ipairs(undefines) do
        table.insert(result, '-U' .. p.esc(undefine))
    end

    return result
end

-- q3lcc doesn't support force includes
function q3lcc.getforceincludes(cfg)
    return {}
end

function q3lcc.getstructuredincludedirs(cfg, dirs, extdirs, frameworkdirs, includedirsafter)
    local result = {}

    for _, dir in ipairs(dirs) do
        dir = p.tools.getrelative(cfg.project, dir)

        table.insert(result, {flag = '-I', value = dir})
    end

    return result
end

function q3lcc.getincludedirs(cfg, dirs, extdirs, frameworkdirs, incdirsafter)
    local result = q3lcc.getstructuredincludedirs(cfg, dirs, extdirs, frameworkdirs, incdirsafter)

    return table.translate(result, function(kv)
        return kv.flag .. p.quoted(kv.value)
    end)
end

function q3lcc.getstructuredimplicitincludedirs(cfg, toolname, language)
    return {}
end

-- q3lcc doesn't support rpath
function q3lcc.getrunpathdirs(cfg, dirs, mode)
    return {}
end

-- q3lcc doesn't support linking libraries
function q3lcc.getldflags(cfg)
    return {}
end

function q3lcc.getLibraryDirectories(cfg)
    return {}
end

function q3lcc.getlinks(cfg, systemonly, nogroups)
    local result = p.config.getlinks(cfg, "system", "fullpath", nil, true)

    return result
end

function q3lcc.getmakesettings(cfg)
    return nil
end

q3lcc.tools = {
    cc = "lcc"
    -- q3rcc seems to be a resource packer but there is
    -- no documentation for it
}

function q3lcc.gettoolname(cfg, tool)
    local p = path.join(q3lcc.dirpath,  q3lcc.tools[tool])

    return p
end

function q3lcc.gettooloutputext(tool)
    return ".asm"
end

function q3lcc.gettoolflags(cfg, tool, input, output, depfile)
    local result = string.format('%s -o %s', input, output)

    return result
end

function q3lcc.getlinkcommand(cfg, linker, output, objects, resources, ldflags, libs)
    local linkerpath = path.join(q3lcc.dirpath, "q3asm")
    local result = string.format('%s -o %s %s %s', linkerpath, output, objects, libs)

    return result
end
