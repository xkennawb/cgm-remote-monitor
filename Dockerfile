FROM node:20-alpine

LABEL maintainer="Nightscout Contributors"

RUN mkdir -p /opt/app
ADD . /opt/app
WORKDIR /opt/app
RUN chown -R node:node /opt/app
USER node

RUN npm install --legacy-peer-deps && \
  mkdir -p tmp && \
  npm run-script generate-keys

EXPOSE 1337

CMD ["node", "lib/server/server.js"]
