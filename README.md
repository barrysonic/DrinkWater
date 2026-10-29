# DrinkWater

Natywna aplikacja SwiftUI na iPhone z iOS 17 lub nowszym. Wymaga Xcode 16 lub nowszego.

Pierwsza wersja: dzienny cel, dodawanie 150/250/500 ml, postęp i lokalny zapis danych. Licznik odnawia się przy zmianie dnia. Przypomnienia i historia nie są jeszcze zaimplementowane.

## Uruchomienie na Macu

1. W Xcode wybierz **Integrate → Clone**, podaj `https://github.com/barrysonic/DrinkWater.git` i wybierz katalog lokalny. Xcode wymaga lokalnej kopii do budowania.
2. Otwórz `DrinkWater.xcodeproj`.
3. Wybierz schemat DrinkWater i symulator iPhone 15 Pro Max, następnie **Run**.
4. Aby uruchomić na swoim iPhonie, wybierz go jako urządzenie docelowe, w **Signing & Capabilities** ustaw swój Team i włącz tryb deweloperski na iPhonie, jeśli Xcode o niego poprosi. Identyfikator aplikacji może wymagać zmiany na unikalny.

## Weryfikacja

Na Macu: `xcodebuild -project DrinkWater.xcodeproj -scheme DrinkWater -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build`.

Sprawdź dodawanie wody, zmianę celu, zachowanie danych po ponownym uruchomieniu i wyzerowanie licznika następnego dnia. Repozytorium nie zawiera jeszcze testów automatycznych.

W środowisku chmurowym Linux nie ma Xcode ani iOS SDK; kompilacja i działanie aplikacji wymagają sprawdzenia na Macu. Aplikacja nie potrzebuje serwera, sekretów ani zewnętrznych pakietów.
