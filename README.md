# Development Container Features

'Features' are self-contained units of installation code and development container configuration. Features are designed to install atop a wide-range of base container images.

### `reflex`

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/brokeyourbike/devcontainer-features/reflex:0": {}
    }
}
```