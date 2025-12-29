#!/bin/bash
set -e  # Exit on any error

SIMULATOR_SDK="iphonesimulator"
DEVICE_SDK="iphoneos"

PACKAGE="Monext"
CONFIGURATION="Release"
DEBUG_SYMBOLS="true"

BUILD_DIR="$(pwd)/build"
DIST_DIR="$(pwd)/dist"

# Verify SDKs are available
echo "🔍 Verifying SDKs..."
IPHONEOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)

echo "Device SDK: $IPHONEOS_SDK_PATH"
echo "Simulator SDK: $IPHONESIMULATOR_SDK_PATH"

if [ ! -d "$IPHONEOS_SDK_PATH" ]; then
  echo "❌ ERROR: iOS SDK not found at $IPHONEOS_SDK_PATH"
  exit 1
fi

if [ ! -d "$IPHONESIMULATOR_SDK_PATH" ]; then
  echo "❌ ERROR: iOS Simulator SDK not found at $IPHONESIMULATOR_SDK_PATH"
  exit 1
fi

build_framework() {
  scheme=$1
  sdk=$2
  if [ "$sdk" = "$SIMULATOR_SDK" ]; then
    dest="generic/platform=iOS Simulator"
  elif [ "$sdk" = "$DEVICE_SDK" ]; then
    dest="generic/platform=iOS"
  else
    echo "❌ Unknown SDK $sdk"
    exit 11
  fi

  echo "=========================================="
  echo "Building framework"
  echo "Scheme: $scheme"
  echo "Configuration:  $CONFIGURATION"
  echo "SDK: $sdk"
  echo "Destination: $dest"
  echo "=========================================="
  echo

  xcodebuild -scheme "$scheme" \
    -configuration "$CONFIGURATION" \
    -destination "$dest" \
    -sdk "$sdk" \
    -derivedDataPath "$BUILD_DIR" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    ENABLE_PREVIEWS=NO \
    OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" || exit 12

  product_path="$BUILD_DIR/Build/Products/$CONFIGURATION-$sdk"
  framework_path="$BUILD_DIR/Build/Products/$CONFIGURATION-$sdk/PackageFrameworks/$scheme.framework"

  # Verify framework was created
  if [ ! -d "$framework_path" ]; then
    echo "❌ ERROR:  Framework not found at $framework_path"
    ls -la "$BUILD_DIR/Build/Products/$CONFIGURATION-$sdk/" || true
    exit 13
  fi

  # Copy Headers
  headers_path="$framework_path/Headers"
  mkdir -p "$headers_path"
  
  # Find Swift header (try both arm64 and x86_64)
  for arch in arm64 x86_64; do
    swift_header="$BUILD_DIR/Build/Intermediates.noindex/$PACKAGE.build/$CONFIGURATION-$sdk/$scheme.build/Objects-normal/$arch/$scheme-Swift. h"
    if [ -f "$swift_header" ]; then
      cp -pv "$swift_header" "$headers_path/" || exit 14
      break
    fi
  done

  # Copy other headers from Sources/
  if [ -d "Sources/$scheme" ]; then
    find "Sources/$scheme" -name "*.h" -exec cp -pv {} "$headers_path/" \; 2>/dev/null || true
  fi

  # Copy Modules
  modules_path="$framework_path/Modules"
  mkdir -p "$modules_path"
  
  modulemap="$BUILD_DIR/Build/Intermediates.noindex/$PACKAGE. build/$CONFIGURATION-$sdk/$scheme.build/$scheme.modulemap"
  if [ -f "$modulemap" ]; then
    cp -pv "$modulemap" "$modules_path/module.modulemap" || exit 15
  fi
  
  mkdir -p "$modules_path/$scheme.swiftmodule"
  cp -pv "$product_path/$scheme.swiftmodule"/*. * "$modules_path/$scheme. swiftmodule/" || exit 16

  # Copy Bundle
  bundle_dir="$product_path/${PACKAGE}_$scheme.bundle"
  if [ -d "$bundle_dir" ]; then
    echo "📦 Copying bundle from $bundle_dir"
    cp -prv "$bundle_dir"/* "$framework_path/" || exit 17
  else
    echo "⚠️  Bundle not found at $bundle_dir (this may be normal)"
  fi
  
  echo "✅ Successfully built $scheme for $sdk"
}

create_xcframework() {
  scheme=$1

  echo "=========================================="
  echo "Creating $scheme.xcframework"
  echo "=========================================="

  args=""
  shift 1
  for p in "$@"; do
    framework="$BUILD_DIR/Build/Products/$CONFIGURATION-$p/PackageFrameworks/$scheme.framework"
    if [ !  -d "$framework" ]; then
      echo "❌ ERROR: Framework not found at $framework"
      exit 20
    fi
    args+=" -framework $framework"
    
    if [ "$DEBUG_SYMBOLS" = "true" ]; then
      dsym="$BUILD_DIR/Build/Products/$CONFIGURATION-$p/$scheme.framework.dSYM"
      if [ -d "$dsym" ]; then
        args+=" -debug-symbols $dsym"
      else
        echo "⚠️  dSYM not found at $dsym"
      fi
    fi
  done

  mkdir -p "$DIST_DIR"
  xcodebuild -create-xcframework $args -output "$DIST_DIR/$scheme.xcframework" || exit 21
  
  echo "✅ Successfully created $scheme.xcframework"
}

reset_package_type() {
  # Remove "type: .dynamic," if it exists
  sed -i '' 's/ type: .dynamic,//g' Package.swift || exit 1
}

set_package_type_as_dynamic() {
  local lib_name=$1
  # Add "type: .dynamic," after the library name
  # This works by finding ". library(name: "LibName"," and inserting "type: .dynamic, " before the "targets:"
  sed -i '' "/\.library(name: \"$lib_name\"/,/targets:/ s/targets:/type: .dynamic, targets: /" Package.swift || exit 1
}

echo "**********************************"
echo "******* Build XCFrameworks *******"
echo "**********************************"
echo

rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR"

reset_package_type

set_package_type_as_dynamic "$PACKAGE"

# Show the modified Package.swift for debugging
echo "📄 Modified Package.swift (library section):"
grep -A 5 "\. library" Package.swift || true
echo ""

build_framework "$PACKAGE" "$SIMULATOR_SDK"
build_framework "$PACKAGE" "$DEVICE_SDK"
create_xcframework "$PACKAGE" "$SIMULATOR_SDK" "$DEVICE_SDK"

echo ""
echo "✅ Build completed successfully!"
echo "📦 XCFramework available at: $DIST_DIR/$PACKAGE.xcframework"
