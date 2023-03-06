FROM node:alpine as builder
WORKDIR /usr/app
ENV TINI_VERSION v0.19.0
RUN wget -c https://github.com/rearc/quest/archive/refs/tags/2.0.0.tar.gz -O - | tar -xz --strip-components=1
RUN apk add --no-cache python3 make g++ dumb-init
RUN npm install

FROM node:alpine
COPY --from=builder /usr/app .
COPY --from=builder /usr/bin/dumb-init /usr/bin/
EXPOSE 80
USER node
ENTRYPOINT ["dumb-init", "--"]
# Run node under dumb-init
CMD ["node", "src/000.js"] 