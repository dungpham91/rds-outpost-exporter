# golang:1.20.6-alpine
FROM golang@sha256:6f5fa9577b686d2c069e3d84aa640cea12b33735b1b9f0ec5d08145b1673b603 as build
WORKDIR /app
COPY . .
RUN env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /rds_outpost_exporter ./ && \
    chmod +x /rds_outpost_exporter

# alpine:3.18.2
FROM alpine@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a
COPY --from=build ["/rds_outpost_exporter", "/bin/" ]
# Check version ca-certificates: https://pkgs.alpinelinux.org/package/edge/main/x86/ca-certificates
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates=20230506-r0 && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

EXPOSE 9999
ENTRYPOINT [ "/bin/rds_outpost_exporter", "--config.file=/etc/rds_outpost_exporter/config.yml" ]
