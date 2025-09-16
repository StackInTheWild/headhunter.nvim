# headhunter.nvim

A Neovim plugin that helps you quickly **navigate and resolve merge conflicts** with customizable keybindings.

---

## ✨ Features

- Jump directly to the **next conflict** in your repository.
- Quickly resolve conflicts using simple keybindings:
  - **Take HEAD** (`<<<<<<< HEAD`) – keeps your local changes.  
  - **Take origin** (`>>>>>>> ...`) – keeps the incoming changes.  
  - **Take both** – keeps both changes, concatenated in order.  
- Minimal and fast — pure Lua implementation with no external dependencies.  
- Fully customizable keybindings to fit your workflow.

---

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "StackInTheWild/headhunter.nvim",
  config = function()
    require("headhunter").setup({
      -- Default keymaps (customize as needed)
      keymaps = {
        next_conflict = "]g",
        take_head    = "<leader>gh",
        take_origin  = "<leader>go",
        take_both    = "<leader>gb",
      },
    })
  end
}
```

---

## 🚀 Usage

### Navigate Conflicts

- `]g` → Jump to the next conflict in your file.

### Resolve Conflicts

Given a conflict block like this:

```
<<<<<<< HEAD
my changes
=======
their changes
>>>>>>> branch
```


| Action      | Keybinding   | Resulting Text in Buffer        |
| ----------- | ------------ | ------------------------------- |
| Take HEAD   | `<leader>gh` | `my changes`                    |
| Take origin | `<leader>go` | `their changes`                 |
| Take both   | `<leader>gb` | `my changes`<br>`their changes` |


*Notes:*
- Take HEAD keeps only your local changes.
- Take origin keeps only the incoming changes from the other branch.
- Take both concatenates your changes with the incoming changes, in that order.

---

## 🧪 Testing

We use plenary.nvim

```sh
make test
```
