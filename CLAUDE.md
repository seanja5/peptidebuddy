# PeptideBuddy — Claude Notes

## Project Overview
iOS SwiftUI app (iOS 17+) — peptide education and community platform. White/grey/blue color scheme. Educational/community content only, no medical advice.

## Tech Stack
- **Language**: Swift 5, SwiftUI
- **Min deployment**: iOS 17.0
- **Bundle ID**: `com.seanandrews.PeptideBuddy`
- **Backend**: Supabase (project ID: `zxvlnpslpgcpbkitpkew`, region: us-east-1)
- **Auth**: Supabase email/password (Google OAuth infrastructure is in place but not wired — see AuthManager.swift)
- **Package**: `supabase/supabase-swift` via SPM (registered in pbxproj, resolves on first Xcode open)

## Supabase
- **URL**: `https://zxvlnpslpgcpbkitpkew.supabase.co`
- **Anon key**: in `SupabaseClient.swift`
- **Email confirmation**: must be OFF in dashboard → Authentication → Providers → Email → "Confirm email"
- **Tables**: `profiles`, `peptides`, `community_notes`, `news_articles`
- **Seeded**: 10 peptides, 5 news articles
- **RLS**: enabled on all tables; public SELECT, auth-gated INSERT/UPDATE

## File Structure
```
PeptideBuddy/
├── PeptideBuddyApp.swift      — @main entry, injects AuthManager env object
├── ContentView.swift          — RootView router (splash → auth → profile setup → tabs) + MainTabView
├── SupabaseClient.swift       — global supabase client singleton
├── DesignSystem.swift         — Color tokens, DS.Spacing, DS.Radius, DS.Avatar
├── AuthManager.swift          — ObservableObject; email sign-up/in/out; auth state stream
├── AuthView.swift             — email/password sign-in + sign-up toggle screen (blue bg)
├── SplashView.swift           — animated blue splash, fades out after 1.8s
├── UserProfile.swift          — Codable model for profiles table
├── CommunityNote.swift        — Codable models: CommunityNote, NoteAuthor, NotePeptide, Peptide
├── NewsArticle.swift          — Codable model + NewsCategory enum
├── CommunityNotesView.swift   — feed + NoteCardView + filter chips + picker sheets
├── CommunityViewModel.swift   — fetch + client-side filter (peptide/goal/age/recency)
├── NewsView.swift             — category strip + NewsCardView + NewsDetailView
├── NewsViewModel.swift        — fetch + filter by category
├── ProfileView.swift          — profile display + ProfileSetupView (first-time username creation)
├── ProfileViewModel.swift     — fetch profile + upsert on create
└── Info.plist                 — manual plist; includes URL scheme com.seanandrews.PeptideBuddy
```

## Design System (DesignSystem.swift)
| Token | Hex | Use |
|---|---|---|
| `primaryBlue` | `#2563EB` | CTAs, active tab, accent |
| `lightBlue` | `#3B82F6` | chips, secondary highlights |
| `appBackground` | `#FFFFFF` | screen backgrounds |
| `appSurface` | `#F8FAFC` | card/input backgrounds |
| `appBorder` | `#E2E8F0` | borders, dividers |
| `textPrimary` | `#1E293B` | headings, body |
| `textSecondary` | `#64748B` | metadata, labels |
| `textTertiary` | `#94A3B8` | timestamps, captions |
| `splashBG` | `#1D4ED8` | splash + auth screen background |
| `splashText` | `#E2E8F0` | text on dark blue bg |

**Rule**: always set `.foregroundStyle(Color.textPrimary)` on TextFields with light backgrounds.

## App Flow
```
Launch → SplashView (1.8s)
  → AuthManager.isLoadingSession? → spinner
  → not authenticated → AuthView (email/password)
  → authenticated, no profile → ProfileSetupView
  → authenticated, has profile → MainTabView (Community | News | Profile)
```

## Known Issues / Remaining Work
- Google OAuth is scaffolded (AuthManager has `signInWithGoogle`) but not activated — needs Google Cloud credentials + Supabase Google provider enabled
- Community Notes tab will be empty until real users post (seed data not added for notes — requires real profile IDs)
- Profile avatar upload not implemented (shows initials placeholder)
- No post-creation flow yet (users can read notes but not write them in-app)
- AccentColor set to `#2563EB` in Assets.xcassets

## Xcode Notes
- SPM package resolves automatically on first open (File → Packages → Resolve Package Versions)
- `GENERATE_INFOPLIST_FILE = NO` — uses manual `PeptideBuddy/Info.plist`
- All new Swift files are registered in `project.pbxproj` — no need to re-add via Xcode
- IDE may show "No such module Supabase" in Cursor/SourceKit — this is normal, build succeeds in Xcode

## GitHub
- Repo: `https://github.com/seanja5/peptidebuddy`
- Branch: `main`
