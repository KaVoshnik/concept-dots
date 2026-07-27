-- ~/.config/nvim/lua/plugins/colorscheme.lua
-- tokyonight, retinted to match the "concept" palette (see .config/hypr/colors.conf)

return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
            comments = { italic = true },
            keywords = { italic = false },
            sidebars = "dark",
            floats = "dark",
        },
        on_colors = function(colors)
            colors.bg = "#101014"
            colors.bg_dark = "#0a0a0c"
            colors.bg_float = "#0a0a0c"
            colors.bg_highlight = "#1c1c24"
            colors.bg_popup = "#0a0a0c"
            colors.bg_sidebar = "#0a0a0c"
            colors.bg_statusline = "#0a0a0c"
            colors.bg_visual = "#272733"
            colors.border = "#272733"

            colors.fg = "#e8e8ec"
            colors.fg_dark = "#a3a3b0"
            colors.fg_gutter = "#47475c"
            colors.comment = "#72758c"

            colors.blue = "#8a90f0"
            colors.blue1 = "#8a90f0"
            colors.blue2 = "#35a8b4"
            colors.cyan = "#35a8b4"
            colors.purple = "#8a90f0"
            colors.magenta = "#e8a0c8"
            colors.magenta2 = "#e8a0c8"
            colors.red = "#f0645c"
            colors.red1 = "#f0645c"
            colors.orange = "#f0a878"
            colors.yellow = "#e8c48a"
            colors.green = "#7cbd82"
            colors.green1 = "#7cbd82"
            colors.teal = "#35a8b4"

            colors.terminal_black = "#1c1c24"
        end,
    },
    config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight")
    end,
}
