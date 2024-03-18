# privacy-manifest-util

`privacy-manifest-util` is a command line tool and a Swift library for 
manipulating privacy manifest files (`PrivacyInfo.xcprivacy`) and App Store Connect nutrition 
label JSON files as used by Fastlane (`app_privacy_details.json`).

Currently supported operations:

- `join`: Join multiple privacy manifest files together.
- `from-nutrition`: Convert an `app_privacy_details.json` file to a privacy manifest.
- `to-nutrition`: Convert a `PrivacyInfo.xcprivacy` file to an `app_privacy_details.json`.
