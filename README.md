# DrinkWater

Natywna aplikacja SwiftUI na iPhone z iOS 17 lub nowszym. Wymaga Xcode 16 lub nowszego.

Ekran główny: pierścień postępu, pozostała ilość do celu, jeden przycisk „Wypiłem szklankę” (250 ml), cofnięcie ostatniego dodania oraz edycja celu. Dane i możliwość jednorazowego cofnięcia ostatniej porcji zapisują się lokalnie. Licznik odnawia się przy zmianie dnia. Lokalne przypomnienia działają codziennie co 2 godziny od 8:00 do 22:00 po włączeniu przełącznika i udzieleniu zgody iOS. Historia nie jest jeszcze zaimplementowana.

## Uruchomienie na Macu

1. W Xcode wybierz **Integrate → Clone**, podaj `https://github.com/barrysonic/DrinkWater.git` i wybierz katalog lokalny. Xcode wymaga lokalnej kopii do budowania.
2. Otwórz `DrinkWater.xcodeproj`.
3. Wybierz schemat DrinkWater i symulator iPhone 15 Pro Max, następnie **Run**.
4. Aby uruchomić na swoim iPhonie, wybierz go jako urządzenie docelowe, w **Signing & Capabilities** ustaw swój Team i włącz tryb deweloperski na iPhonie, jeśli Xcode o niego poprosi. Identyfikator aplikacji może wymagać zmiany na unikalny.

## Weryfikacja

Na Macu: `xcodebuild -project DrinkWater.xcodeproj -scheme DrinkWater -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build`.

Sprawdź dodawanie szklanki (250 ml), jednorazowe cofnięcie ostatniej porcji również po restarcie, zmianę celu bez utraty postępu i zachowanie danych po ponownym uruchomieniu. Sprawdź osiągnięcie i przekroczenie celu, wyzerowanie licznika i cofania następnego dnia, duży rozmiar tekstu, VoiceOver oraz tryb ciemny. Repozytorium nie zawiera jeszcze testów automatycznych.

W środowisku chmurowym Linux nie ma Xcode ani iOS SDK; kompilacja i działanie aplikacji wymagają sprawdzenia na Macu. Aplikacja nie potrzebuje serwera, sekretów ani zewnętrznych pakietów.

## Przypomnienia — sprawdzenie na iPhonie

- Włącz „Przypomnienia co 2 godziny” i zaakceptuj zgodę iOS. Zaplanowanych jest 8 powtarzalnych powiadomień kalendarzowych: 8:00–22:00, w lokalnym czasie urządzenia. To stałe godziny, nie dwie godziny od ostatniej szklanki.
- Zamknij aplikację i sprawdź dostarczenie o najbliższej zaplanowanej godzinie; sprawdź też baner przy otwartej aplikacji.
- Wyłącz przełącznik: oczekujące i dostarczone przypomnienia aplikacji zostają usunięte.
- Sprawdź odmowę zgody, przejście do ustawień i ponowne włączenie, cofnięcie zgody w ustawieniach, restart aplikacji i zmianę strefy czasowej.
- Dźwięk jest standardowym dźwiękiem powiadomienia. Tryb cichy, skupienie i ustawienia iOS mogą go wyciszyć lub opóźnić dostarczenie; aplikacja nie używa alarmów krytycznych i nie gwarantuje głośnego alarmu.
- Powiadomienia są lokalne: nie wymagają serwera, push entitlement ani działania aplikacji w tle. Zgoda jest proszona tylko po świadomym włączeniu przez użytkownika.

Kompilacja oraz dostarczanie powiadomień nie zostały zweryfikowane w Linux; powyższe scenariusze wymagają iOS/Xcode.
