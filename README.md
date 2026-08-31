# Rick and Morty Wiki

A Flutter app that browses, searches, and favourites characters from the Rick and Morty API, with offline support.

## How to run it

- Flutter version: 3.38.3
- Clone the repo, then:
  ```bash
  flutter pub get
  flutter run
  ```

## Platform tested

- Android 17 Emulator (API 37.1)
-  Android 11 Device (API 30)
- IOS 16e Simulator

## Architecture overview

The app is split into three layers:

- **`data/`** — remote (ApiClient, DTOs) and local (cache/favourites storage) sources, and the repositories.
- **`domain/`** — UI-facing models and a typed `AppFailure` hierarchy for errors.
- **`presentation/`** — screens and Riverpod state management.

Repositories are the single source of truth the UI depends on — they decide whether to serve network or cached data, and translate raw exceptions into typed failures before anything reaches the UI.

## State management

Riverpod, as Bloc/cubit are used for complex apps where multiple states are required. Riverpod is a modified version of Provider and i am moe comfortable using Riverpod so decided to go with that. Async notifier easly aligns to the state loading, data, empty and error states.

## Caching and offline strategy

- Fetched character list pages are cached locally via  Hive, along with the fetch timestamp.
- When a network request fails due to connectivity, the repository falls back to the last cached data, and the UI shows a non-blocking "offline — showing cached data" banner along  with the last fetched time.
- connectivity_plus package is used to detect network connectivity changes, and the app triggers remote data fetching on next search/refresh when the connection returns.
- Favourites are persisted independently via Hive and are fully available offline.

## Assumptions


- Debounce set to 400ms
- A search returning HTTP 404 is treated as zero results, and a  'No character found for {searchTerm}' empty state is displayed

## How I chose the debounce value


- Timed the API's own response latency for a typical search request — round trip was roughly 0.045 ms on a normal connection.
- Settled on 400 ms, balancing perceived responsiveness against not firing a request per keystroke. t is not based on response time as network latency is negligible.

## How I chose the episode-batch chunk size 

 - I measured response time across chunk sizes and confirmed the API doesn't meaningfully slow down even at 40+ ids, so the real constraint I optimized for was keeping each failure unit small and staying safely under any URL length constraints, not raw speed. Limiting to 20 per chunk makes sure the requests stay under 3
## Known limitations / unfinished
- Episode fan-out bonus: implemented as a design doc (Path 2), not built — see `docs/episode-fanout.md`.

## Roughly how long I spent

7 hours; This includes readme and episode bonus doc.

## AI tools used

- Claude: Create initial architecture, draft the episode bonus doc, review and polish the Readme.md
- Antigravity: Create domain, data layers, and test widgets.

