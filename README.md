# Development Container Features

'Features' are self-contained units of installation code and development container configuration. Features are designed to install atop a wide-range of base container images.

### `reflex`

Reflex is a small tool to watch a directory and rerun a command when certain files change.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/brokeyourbike/devcontainer-features/reflex:0": {}
    }
}
```

## Authors
- [Ivan Stasiuk](https://github.com/brokeyourbike) | [Twitter](https://twitter.com/brokeyourbike) | [LinkedIn](https://www.linkedin.com/in/brokeyourbike) | [stasi.uk](https://stasi.uk)

## License
[MIT License](https://github.com/brokeyourbike/devcontainer-features/blob/main/LICENSE)
