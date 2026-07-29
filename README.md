# Galaxy Investment Limited — Website

Corporate marketing website for **Galaxy Investment Limited**, a Hong Kong–based
technology and consulting firm.

It is a **standalone static site** — plain HTML, CSS, and JavaScript with no build
step and no dependencies. Open it, host it anywhere, done.

## Pages

| File            | Page                                                         |
| --------------- | ------------------------------------------------------------ |
| `index.html`    | Home — hero, key figures, services, approach, industries, CTA |
| `about.html`    | About — story, mission &amp; vision, values                  |
| `services.html` | Services — technology, strategy, investment, governance      |
| `contact.html`  | Contact — office details and an enquiry form                 |

Shared assets live in `assets/`:

- `assets/styles.css` — the full design system (dark "galaxy" theme: navy + gold)
- `assets/script.js` — sticky nav, animated starfield, and the contact form

## View it locally

Just open `index.html` in a browser. For clean relative paths you can also run a
tiny local server:

```bash
# Python 3
python3 -m http.server 8000
# then visit http://localhost:8000
```

## Deploy

Because it is fully static, it deploys anywhere:

- **GitHub Pages** — Settings → Pages → Deploy from branch → `main` / root.
  The included `.nojekyll` file makes sure the `assets/` folder is served as-is.
- **Vercel / Netlify / Cloudflare Pages** — import the repo, no build command,
  output directory is the repo root.

## Notes

- The contact form has no backend; on submit it opens the visitor's email client
  with the message pre-filled to `hello@galaxyinvestment.hk`. To collect
  submissions server-side later, point the form at a service such as Formspree,
  or wire it to your own endpoint.
- Company details, statistics, and the testimonial are placeholders — replace
  them with real content (email, phone, address, figures) when available.
