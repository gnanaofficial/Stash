# Antigravity Master Prompt --- Personal Knowledge & Discovery App

> **Project mode:** Continue and improve an existing Flutter
> application. Do not generate a new application from scratch.
>
> **Primary instruction:** Inspect the complete existing project before
> changing anything. Preserve working functionality, especially the
> existing Supabase connection, signup flow, login flow, authentication
> session handling, and any working screens or database integrations.

------------------------------------------------------------------------

## 1. Your role

Act as a senior Flutter architect, Android engineer, Supabase/PostgreSQL
engineer, on-device AI engineer, and product UI/UX designer.

You are working on an existing Android-first Flutter application. The
application already has some screens and functionality, is connected to
Supabase, and its signup pages are working.

Your job is to audit the current implementation, understand what already
works, and evolve it into a polished, maintainable, offline-first
**Personal Knowledge & Discovery Platform**.

Do not overwrite working code simply because you prefer a different
architecture. Make incremental, testable changes. If a migration or
refactor is necessary, explain why, preserve behaviour, and implement it
in small steps.

## 2. Product vision

The app lets users collect, organize, search, understand and rediscover
useful information from across their digital life.

It combines:

1.  **Personal Knowledge Manager** --- save links, videos, websites,
    documents, images and notes.
2.  **AI Search & Assistant** --- search only the user's authorized app
    resources, ask questions, upload documents, use voice, and organize
    multiple items.
3.  **Places & Discovery** --- discover budget-friendly restaurants,
    food spots, shopping destinations and experiences on a map; also
    view places personally saved from Instagram, YouTube and other
    sources.
4.  **Secure Vault** --- a future encrypted area for passwords, cards
    and sensitive documents. Plan the boundaries now, but do not
    implement vault storage until its encryption and recovery design has
    been reviewed.

The product should feel simple to use even though its architecture is
sophisticated.

## 3. Non-negotiable existing-project rules

Before editing:

1.  Inspect `pubspec.yaml`, `pubspec.lock`, `lib/`, `android/`, Supabase
    initialization, routing, state management, assets, tests and
    existing environment configuration.
2.  Identify the current Flutter and Dart versions. Keep the existing
    Flutter 3.38.5 baseline if that is what the project uses.
3.  Locate the existing Supabase client initialization and reuse it.
4.  Trace the current signup, login, email verification, password reset
    (if present), session restoration and logout flows.
5.  Identify existing database tables, RLS policies, storage buckets and
    Edge Functions where available.
6.  Create a concise audit report before making structural changes.
7.  Do not replace the current Supabase project, URL, keys,
    authentication configuration or working signup screens.
8.  Never place Supabase service-role keys, secret API keys or private
    provider credentials in Flutter code, assets, source control or the
    APK.
9.  Do not reset, drop, rename or recreate existing database tables
    without explicit approval and a safe migration plan.
10. Do not delete working features, screens, routes, assets or user
    data.
11. Keep changes small and compile/test after each meaningful stage.
12. If a required credential, API key, provider account or schema detail
    is unavailable, build a safe configuration interface or adapter and
    document what the developer must supply. Never invent credentials.

**First deliverable:** an audit of the existing project and a proposed
implementation plan identifying what can be reused, what needs
improvement, and what is missing. Do not start a destructive refactor.

## 4. Target platform and technology decisions

### Current target

-   Android first.
-   Existing Flutter application; preserve its current compatible SDK.
-   Supabase is already connected.
-   Signup screens already work.
-   The same backend should eventually support a Next.js web
    application.

### Preferred architecture

Use feature-based Clean Architecture, adapted to the code already
present.

-   State management: Riverpod, only if not already using a suitable
    working solution.
-   Navigation: go_router, only if compatible with the existing routing.
-   Backend: existing Supabase project and `supabase_flutter`.
-   Cloud database: PostgreSQL.
-   Local database: Drift + SQLite, introduced incrementally.
-   Offline search: SQLite FTS5.
-   Background sync: Android WorkManager where appropriate.
-   Maps: MapLibre-compatible Flutter integration and an OSM-compatible
    tile provider.
-   Location: geolocator, with permission handling and graceful denial.
-   On-device ML: LiteRT / LiteRT-LM or supported Android ML Kit GenAI
    capabilities.
