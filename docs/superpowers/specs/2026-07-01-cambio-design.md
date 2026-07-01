# Cambio — Design Spec

**Date:** 2026-07-01
**Author:** Anas Ben Ahmed
**Status:** Approved — in build

---

## 1. What it is

**Cambio** is a cross-platform currency converter for Android and iOS, built from a
single Flutter (Dart) codebase so the UI is pixel-identical on both platforms.
Inspired by the "Currency" iOS app's layout, but re-skinned in Anas's dark-luxe
brand language — not a 1:1 clone.

The name *Cambio* is Spanish/Italian for "exchange" — what currency-exchange booths
are literally called.

## 2. Goals & non-goals

**Goals**
- Fast, tactile conversion via a full-screen custom keypad.
- Live rates + historical charts for ~40 world currencies, including TND.
- Favorites: a saved list of pairs with live mini-rates.
- One codebase → Android APK + iOS IPA.
- Ships with an automated test suite (per project rule).

**Non-goals**
- No web build (CORS friction with the data source; revisit later).
- No crypto/metals (free data source is fiat-only).
- No accounts, no backend, no ads.

## 3. Data source

**Yahoo Finance chart endpoint** (unofficial, free, no API key):

```
https://query1.finance.yahoo.com/v8/finance/chart/{FROM}{TO}=X?range={r}&interval={i}
```

- Symbol format: `TNDUSD=X` = "1 TND in USD".
- Live rate: `chart.result[0].meta.regularMarketPrice` (fallback: last non-null close).
- History: parallel `timestamp[]` and `indicators.quote[0].close[]` arrays.
- Verified working for TND on 2026-07-01: live `0.3393`, 7D→101 hourly points,
  1Y→261 daily points.

**Range → interval mapping**

| Tab | range | interval |
|-----|-------|----------|
| 1D  | 1d    | 5m       |
| 7D  | 5d    | 30m      |
| 1M  | 1mo   | 1d       |
| 1Y  | 1y    | 1d       |
| 2Y  | 2y    | 1wk      |
| 5Y  | 5y    | 1wk      |

**Caveats (handled, not hidden)**
- Unofficial endpoint → requires a browser-like `User-Agent` header; wrap calls in
  try/catch and show a graceful retry state on failure.
- 1D returns empty when forex markets are closed (weekends) — show an
  "Markets closed" empty state rather than an error.

## 4. Screens

1. **Converter (home)**
   - Top bar: ⭐ favorite toggle · live header `1 TND = 0.339 USD` · 📊 chart icon.
   - Big display: `amount  =  converted`, stacked over two currency rows
     (flag + name + "Tap to change"), with a center divider/arrow.
   - Lower half: full-bleed custom keypad — `7 8 9 / 4 5 6 / 1 2 3 / , 0`,
     plus delete-last (⌫), clear-all, and switch (⇄) keys.
   - Footer: "Last updated: HH:MM".

2. **Currency picker** (modal)
   - Searchable list (by code or name), flag + code + full name, tap to select.
   - Reused for both the From and To slots.

3. **Favorites** (modal)
   - Saved pairs, each showing `1 FROM → x.xx TO` with a live mini-rate + flag.
   - Add (current pair) / remove (swipe or tap). Persisted locally.

4. **Chart** (modal)
   - Title `FROM → TO`, range tabs `1D · 7D · 1M · 1Y · 2Y · 5Y`.
   - Branded area chart (crimson→gold gradient fill) over the selected range.

## 5. Brand / theme

- Base `#0D0D0D`, surfaces `#151515`/`#1A1A1A`, hairlines `#262626`.
- Accents: crimson `#E11B22`, gold `#E0A82E`. The Switch key and chart fill use the
  crimson→gold gradient (replacing the reference app's green).
- Type: **Bebas Neue** for big display numbers; **Space Grotesk** for body/labels —
  same pairing as the portfolio.
- Flags: rectangular ISO flags (via `country_flags`), like the reference.

## 6. Architecture

```
lib/
  main.dart                 app entry, providers, navigation
  theme/app_theme.dart      colors, text styles, ThemeData
  models/
    currency.dart           code, name, symbol, flagCountryCode
    rate_point.dart         (timestamp, value) for charts
    chart_range.dart        enum + range/interval mapping
  data/currencies.dart      curated catalog (~40 currencies, incl. TND)
  services/rate_service.dart Yahoo fetch + JSON parse (live + history)
  state/
    converter_state.dart    amount input, from/to, live rate, keypad ops
    favorites_state.dart    saved pairs + persistence
  screens/
    converter_screen.dart
    currency_picker_screen.dart
    favorites_screen.dart
    chart_screen.dart
  widgets/
    keypad.dart             the custom keypad grid
    currency_row.dart       flag + name + "tap to change"
    ...
test/
  converter_logic_test.dart amount entry, clamping, switch, conversion math
  rate_service_test.dart    parse live rate + history from sample JSON
  favorites_test.dart       add/remove/dedupe/persist
```

**State:** `provider` + `ChangeNotifier`. **Storage:** `shared_preferences`
(favorites list + last-used pair). **HTTP:** `http`. **Charts:** `fl_chart`.

## 7. Conversion logic

- `rate` = value of 1 FROM in TO units (Yahoo `FROMTO=X`).
- `converted = amount * rate`.
- Amount is built by the keypad as a string (digits + single decimal comma),
  parsed to double; empty → `0`. Display formatted via `intl` to the TO currency's
  typical decimals.
- Switch (⇄) swaps FROM/TO and re-fetches the rate.

## 8. Testing

Pure-logic unit tests (no network):
- **converter_logic** — keypad append/delete/clear, single-decimal guard,
  switch swap, `amount * rate` conversion + formatting.
- **rate_service** — parsing live rate and history arrays from captured sample JSON
  (incl. null-close handling and the markets-closed empty case).
- **favorites** — add, remove, no-duplicate, serialize/deserialize round-trip.

## 9. Build / delivery

1. `flutter create` scaffolds android/ios platform folders; lib/ + pubspec drop in.
2. Android first: `flutter build apk --release` → sideload to device.
3. iOS: `flutter build ipa` → install via cert + ESign.

## 10. Open items

- Bundle Bebas Neue / Space Grotesk TTFs as assets later (currently via
  `google_fonts`, fetched + cached at runtime).
- App icon + splash in Cambio branding (crimson/gold) before release builds.
