import 'dart:async';
import 'package:flutter/services.dart';

typedef Future<dynamic> OnCancelHandler();
typedef Future<dynamic> OnErrorHandler(String error);
typedef Future<dynamic> OnSuccessHandler(String postId);

class FlutterShareSocial {
  static const MethodChannel _channel =
      const MethodChannel('flutter_share_social');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  static Future<String?> instagramShare(
      {String type = 'image/*', required String path}) async {
    return _channel.invokeMethod<String>('instagramShare', <String, dynamic>{
      'type': type,
      'path': path,
    });
  }

  static Future<String?> facebookShare({
    String? caption,
    required String path,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((MethodCall call) async{
      switch (call.method) {
         case "onSuccess":
          if (onSuccess != null){
            return onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            return onCancel();
          }
          break;
        case "onError":
        if (onError != null) {
          return onError(call.arguments);
        }
        break;
        default:
          throw UnsupportedError("Unknown method called");
      }
      return call.arguments;
    });
    return _channel.invokeMethod<String>('facebookShare', <String, dynamic>{
      'caption': caption,
      'path': path,
    });
  }

  static Future<String?> facebookSharePhotos({
    required List<String> paths,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null){
            return onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            return onCancel();
          }
          break;
        case "onError":
        if (onError != null) {
          return onError(call.arguments);
        }
        break;
        default:
          throw UnsupportedError("Unknown method called");
      }
      return call.arguments;
    });
    return _channel.invokeMethod<String>('facebookSharePhotos', <String, dynamic>{
      'paths': paths,
    });
  }

  static Future<String?> facebookShareLink({
    String? quote,
    required String url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((MethodCall call) async{
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null){
            return onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            return onCancel();
          }
          break;
        case "onError":
        if (onError != null) {
          return onError(call.arguments);
        }
        break;
        default:
          throw UnsupportedError("Unknown method called");
      }
      return call.arguments;
    });
    return _channel.invokeMethod<String>('facebookShareLink', <String, dynamic>{
      'quote': quote,
      'url': url,
    });
  }
}
