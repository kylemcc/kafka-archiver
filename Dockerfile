FROM golang:alpine as builder

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go
ENV CGO_ENABLED 0

RUN set -x \
	apk add --no-cache ca-certificates \
	&& apk add --no-cache --virtual .build-deps \
			git \
			gcc \
			libc-dev \
			libgcc 

COPY . /app
WORKDIR /app

RUN set -x \
		&& go build \
		&& mv kafka-archiver /usr/bin/kafka-archiver \
		&& echo "Build complete."

FROM alpine:latest

COPY --from=builder /usr/bin/kafka-archiver /usr/bin/kafka-archiver
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

ENTRYPOINT ["kafka-archiver"]
