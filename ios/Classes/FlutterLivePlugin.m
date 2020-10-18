#import "FlutterLivePlugin.h"
#if __has_include(<flutter_live/flutter_live-Swift.h>)
#import <flutter_live/flutter_live-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_live-Swift.h"
#endif

@implementation FlutterLivePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLivePlugin registerWithRegistrar:registrar];
}
@end
