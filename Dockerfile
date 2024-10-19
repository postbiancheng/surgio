FROM node:18-alpine

COPY docker-entrypoint.sh gateway.js /

# init surgio and rules
RUN  apk -u add bash grep && \
     chmod +x /docker-entrypoint.sh && \
     npm init surgio-store surgio && \
     cd /surgio && npm install surgio@latest && npm install @surgio/gateway@latest && \
     npm cache clean --force

RUN apk update && apk add openssh-client && apk add --no-cache git

# Persistent config file
ENTRYPOINT [ "/docker-entrypoint.sh" ]
