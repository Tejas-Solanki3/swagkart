# SwagKart Technical Architecture & Concepts Guide

A comprehensive technical manual covering every animation, Dart function, Flutter architectural pattern, and Firebase/Firestore concept implemented in SwagKart.

---

## Table of Contents
1. [Architecture & System Design](#1-architecture--system-design)
2. [Animations & Micro-Interactions Guide](#2-animations--micro-interactions-guide)
3. [Dart 3 Concepts & Functional Utilities](#3-dart-3-concepts--functional-utilities)
4. [Flutter Framework Concepts & Custom Design System](#4-flutter-framework-concepts--custom-design-system)
5. [Firebase Authentication & Cloud Firestore Integration](#5-firebase-authentication--cloud-firestore-integration)
6. [Responsive Breakpoint Engine](#6-responsive-breakpoint-engine)
7. [Step-by-Step Demo Guide (Admin & Customer Flows)](#7-step-by-step-demo-guide-admin--customer-flows)

---

## 1. Architecture & System Design

SwagKart is architected using the **MVVM (Model-View-ViewModel)** paradigm powered by Flutter's **`ChangeNotifier`** and **`Provider`** pattern, backed by a dedicated Service Layer that interfaces with Firebase and local fallbacks.

```
┌────────────────────────────────────────────────────────┐
│                      UI Layer                          │
│  AuthGate ───► AppShell (5 Tabs) / AdminDashboardScreen │
│  (HomeScreen, CatalogScreen, Wishlist, Bag, Account)   │
└──────────────────────────┬─────────────────────────────┘
                           │ (Watches state / Dispatches actions)
┌──────────────────────────▼─────────────────────────────┐
│                    ViewModel Layer                     │
│                     SwagAppStore                       │
│    - Products State       - Cart & Bag State           │
│    - Wishlist State       - User & Auth State          │
│    - Orders & Admin State - Active Filter & Tabs       │
└──────────────────────────┬─────────────────────────────┘
                           │ (Async calls / Data persistence)
┌──────────────────────────▼─────────────────────────────┐
│                    Service Layer                       │
│  ┌───────────────────────┐   ┌───────────────────────┐ │
│  │      AuthService      │   │   FirestoreService    │ │
│  │ (FirebaseAuth + Cache)│   │ (Cloud Firestore CRUD)│ │
│  └───────────────────────┘   └───────────────────────┘ │
└──────────────────────────┬─────────────────────────────┘
                           │ (Network / Local Cache)
┌──────────────────────────▼─────────────────────────────┐
│                   Backend & Data                       │
│  Firebase Auth ── Cloud Firestore ── Local In-Memory   │
│  ('users' coll)    ('orders' coll)   (Demo Fallback)   │
└────────────────────────────────────────────────────────┘
```

### Separation of Concerns:
- **`lib/core/`**: Reusable foundation containing the custom design system (`app_colors.dart`, `app_theme.dart`), responsive calculation utilities (`responsive.dart`), routing utilities (`nav.dart`), currency and date formatters (`format.dart`), and atomic widgets (`pressable.dart`, `swag_button.dart`, `swag_icon.dart`, `product_card.dart`, `empty_state.dart`).
- **`lib/data/`**: Domain entities and immutable models (`Product`, `CartItem`, `SwagOrder`, `UserProfile`, `Category`, `HeroSlide`).
- **`lib/services/`**: Infrastructure layer isolating backend SDKs (`FirebaseService`, `AuthService`, `FirestoreService`). Contains zero UI code.
- **`lib/state/`**: Global application state (`SwagAppStore`) providing reactive signals, mutation methods, and business logic.
- **`lib/features/`**: Feature-scoped UI modules (`auth`, `shell`, `home`, `catalog`, `product`, `wishlist`, `bag`, `checkout`, `account`, `admin`, `search`).

---

## 2. Animations & Micro-Interactions Guide

SwagKart delivers a silky, 60/120 FPS native experience by blending declarative animation chaining (`flutter_animate`) with implicit Flutter widgets.

### 2.1 Declarative Animation Chaining (`flutter_animate`)

The app leverages fluent extension methods on widgets (`widget.animate().effect()`) to construct entrance and continuous motions:

1. **Staggered Grid Entrance**:
   - Used in `ProductCard`, `HomeScreen`, `CatalogScreen`, and `WishlistScreen`.
   - Cards cascade into view based on their row and column coordinates:
   ```dart
   Pressable(...)
     .animate(delay: (stagger * 45).ms)
     .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
     .moveY(begin: 18, end: 0, duration: 380.ms, curve: Curves.easeOutCubic);
   ```
   - **Concept**: By offsetting `delay` by `stagger * 45ms`, a natural wave-like entrance is achieved without manual `AnimationController` orchestration.

2. **Attention & Loop Animations**:
   - **Notification Bell Shake** (`home_screen.dart`):
     ```dart
     bellIcon
       .animate(onPlay: (controller) => controller.repeat(reverse: true), delay: 2400.ms)
       .rotate(begin: -0.04, end: 0.04, duration: 700.ms);
     ```
   - **Hero Logo Spring** (`login_screen.dart`):
     ```dart
     logoContainer
       .animate()
       .scale(duration: 400.ms, curve: Curves.easeOutBack);
     ```
     `Curves.easeOutBack` provides an organic overshoot bounce.

3. **Status Indicators & Shimmer**:
   - **Skeleton Loading Shimmer** (`shimmer_box.dart`):
     ```dart
     box.animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.4));
     ```

### 2.2 Micro-Interactions & Physics-Based Feedback

1. **Spring Press Feedback (`Pressable` Widget)**:
   - Located in `lib/core/widgets/pressable.dart`.
   - Uses `GestureDetector` to track `onTapDown` and `onTapUp`/`onTapCancel`, scaling the child widget down to `0.96` with `AnimatedScale`:
   ```dart
   AnimatedScale(
     scale: _pressed ? 0.96 : 1.0,
     duration: const Duration(milliseconds: 110),
     curve: Curves.easeOutCubic,
     child: widget.child,
   )
   ```
   - Delivers tactile, haptic-feeling feedback across all buttons, cards, and icon actions.

2. **Emoji Confetti Celebration (`fireCelebration`)**:
   - Located in `lib/core/widgets/emoji_celebration.dart`.
   - Triggered when a shopper adds an item to bag or completes checkout.
   - Dynamically inserts an `OverlayEntry` into Flutter's `OverlayState`.
   - Emits floating particles (`🔥`, `⚡`, `👟`, `✨`, `🎉`) using randomized velocities and tweened opacity/movement:
   ```dart
   Overlay.of(context).insert(entry);
   // Self-cleans and removes overlay after 1500ms
   ```

3. **Wishlist Heart Pop**:
   - In `ProductCard`:
   - When tapped, the heart bubble triggers an animated scale bounce and switches instantly from an outline heart to `SwagColors.blushDeep` filled heart.

---

## 3. Dart 3 Concepts & Functional Utilities

SwagKart leverages modern Dart features for expressive, crash-resilient code.

### 3.1 Records & Pattern Matching (Dart 3)
- **Multi-Return Records**:
  Used in `_TrustStrip` and KPI widgets to define typed tuples without boilerplate classes:
  ```dart
  final items = <(String icon, String title, String subtitle, Color tint, Color accent)>[
    ('truck', 'Free shipping', 'On orders over ₹999', SwagColors.mistSoft, SwagColors.mistDeep),
    ('return', '7-day returns', 'No questions asked policy', SwagColors.blushSoft, SwagColors.blushDeep),
  ];
  ```
- **Record Destructuring**:
  ```dart
  for (final (icon, title, subtitle, bg, fg) in items) { ... }
  ```

### 3.2 Functional Collection Operations
- **`fold()`**: Computing cart subtotal and admin gross revenue:
  ```dart
  double get cartSubtotal => _cart.fold(0.0, (sum, item) => sum + item.lineTotal);
  final totalRevenue = orders.fold(0.0, (sum, o) => sum + o.total);
  ```
- **`where()` & `take()`**: Filtered product subsets:
  ```dart
  final deals = store.products.where((p) => p.onSale).toList();
  final trending = store.byCategory(SwagCategory.allId).take(6).toList();
  ```
- **List Chunking for Responsive Grid Rows**:
  ```dart
  final rows = <List<Product>>[
    for (var i = 0; i < saved.length; i += cols)
      saved.sublist(i, i + cols > saved.length ? saved.length : i + cols),
  ];
  ```

### 3.3 Custom Extension & Utility Functions
- **Currency Formatter (`format.dart`)**:
  Formats prices with Indian currency numbering standards:
  ```dart
  String inr(num value) {
    // Formats into ₹1,299 or ₹2,48,690 without external heavy packages
  }
  ```
- **Time Elapsed Calculation (`timeAgo`)**:
  Calculates human-readable timestamps (`"just now"`, `"5m ago"`, `"2d ago"`) for orders and reviews.

---

## 4. Flutter Framework Concepts & Custom Design System

### 4.1 State Management (`Provider` Architecture)
- **`SwagAppStore` (`ChangeNotifier`)**:
  - Registered at root in `main.dart` via `ChangeNotifierProvider(create: (_) => SwagAppStore()..bootstrap())`.
  - Exposes fine-grained getters (`cartCount`, `wishlistCount`, `isLoggedIn`, `isAdmin`, `allOrders`).
- **Selective Rebuilding**:
  - `context.watch<SwagAppStore>()`: Subscribes the widget to all notifications.
  - `context.read<SwagAppStore>()`: Used inside callbacks and event handlers (`onTap`, button presses) to dispatch methods without triggering unnecessary re-renders.
  - `Consumer<SwagAppStore>`: Localizes rebuilds to specific subtrees (e.g. badge counters).

### 4.2 Reactive Gateways & Routing
- **`AuthGate` (`lib/features/auth/auth_gate.dart`)**:
  Listens directly to `SwagAppStore`:
  ```dart
  if (!store.isLoggedIn) return const LoginScreen();
  if (store.isAdmin) return const AdminDashboardScreen();
  return const AppShell();
  ```
  Whenever `store.logout()` or `store.signIn()` completes, Flutter automatically re-evaluates `AuthGate` and shifts the entire route hierarchy seamlessly.
- **Smart Fallback Back Navigation**:
  In `AdminDashboardScreen`, `<` checks if a pop route exists:
  ```dart
  if (Navigator.canPop(context)) {
    SwagNav.pop(context);
  } else {
    // If Admin was loaded as root, seamlessly opens the Customer Storefront
    SwagNav.push(context, (_) => const AppShell());
  }
  ```

### 4.3 Custom Design Tokens (`SwagColors` & `SwagTheme`)
- **Semantic Palette (`app_colors.dart`)**:
  - `SwagColors.ink` (`#1C1B24`): Dominant midnight dark tone.
  - `SwagColors.canvas` (`#F5F1E8`): Warm organic ecru/off-white background.
  - `SwagColors.accent` (`#E5876C`): Streetwear coral accent.
  - `SwagColors.butter` (`#EED284`): Warm gold highlight.
  - `SwagColors.mint` (`#89C2A4`): Live status & success indicator.
- **Typography Scale (`app_theme.dart`)**:
  - `SwagTheme.display()`: Impactful display headers (Outfit/Cabinet font styles).
  - `SwagTheme.title()`: Section headings.
  - `SwagTheme.body()`: Crisp, legible body and label text with tailored letter-spacing.

---

## 5. Firebase Authentication & Cloud Firestore Integration

### 5.1 Dual-Mode Resilience (Online + In-Memory Fallback)
SwagKart is engineered to run flawlessly whether connected to live Cloud Firestore or operating offline in demo environments. `FirebaseService.isInitialized` guards every cloud call:
- If Firebase is online: reads/writes stream to Firestore and Firebase Auth.
- If offline or demo: local in-memory dictionaries (`_localUsers`, `_localOrders`) preserve state throughout the session with zero crashes.

### 5.2 Firebase Authentication (`AuthService.dart`)
1. **Email & Password Authentication**:
   - `_auth.signInWithEmailAndPassword(email: ..., password: ...)`
   - `_auth.createUserWithEmailAndPassword(email: ..., password: ...)`
2. **Profile Synchronization**:
   - Once a user signs in, their profile document is read from `/users/{uid}`.
   - If missing, a new document is automatically generated with `displayName`, `email`, `role: 'customer'`, and `createdAt`.
3. **Password Reset**:
   - `_auth.sendPasswordResetEmail(email: ...)` with in-app confirmation snackbar.
4. **Auth State Stream**:
   - `_auth.authStateChanges()` feeds a broadcast `StreamController<UserProfile?>`, instantly updating UI states.

### 5.3 Cloud Firestore Collections (`FirestoreService.dart`)

| Collection | Document ID | Key Fields | Description |
| :--- | :--- | :--- | :--- |
| **`users`** | Firebase `uid` | `name`, `email`, `phone`, `role`, `street`, `city`, `pincode`, `state`, `createdAt` | Customer & admin profiles |
| **`orders`** | Order ID (`#SWAG-xxxx`) | `id`, `userId`, `userEmail`, `items[]`, `subtotal`, `discount`, `shipping`, `total`, `method`, `status`, `placedAt` | Real-time placed orders |

- **Real-Time Order Ingestion**:
  When a shopper completes checkout in `CheckoutScreen`, `FirestoreService.instance.saveOrder(...)` persists the order to `/orders/{orderId}` and attaches full line-item details.
- **Admin Order Stream**:
  `FirestoreService.instance.getAllOrders()` executes an `orderBy('placedAt', descending: true)` query so newly placed orders appear instantly at the top of the Admin Console.
- **Status Updates**:
  Admins can cycle orders through `Processing` ➔ `Shipped` ➔ `Delivered`, firing `_db.collection('orders').doc(orderId).update({'status': newStatus})`.

---

## 6. Responsive Breakpoint Engine

SwagKart uses a 3-tier breakpoint system defined in `lib/core/utils/responsive.dart`:

```dart
enum SwagSize { phone, tablet, wide }

SwagSize swagSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 640) return SwagSize.phone;
  if (w < 1024) return SwagSize.tablet;
  return SwagSize.wide;
}

int swagColumns(double width) {
  if (width < 640) return 2;   // Mobile: 2 Columns
  if (width < 1024) return 3;  // Tablet: 3 Columns
  return 4;                    // Web/Desktop: 4 Columns
}

double swagPad(double width) => width < 640 ? 18 : (width < 1024 ? 28 : 36);
```

### 6.1 Wishlist Web & Mobile Card Sizing Fix
- **Problem**: Previously, Wishlist used a hardcoded `crossAxisCount: 2`, making cards 700px wide on Web and causing massive whitespace when few items existed.
- **Solution**:
  1. Width capped at `1180px` (`maxWidth: 1180`) and centered.
  2. Dynamically evaluates `swagColumns(contentWidth)` (4 columns on Web, 2 on Phone).
  3. **Trailing Row Balancing**: Incomplete rows are padded with `Expanded(child: SizedBox.shrink())`:
     ```dart
     for (var c = 0; c < cols; c++) ...[
       if (c > 0) const SizedBox(width: 14),
       if (c < rows[r].length)
         Expanded(child: ProductCard(product: rows[r][c], stagger: r * cols + c))
       else
         const Expanded(child: SizedBox.shrink()),
     ]
     ```
  4. Cards stay a uniform ~260px wide on Web (matching Home page) and cleanly fill 2 columns on Mobile with zero awkward whitespace.

---

## 7. Step-by-Step Demo Guide (Admin & Customer Flows)

Follow this structured script during presentations to showcase both roles end-to-end.

```
                  ┌───────────────────────────────┐
                  │         Login Screen          │
                  └───────┬───────────────┬───────┘
                          │               │
            [Demo Admin]  │               │  [Create Account]
                          ▼               ▼
             ┌──────────────────┐   ┌──────────────────┐
             │  Admin Console   │   │  Customer Store  │
             │ - Live Revenue   │   │ - Browse Catalog │
             │ - Manage Stock   │   │ - Wishlist Heart │
             │ - Process Orders │   │ - Cart & Bag     │
             │ - Shoppers List  │   │ - Live Checkout  │
             └────────┬─────────┘   └────────┬─────────┘
                      │                      │
             [Sign Out / Store]     [Place Live Order]
                      │                      │
                      └──────────────►───────┘
                      (Admin sees new order in real-time)
```

### Flow A: The Store Administrator Journey
1. **Launch App**: The app opens to `LoginScreen`.
2. **One-Tap Demo Login**:
   - Tap **Demo Admin** (at the bottom under "Or Test With Demo Accounts").
   - Notification appears: `Logged in as Demo Admin 👑`.
   - `AuthGate` directs you straight into the dark-mode **SwagKart Console**.
3. **Overview Dashboard**:
   - Note the **Gross Revenue** KPI (`₹2,48,690`), **Total Orders**, **Live Products**, and **Active Shoppers**.
   - Note the live pulsing green dot: `Live` / `Firestore Live`.
4. **Inspect Live Orders**:
   - Switch to the **Orders** tab (tab 3).
   - Show existing real-time orders with customer names, totals, and payment methods (`UPI`, `Card`, `COD`).
   - Tap any order status pill to cycle it from `Processing` ➔ `Shipped` ➔ `Delivered`.
5. **Inspect Registered Shoppers**:
   - Switch to the **Shoppers** tab (tab 4).
   - Point out active accounts stored in Firestore (e.g. `tejas@swagkart.in`).
6. **Change Admin Password**:
   - Tap the **Password** button in the top navigation header.
   - Enter a new password and tap **Update**. Notice the confirmation badge.
7. **Switch to Storefront**:
   - Tap the `<` (Back to Store) button on the top left.
   - You are transported into the customer storefront (`AppShell`) to preview the store as an admin!
   - Navigate to **Account** tab ➔ Tap **Admin Console** badge to return anytime.
8. **Sign Out**:
   - In the top navigation header of Admin Console, tap the **Sign Out** button (logout icon).
   - Tap **Sign Out** on the dialog. You are returned cleanly to `LoginScreen`.

---

### Flow B: The New Customer / Shopper Journey
1. **Create an Account**:
   - On `LoginScreen`, switch to **Join the Club** tab.
   - Enter:
     - Name: `Aryan Sharma`
     - Email: `aryan@swagkart.in`
     - Password: `password123`
   - Tap **Join SwagKart Club ⚡**.
   - Account is created in Firebase Auth and registered into Firestore `/users/`!
   - *(Alternatively, tap "Demo Shopper" to login instantly as Tejas).*
2. **Explore the Streetwear Catalog**:
   - On **Home**, view the animated hero slideshow, brand trust strips, and trending picks.
   - Switch to **Catalog** tab.
   - Filter by categories: `Hoodies`, `Sneakers`, `Tees`, `Accessories`.
   - Toggle sorting (Price low-to-high, High-to-low, Customer rating).
3. **Wishlist Interaction**:
   - Tap the heart icon on 2–3 products.
   - Switch to the **Wishlist** tab.
   - Show the responsive, card-matched grid. Point out how cards stay standard size on Web (~260px) and 2-column on mobile with zero excess whitespace.
4. **Add to Bag & Celebration**:
   - Tap into any product detail screen (e.g., *Cyberpunk Oversized Tee*).
   - Select size (`L`), color, and tap **Add to Bag**.
   - Watch the emoji celebration burst (`🔥 ⚡ ✨`).
5. **Review Bag & Apply Coupon**:
   - Switch to **Bag** tab.
   - Enter promo code `SWAG20` and tap Apply (deducts 20% discount).
6. **Complete Checkout**:
   - Tap **Checkout Now**.
   - Select payment method (`UPI - Google Pay/PhonePe`).
   - Tap **Place Order**.
   - Confetti overlay fires, and order confirmation displays with Order ID `#SWAG-xxxx`.
7. **Verify Real-Time Order in Admin Console**:
   - Go to **Account** tab ➔ Sign out.
   - Tap **Demo Admin**.
   - Open **Orders** tab: **Aryan's newly placed order appears right at the top in real-time!**
