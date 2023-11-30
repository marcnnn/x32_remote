# X32Remote

[![Hex.pm Version](https://img.shields.io/hexpm/v/x32_remote.svg?style=flat-square)](https://hex.pm/packages/x32_remote)

X32Remote is a library for controlling Behringer X32 and M32 mixing consoles.

By pointing this library at the IP address of your X32 console hardware, you can control most of the mixing variables, including fader levels, mute/solo status, output routing, and more.

## Installation

X32Remote requires Elixir v1.14.  To use it, add `:x32_remote` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:x32_remote, "~> 0.1.0"}
  ]
end
```

To run X32Remote, you'll need to point it at your mixer's IP address.  The easiest way is to set the `X32R_IP` environment variable, e.g. `export X32R_IP=x.x.x.x` in your shell.  See the "Mixer IP address" section in the `X32Remote` module documentation for details.

## Usage

Here's an example of using X32Remote to control an X32 Rack digital mixer, where channels 17 and 18 are a linked stereo pair:

```elixir
iex> X32Remote.Mixer.get_panning("ch/17")
0.0
iex> X32Remote.Mixer.get_panning("ch/18")
1.0
iex> X32Remote.Mixer.muted?("ch/17")
false
iex> X32Remote.Mixer.get_fader("ch/17")
0.7497556209564209
iex> X32Remote.Mixer.set_fader("ch/18", 0.5)
:ok
iex> X32Remote.Mixer.get_fader("ch/17")
0.4995112419128418
```

## Documentation

Full documentation can be found at <https://hexdocs.pm/x32_remote>.

The X32 command set is huge, and this library only implements a subset of it.  If X32Remote does not (yet) do what you need it to do, you may want to look at the [unofficial X32 OSC protocol document](https://drive.google.com/file/d/1Snbwx3m6us6L1qeP1_pD6s8hbJpIpD0a/view) courtesy of Patrick-Gilles Maillot, who also provides [tools to work with X32 hardware](https://sites.google.com/site/patrickmaillot/x32).  (Thanks Patrick-Gilles!)

## Legal stuff

Copyright © 2023, Adrian Irving-Beer.

X32Remote is released under the [MIT license](https://github.com/wisq/x32_remote/blob/main/LICENSE) and is provided with **no warranty**.  I'm not responsible if you set every fader to max volume and blow out your speakers.

X32Remote is not developed by Behringer, and is in no way associated with them.  All trademarks are the property of their respective owners.