-   Image caching: cached_network_image.
-   File picking: file_picker.
-   Voice input: speech_to_text or a suitable Android-native speech
    integration.
-   Secure storage: Android Keystore-backed platform storage; use a
    reviewed cryptographic implementation for the future Vault.

Do not blindly install the latest versions of packages. Verify
compatibility with the project's Flutter/Dart SDK, Android Gradle
Plugin, Kotlin and Java versions. Pin compatible versions and run
`flutter pub get`, `flutter analyze` and tests.

## 5. Application information architecture

Create or refine these primary destinations while respecting the
existing navigation where possible:

### Home

-   Greeting and profile access.
-   Universal search entry point.
-   Quick Add action.
-   Recently saved resources.
-   Smart Inbox / items needing review.
-   Continue exploring collections.
-   Recent activity and useful shortcuts.

### Collections

-   Technical.
-   Design.
-   Learning.
-   Places.
-   Personal.
-   User-created collections.
-   Standard collections supplied by the app.
-   Nested categories and subcategories.
-   Grid/list presentation.
-   Favorites and custom ordering.

Users may hide a standard collection from their own view, but must not
delete or modify the global system template. Keep system templates
separate from user-owned collection instances.

### AI Assistant

-   Natural-language chat.
-   AI search over the user's own resources.
-   Voice input.
-   URL input.
-   Document and image attachment input.
-   Multi-resource selection and bulk organization.
-   Search results rendered as actual resource cards.
-   Proposed actions shown for review before execution.

### Explore

-   City selection/search.
-   Map/list switch.
-   Budget-friendly places.
-   Food, cafes, shopping, hotels, travel and experiences.
-   Curated recommendations.
-   My Places: personally saved places and linked social-media
    resources.
-   Place details, directions and related saved resources.

### Vault

-   Show a planned/locked placeholder if the rest of the app is ready.
-   Do not store passwords or sensitive data in ordinary resources.
-   Do not implement encryption with improvised cryptography.
-   Implement only after a documented key-management, recovery and
    security design is approved.

### Profile and Settings

-   Account and existing authentication actions.
-   Appearance and accessibility.
-   Sync status.
-   AI privacy and model preferences.
-   Storage and downloads.
-   Data export and account deletion planning.
-   Permissions and privacy controls.

## 6. Design direction --- iOS 26-inspired Liquid Glass

Build a reusable design system rather than styling every screen
independently.

The visual language should be inspired by modern iOS Liquid Glass, but
implemented appropriately for Android and Flutter. Do not claim to
reproduce Apple's native implementation exactly.

Create reusable components such as:

-   `GlassContainer`
-   `GlassCard`
-   `GlassButton`
-   `GlassIconButton`
-   `GlassNavigationBar`
-   `GlassSearchField`
-   `GlassBottomSheet`
-   `GlassDialog`
-   `GlassChip`
-   `GlassFloatingActionButton`
-   `ResourceCard`
-   `PlatformBadge`
-   `ThumbnailPreview`
-   `EmptyState`
-   `SkeletonLoader`
-   `SyncStatusIndicator`

Use:

-   Controlled `BackdropFilter` blur.
-   Translucent surfaces.
-   Subtle gradients and borders.
-   Consistent rounded corners.
-   Clear typography and spacing tokens.
-   Smooth, restrained animations.
-   Proper light and dark themes.
-   Reduced-transparency and reduced-motion fallbacks.
-   Good contrast, accessible touch targets and screen-reader labels.

Performance rules:

-   Avoid excessive nested blur filters in scrolling lists.
-   Prefer one shared background/material layer where possible.
-   Use image caching and lazy lists/grids.
-   Do not animate every card continuously.
-   Test on a mid-range Android device.
-   Provide a simpler material fallback on low-memory devices.

## 7. Resource and collection model

The central concept is **one resource, multiple ways to organize and
discover it**.

Supported resource types:

-   Instagram Reel/post URL.
-   YouTube video/short URL.
-   Website URL.
-   PDF and other supported documents.
-   Images.
-   Notes.
-   Other supported file types.

Each resource should support, where available:

