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
  config = function()
    require("headhunter").setup()
  end,
}
```

Customize inline with lazy.nvim if you need different bindings:

```lua
{
  "StackInTheWild/headhunter.nvim",
  config = function()
    require("headhunter").setup({
      enabled = true,         -- set to false to opt out entirely
      keys = {
        next = "]c",         -- remap `]g` → `]c`
        prev = "[c",          -- remap `[g` → `[c`
        quickfix = false,     -- disable the quickfix opener
        -- omit other keys to keep their defaults
      },
    })
  end,
}
```

---

### Default Keymaps

Headhunter ships with the following `keys` defaults:

```lua
keys = {
  prev = "[g",
  next = "]g",
  take_head = "<leader>gh",
  take_origin = "<leader>go",
  take_both = "<leader>gb",
  quickfix = "<leader>gq",
}
```

These expand to normal-mode commands:

- `keys.prev` (`[g`) → `:HeadhunterPrevious`
- `keys.next` (`]g`) → `:HeadhunterNext`
- `keys.take_head` (`<leader>gh`) → `:HeadhunterTakeHead`
- `keys.take_origin` (`<leader>go`) → `:HeadhunterTakeOrigin`
- `keys.take_both` (`<leader>gb`) → `:HeadhunterTakeBoth`
- `keys.quickfix` (`<leader>gq`) → `:HeadhunterQuickfix`

To disable every keybindings, set `keys = false`.

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
