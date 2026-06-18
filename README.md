# Galactic Unicorn Data

Stock files for the Galactic Unicorn’s LittleFS `/data` partition: system scripts (`/system/`), shared libs (`/lib/`), cartridges, assets, and the rest of the built-in content.

These files are used by the [Web SDK](https://github.com/florian-rieder/galactic-unicorn-web-sdk) and firmware for the GameLab Galactic Unicorn

## How to write programs for the Galactic Unicorn

Check out the [Galactic Unicorn API Docs](https://florian-rieder.github.io/galactic-unicorn-web-sdk/docs/api.html)

Other useful references:

- [Programming in Lua (1st edition)](https://www.lua.org/pil/contents.html)
- [Lua 5.3 Reference Manual](https://www.lua.org/manual/5.3/manual.html)
- [Lua Metamethods Cheatsheet](https://gist.github.com/oatmealine/655c9e64599d0f0dd47687c1186de99f)

## How to create a cartridge

1. Create a directory inside `/data` for your cartridge, e.g. `/data/my-project/`
2. Create a `manifest.lua` file inside it with metadata about the cartridge:

`/data/my-project/manifest.lua`:

```lua
return {
    title = "The name of your cartridge",
    color = "rgb(255, 255, 255)",
    author = "You",
}
```

1. Create a `main.lua` file. This file will be run as the entrypoint of your program.

`/data/my-project/main.lua`:

```lua
local H = SCREEN_H - 1
local W = SCREEN_W - 1
local COLOR = rgb(157, 0, 255)

function draw()
  clear()

  set_pixel_f(
    math.sin(get_time()) * W / 2 + W / 2,
    math.cos(get_time()) * H / 2 + H / 2,
    COLOR
  )
end
```

## How to contribute

Check out this [guide](CONTRIBUTING.md)

## Release

```
git tag v1.0.0
git push origin v1.0.0

```
