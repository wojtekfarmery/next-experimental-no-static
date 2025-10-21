🧱 Next.js – No Static, With ISR (Experimental Compile + Generate Env)

This example demonstrates how to build and run a Next.js 15 application using the experimental build pipeline — specifically the
compile and generate-env build modes — to produce an image that does not include pre-rendered static pages, but still supports ISR (Incremental Static Regeneration) at runtime.

🧠 Why This Matters

Normally, next build generates static HTML for pages — which means your database or API gets hit at build time.
That’s often a problem when:

❌ Your database isn’t available during CI/CD builds

❌ You don’t want to use live credentials in your build environment

❌ Your data changes frequently, so static pre-generation doesn’t make sense

With experimental compile mode, Next.js skips HTML generation and compiles only the server code.
ISR still works at runtime, so pages are generated on-demand — not during build.

You get:

✅ No DB or API calls during build
✅ ISR still works dynamically at runtime
✅ Smaller Docker images
✅ No need for live DB connections in CI
✅ Runtime env injection via generate-env

⚙️ Build Modes Used
Command Purpose
npx next build --experimental-build-mode compile Compiles server code without static HTML output
npx next build --experimental-build-mode generate-env Generates runtime environment injection for deployed environments
🐳 Docker Setup
Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app

# We define the ARG, but we won't inject it here — runtime only

ARG NEXT_PUBLIC_EXAMPLE_ENV
ENV NEXT_PUBLIC_EXAMPLE_ENV=$NEXT_PUBLIC_EXAMPLE_ENV

COPY package\*.json ./
RUN npm ci
COPY . .

# Compile the app without static HTML output

RUN npx next build --experimental-build-mode compile
RUN npx next build --experimental-build-mode generate-env

RUN rm -rf .next/cache

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Define ARG again for consistency, but actual value comes at runtime

ARG NEXT_PUBLIC_EXAMPLE_ENV
ENV NEXT_PUBLIC_EXAMPLE_ENV=$NEXT_PUBLIC_EXAMPLE_ENV

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package\*.json ./
COPY --from=builder /app/node_modules ./node_modules

RUN npm prune --omit=dev && npm cache clean --force

EXPOSE 3000
CMD ["npx", "next", "start"]

🚀 How to Build & Run
🧱 1. Build the image (no static HTML, no env vars yet)

Build once — no database or API calls happen here.

docker build -t next-no-static-isr .

💡 Notice we don’t pass --build-arg NEXT_PUBLIC_EXAMPLE_ENV here — because we only inject the env var at runtime.

🏃‍♂️ 2. Run the container (inject env vars dynamically)

Now inject the env var at runtime:

docker run -p 3000:3000 \
 -e NEXT_PUBLIC_EXAMPLE_ENV="Hello from runtime 🐳" \
 next-no-static-isr

You’ll see something like:

▲ Next.js 15.0.0

- Local: http://localhost:3000
- Environment: production

Then open:
👉 http://localhost:3000

🧩 What You’ll See

The app doesn’t pre-render HTML during build.

Pages are generated on-demand the first time they’re requested.

ISR regenerates them in the background after revalidation.

Database/API access happens only at runtime — never during build.

The environment variable (NEXT_PUBLIC_EXAMPLE_ENV) displays its runtime value on the page.

Check the .next folder — you’ll see only compiled server output, no /index.html or static files.

📚 More Info

Next.js 15 experimental build modes

Incremental Static Regeneration (ISR)

Dockerizing Next.js
