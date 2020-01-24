# docker-graalvm

Alpine based docker image using GraalVM as JVM.

Download from https://hub.docker.com/r/lustefaniak/graalvm/tags

It uses versioning based on: `<javaVersion>-<graalVersion>-<gitSha>`. Merges to master update `<javaVersion>-<graalVersion>` and `<javaVersion>` images.

```
docker pull lustefaniak/graalvm:11
docker pull lustefaniak/graalvm:11-19.3.1
docker pull lustefaniak/graalvm:11-19.3.1-<gitSha>

docker pull lustefaniak/graalvm:8
docker pull lustefaniak/graalvm:8-19.3.1
docker pull lustefaniak/graalvm:8-19.3.1-<gitSha>
```

## Building:
Github Actions are used: https://github.com/lustefaniak/docker-graalvm/actions
