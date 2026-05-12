import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";
import sitemap from "@astrojs/sitemap";
import cloudflare from "@astrojs/cloudflare";

export default defineConfig({
  site: "https://example.com",
  // Static output with on-demand SSR for pages with prerender = false
  output: "static",
  adapter: cloudflare(),
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [sitemap()],
});
