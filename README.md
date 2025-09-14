# headhunter.nvim

A Neovim plugin that helps you quickly jump to conflicts (e.g., merge conflicts) inside your buffer using customizable keybindings.

---

## ✨ Features
- Jump directly to the **next** conflict in your file.
- Minimal and fast — pure Lua implementation.
- Fully customizable keybindings.

---

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "davidlacasse/headhunter.nvim",
  config = function()
    require("headhunter").setup({
      -- Default keymaps
      keymaps = {
        next = "]g",   -- Jump to next conflict
      },
    })
  end
}

