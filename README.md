# SwagKart 🛍️

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

A **playful, premium Indian e-commerce storefront** built in Flutter —
soft-pastel, motion-rich and India-first: ₹ pricing with Indian digit grouping,
GST notes, UPI / card / COD checkout, free-shipping thresholds and streetwear
flavor throughout.

> **In this repo:** full storefront + product discovery, a working shopping bag,
> and a **demo checkout** (UPI · card · COD) with order confirmation.
> Order tracking, persistence, accounts and the admin console are next (see roadmap).

---

## Design language

A premium soft-pastel system, inspired by high-end monochrome commerce UIs but
warmer and more alive:

- **Misty lavender canvas** (`#F1F0F6`) with **white cards**, hairline borders and whisper-soft shadows
- **Near-black ink** (`#1C1B24`) for type, the floating **black pill bottom nav** and all primary CTAs
- **Muted coral** signature accent + a calm pastel set (lavender / mist / blush / butter / mint / peach) for chips, tags and tints
- **Baloo 2** (rounded display) + **Inter** (body), bundled — no runtime font fetches
- Motion everywhere, kept tasteful: elastic pops, slide-up page transitions,
  confetti on add-to-bag, sliding nav pill, shimmer skeletons, ringing bell,
  live card preview as you type

## What's inside

| Area | Details |
|---|---|
| **Storefront** | Greeting header, animated search bar with rotating suggestions, pastel offer card with rotating image, category chips, trending rail, deals strip, responsive "fresh for you" grid (2/3/4 cols), trust strip, promo-code card with copy-to-clipboard |
| **Discovery** | Catalog tab (search, category chips, On Sale filter, 4 sort modes, skeleton loading) · dedicated Search tab (trending + recent chips, live results) · product detail with gallery, colour/size pickers (shake when invalid), qty stepper, accordions, related items |
| **Bag** | Line items with qty steppers + swipe-to-dismiss, free-shipping progress bar, promo codes (`SWAG15`, `SWAG10`) with stamp animation, animated totals, "you're saving" counter, clear-with-undo |
| **Checkout** | Payment screen: UPI / Card / COD picker, **live gradient card preview** as you type, auto-formatting card/expiry/CVV inputs with validation, UPI id flow, COD note, processing overlay → order confirmation with confetti + order summary. Recent order surfaces in the Account tab |
| **Account** | Profile card, saved-items sheet (wishlist grid), recent order card, phase-gated menu, About dialog, admin gate |
| **State** | Single shared `SwagAppStore` (provider + ChangeNotifier): products, cart, wishlist, promos, orders, tab requests. In-memory demo data; swap for network later without touching widgets |
| **Icons & type** | custom geometric **S + spark logo** (launcher, web, favicon, in-app mark) · 38 premium stroke SVG icons, all recolorable via currentColor, bundled fonts |
| **Platforms** | Ships for **Android** (`minSdk = 24`); `macos/` + `web/` targets included for local preview |

## Run it

```bash
flutter pub get
flutter run -d <android>   # Android device / emulator (API 24+)
flutter run -d macos       # desktop preview
flutter run -d chrome      # browser preview
flutter test               # 11 tests: cart math, promos, shipping rules, discovery + full boot smoke
flutter analyze            # 0 issues
```

## Project structure

```
lib/
├── main.dart                  # app entry, SystemChrome, store provider
├── app.dart                   # MaterialApp + theme
├── core/
│   ├── nav.dart               # SwagNav push/pop/popToRoot helpers
│   ├── theme/                 # pastel palette, theme, shape helpers, page transitions
│   ├── utils/                 # inr() ₹ formatting, responsive breakpoints
│   └── widgets/               # SwagIcon, Pressable, SwagButton (shine sweep),
│                              # chips, product card, confetti burst, shimmer,
│                              # empty state, animated count badge
├── data/
│   ├── models/                # Product, CartItem, SwagOrder
│   └── demo_data.dart         # 12 products, categories, heroes, promos
├── state/app_store.dart       # shared demo state (cart, wishlist, orders, discovery)
└── features/
    ├── splash/                # wave + letter-bounce splash
    ├── shell/app_shell.dart   # 5-tab black pill nav + IndexedStack
    ├── home/                  # discover feed
    ├── catalog/               # filters + sort + responsive grid
    ├── search/                # live search + tag chips
    ├── product/               # detail screen (gallery, pickers, Buy Now)
    ├── bag/                   # cart screen (promo, totals, undo)
    ├── payment/               # payment methods, card preview, order confirmation
    ├── account/               # profile, saved sheet, recent order, menu
    └── admin/admin_gate.dart  # Phase-3 placeholder (dark, roadmap chips)
assets/
├── fonts/                     # Baloo2 (400–800), Inter (400–700)
├── icons/                     # 37 hand-drawn SVG icons
└── images/products/           # studio product photography
test/cart_test.dart            # 10 tests: cart math, promos, shipping, discovery
test/app_smoke_test.dart       # full boot: splash → shell → tabs → scroll → bag
```

## Roadmap

- **Next — Commerce:** order tracking timeline, account auth + addresses,
  persistence (Hive/Isar), push-style notifications.
- **After — Admin:** merchant login, KPI dashboard, revenue analytics with
  count-ups, order management, category control (UI direction: dark console —
  see `AdminGate`).

## Notes

- Product photography is AI-generated studio shots on a warm cream background;
  `hero-*.png` lifestyle banners and `beanie.png` / `pack.png` are marked with
  `TODO(phase-1-assets)` in `demo_data.dart` and will be swapped in when they land.
- All demo state lives in memory — refreshing the app resets cart/wishlist/orders
  (persistence is next).
- Checkout is a **demo**: no real payments, cards or UPI requests are made.
- Promo codes: `SWAG15` (15% off), `SWAG10` (10% off).

## License

MIT — do whatever you like, attribution appreciated. 🧡
