<!-- markdownlint-disable MD013 MD033 MD041 -->

Predicate-autocmd is a Neovim plugin that provides a Lua library for creating predicate-based autocmds.
This is useful for lazy loading when we want to wait for specific events to occur.

## ⚡️ Requirements

- Neovim 0.10+

## 📦 Installation

Install the plugin with your preferred package manager, such as [Lazy]:

```lua
{
  [1] = "gregorias/predicate-autocmd.nvim",
  version = "1.0"
}
```

## 🚀 Usage

In your Neovim configuration, to, for example, run lazily run a setup function only once we are in a Lua file, you can run:

```lua
require"predicate-autocmd".create_autocmd(
  { "and", { "FileType", pattern="lua" }, { "User", pattern="VeryLazy" } },
  setup
)
```

## 🔗 See also

- [Coerce](https://github.com/gregorias/coerce.nvim) — My Neovim plugin for case coercion.
- [Toggle](https://github.com/gregorias/toggle.nvim) — My Neovim plugin for quick option switching.

[Lazy]: https://github.com/folke/lazy.nvim
