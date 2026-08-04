fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Increment build number

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Increment marketing version (type: patch|minor|major)

### ios release_letsstretch

```sh
[bundle exec] fastlane ios release_letsstretch
```

Build and upload IPA via altool

Options: skip_bump:true to reuse current build number

### ios upload_letsstretch_ipa

```sh
[bundle exec] fastlane ios upload_letsstretch_ipa
```

Upload existing LetsStretch.ipa via altool

### ios submit_letsstretch

```sh
[bundle exec] fastlane ios submit_letsstretch
```

Create App Store version, attach build, upload release notes, optionally submit

Options: submit:true, skip_screenshots:true

### ios ship

```sh
[bundle exec] fastlane ios ship
```

One-shot: bump minor version, build, altool upload, wait, submit

### ios release

```sh
[bundle exec] fastlane ios release
```

Alias for release_letsstretch

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
