# 🧱 Next.js – No Static, With ISR

## Using Experimental Compile + Generate Env

This example demonstrates how to build and run a Next.js 15 application using the experimental build pipeline — specifically the `compile` and `generate-env` build modes — to produce an image that does not include pre-rendered static pages, but still supports `ISR` (Incremental Static Regeneration) at runtime.

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

- Injects the environment variables into the bundle

## ⚙️ Build Behavior (Server vs Client Env Vars)

When using `NEXT_PUBLIC_` variables, **where** and **when** you inject them matters.

### 1. Server-only variables

If your variable is only used on the **server**
you **don’t need `generate-env`** — just compile the app:

```bash
npx next build --experimental-build-mode compile
```

and pass the env vars at runtime:

```bash
NEXT_PUBLIC_EXAMPLE_ENV="Hello from runtime 👋" npx next start`
```

✅ Works in Docker and local Node environments.  
✅ Env var is available in all **server-side** code at runtime.  
⚠️ Not available in **client components**.

---

### 2. Client-side (NEXT*PUBLIC*) variables

If your variable is used in the **browser** (inside a Client Component or exposed via hydration),  
you need to **inject it during build** using `generate-env`, like so:

First:

```bash
npx next build --experimental-build-mode compile
```

then

```bash
NEXT_PUBLIC_EXAMPLE_ENV="Hello from local runtime 👋" npx next build --experimental-build-mode generate-env
```

Then start the app (no need to pass it again):

```bash
npx next start
```

✅ Now the variable is available in both:

- the **client bundle** (e.g. `process.env.NEXT_PUBLIC_EXAMPLE_ENV` in client components)
- and the **server** runtime

---

### 🐳 Running with Docker

##### 🧱 Build once — no database or API calls happen here.

### ⚙️ Injecting Environment Variables

You have **two options**, depending on where your variable needs to be available 👇

#### 🧠 Option 1 — Inject at runtime (Server-only)

If your variable is only used on the **server** (like inside API routes or Server Components):

```bash
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_EXAMPLE_ENV="Hello from runtime 🐳" \
  next-no-static-isr
```

✅ Available in **server-side code** (Node runtime)  
❌ Not available to the **client bundle**  
✅ Works great for most backend-only values

So if your app just needs it for database queries, server logs, etc. — this is all you need.

---

#### 🌍 Option 2 — Inject at build time (Client + Server)

If your variable needs to appear on the **client side** (e.g., displayed in the UI),  
you must pass it during the **build** so that Next.js can include it in the generated env manifest:

```bash
docker build \
  --build-arg NEXT_PUBLIC_EXAMPLE_ENV="Hello from Docker build 🧱" \
  -t next-no-static-isr .
```

Then run normally:

```bash
docker run -p 3000:3000 next-no-static-isr
```

✅ Available in both **client** and **server** code  
⚠️ The value is **baked into the image** — if you rebuild with a new value, you must rebuild the image.
