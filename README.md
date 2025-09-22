# headhunter.nvim

A Neovim plugin that helps you quickly **navigate and resolve merge conflicts** with customizable keybindings.

---

## ✨ Features

- Jump directly to the **next or previous conflict** in your repository.
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
  lazy = true,
  opts = {
     register_keymaps = false, -- Disable internal keymaps if using lazy.nvim keys
  },
  keys = {
    { "]g", ":HeadhunterNext", desc = "Go to next Conflict" },
    { "[g", ":HeadhunterPrevious", desc = "Go to previous Conflict" },
    { "<leader>gh", ":HeadhunterTakeHead", desc = "Take changes from HEAD" },
    { "<leader>go", ":HeadhunterTakeOrigin", desc = "Take changes from origin" },
    { "<leader>gb", ":HeadhunterTakeBoth", desc = "Take both changes" },
  },
}
```

---

## 🚀 Usage

Assuming you are using the keybindings from above:

### Navigate Conflicts

- `[g` → Jump to the previous conflict.
- `]g` → Jump to the next conflict.

### Resolve Conflicts

Given a conflict block like this:

```
<<<<<<< HEAD
my changes
=======
their changes
>>>>>>> branch
```

| Action      | Keybinding   | Command                 | Resulting Text in Buffer        |
| ----------- | ------------ | ----------------------- | ------------------------------- |
| Take HEAD   | `<leader>gh` | `:HeadhunterTakeHead`   | `my changes`                    |
| Take origin | `<leader>go` | `:HeadhunterTakeOrigin` | `their changes`                 |
| Take both   | `<leader>gb` | `:HeadhunterTakeBoth`   | `my changes`<br>`their changes` |

_Notes:_

- Take HEAD keeps only your local changes.
- Take origin keeps only the incoming changes from the other branch.
- Take both concatenates your changes with the incoming changes, in that order.

---

## 🧪 Testing

We use plenary.nvim

```sh
make test
```
