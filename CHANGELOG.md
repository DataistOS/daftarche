# Changelog

## [0.1.1] - 2026-11-09

### Refactor
- Modularized project architecture by introducing dedicated layers:
    - Added `ContactService` in `lib/services/` for managing Upupa SDK backend calls.
    - Moved `ContactsScreen` to `lib/screens/` for cleaner UI management.
- Streamlined `main.dart` to focus solely on app initialization and global theme configuration.

## [0.1.0] - 2026-11-08

### Added
- Initial project structure for **Daftarche** (Contact Management Application).
- Integrated local `upupa_dart` dependency and configured `pubspec.yaml`.
- Implemented `ContactsScreen` with Upupa SDK integration supporting fetching, adding, and deleting contacts.
- Added standard Flutter `.gitignore` and project metadata files.