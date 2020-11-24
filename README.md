# docker-graalvm

Alpine based docker image using GraalVM as JVM.

Download from https://hub.docker.com/r/lustefaniak/graalvm/tags

It uses versioning based on: `<javaVersion>-<graalVersion>-<gitSha>`. Merges to master update `<javaVersion>-<graalVersion>` and `<javaVersion>` images.

```bash
docker pull lustefaniak/graalvm:11
docker pull lustefaniak/graalvm:11-20.3.0
docker pull lustefaniak/graalvm:11-20.3.0-<gitSha>
```

## Building

Github Actions are used: https://github.com/lustefaniak/docker-graalvm/actions
