export interface NavItem {
  label: string;
  href: string;
}

export interface SiteConfig {
  title: string;
  description: string;
  url: string;
  author: string;
  github: string;
  navItems: NavItem[];
}

export const siteConfig: SiteConfig = {
  title: "Your Project",
  description:
    "A brief description of your project or organization. Update this with your own tagline.",
  url: "https://example.com",
  author: "Your Name",
  github: "https://github.com/your-username",
  navItems: [
    { label: "Features", href: "/#features" },
    { label: "About", href: "/about" },
    { label: "Contact", href: "/contact" },
  ],
};
