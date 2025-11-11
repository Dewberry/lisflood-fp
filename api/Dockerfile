FROM golang:1.23.6-alpine3.21 AS dev

RUN go install github.com/githubnemo/CompileDaemon@v1.4.0

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

WORKDIR /api
COPY . .

RUN go mod tidy && go build main.go

ENTRYPOINT CompileDaemon --build="go build main.go" --command=./main

FROM golang:1.23-alpine AS prod

COPY --from=dev /api/main .

CMD [ "./main" ]
