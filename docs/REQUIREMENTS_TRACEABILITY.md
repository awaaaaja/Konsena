# Requirements traceability and phase gates

| Capability | Screen IDs | Phase impl | Real check | Gate |
|---|---|---|---|---|
| Repo Flutter + baseline Supabase (Auth, RLS, bucket private) | infra non-screen | 00 | Flutter test/build; Supabase local migration reset; pgTAP RLS user A/B; status remote explicit | required infrastructure (remote may remain pending) |
| Branding, Splash, onboarding | S00–S03 | 01A | golden/widget + skip flow | required |
| Five bottom tabs and route map | S03/S06/S19/S21/S24, seluruh S00–S39 | 01B | route smoke test 40 screen, guest tab profile | required |
| UX states & accessibility | S00–S39 | 01C | text 200%, back state, TalkBack labels, tap 48dp | required |
| Audit workspace lokal | S14/S24/S19/S34 | 02 | restart, attach/detach, local migration | required |
| Android native inspector | S04/S05 | 03 | physical device, actual permission snapshot | required |
| PDF/image/text import+OCR | S07/S11/S25/S26/S28 | 04 | 6 real fixtures, corrupt/password errors | required |
| Camera-to-laptop LiveScan | S08–S11/S27/S35/S39 | 05 | real camera+monitor, overlap/gap trace | required |
| Consent screenshot, evidence, actions | S12/S13/S15/S16/S17/S29–S32 | 06 | source provenance + no fake ML | required |
| PDF/history/privacy/cloud sync opt-in | S18/S19/S20–S23/S33–S37 | 07 | export/delete/guest offline; login + explicit sync, conflict/retry; remote RLS test if configured | required; cloud may be blocked |
| Product stability | All | 08 | builds, accessibility, performance, permissions audit | required |
| NLP/CV ONNX | S15/S29–S31 | 09 | manifests + tokenizer parity + model card + real metrics | conditional: requires artifacts |
| Pilot/release | All | 10 | tested APK/AAB, privacy docs, known issues | required after chosen scope |

## Source and model truth

- Flutter pages are present only when generated and tested. Spec doesn't equal implementation.
- `analysis_available=false` before Phase 09; do not fabricate scores or prediction arrays.
- `dark_pattern_detected` only when supported by valid evidence and tested inference.
- PermissionInspector uses PackageManager visibility, not usage tracking; app cannot change another app's permissions programmatically.
- Opt-in sync is privacy-sensitive: default false, RLS tested, no silent raw evidence upload.
