Kk.colorschemes = {
    ['default-light'] = {name = 'default', background = 'light'},
    ['default-dark'] = {name = 'default', background = 'dark'},
    ["ayu-light"] = {
        name = "ayu",
        setup = function() vim.g.ayucolor = "light" end,
        background = "light"
    },
    ["ayu-mirage"] = {
        name = "ayu",
        setup = function() vim.g.ayucolor = "mirage" end,
        background = "dark"
    },
    ["ayu-dark"] = {
        name = "ayu",
        setup = function() vim.g.ayucolor = "dark" end,
        background = "dark"
    },
    ["github-dark"] = {name = "github_dark", background = "dark"},
    ["github-light"] = {name = "github_light", background = "light"},
    ["github-dark-dimmed"] = {name = "github_dark_dimmed", background = "dark"},
    ["github-dark-high-contrast"] = {
        name = "github_dark_high_contrast",
        background = "dark"
    },
    ["github-light-high-contrast"] = {
        name = "github_light_high_contrast",
        background = "light"
    },
    ["gruvbox-dark"] = {
        name = "gruvbox",
        setup = {
            italic = {strings = true, operators = false, comments = true},
            contrast = "hard"
        },
        background = "dark"
    },
    ["gruvbox-light"] = {
        name = "gruvbox",
        setup = {
            italic = {strings = true, operators = false, comments = true},
            contrast = "hard"
        },
        background = "light"
    },
    ["kanagawa-wave"] = {name = "kanagawa", theme = "wave", background = "dark"},
    ["kanagawa-dragon"] = {name = "kanagawa", theme = "dragon", background = "dark"},
    ["kanagawa-lotus"] = {name = "kanagawa", theme = "lotus", background = "light"},
    ['nightfox'] = {name = "nightfox", background = "dark"},
    ["nightfox-carbon"] = {name = "carbonfox", background = "dark"},
    ["nightfox-day"] = {name = "dayfox", background = "light"},
    ["nightfox-dawn"] = {name = "dawnfox", background = "light"},
    ["nightfox-dusk"] = {name = "duskfox", background = "dark"},
    ["nightfox-nord"] = {name = "nordfox", background = "dark"},
    ["nightfox-tera"] = {name = "terafox", background = "dark"},
    ['tokyonight'] = {
        name = "tokyonight",
        setup = {
            style = "moon",
            styles = {comments = {italic = true}, keywords = {italic = false}}
        },
        background = "dark"
    },
    ['onedark-dark'] = {name = 'onedark', background = 'dark', setup = {
        style = 'dark'
    }},
    ['onedark-darker'] = {
        name = 'onedark',
        background = 'dark',
        setup = {style = 'darker'}
    },
    ['onedark-cool'] = {name = 'onedark', background = 'dark', setup = {
        style = 'cool'
    }},
    ['onedark-deep'] = {name = 'onedark', background = 'dark', setup = {
        style = 'deep'
    }},
    ['onedark-warm'] = {name = 'onedark', background = 'dark', setup = {
        style = 'warm'
    }},
    ['onedark-warmer'] = {
        name = 'onedark',
        background = 'dark',
        setup = {style = 'warmer'}
    },
    ['gruvbox-material-hard'] = {
        name = 'gruvbox-material',
        background = 'dark',
        setup =function()
            vim.g.gruvbox_material_enable_italic = true
            vim.g.gruvbox_material_background = ''
        end 
    },
    ['gruvbox-material-medium'] = {
        name = 'gruvbox-material',
        background = 'dark',
        setup =function()
            vim.g.gruvbox_material_enable_italic = true
            vim.g.gruvbox_material_background = 'medium'
        end 
    },
    ['gruvbox-material-soft'] = {
        name = 'gruvbox-material',
        background = 'dark',
        setup =function()
            vim.g.gruvbox_material_enable_italic = true
            vim.g.gruvbox_material_background = 'soft'
        end 
    }
}
