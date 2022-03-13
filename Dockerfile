FROM ubuntu:focal as builder

WORKDIR /usr

COPY local/engine.json ./engine.json

RUN apt-get update \
  && apt-get install -y curl \
    jq \
  && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.44.2 \
  && VERSION="$(golangci-lint --version | sed 's/.*version //' | sed 's/ built.*//')" \
  && jq --arg version "$VERSION" '.version = $version' > /engine.json < ./engine.json

FROM golang:1.17-alpine as golangci-builder

COPY --from=builder /usr/bin/golangci-lint /usr/bin/golangci-lint

LABEL maintainer="Megabyte Labs <help@megabyte.space>"
LABEL org.opencontainers.image.authors="Brian Zalewski <brian@megabyte.space>"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.description=""
LABEL org.opencontainers.image.documentation="https://github.com/ProfessorManhattan/codeclimate-golangci-lint/blob/master/README.md"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.source="https://gitlab.com/megabyte-labs/docker/codeclimate/eslint.git"
LABEL org.opencontainers.image.url="https://megabyte.space"
LABEL org.opencontainers.image.vendor="Megabyte Labs"
LABEL org.opencontainers.image.version=$VERSION
LABEL space.megabyte.type="code-climate"

FROM golangci-builder AS golangci-lint

ENTRYPOINT ["golangci-lint"]
CMD ["--version"]
LABEL space.megabyte.type="code-climate-standalone"

FROM golangci-builder AS codeclimate-golangci-lint

COPY --from=builder /engine.json /engine.json

USER app

VOLUME ["/code"]
WORKDIR /code
