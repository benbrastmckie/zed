export interface Feature {
  title: string;
  description: string;
}

export const features: Feature[] = [
  {
    title: "Fast by Default",
    description:
      "Built on Astro's islands architecture, your site ships zero JavaScript unless you explicitly opt in. Pages load instantly with static HTML.",
  },
  {
    title: "Modern Styling",
    description:
      "Tailwind CSS v4 with CSS-first configuration. Define your brand colors in one place and every utility class updates automatically.",
  },
  {
    title: "Type Safe",
    description:
      "Strict TypeScript throughout. Component props are validated at build time, and content collections use Zod schemas for runtime safety.",
  },
  {
    title: "Accessible",
    description:
      "Semantic HTML, ARIA labels, keyboard navigation, and reduced-motion support are built into every component from the start.",
  },
  {
    title: "Dark Mode Ready",
    description:
      "A complete dark color palette with semantic color tokens. Toggle between light and dark themes with a single CSS class.",
  },
  {
    title: "Edge Deployment",
    description:
      "Pre-configured for Cloudflare Pages with automatic preview deployments, sitemap generation, and edge-optimized static output.",
  },
];
