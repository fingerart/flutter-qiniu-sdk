#import "FlutterQiniuSdkPlugin.h"
#import <flutter_qiniu_sdk/flutter_qiniu_sdk-Swift.h>

@implementation FlutterQiniuSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterQiniuSdkPlugin registerWithRegistrar:registrar];
}
@end
