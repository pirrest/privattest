# Product Catalog

A Flutter app for searching and browsing products from the public
[DummyJSON](https://dummyjson.com/) API, with an offline cache and deep links.

## Features

- **Product grid** with infinite-scroll pagination (`limit`/`skip`). Each cell
  shows the preview, title, description, price and rating. By default it lists
  all products.
- **Search** — triggers from 2 characters, debounced by 1 s, and replaces the
  grid contents with the matches. With an empty or shorter query the grid lists
  all products.
- **Details screen** — image gallery, brand, category, price and discount,
  rating, stock, description, tags, specifications and reviews.
- **Offline mode** — every product the app has seen is stored in SQLite. With no
  connection, the list and search run locally over the cached products, details open from
  the cache, and images come from the disk cache. A banner tells you when the
  data is served from the cache.
- **Deep links** — `privattest://app/product/{id}` opens the details of that
  product, from a cold start or while the app is running. Back returns to the list.

## Run

```sh
fvm flutter pub get
fvm flutter run --dart-define-from-file=config/dev.json
fvm flutter test
```

Flutter 3.47.9 (pinned in `.fvmrc`). Android and iOS.

### Configuration

Environment settings are compile-time values read from `config/<env>.json`
(`dev`, `stg`, `prod`) with `--dart-define-from-file`; add the same flag to
`flutter build ...` (for example `--dart-define-from-file=config/prod.json`).
`ConfigService` (in `lib/core`) exposes them as typed fields and fails fast at
start-up, with a hint, when a value is missing or invalid. Current settings:

| Key | Meaning |
| --- | --- |
| `API_BASE_URL` | Base URL of the API; services use paths relative to it. |

The files are committed because they hold no secrets, and nothing placed in a
mobile app is secret anyway. For personal overrides use `config/*.local.json`
(git-ignored).

Run configurations named `dev`, `stg` and `prod` are committed for both IDEs:
`.run/*.run.xml` for IntelliJ IDEA / Android Studio and `.vscode/launch.json`
for VS Code. Each one runs `lib/main.dart` with the matching config file.

Try the deep link:

```sh
# iOS simulator
xcrun simctl openurl booted privattest://app/product/1
# Android emulator
adb shell am start -a android.intent.action.VIEW -d "privattest://app/product/1"
```

Links are handled by Flutter's built-in deep linking and routed by `go_router`
with no extra code. Android passes only the path of the link to Flutter, so the
host is a fixed placeholder (`app`) and the route is `/product/:id`. The details
route is nested under the list route, so a link opens `[list, details]`.

## Architecture

No code generation. The code is split into two domains, each sliced into
`controller` (services and commands), `model` (data classes and repositories)
and `view`:

- **`lib/core`** — everything shared across the app. It never imports `shop`.
  - `utils/` — `Dispatcher` (a small event bus), `MyCubit`, helpers.
  - `controller/` — the app-wide services `ConfigService` (typed settings from
    the `--dart-define-from-file` config), `HttpClient` (dio) and
    `LoggerService`, and in `controller/commands/` the `InitializeAppCommand`:
    it registers these plus the router, then lets each domain register itself.
  - `view/` — router, theme, the shared `export.dart` barrel and widgets used
    by any screen (`ErrorView`, `OfflineBanner`, `CachedImage`).
- **`lib/shop`** — everything that belongs to products.
  - `model/` — `Product` and friends: hand-written `fromMap`/`toMap` with
    `Equatable`.
  - `model/repositories/` — `ProductsRepo` (sqflite): the product cache, in its own
    database file.
  - `controller/` — `ShopApiService`, `ProductsService`.
  - `view/` — one folder per screen (page, cubit, state as a `part` file,
    widgets), plus `shop_routes.dart` and `PagePath`.
  - `dependencies.dart` — `registerShopDependencies()`.
- **`lib/main.dart`** — the composition root, the only place that knows both
  domains: it passes the shop routes and `registerShopDependencies` to
  `InitializeAppCommand`.

Dependencies point downwards: shop → core, and within a domain
view/cubits → controller (services, commands) → model (repositories, data classes).

- **Dispatcher.** Services extend `Dispatcher<Event>` and publish sealed events.
  Cubits subscribe to them (`ProductsServiceEventServedFromCache` drives the
  offline banner).
- **API services.** One shared `HttpClient`; every domain has its own API
  service on top of it (`ShopApiService`) with its own paths, so a new feature
  adds a service next to its code without touching core.
- **Offline fallback.** `ProductsService` always tries the API first and caches
  what it returns. Only a failure with no response at all (offline, DNS,
  timeout) switches to the cache; real HTTP errors are shown as errors.
- **DI** is `get_it` (through `watch_it`) via `di()`. `InitializeAppCommand` registers the core
  services; each domain registers its own (`registerShopDependencies`).

## Libraries

Besides Flutter itself and `equatable` (value equality for models):

| Package | Why |
| --- | --- |
| `bloc`, `flutter_bloc` | State management required by the task; cubits drive each screen. |
| `dio` | HTTP client required by the task. Retrofit and code generation were deliberately skipped: there are only two endpoints, so a small hand-written `ApiService` is clearer. |
| `sqflite`, `path` | Local database for the offline cache (required by the task); `path` builds the database file path. |
| `watch_it` | Service locator used for dependency injection (it re-exports `get_it` as `di`). |
| `go_router` | Declarative routing with path parameters (`/product/:id`) and deep links. |
| `infinite_scroll_pagination` | Handles page keys, loading/error/empty states and retry for the paginated grid. |
| `cached_network_image` | Caches images on disk so previews and galleries also show offline. |
| `easy_localization` | UI strings live in `assets/translations/en.json` instead of the code. |
| `sqflite_common_ffi` (dev) | Runs the SQLite repository tests on the host machine. |

Tests (`fvm flutter test`) use `flutter_test` only, with hand-written fakes and no
mocking library.

## Notes

- Search needs at least 2 characters. Below that, the grid lists all products.
- Offline search is a case-insensitive substring match over the cached
  title, description, category, brand and tags, so it can differ slightly from
  the server's results.
