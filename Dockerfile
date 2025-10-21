FROM node:20-alpine AS builder

WORKDIR /app

ARG NEXT_PUBLIC_EXAMPLE_ENV
ENV NEXT_PUBLIC_EXAMPLE_ENV=$NEXT_PUBLIC_EXAMPLE_ENV


COPY package*.json ./
RUN npm ci 

COPY . .

RUN npx next build --experimental-build-mode compile
RUN npx next build --experimental-build-mode generate-env

RUN rm -rf .next/cache

FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

ARG NEXT_PUBLIC_EXAMPLE_ENV
ENV NEXT_PUBLIC_EXAMPLE_ENV=$NEXT_PUBLIC_EXAMPLE_ENV

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package*.json ./

COPY --from=builder /app/node_modules ./node_modules
RUN npm prune --omit=dev && npm cache clean --force


EXPOSE 3000

CMD ["npx", "next", "start"]