-   UUID.
-   Owner/user ID.
-   Original URL.
-   Canonical URL.
-   Platform/source.
-   Content type.
-   Title.
-   Description.
-   Thumbnail reference.
-   Category and subcategory.
-   Tags.
-   Optional place association.
-   User notes.
-   Saved date.
-   Favorite/archive state.
-   Metadata extraction status.
-   Classification status and confidence.
-   Local/cloud sync state.

A resource can belong to multiple collections without being duplicated.
Use a many-to-many association table.

Standard collection templates must be separate from per-user collection
instances. Hiding or renaming a user's instance must not alter the
global template.

## 8. Universal Android Share-to-App

Implement Android sharing so users can select this app from the Android
share sheet in apps such as Instagram, YouTube, Chrome and other
compatible apps.

Handle:

-   Shared text and URLs.
-   Shared images and supported files.
-   App launched from a terminated state.
-   App already running.
-   Repeated share delivery.
-   Multiple shared items where the source app provides them.
-   `content://` URIs and temporary URI permissions.
-   Text containing both a URL and additional notes.

Suggested flow:

1.  Receive Android share intent.
2.  Validate and normalize input.
3.  Create a local pending resource immediately.
4.  Detect platform.
5.  Attempt metadata extraction.
6.  Attempt classification only when enough evidence exists.
7.  Display a save-preview screen.
8.  Let the user correct title, thumbnail, category, location and
    collection.
9.  Save locally immediately.
10. Synchronize when online.

### Platform-specific extraction

**YouTube** - Parse video ID safely. - Use predictable thumbnail
patterns where available. - Use the YouTube Data API only if a
configured key and quota are available. - Do not assume every thumbnail
resolution exists.

**Instagram** - Preserve the original URL even when metadata is
unavailable. - Use supported and authorized Meta integrations where
configured. - Do not rely on undocumented scraping or bypass access
controls. - Do not promise a thumbnail or caption when it cannot be
obtained.

**Websites** - Extract Open Graph and Twitter metadata where
accessible. - Handle redirects and malformed metadata safely. - Use a
server-side metadata extractor for public URLs.

**Unknown or unsupported links** - Never discard the URL. - Save it to
Smart Inbox. - Ask the user to select a category or leave it
unorganized.

### Security for URL fetching

Any server-side URL extractor must defend against SSRF:

-   Allow only HTTP/HTTPS.
-   Reject localhost, private, link-local and reserved IP ranges.
-   Revalidate every redirect destination.
-   Limit redirect count, response size and timeout.
-   Block unsupported ports and schemes.
-   Do not execute page scripts.
-   Do not forward internal credentials or cloud metadata.
-   Apply rate limits and authenticated ownership checks.

## 9. Smart Inbox and automatic classification

Create resource processing states:

-   `pending`
-   `processing`
-   `needs_review`
-   `organized`
-   `failed`

Classification should use a hybrid pipeline:

1.  Deterministic URL/platform detection.
2.  Metadata and keyword rules.
3.  Lightweight local classifier.
4.  Local generative model only if genuinely required and supported.
5.  Optional cloud model only when the user has opted in.

Suggested initial confidence policy:

-   High confidence: show a suggested category prominently.
-   Medium confidence: request confirmation.
-   Low confidence or missing metadata: send to Smart Inbox.

Do not automatically infer a place from the user's current GPS location.
Distinguish: - Device location. - Place explicitly mentioned in
content. - Actual verified business/place location.

Keep user corrections as feedback data, but do not train or change model
behaviour invisibly without a controlled evaluation process.

## 10. AI Search and local RAG

AI Search must search only resources the authenticated user is
authorized to access.

The search engine must remain useful without a generative model.

### Local search layers

1.  SQLite FTS5 for exact and keyword search.
2.  Metadata filters for category, collection, platform, date, tags and
    location.
3.  Local embeddings for semantic retrieval when the embedding model is
    installed.
4.  Optional local reranking or lightweight classification.

### RAG ingestion

For accessible documents and webpages:

1.  Extract available text.
2.  Clean and normalize it.
3.  Split into chunks.
4.  Preserve source resource ID, page/section and chunk index.
5.  Generate local embeddings.
6.  Store text and embeddings locally.
7.  Retrieve relevant chunks for a query.
8.  Provide source references in the answer.

For social videos, do not assume full transcripts are available. Use
accessible metadata, user notes and authorized transcript sources only.

