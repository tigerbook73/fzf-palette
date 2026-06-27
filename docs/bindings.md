# Bindings

`src/fzf-palette.bash` currently binds `Ctrl-G` to `fzf_palette`:

```bash
bind -x '"\C-g": fzf_palette'
```

Keep bindings centralized in the entrypoint until the command surface grows.
When adding new handlers, prefer dispatching from `fzf_palette()` based on the
first word of `READLINE_LINE`.
