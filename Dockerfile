FROM node:lts-alpine
WORKDIR /srv

COPY package.json yarn.lock .
RUN yarn
COPY . .
ENV OUTPUT_HOME=/tmp

CMD ["node", "docker.js"]