### Model/version management

Store: - Model identifier. - Model version. - Embedding dimensions. -
Tokenizer/preprocessing version. - Model file checksum. - Index
generation version.

If the embedding model changes, reindex affected resources. Do not
compare vectors produced by incompatible models.

### Local model priority

Use this routing priority:

1.  Local SQL/FTS search.
2.  Local embeddings.
3.  Lightweight LiteRT classifier.
4.  Gemini Nano through Android AICore/ML Kit GenAI only when the device
    supports the exact capability.
5.  Optional LiteRT-LM compatible local generative model if device
    resources permit.
6.  Cloud fallback only if online, configured, enabled by the user and
    within quota.

Do not assume every Android phone supports Gemini Nano. Build a
capability check and a no-model fallback.

Do not bundle a large model in the base APK. Download optional model
files with user consent, integrity checks, versioning and storage
controls.

## 11. AI Assistant and controlled tools

The AI Assistant should accept:

-   Text.
-   Voice transcription.
-   URLs.
-   PDFs and supported documents.
-   Images where supported.

It should support: - Search saved resources. - Find related resources. -
Summarize accessible documents. - Suggest tags and categories. -
Organize multiple selected resources. - Find saved places. - Prepare
collections. - Identify duplicates. - Explain why a result was returned.

Create a restricted tool registry, for example:

-   `search_resources`
-   `get_resource`
-   `search_documents`
-   `extract_url`
-   `suggest_category`
-   `find_collections`
-   `prepare_bulk_organization`
-   `find_places`
-   `prepare_resource_place_link`

The AI must never execute arbitrary SQL or unrestricted database
operations.

Bulk operations must follow:

1.  Select resources.
2.  Analyze them.
3.  Prepare proposed changes.
4.  Show a review screen.
5.  Obtain explicit user confirmation.
6.  Execute validated changes.
7.  Record an operation/audit record.
8.  Offer undo where feasible.

The model's output is untrusted input. Validate IDs, fields, ownership,
permitted actions and all arguments before executing.

## 12. Local and cloud AI routing

Create a provider abstraction, for example:

``` text
AiRouter
  ├── LocalSearchProvider
  ├── LocalEmbeddingProvider
  ├── LocalClassifierProvider
  ├── AndroidGenAiProvider
  ├── LiteRtLmProvider
  └── CloudAiProvider
```

Normalize results into a consistent response structure.

For cloud AI: - Call providers through a trusted backend gateway. -
Store API secrets only in server-side environment secrets. - Verify the
user's Supabase JWT. - Check user opt-in. - Enforce quotas and rate
limits. - Validate structured responses. - Record provider, model,
latency and token usage where available.

Do not send private documents or resource content to cloud AI without an
explicit privacy setting or user action. Clearly indicate when a request
leaves the device.

## 13. Maps and Places

Use MapLibre-compatible Flutter rendering with an appropriately licensed
OpenStreetMap-derived tile provider.

Do not use the public OSM tile servers as an unlimited production
service. Keep the tile provider configurable, show attribution, respect
provider caching/rate limits, and review the selected provider's terms.

Use Supabase/PostGIS for: - Place coordinates. - Nearby queries. -
City/category filtering. - Distance-based discovery.

Separate: 1. Curated public places managed by the application. 2. Places
personally created by a user. 3. Places saved by a user. 4. External
provider records. 5. Social resources linked to a place.

Explore screens should offer:

-   City search/selection.
-   Map/list toggle.
-   Food, cafes, shopping, travel, hotels and experiences.
-   Budget filters.
-   Nearby and popularity filters where data is trustworthy.
-   Place details.
-   Directions handoff.
-   Save/visited/want-to-visit states.
-   Linked Instagram, YouTube and website resources.

For price and rating data: - Store source and verification date. -
Distinguish estimates from verified values. - Never invent prices,
ratings, opening hours or businesses. - Allow stale data to be marked as
needing verification.

## 14. Offline-first database and synchronization

Introduce Drift without replacing the existing Supabase backend.

Local-first flow:

