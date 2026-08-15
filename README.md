# Sticky Keys Indicator

A theme-aware sticky-modifier indicator for the Omarchy Quattro bar. It listens
to `keyd` layer changes and displays badges for latched Control, Alt, Shift, and
Super layers. Badges remain hidden while no sticky layer is active.

## Requirements

- Omarchy Quattro
- `keyd` running with a socket readable by the desktop user
- Modifier layers named `control`, `alt`, `shift`, and `meta`

The common sticky-key configuration uses bindings such as:

```ini
[main]
control = oneshot(control)
meta = oneshot(meta)
shift = oneshot(shift)
leftalt = oneshot(alt)
```

## Install

When this folder is published as a Git repository:

```sh
omarchy plugin add https://github.com/scottpruett/omarchy-sticky-keys.git --enable
```

## Configure

```sh
omarchy bar move io.github.scottpruett.sticky-keys --section center
```

## Remove

```sh
omarchy plugin remove io.github.scottpruett.sticky-keys
```

## Security

The plugin runs `keyd listen` as the current desktop user. It does not request
elevated privileges, alter key bindings, or transmit data.
