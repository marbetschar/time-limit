# <img src="data/icons/128/com.github.marbetschar.time-limit.svg?raw=true" width="42" height="42" align="left" /> Time Limit

A simple and beautiful timer app for elementary OS

<img src="data/screenshots/Dark-Light-Accent-Variants-Background.png?raw=true" />

## Usage

Drag the blue arrow to set a timer. Release to start and click to pause.
When the time is up, a notification will show up with a nice sound.

### Keyboard shortcuts

- `Space` for pause/play
- `Esc` to reset

## Installation

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.marbetschar.time-limit)

## Building

You'll need the following dependencies:
* glib-2.0
* gtk+-3.0
* granite >=0.5
* libhandy-1-dev >= 0.83.0
* meson
* unity
* valac

Simply run

```
./install.sh
```

The install script configures the build environment, compiles the app and installs it.
The app is started automatically after successful installation.

## Acknowledgements

- Designed by [Michael Villar](https://github.com/michaelvillar/timer-app).
