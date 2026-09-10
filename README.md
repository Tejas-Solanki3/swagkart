# SwagKart 🛍️

A **playful, premium Indian e-commerce storefront** built in Flutter — inspired by
high-end monochrome commerce UIs, but warmer, candy-colored and full of motion.
India-first: ₹ pricing with lakh/crore grouping, GST notes, UPI/COD messaging,
free-shipping thresholds and Indian streetwear flavor throughout.

> **Phase 1 (this repo):** app setup, visual assets, shared demo state,
> responsive storefront & product discovery, and a working shopping bag.
> Checkout, orders/tracking and the admin console are Phase 2–3 (see roadmap).

---

## What's in Phase 1

| Area | Details |
|---|---|
| **Storefront** | Animated splash (wave + letter bounce), auto-advancing hero carousel with wiggling CTA, category orbit, trending rail, deals strip, responsive "fresh for you" grid (2/3/4 columns), trust strip, promo-code banner with copy-to-clipboard |
| **Discovery** | Catalog tab with search field, category chips, "On Sale" filter and 4 sort modes · dedicated Search tab with trending + recent chips and live results · product detail with gallery, color/size pickers (shake when invalid), qty stepper, accordions, related items |
| **Bag** | Line items with qty steppers + swipe-to-dismiss, free-shipping progress bar, promo codes (`SWAG15`, `SWAG10`) with stamp animation, animated totals, "you're saving" counter, clear-with-undo |
| **Account** | Profile card, saved-items sheet (wishlist grid), phase-gated menu, About dialog, admin gate |
| **State** | Single shared `SwagAppStore` (provider + ChangeNotifier): products, cart, wishlist, promos, tab requests. In-memory demo data; swap for network later without touching widgets |
| **Animation** | flutter_animate chains, confetti burst on add-to-bag, sliding pill bottom-nav with elastic indicator, badge pops, shimmer skeletons, custom page transitions (spring scale + fade), rotating sparkles, ringing bell |
| **Responsive** | Phone / tablet / wide breakpoints, adaptive grid columns, max content width on very wide screens |
| **Icons & type** | 37 hand-crafted stroke SVG icons (currentColor recoloring), bundled **Baloo 2** (display) + **Inter** (body) fonts — no runtime font fetches |

## Run it

```bash
flutter pub get
flutter run          # on a connected Android device / emulator (API 24+)
flutter test         # 11 tests: cart math, promos, shipping rules, discovery + full boot smoke
flutter analyze      # 0 issues
```

Android only by design (`android/` is the only platform directory, `minSdk = 24`).

## Project structure

```
lib/
├── main.dart                  # app entry, SystemChrome, store provider
├── app.dart                   # MaterialApp + theme
├── core/
│   ├── nav.dart               # SwagNav push/pop helpers
│   ├── theme/                 # colors (candy palette), theme, page transitions
│   ├── utils/                 # inr() ₹ formatting, responsive breakpoints
│   └── widgets/               # SwagIcon, Pressable, SwagButton (shine sweep),
│                              # chips, product card, confetti burst, shimmer,
│                              # empty state, animated count badge
├── data/
│   ├── models/                # Product, CartItem
│   └── demo_data.dart         # 12 products, categories, heroes, promos
├── state/app_store.dart       # shared demo state (cart, wishlist, discovery)
└── features/
    ├── splash/                # wave + letter-bounce splash
    ├── shell/app_shell.dart   # 5-tab floating pill nav + IndexedStack
    ├── home/                  # discover feed
    ├── catalog/               # filters + sort + responsive grid
    ├── search/                # live search + tag chips
    ├── product/               # detail screen (gallery, pickers, confetti)
    ├── bag/                   # cart screen (promo, totals, undo)
    ├── account/               # profile, saved sheet, menu
    └── admin/admin_gate.dart  # Phase-3 placeholder (dark, roadmap chips)
assets/
├── fonts/                     # Baloo2 (400–800), Inter (400–700)
├── icons/                     # 37 hand-drawn SVG icons
└── images/products/           # studio product photography
test/cart_test.dart            # 10 tests: cart math, promos, shipping, discovery
test/app_smoke_test.dart       # full boot: splash → shell → tabs → scroll → bag
```

## Roadmap

- **Phase 2 — Commerce:** checkout & payment (UPI / card / COD, address form),
  order confirmation + live tracking timeline, account (auth, addresses, orders),
  persistence (Hive/Isar), push-style notifications.
- **Phase 3 — Admin:** merchant login, KPI dashboard, revenue analytics with
  count-ups, order management, category control (UI direction: dark console —
  see `AdminGate`).

## Notes

- Product photography is AI-generated studio shots on a warm cream background;
  `hero-*.png` lifestyle banners and `beanie.png` / `pack.png` are marked with
  `TODO(phase-1-assets)` in `demo_data.dart` and will be swapped in when they land.
- All demo state lives in memory — refreshing the app resets cart/wishlist
  (persistence is Phase 2).
- Promo codes: `SWAG15` (15% off), `SWAG10` (10% off).
