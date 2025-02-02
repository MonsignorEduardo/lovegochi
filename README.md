# Edugochi

Edugochi

## Server

### Server Overview

This server is built with Elysia and handles location data using getLocationUser and setLocationUser from the Bun-based key-value store in BunSqliteKeyValue.

### Installation and Usage

- 1 Install dependencies:

```bash
bun install
```

- 2 Start the server:

```bash
bun start
```

The server runs by default on port 3000. Check [index.ts](src/index.ts) for the main entrypoint.

### Docker

A [Dockerfile](Dockerfile) is provided:

```bash
docker build -t server .
docker run -p 3000:3000 server
```

Use [.dockerignore](.dockerignore) to exclude unwanted files from your container. For environment options, see tsconfig.json and the Bun runtime docs.
