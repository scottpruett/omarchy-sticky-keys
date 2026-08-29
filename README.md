# Sticky Keys Indicator

A theme-aware sticky-modifier indicator for the Omarchy Quattro bar. It listens
to `keyd` layer changes and displays badges for latched Control, Alt, Shift, and
Super layers. Badges remain hidden while no sticky layer is active.

Double-tapping a configured modifier latches it until it is tapped again; the
badge remains visible for the full latched state.

## Requirements

- Omarchy Quattro
- `keyd` installed and running, with its socket readable by the desktop user
  (your user must be in the `keyd` group — check with `groups`)
- Modifier layers named `control`, `alt`, `shift`, and `meta`, each latched by
  a double-tap

**This last requirement is a system-level `keyd` config, not something the
plugin installs for you.** It lives in `/etc/keyd/`, outside this repo, so it
does not travel with `omarchy plugin add` — you must add it by hand on every
machine you install this plugin on. If the badges never appear no matter what
you tap, this is almost always why: `keyd listen` is running but never emits
a matching layer name.

Merge the following into your `/etc/keyd/*.conf` (add these sections; don't
overwrite bindings you already have for other keys/devices):

```ini
[main]
control = oneshot(control)
meta = oneshot(meta)
shift = oneshot(shift)
leftalt = oneshot(alt)

[control]
control = toggle(control)

[meta]
meta = toggle(meta)

[shift]
shift = toggle(shift)

[alt]
leftalt = toggle(alt)
```

The `[main]` block makes a single tap of a modifier a one-shot (normal
modifier-then-key behavior); a second tap while already in that layer enters
the matching `[control]`/`[meta]`/`[shift]`/`[alt]` block, whose `toggle(...)`
binding is what latches the layer — and is what this plugin's badges reflect.

After editing, apply it with:

```sh
sudo systemctl restart keyd
```

Then verify the events are actually firing before checking the bar:

```sh
keyd listen
# double-tap a modifier and confirm you see lines like +control / -control
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
