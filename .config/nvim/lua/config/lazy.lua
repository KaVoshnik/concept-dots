-- ~/.config/nvim/lua/config/lazy.lua
-- bootstraps lazy.nvim and loads everything under lua/plugins/

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    change_detection = { notify = false },
    checker = { enabled = true, notify = false },
    install = { colorscheme = { "tokyonight" } },
})
