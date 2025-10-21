# 🧱 Next.js – No Static, With ISR

## Using Experimental Compile + Generate Env

This example demonstrates how to build and run a Next.js 15 application using the experimental build pipeline — specifically the `compile` and `generate-env `build modes — to produce an image that does not include pre-rendered static pages, but still supports `ISR` (Incremental Static Regeneration) at runtime.

### 🧠 Why This Matters

Normally, next build generates static HTML for pages — which means your database or API gets hit at build time.

That’s often a problem when:

- ❌ Your database isn’t available during CI/CD builds
- ❌ You don’t want to use live credentials in your build environment
- ❌ Your data changes frequently, so static pre-generation doesn’t make sense

With experimental compile mode, Next.js skips HTML generation and compiles only the server code.

ISR still works at runtime, so pages are generated on-demand — not during build.

You get:

- ✅ No DB or API calls during build
- ✅ ISR still works dynamically at runtime
- ✅ Smaller Docker images
- ✅ No need for live DB connections in CI
- ✅ Runtime env injection via generate-env

### ⚙️ Build Modes Used

Command Purpose

```bash
npx next build --experimental-build-mode compile
```

- Compiles server code without static HTML output

```bash
npx next build --experimental-build-mode generate-env
```

- Generates runtime environment injection for deployed environments

### ⚙️ Build & Run Options

This example can be run with or without Docker — both methods skip static page generation and inject environment variables only at runtime.

#### 🐳 Option 1 — Run with Docker (Recommended)

#### 🧱 1. Build the image (no static HTML, no env vars yet)

##### Build once — no database or API calls happen here.

```bash
docker build -t next-no-static-isr .
```

Notice we don’t pass --build-arg NEXT_PUBLIC_EXAMPLE_ENV here — because env vars are only injected at runtime.

##### Run the container (inject env vars dynamically)

```bash
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_EXAMPLE_ENV="Hello from runtime 🐳" \
  next-no-static-isr
```

You’ll see something like:

```
▲ Next.js 15.0.0

- Local: http://localhost:3000
- Environment: production
```

Then open:

```
http://localhost:3000
```

#### 💻 Option 2 — Run Locally (No Docker)

You can also run this example directly on your machine — the same build logic applies.

#### 🧩 1. Install dependencies

```bash
npm ci
```

#### ⚙️ 2. Build with experimental modes

```bash
npx next build --experimental-build-mode compile
```

```bash
npx next build --experimental-build-mode generate-env
```

#### 🚀 3. Start the app and inject a runtime env variable

```
NEXT_PUBLIC_EXAMPLE_ENV="Hello from local runtime 👋" npx next start
```

Then open:

```
👉 http://localhost:3000
```

### 🧠 What’s Happening Behind the Scenes

- 🧩 compile skips HTML generation — no database or API calls occur during build.
- ⚡️ generate-env prepares the app to read environment variables at runtime.
- 🌀 When you run the container (or start locally), process.env values are read live.
- 🔁 ISR still works — pages render on-demand and revalidate in the background.

### 🐳 Docker Setup

- Explanation of the dockerfile

```dockerfile
Dockerfile

FROM node:20-alpine AS builder

WORKDIR /app
```

#### We define the ARG, but we won't inject it here — runtime only

```dockerfile
ARG NEXT_PUBLIC_EXAMPLE_ENV

ENV NEXT_PUBLIC_EXAMPLE_ENV=$NEXT_PUBLIC_EXAMPLE_ENV
COPY package\*.json ./

RUN npm ci

COPY . .
```

#### Compile the app without static HTML output

```dockerfile
RUN npx next build --experimental-build-mode compile

RUN npx next build --experimental-build-mode generate-env


RUN rm -rf .next/cache

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

ENV PORT=3000
```

#### Define ARG again for consistency, but actual value comes at runtime

```dockerfile
ARG NEXT_PUBLIC_EXAMPLE_ENV

ENV NEXT_PUBLIC_EXAMPLE_ENV=$NEXT_PUBLIC_EXAMPLE_ENV



COPY --from=builder /app/.next ./.next

COPY --from=builder /app/public ./public

COPY --from=builder /app/package\*.json ./

COPY --from=builder /app/node_modules ./node_modules



RUN npm prune --omit=dev && npm cache clean --force



EXPOSE 3000

CMD ["npx", "next", "start"]
```
