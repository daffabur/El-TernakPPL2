FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o backend-el-ternak .


FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/backend-el-ternak .

EXPOSE 11222

CMD ["./backend-el-ternak"]
