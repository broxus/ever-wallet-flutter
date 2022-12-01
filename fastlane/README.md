fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android deploy_google_play_internal

```sh
[bundle exec] fastlane android deploy_google_play_internal
```

Deploy a new build to the Google Play Internal channel

### android deploy_fad

```sh
[bundle exec] fastlane android deploy_fad
```

Deploy a new build to the FAD

----


## iOS

### ios deploy_testflight

```sh
[bundle exec] fastlane ios deploy_testflight
```

Deploy a new build to the TestFlight

### ios deploy_fad

```sh
[bundle exec] fastlane ios deploy_fad
```

Deploy a new build to the FAD

### ios match_assure

```sh
[bundle exec] fastlane ios match_assure
```

Assure there is correct iOS certs and profiles

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
