# Translating 240-MP

240-MP uses Qt Linguist: English is the source language, TS files contain editable translations, and CMake compiles them into QM resources embedded in the executable. `i18n/240mp_cs.ts` is the initial **unfinished Czech template**, not a completed Czech translation. Unfinished/missing entries fall back to English. No translation service or network connection is used.

## User language selection

Settings → Language offers the system language, English, and Czech. The stable selection (`auto`, `en`, `cs`) is stored as `app.language` in the existing config.json. Restart the application after changing it. Only UI language changes: media languages, date/numeric parsing, server APIs, configuration values and content metadata keep their original values. Unsupported locales fall back to English. System mode checks the OS UI-language preference list in order.

The existing Unifont fallback covers glyphs missing from the retro VCR font. Check accented letters and long text on an actual low-resolution/CRT display before declaring a translation complete.

## Update and edit a catalog

Install the Qt Linguist tools as described in BUILDING.md, then run from the repository root:

```sh
python3 scripts/update-manifest-translations.py
cmake -B build
cmake --build build --target 240mp_lupdate
```

Open `i18n/240mp_cs.ts` in Qt Linguist. Translate and mark entries finished, then rebuild:

```sh
python3 scripts/check-translations.py
cmake --build build
```

Do not edit generated `i18n/ManifestStrings.h` or `i18n/MpvStrings.h`. Commit updated generated extraction headers and TS catalogs; QM files belong to the build tree and must not be committed. Updating catalogs removes obsolete source entries, so version control retains their history.

To add another language, add its TS path to `qt_add_translations` in CMakeLists.txt, add its code and native name to LanguageManager, and run lupdate. English needs no QM file. Keep the `240mp_<code>.ts` naming scheme consistent with LanguageManager's resource lookup.

## Marking source strings

Use `qsTr("Settings")` for QML and `tr("Message")` inside QObject C++ classes. Use whole sentences with placeholders rather than concatenating translated fragments:

```qml
text: qsTr("Installed: %1").arg(root.appVersion)
// %n handles the plural rules of the target language:
text: qsTr("%n item(s)", "", itemCount)
```

Keep placeholders (`%1`, `%2`, `%n`), keyboard hints, required line breaks and markup intact. Add a `//:` translator comment when the context is unclear. Duplicate QML basenames share a Qt context, so use the optional disambiguation argument or qsTranslate for strings needing different meanings.

Settings stored in config files **must remain language independent**. Never translate IDs, action names, enum values, JSON keys, URLs or mpv commands. `ModuleSettings` uses raw booleans and option IDs for behavior, translated labels for presentation. Application settings have the same distinction. The toggle regression test uses non-English ON/OFF labels to catch this class of bug.

## Modules and external playback

Module manifest names, setting labels, descriptions, and static option labels are extracted into contexts named after each module ID. `AppCore` translates copies returned to the UI, leaving manifest files, option IDs and defaults untouched. Run the extraction generator after editing a manifest. Static backend option labels and user-visible errors use the backend's `tr()` context; server-provided library names, titles and language metadata stay as content.

mpv is a separate process. `MpvController` writes a small translated UI dictionary into the existing app data directory and passes its path to the normal and ambient OSC scripts. These use `mpv-i18n.lua` and the `MpvOsd` catalog context. Missing/unreadable dictionaries fall back to English, and dictionary values never drive player actions.

## Validation and remaining review

The Translation checks workflow compiles Linux x86_64 and ARM64, runs lupdate/lrelease, tests locale selection and catalog loading on both architectures, checks translated toggle behavior and QML parsing on desktop Qt 6.7, and validates the mpv dictionary fallback. Ubuntu’s ARM builder has Qt 6.4, so visual-QML tests requiring the upstream QtQuick.Effects module run on the desktop job. Test catalogs are separate from the unfinished production catalog.

This preparation marks the common shell, module UI labels, keyboard footers, backend option labels/errors and the main mpv menus. Before completing a language, review remaining dynamically assembled messages and helper-function return strings (for example media/track descriptions, backend responses and weather-provider text). Do not indiscriminately translate strings: many are protocol values or user/server content. Long/RTL translations and macOS visual behavior still need human verification. Switching language during a running session is intentionally not implemented; cached models, backend state and the external mpv process all pick up the new language on restart.
