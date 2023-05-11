# Development Container Features

[![tests](https://github.com/brokeyourbike/devcontainer-features/actions/workflows/test.yaml/badge.svg)](https://github.com/brokeyourbike/devcontainer-features/actions/workflows/test.yaml)

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

### `staticcheck`

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/brokeyourbike/devcontainer-features/staticcheck:0": {}
    }
}
```

## Authors
- [Ivan Stasiuk](https://github.com/brokeyourbike) | [Twitter](https://twitter.com/brokeyourbike) | [LinkedIn](https://www.linkedin.com/in/brokeyourbike) | [stasi.uk](https://stasi.uk)

## License
[MIT License](https://github.com/brokeyourbike/devcontainer-features/blob/main/LICENSE)
