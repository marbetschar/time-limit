# Timer

## Building and Installation

You'll need the following dependencies:
* gtk+-3.0
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

```bash
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`, then execute with `name.betschart.marco.timer`

```bash
ninja install
name.betschart.marco.timer`
```
