FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

COPY src ./src

EXPOSE 3000

CMD ["node", "src/index.js"]
