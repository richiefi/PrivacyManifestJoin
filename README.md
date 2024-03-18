# privacy-manifest-util

`privacy-manifest-util` is a command line tool and a Swift library for 
manipulating [privacy manifest files] (`PrivacyInfo.xcprivacy`) and App Store Connect nutrition 
label JSON files as [used by Fastlane][fastlane-privacy-details] (`app_privacy_details.json`).

Currently supported operations:

- `join`: Join multiple privacy manifest files together.
- `from-nutrition`: Convert an `app_privacy_details.json` file to a privacy manifest.
- `to-nutrition`: Convert a privacy manifest file to an `app_privacy_details.json`.

[privacy manifest files]: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
[fastlane-privacy-details]: https://docs.fastlane.tools/uploading-app-privacy-details/

