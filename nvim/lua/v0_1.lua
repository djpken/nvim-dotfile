-- do not use vim.version.cmp as it seems buggy
    local version = vim.version()
    if version.major * 100 + version.minor < 10 then
        Kk.plugins["indent-blankline"].version = "3.5"
        Kk.plugins.neogit.tag = "v0.0.1"
    end