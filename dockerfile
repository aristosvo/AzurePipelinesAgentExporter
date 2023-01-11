FROM golang:1.19 AS builder

WORKDIR /usr/src/app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN mkdir -p /usr/local/bin
RUN go build -v -o /usr/local/bin/ ./...
RUN ls /usr/local/bin/

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN mkdir -p /usr/local/bin
COPY --from=builder /usr/local/bin/AzurePipelinesAgentExporter /usr/local/bin/AzurePipelinesAgentExporter
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/AzurePipelinesAgentExporter"]