FROM node:20-alpine

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

COPY src ./src
COPY .env.sample .env

EXPOSE 3000

CMD ["node", "src/index.js"]