1.  Save resource in a SQLite transaction.
2.  Insert a corresponding outbox operation in the same transaction.
3.  Update UI immediately.
4.  Sync when authenticated and online.
5.  Mark operation as complete after server confirmation.
6.  Retry transient failures with exponential backoff.
7.  Use idempotency keys to avoid duplicate creates.
8.  Preserve tombstones for deletions.
9.  Detect concurrent edits and resolve them deliberately.

Use WorkManager for deferrable background jobs, not exact-time
execution.

Do not assume `connectivity_plus` proves internet access. Verify actual
backend reachability when syncing.

Avoid naive last-write-wins for all data. Use version checks and
preserve conflicting edits when necessary.

## 15. Supabase and PostgreSQL migration policy

The existing Supabase project is already connected. Extend it safely.

Before writing migrations: - Inspect existing schema. - Inspect RLS
policies. - Inspect triggers, functions and storage buckets. - Identify
existing table names and relationships. - Check whether current
user/profile IDs use `auth.users.id`. - Avoid duplicate tables or
incompatible columns.

Potential logical entities, adapted to the actual schema:

-   profiles
-   user_preferences
-   collection_templates
-   user_collections
-   categories
-   resources
-   collection_resources
-   tags
-   resource_tags
-   resource_attachments
-   resource_chunks
-   resource_embeddings
-   ai_conversations
-   ai_messages
-   ai_action_proposals
-   ai_feedback
-   places
-   place_categories
-   user_saved_places
-   place_resource_links
-   place_price_history
-   sync_operations
-   vault_items (future, ciphertext only)

Do not blindly execute a schema copied from a prompt. First reconcile it
with the existing database.

### Database rules

-   Use UUID primary keys.
-   Use explicit foreign keys and indexes.
-   Use timestamps consistently.
-   Add `updated_at` handling.
-   Add ownership constraints.
-   Enable RLS on every user-owned table.
-   Test cross-user access denial.
-   Keep public curated place data read-only to normal users.
-   Use private Storage buckets for user documents.
-   Keep service-role credentials server-side only.

For embeddings, choose one model and fixed vector dimension per index.
Use pgvector only for optional cloud indexing; local search must remain
available independently.

## 16. API and Edge Function boundaries

Use Supabase's existing Data API for ordinary authenticated CRUD.

Use Edge Functions for trusted server-side operations such as: -
`extract-metadata` - `process-resource` - `ai-chat` - `ai-search` -
`ai-classify` - `ai-organize` - `document-process` - `sync-batch` -
`sync-changes` - curated place administration

These are logical capabilities; combine functions where appropriate
rather than creating unnecessary endpoints.

Every function must: - Validate the authenticated user. - Validate
request schema. - Enforce ownership and permissions. - Apply rate
limits. - Return structured errors. - Avoid logging sensitive content. -
Keep secrets server-side.

## 17. Secure Vault --- future phase only

Do not implement the Vault as ordinary database records protected only
by RLS.

Future design requirements: - Client-side authenticated encryption. -
AES-256-GCM or another reviewed authenticated encryption scheme. -
Argon2id-based passphrase key derivation with unique salts and
appropriate parameters. - Device key protection through Android
Keystore. - Unique nonces per encryption key. - Key versioning and
authenticated additional data. - Recovery key or explicitly designed
encrypted key backup. - No plaintext vault secrets in logs, analytics or
ordinary AI context. - Email account reset must not silently reset the
vault encryption key.

Do not start Vault implementation until a security design and recovery
test plan are approved.

## 18. Testing requirements

Create: - Unit tests for use cases and repositories. - Widget tests for
core screens and reusable components. - Database migration tests. - Sync
and retry tests. - AI output validation tests. - Share-intent
integration tests. - RLS isolation tests using separate users. - Android
permission tests. - Performance tests for long lists, thumbnails and map
screens.

Minimum acceptance scenarios:

1.  Existing signup still works.
2.  Existing login and session restoration still work.
3.  A YouTube link can be shared into the app.
4.  An Instagram link is saved even when metadata is unavailable.
5.  A resource can be saved offline.
6.  A resource can belong to multiple collections.
7.  Search works without an internet connection.
8.  AI returns actual resources, not invented links.
9.  Bulk changes require confirmation.
10. A user cannot read another user's resources.
11. A place can link to several personal resources.
12. Map data displays attribution and respects provider policy.
13. Synchronization retries without duplicating records.
14. No service-role key or provider secret exists in the APK.

