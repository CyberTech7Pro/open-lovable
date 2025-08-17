# ===== Builder =====
FROM node:18-bullseye AS builder
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1

# pnpm via corepack (mesma major usada no log)
RUN corepack enable && corepack prepare pnpm@9.15.9 --activate

# Instala dependências primeiro para melhor cache
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --no-frozen-lockfile --include=dev

# Copia o restante do código e builda
COPY . .
RUN pnpm run build

# ===== Runner =====
FROM node:18-bullseye AS runner
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1
ENV HOST=0.0.0.0
ENV PORT=6000

# Copia app já buildado + node_modules
COPY --from=builder /app ./

EXPOSE 6000
CMD ["pnpm", "run", "start"]
