/**
 * Nexus Dev Orchestrator - iOS Build Configuration
 * Release build with signing and security hardening
 */

// ios/Runner/Info.plist additions
/*
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.x.ai</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSRequiresCertificateTransparency</key>
            <true/>
        </dict>
        <key>api.exa.ai</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSRequiresCertificateTransparency</key>
            <true/>
        </dict>
        <key>generativelanguage.googleapis.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSRequiresCertificateTransparency</key>
            <true/>
        </dict>
    </dict>
</dict>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Nexus Dev Orchestrator uses speech recognition for voice commands</string>
<key>NSMicrophoneUsageDescription</key>
<string>Nexus Dev Orchestrator uses microphone for voice input</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<key>ITSAppUsesNonExemptEncryption</key>
<false/>
*/

// ios/Runner/Release.xcconfig
/*
// Release build configuration
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = YOUR_TEAM_ID
PROVISIONING_PROFILE_SPECIFIER = Nexus Dev Orchestrator Release

// Security
ENABLE_BITCODE = NO
ENABLE_HARDENED_RUNTIME = YES
OTHER_LDFLAGS = -Wl,-dead_strip
STRIP_INSTALLED_PRODUCT = YES
STRIP_STYLE = all
DEPLOYMENT_POSTPROCESSING = YES
SEPARATE_STRIP = YES
STRIP_BITCODE_FROM_COPIED_FILES = YES

// Optimization
SWIFT_OPTIMIZATION_LEVEL = -O
GCC_OPTIMIZATION_LEVEL = fast
GCC_GENERATE_DEBUGGING_SYMBOLS = NO
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym

// App signing
CODE_SIGN_IDENTITY = Apple Distribution
CODE_SIGN_INJECT_BASE_ENTITLEMENTS = YES

// Version
MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 1
*/

// ios/Runner/Debug.xcconfig
/*
// Debug build configuration
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = YOUR_TEAM_ID

ENABLE_HARDENED_RUNTIME = NO
STRIP_INSTALLED_PRODUCT = NO
GCC_GENERATE_DEBUGGING_SYMBOLS = YES
DEBUG_INFORMATION_FORMAT = dwarf

MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 1
*/

// ios/Podfile additions
/*
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['ENABLE_HARDENED_RUNTIME'] = 'YES'
      config.build_settings['CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED'] = 'YES'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'YES'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      
      if config.name == 'Release'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
        config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'YES'
        config.build_settings['STRIP_STYLE'] = 'all'
        config.build_settings['DEPLOYMENT_POSTPROCESSING'] = 'YES'
      end
    end
  end
end
*/

// ios/Runner/Runner.entitlements (Release)
/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <false/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
    <key>com.apple.security.get-task-allow</key>
    <false/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <false/>
    <key>com.apple.security.cs.disable-executable-page-protection</key>
    <false/>
</dict>
</plist>
*/
