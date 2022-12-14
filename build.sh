#!/bin/bash

set -eo pipefail

clean=false
ios_match_assure=false
ios_match_new_devices=false
deploy_store=false
deploy_fad=false

usage() {
  echo "Usage: $0 [--clean] [--ios_match_assure] [--ios_match_new_devices] [--deploy_store] [--deploy_fad]"
}

get_build_number() {
  echo "#️⃣  Getting next build number"
  build_number=`node build_number.js`
  echo "#️⃣  Next build number: $build_number"
  build_number_string="--build-number=$build_number"
}

get_changelog() {
  echo "🌳  Getting changelog"
  branch=`git branch | sed -n '/\* /s///p'`
  log=`git log -n 10`
  changelog_string="Branch: $branch "$'\n'"Changes: $log"
}

clean_and_install() {
  echo "🧹  Cleaning all"
  flutter clean
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  flutter gen-l10n
}

if [ $# -eq 0 ]
  then
    usage
fi

while [ "$1" != "" ]; do
    case $1 in
        --clean )                         clean=true
                                          ;;
        --ios_match_assure )              ios_match_assure=true
                                          ;;
        --ios_match_new_devices )         ios_match_new_devices=true
                                          ;;
        --deploy_store )                  deploy_store=true
                                          ;;
        --deploy_fad )                    deploy_fad=true
                                          ;;
        -h | --help )                     usage
                                          exit 0
                                          ;;
        * )                               echo Unknown param $1
                                          ;;
    esac
    shift
done

if [ $ios_match_assure = true ]; then
  echo "📜  Making sure the iOS certificates and profiles are installed"

  fastlane ios match_assure
fi

if [ $ios_match_new_devices = true ]; then
  echo "📜  Registering new devices already added through devportal"

  fastlane ios match_new_devices
fi

if [[ $clean = true || $deploy_store = true || $deploy_fad = true ]]; then
  clean_and_install
fi

if [ $deploy_store = true ]; then
  echo "🛒  Deploy to stores"

  get_build_number

  echo "🛒🏗️  Build IPA"
  flutter build ipa --release --export-options-plist ios/export_options_appstore.plist $build_number_string

  echo "🛒🏗️🤖  Build AAB"
  flutter build appbundle $build_number_string

  echo "🛒  Deploy IPA"
  fastlane ios deploy_testflight

  echo "🛒🤖  Deploy AAB"
  fastlane android deploy_google_play_internal

  echo "🛒  Deploy to stores done, build number $build_number"
fi

if [ $deploy_fad = true ]; then
  echo "🔥  Deploy to FAD"

  get_build_number
  get_changelog

  echo "🔥🏗️  Build IPA"
  flutter build ipa --release --export-options-plist ios/export_options_adhoc.plist $build_number_string

  echo "🔥🏗️🤖  Build APK"
  flutter build apk $build_number_string

  echo "🔥  Deploy IPA"
  fastlane ios deploy_fad changelog_string:"$changelog_string"

  echo "🔥🤖  Deploy APK"
  fastlane android deploy_fad changelog_string:"$changelog_string"

  echo "🔥  Deploy to FAD done, build number $build_number"
fi

echo "🎉 All done!"


