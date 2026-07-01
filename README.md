<!-- ============ HEADER BANNER ============ -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:E11B22,100:E0A82E&height=230&section=header&text=Cambio&fontSize=90&fontColor=ffffff&fontAlignY=40&desc=Currency%20Converter%20for%20Android%20and%20iOS&descSize=18&descAlignY=64&descColor=ffffff" width="100%"/>

<!-- ============ BADGES ============ -->
<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  &nbsp;
  <img src="https://img.shields.io/badge/One%20Codebase-E0A82E?style=for-the-badge&logo=rocket&logoColor=white"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Tested-43%20passing-6E9F18?style=for-the-badge&logo=flutter&logoColor=white"/>
</p>

<!-- ============ ANIMATED TAGLINE ============ -->
<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=13&duration=2500&pause=99999&color=FFFFFF&center=true&vCenter=true&width=720&height=30&lines=Type+an+amount.+Pick+two+currencies.+Done.&repeat=false" alt="Tagline"/>
</p>

<!-- ============ PLATFORM ROW ============ -->
<p align="center">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=flat-square&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Pixel--identical-both%20platforms-E11B22?style=flat-square"/>
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E11B22,100:E0A82E&height=4" width="100%"/>

<!-- ============ ABOUT ============ -->
<h2 align="center"><img src="https://media.giphy.com/media/hvRJCLFzcasrR4ia7z/giphy.gif" width="26"> About</h2>

<p align="center">
  <b>Cambio</b> is a fast, tactile currency converter built with <b>Flutter</b> — one Dart codebase that renders
  <b>pixel-identical on Android and iOS</b>. Type on a full-screen keypad, flip between 45+ world currencies,
  save your favourite pairs, and view real historical charts.
</p>

<p align="center">
  Named after the Spanish/Italian word for <i>exchange</i> — what a currency booth is literally called — and
  dressed in a dark-luxe crimson &amp; gold theme.
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E0A82E,100:E11B22&height=4" width="100%"/>

<!-- ============ PREVIEW ============ -->
<h2 align="center">🖼️ Preview</h2>

<p align="center"><i>Converter · Currency picker · Favourites · History chart</i></p>

<p align="center">
  <!-- Device screenshots live in /screenshots -->
  <img src="screenshots/converter.png" width="24%" alt="Converter"/>
  <img src="screenshots/picker.png" width="24%" alt="Currency picker"/>
  <img src="screenshots/favorites.png" width="24%" alt="Favourites"/>
  <img src="screenshots/chart.png" width="24%" alt="History chart"/>
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E11B22,100:E0A82E&height=4" width="100%"/>

<!-- ============ FEATURES ============ -->
<h2 align="center">✨ Features</h2>

<p align="center">
⌨️ &nbsp;<b>Full-screen keypad</b> — big Bebas Neue numerals, decimal, delete-last, clear-all, and a one-tap switch<br/><br/>
🌍 &nbsp;<b>45+ currencies</b> — with rounded ISO flags, from USD &amp; EUR to TND, the Gulf dinars, and more<br/><br/>
📈 &nbsp;<b>Real history charts</b> — 1D · 7D · 1M · 1Y · 2Y · 5Y area charts in the crimson→gold gradient<br/><br/>
⭐ &nbsp;<b>Favourites</b> — save any pair, see live mini-rates at a glance, swipe to remove<br/><br/>
💾 &nbsp;<b>Remembers you</b> — your last pair and favourites persist between launches<br/><br/>
🎨 &nbsp;<b>One design, two platforms</b> — Flutter draws every pixel, so Android and iOS look identical
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E11B22,100:E0A82E&height=4" width="100%"/>

<!-- ============ TECH STACK ============ -->
<h2 align="center">🧰 Tech Stack</h2>

<p align="center">
  <b>Framework</b><br/>
  <img src="https://skillicons.dev/icons?i=flutter,dart&theme=light" />
</p>
<p align="center">
  <b>Libraries</b><br/>
  <code>provider</code> · <code>fl_chart</code> · <code>http</code> · <code>shared_preferences</code> · <code>country_flags</code> · <code>google_fonts</code>
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E0A82E,100:E11B22&height=4" width="100%"/>

<!-- ============ DATA ============ -->
<h2 align="center">📡 Where the rates come from</h2>

<p align="center">
  Cambio reads live and historical FX from <b>Yahoo Finance's public chart endpoint</b> — free, no API key,
  and one of the few sources that covers the <b>Tunisian Dinar (TND)</b> with intraday data.<br/>
  All parsing is isolated in <code>RateService</code> and fully unit-tested.
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E11B22,100:E0A82E&height=4" width="100%"/>

<!-- ============ GETTING STARTED ============ -->
<h2 align="center">🚀 Getting Started</h2>

<p align="center"><b>Prerequisites</b> — Flutter <b>3.44+</b> · Android SDK (for APK) · Xcode (for iOS)</p>

```bash
flutter pub get

# Run on a connected device / emulator
flutter run

# Build a release APK (sideload on Android)
flutter build apk --release
#   → build/app/outputs/flutter-apk/app-release.apk

# Build for iOS (install via signing cert + a sideloader)
flutter build ipa
```

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E0A82E,100:E11B22&height=4" width="100%"/>

<!-- ============ TESTS ============ -->
<h2 align="center">🧪 Tests</h2>

<p align="center">
  The pure logic — keypad input, number formatting, rate parsing, and the favourites store —
  is covered by <b>flutter_test</b>. No network, deterministic, fast.
</p>

```bash
flutter test
```

<p align="center">
  <b>43 tests</b> across <code>AmountInput</code>, the French-style formatters,
  <code>RateService.parse</code> + USD triangulation (incl. null gaps, markets-closed, and error responses),
  <code>ConverterState</code> conversion math, and the favourites serialization + store.
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E11B22,100:E0A82E&height=4" width="100%"/>

<!-- ============ ARCHITECTURE ============ -->
<h2 align="center">⚙️ How It's Built</h2>

```
lib/
  main.dart              app entry + providers
  theme/                 brand palette + typography
  models/                Currency · RatePoint · ChartRange
  data/                  curated currency catalog
  services/              RateService — Yahoo fetch + pure parse
  state/                 AmountInput · ConverterState · FavoritesState
  screens/               converter · picker · favorites · chart
  widgets/               keypad · currency chip · flag · modal header
```

<p align="center">
  State is plain <code>ChangeNotifier</code> + <code>provider</code>. The keypad logic lives in a dependency-free
  <code>AmountInput</code> class so it's trivial to test, and all Yahoo parsing is a static pure function.
</p>

<!-- divider -->
<img src="https://capsule-render.vercel.app/api?type=rect&color=0:E0A82E,100:E11B22&height=4" width="100%"/>

<!-- ============ DISCLAIMER ============ -->
<h2 align="center">⚖️ Disclaimer</h2>

<p align="center">
  Cambio is an independent project and is <b>not affiliated with, endorsed by, or associated with</b>
  Yahoo or any data provider. Exchange rates are provided for reference only and may be delayed or inaccurate —
  do not rely on them for financial decisions. All trademarks belong to their respective owners.
</p>

<p align="center">
  <sub>© 2026 Anas Ben Ahmed · Provided "as is", without warranty of any kind.</sub>
</p>

<!-- ============ FOOTER WAVE ============ -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:E0A82E,100:E11B22&height=160&section=footer&text=Built%20by%20Anas%20Ben%20Ahmed&fontSize=22&fontColor=ffffff&fontAlignY=72&desc=One%20codebase%20.%20Every%20platform&descSize=14&descAlignY=88&descColor=ffffff" width="100%"/>
