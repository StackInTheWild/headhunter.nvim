vim.cmd("set rtp+=.")
vim.cmd("set rtp+=../lua")
vim.cmd("packadd plenary.nvim")

require("headhunter").setup()
