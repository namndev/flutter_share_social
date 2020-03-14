#import "FlutterShareSocialPlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation FlutterShareSocialPlugin{
    FlutterMethodChannel* _channel;
    UIDocumentInteractionController* _dic;
    FlutterResult _result;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_share_social"
            binaryMessenger:[registrar messenger]];
  FlutterShareSocialPlugin* instance = [[FlutterShareSocialPlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
    self = [super init];
    if(self) {
        _channel = channel;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application
     didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
   return YES;
 }

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
                (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
   BOOL handled = [[FBSDKApplicationDelegate sharedInstance]
             application:application
                 openURL:url
       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
  return handled;
}

 - (BOOL)application:(UIApplication *)application
               openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication
            annotation:(id)annotation {
   BOOL handled =
       [[FBSDKApplicationDelegate sharedInstance] application:application
                                                      openURL:url
                                            sourceApplication:sourceApplication
                                                   annotation:annotation];
   return handled;
 }

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"facebookShare" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          result(false);
      }
    } else if ([@"facebookSharePhotos" isEqualToString:call.method]) {
        NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
        if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
            [self facebookSharePhotos:call.arguments[@"paths"]];
            result(nil);
        } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          result(false);
      }
    } else if([@"facebookShareLink" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShareLink:call.arguments[@"quote"] url:call.arguments[@"url"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          result(false);
      }
    } else if ([@"instagramShare" isEqualToString:call.method]) {
      NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
      if([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
          [self instagramShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *instagramLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id389801252";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramLink]];
          result(false);
      }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)facebookShare:(NSString*)imagePath {
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)facebookSharePhotos:(NSArray*)imagePaths {
    NSString *imagePath;
    NSArray *photos = [NSArray array];
    for(imagePath in imagePaths){
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        photos= [photos arrayByAddingObject:photo];
    }
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = photos;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)facebookShareLink:(NSString*)quote
                      url:(NSString*)url {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    content.quote = quote;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)instagramShare:(NSString*)imagePath {
    NSError *error = nil;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [[NSFileManager defaultManager] moveItemAtPath:imagePath toPath:[NSString stringWithFormat:@"%@.igo", imagePath] error:&error];
    NSURL *path = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@.igo", imagePath]];
    _dic = [UIDocumentInteractionController interactionControllerWithURL:path];
    _dic.UTI = @"com.instagram.exclusivegram";
    if (![_dic presentOpenInMenuFromRect:CGRectZero inView:controller.view animated:TRUE]) {
        NSLog(@"Error sharing to instagram");
    };
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    [_channel invokeMethod:@"onSuccess" arguments:results[@"postId"]];
    NSLog(@"Sharing completed successfully");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    [_channel invokeMethod:@"onCancel" arguments:nil];
    NSLog(@"Sharing cancelled");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    [_channel invokeMethod:@"onError" arguments:nil];
    NSLog(@"%@",error);
}

@end
