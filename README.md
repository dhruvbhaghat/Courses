# Courses
demo Project submission

LEARNING DASHBOARD (iOS - SwiftUI, Combine, async/await)
Run: brew install xcodegen; xcodegen generate; open the project (iOS 17+).
Demo login: student@example.com / Password123
 
1. ARCHITECTURE
MVVM + Repository: View -> ViewModel -> Repository -> NetworkManager +
FileCourseStore. I chose it because it fits SwiftUI/Combine natively, gives
each layer one job, and puts every dependency behind a protocol, so
ViewModels and repositories are unit-tested with stubs. The repository is
the single source of truth and decides network vs. cache, so the UI never
knows where data came from. AppContainer wires dependencies in one place.
NetworkManager takes an Endpoint enum and returns a generic Decodable; each
enum case decodes its mock JSON in a switch, so moving to real URLSession
touches only that file.
 
2. OFFLINE SUPPORT
- Courses are fetched network-first, then saved as JSON in Application
  Support (an actor with atomic writes). If the network fails, the
  repository returns the cached copy and the UI shows a "saved courses"
  banner.
- Lessons are cached per course. A completed lesson is written locally first,
  so progress survives offline use and relaunch. Local progress wins over a
  stale server value.
- NWPathMonitor reports connectivity. A corrupt cache file is discarded
  instead of crashing. The session lives in the Keychain, so relaunching
  offline still works. Logout clears the cache.
 
3. SECURITY
Authentication tokens belong in the Keychain, never UserDefaults, plain
files or logs. This app uses the Keychain with AfterFirstUnlock. In
production I would use AfterFirstUnlockThisDeviceOnly, with a short-lived
access token and a rotating refresh token (the refresh token stored only in
the Keychain), HTTPS/ATS everywhere, certificate pinning for sensitive
endpoints, and an optional biometric gate before using the refresh token.
 
4. SCALE (1 million users, hundreds of courses)
1. Cursor pagination and server-side search/filtering for courses; load
   lessons lazily.
2. Replace JSON files with SQLite/SwiftData (indexed, per-row updates)
   instead of rewriting whole files.
3. Real sync: an outbox queue for lesson completions with retry/backoff,
   idempotency keys and server-side conflict rules (today it is best-effort
   and failures are only logged).
4. HTTP caching (ETag/If-None-Match), CDN, compression, request
   de-duplication.
5. Observability and safe releases: crash reporting, metrics, feature flags,
   staged rollouts, plus backend rate limiting.
 
5. SECOND PLATFORM (Android)
Keep the same layers and the same JSON contract in Kotlin: Jetpack Compose UI
-> ViewModel (StateFlow replaces @Published/Combine; coroutines replace
async/await) -> Repository interface -> Retrofit/OkHttp (sealed Endpoint
class) + Room (replaces FileCourseStore). Hilt provides DI (like
AppContainer) and Navigation Compose handles screens. Tokens go in
EncryptedSharedPreferences or DataStore + Tink, backed by the Android
Keystore. ConnectivityManager reports network state and WorkManager syncs
pending completions. Tests use JUnit, MockK and Turbine with fake
repositories and DAOs. A sealed UiState (Loading, Success, Empty, Error)
mirrors the iOS LoadState.
