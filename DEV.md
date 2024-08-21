# 🛠️ Developer documentation

This is a documentation file for developers.

## Dev environment setup

This project requires the following tools:

- [Commitlint]
- [Lefthook]

Install lefthook:

```shell
lefthook install
```

## ADRs

### 1. Why is it a plugin and not a module in `.config/nvim`?

#### Context

I have a bunch of utility functions in my Neovim config. Predicate autocmd is
my utility for lazy initialization: I often want to lazy load a plugin once
some conditions are met.

In addition to having a robust config for my daily workflow, I also want a
config structure that supports the following:

1. Removing plugins during debugging. I often remove plugins from the spec to
   understand where some functionality is coming from.
2. Setting up a new config from scratch. I sometimes set up an empty Docker
   container and want to create a minimal init that reproduces an issue.

In summary, my Neovim configuration should be composed of independent
modules that can be plugged in and out. The less strong coupling the better.

#### Considerations

The benefits of using a plugin:

- I can test the relevant code.
- I can define the plugin as a dependency of other plugin specs. It’s a
  library, so it doesn’t need setup.
- It’s more natural for this code to be kept self-contained and decoupled from
  any other module.
- It’s more straightforward to remove or add this library. We change the
  plugin spec.

The benefits of keeping this functionality as a config module:

- Updates do not require version juggling across two repos (this repo and
  Chezmoi).
- Less boilerplate. No need to keep it as a plugin.
- No dependency on Lazy or GitHub.

In both cases, we need to take care to make sure that code that depends on
predicate autocmd only does so weakly and is robust to this library being
unavailable.

Overall, I believe the benefits of a plugin outweight the drawbacks.

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