## 19. Implementation phases

Work incrementally in this order:

### Phase 0 --- Existing-project audit

-   Inspect existing app and Supabase integration.
-   Document current routes, screens, schema and working features.
-   Identify dependency compatibility.
-   Create a safe implementation plan.

### Phase 1 --- UI and app foundation

-   Improve design tokens and Liquid Glass components.
-   Refine navigation and responsive layouts.
-   Preserve existing authentication.
-   Add loading, empty, error and offline states.

### Phase 2 --- Resource engine

-   Resource models and repositories.
-   Collections, categories and tags.
-   Drift local database.
-   Smart Inbox.
-   Basic synchronization.

### Phase 3 --- Universal sharing

-   Android share intents.
-   URL validation.
-   Platform detection.
-   YouTube and website metadata.
-   Instagram fallback.
-   Save-preview UI.

### Phase 4 --- Search and local intelligence

-   SQLite FTS5.
-   Metadata filters.
-   Local classifier.
-   Local embeddings.
-   AI routing and capability detection.

### Phase 5 --- AI Assistant

-   Chat interface.
-   Search tool.
-   Voice input.
-   URL/document input.
-   Local RAG.
-   Bulk proposals and confirmation.
-   Optional cloud AI adapter.

### Phase 6 --- Explore and maps

-   MapLibre integration.
-   Place database and PostGIS.
-   Curated places.
-   Budget filters.
-   User-saved places.
-   Social-resource linking.

### Phase 7 --- Security and production hardening

-   Security review.
-   RLS review.
-   Storage policy review.
-   Sync conflict tests.
-   Performance optimization.
-   Release testing.

### Phase 8 --- Vault and web application

-   Vault threat model, key management and recovery.
-   Next.js frontend using the same Supabase backend.
-   Cross-device synchronization.

## 20. Required working method for Antigravity

Follow this exact development workflow:

1.  Start by inspecting the existing project. Do not edit files yet.
2.  Report the current architecture, working functionality, package
    versions, Supabase integration and missing pieces.
3.  Propose a phased plan that maps the desired architecture onto the
    existing code.
4.  Identify any risky database migrations and request approval before
    destructive changes.
5.  Implement one milestone at a time.
6.  Before each milestone, list the files that will be created or
    modified.
7.  Reuse existing working authentication and Supabase configuration.
8.  Do not create duplicate services, models, screens or database
    tables.
9.  Use typed models and repository abstractions.
10. Add tests for each important business rule.
11. Run formatting, analysis and relevant tests after each milestone.
12. Fix regressions before continuing.
13. Keep a concise `IMPLEMENTATION_STATUS.md` documenting completed
    work, remaining tasks, migrations, configuration and known
    limitations.
14. Do not claim a feature is complete unless it has been implemented
    and tested.
15. Do not fabricate successful API responses, metadata, model
    capabilities, map data or credentials.

### Commands to run at appropriate checkpoints

``` bash
flutter --version
flutter doctor -v
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Run Android builds after dependency or native configuration changes:

``` bash
flutter build apk --debug
```

Do not run destructive database resets or production migrations without
explicit approval.

------------------------------------------------------------------------

# 21. First instruction --- Begin with the audit

**Do not implement the whole product in one attempt.**

Your first task is:

1.  Inspect the existing Flutter project.
2.  Identify the existing Supabase initialization.
3.  Verify the signup and authentication flow without changing it.
4.  Inspect the current database integration and existing tables if the
    project configuration makes them available.
5.  Identify the current state-management and navigation approach.
6.  Check Flutter, Dart, Gradle, Kotlin and package compatibility.
7.  Identify existing reusable UI components.
8.  Produce a project audit and a prioritized implementation plan.

Then stop and present:

-   Existing functionality that must be preserved.
-   Architecture gaps.
-   Files that should be modified.
-   New files/modules required.
-   Database migrations required, if any.
-   Risks and compatibility issues.
-   The exact first implementation milestone.

Wait for approval before making broad structural or database changes.

**Final product objective:** Build a polished, Android-first,
offline-first personal knowledge and discovery application where every
saved resource can be organized, searched, understood and connected to
places --- while preserving the user's control, privacy and data
ownership.
