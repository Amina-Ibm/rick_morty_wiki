# Episode Bonus Design (Path 2)

## 1. Batching and Chunking Strategy
**A character appears in 51 episodes. How many HTTP requests does your screen make, and why that number?**
The screen should make **3 requests**, chunking the IDs at a size of 20.
Chunking at 20 keeps the URL comfortably short, and ensures responses are small enough to be parsed quickly, while still significantly reducing network calls compared to the N+1 fan-out approach (51 requests).

## 2. Response Shapes
**What comes back from a request for a single id versus several, and how does your parser handle both?**
- Requesting one ID (`/api/episode/1`) returns a **single JSON object**.
- Requesting multiple IDs (`/api/episode/1,2,3`) returns a **JSON array of objects**.
Our parser will check the type of the decoded JSON. If it is a `List`, it parses it normally. If it is a `Map` (a single object), it wraps it in a list before mapping to our DTOs.
```dart
final data = jsonDecode(response.body);
final List<dynamic> jsonList = data is List ? data : [data];
final episodes = jsonList.map((e) => EpisodeDto.fromJson(e)).toList();
```

## 3. Caching and Deduplication
**The user opens a second character who shares 40 episodes with the first. How many requests now?**
Ideally, **0 to 1 new request**. We will maintain a local cache (e.g. Hive or an in-memory Map) keyed by episode ID. Before chunking, we check the cache. If 40 out of 51 episodes are already cached from the first character, we only need to fetch the remaining 11 episodes. Since 11 < 20 (our chunk size), this results in exactly **1 HTTP request** for those remaining 11 IDs.

## 4. Single-Flight Requests
**Two widgets ask for episode 12 at the same instant. How many network calls happen?**
**Exactly one.** We implement a "single-flight" pattern (or request deduplication map) using an in-memory `Map<int, Future<Episode>> inFlightRequests`. When widget A requests episode 12, it creates a `Future` that fetches it and stores it in the map. When widget B asks for episode 12 microseconds later, it checks the map and `await`s the same exact `Future` that widget A created.

## 5. Partial Failure Handling
**One chunk of your batch fails while the others succeed. What does the user see, and what can they do about it?**
The user sees the episodes that successfully arrived (e.g. episodes 1-20 and 41-51). In the space where the failed chunk (episodes 21-40) would be, a localized "Retry missing episodes" widget is shown. This keeps the UI responsive and prevents throwing away perfectly good data just because one chunk timed out.

## 6. Clean Cancellation
**The user taps back while five chunks are still in flight. What happens to those requests and to your state?**
We use a `CancelToken` from Dio (or similar mechanism) attached to the requests for the detail screen. When the user taps back, the detail view's state controller is disposed. In `dispose()`, we call `cancelToken.cancel()`. This drops the TCP connections if they are still pending and throws a `CancelError`, which our catch block explicitly ignores so it doesn't update "dead" state. If it wasn't cancelled in time, Riverpod/state management automatically ignores state updates to disposed providers.

## 7. Testing Strategy
**How would you test all of this without hitting the real API?**
By injecting an interface `EpisodeDataSource` instead of directly calling the network. In tests, we provide a `FakeEpisodeDataSource` that returns canned data. We can mock responses for single-id and multi-id calls, test the array/object parser distinction, and introduce intentional delays (`Future.delayed`) or throw socket exceptions in the fake source to verify partial failure handling and concurrent single-flight logic.

## 8. Persisting the Cache
**Your cache is in memory. What changes if it needs to survive an app restart?**
We move the cache from an in-memory `Map<int, Episode>` to a persistent key-value store, such as `Hive` (`Box<EpisodeDto>`) or `sqflite`. The `EpisodeRepository` will first check this persistent disk cache upon initialization. The interface remains exactly the same; only the underlying implementation details swap out, proving the value of the layered architecture.
