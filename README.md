# Bufmenu.nvim
A simple plugin that allows for quicker buffer management with a little visual menu. Keep in mind that this is my first plugin so while I did try to make it decent it is probably not as good as the alternatives.
![There it is!](https://www.github.com/SneezNoodle/bufmenu.nvim/blob/main/images/thereitis.png?raw=true)

## Installation
Can be installed either using a plugin manager, such as [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "sneeznoodle/bufmenu.nvim",
    -- Optional, adds filetype icons
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Example options
    opts = {
        view = {
            width = 0.4,
            height = 0.35,
            relative_to_window = false,
            border = "rounded",
        },
    },
    -- Or if you don't want to change anything
    config = true,
}
```

Or simply cloned to a location on your runtime path.

## Everything is purple
The default buffer name highlight group is "String", and with the default neovim colorscheme this is the same color as default floating window background. This can be fixed by changing the floating window background color with winhighlight, or by changing the highlight group for the buffer name:

```lua
opts = {
    view = {
        winhighlight = {
            "NormalFloat:Normal",
        }
    },
    -- OR
    menu = {
        highlights = {
            buffer_name = "MoreMsg",
        }
    }
}
```

