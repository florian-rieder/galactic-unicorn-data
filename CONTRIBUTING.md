# Contributing

Thanks for contributing to the Galactic Unicorn data partition.

## How to contribute

1. Fork the repo and create a branch for your change.
2. Open a pull request with a short description of what the change does and why.
3. We'll review it and merge when it looks good.

## Code style

We follow the spirit of the [Lua Style Guide](http://lua-users.org/wiki/LuaStyleGuide). Match what's already in the repo when in doubt.

Consistency within a file matters more than rigid rules across the whole project.

### Naming

- `snake_case` for variables and functions (`ball_position`, `enable_flashes()`)
- `SCREAMING_SNAKE_CASE` for constants (`MAX_HEALTH`, `PLAYER_COLOR`)
- `PascalCase` for module/class tables that you instantiate into objects (`Vector2`, then `Vector2.new(...)`)

### General

- Prefer `local` over globals.
- Two-space indentation (see `.editorconfig`).
- LF line endings, with a final newline at end of file. EditorConfig handles this if your editor supports it.

### Comments

- Use `--` with a space after it
- Comment non-obvious logic and design decisions; don't narrate what the code already says.
