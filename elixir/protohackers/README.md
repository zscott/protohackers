# Protohackers

## Description
Elixir application that runs a set of servers that implement solutions to the problems at protohackers.com.

## Build
```bash
mix deps.get
mix compile
```

## Run
```bash
mix run --no-halt
```

## Test
```bash
mix test
```

## Release
```bash
mix release
```

## Docker Build
```bash
docker buildx build -t protohackers:latest .
```

## Docker Run (as a daemon)
```bash
docker run -d -p 11000-11099:11000-11099/tcp protohackers:latest
```

## Docker Run (in the foreground)
```bash
docker run --rm -p 11000-11099:11000-11099/tcp protohackers:latest
```




