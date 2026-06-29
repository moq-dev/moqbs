# moqbs (deprecated)

This repository is **deprecated** and no longer maintained.

`moqbs` was a fork of [OBS Studio](https://obsproject.com) that carried patches
to add [Media over QUIC (MoQ)](https://moq.dev) support directly into the
application. Maintaining a full OBS fork just to ship MoQ was a lot of overhead,
and it's no longer necessary.

## Use the plugin instead

MoQ support now lives in the standalone **moq-obs** plugin:

👉 **https://github.com/moq-dev/obs**

The plugin adds a **Dock** to OBS Studio that you can use to publish a MoQ
broadcast, with no custom OBS build required. Install the plugin into a stock copy
of OBS and you're ready to go.

## Caveats

There's still **no first-class support** for MoQ publishing in OBS (i.e. it's
not a real output you can wire into the normal streaming/recording pipeline).
The Dock is a separate path bolted on alongside it. That said, it works well
enough for publishing today, and it's far easier to maintain than a whole fork.

If you were relying on `moqbs`, switch to the plugin above.
