import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

typedef Future<dynamic> OnCancelHandler();
typedef Future<dynamic> OnErrorHandler(String error);
typedef Future<dynamic> OnSuccessHandler(String postId);

class FlutterShareSocial {
  static const MethodChannel _channel =
      const MethodChannel('flutter_share_social');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> instagramShare(
      {String type = 'image/*', @required String path}) async {
    return _channel.invokeMethod('instagramShare', <String, dynamic>{
      'type': type,
      'path': path,
    });
  }

  static Future<void> facebookShare({
    String caption,
    @required String path,
    OnSuccessHandler onSuccess,
    OnCancelHandler onCancel,
    OnErrorHandler onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess(call.arguments);
        case "onCancel":
          return onCancel();
        case "onError":
          return onError(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('facebookShare', <String, dynamic>{
      'caption': caption,
      'path': path,
    });
  }

  static Future<void> facebookSharePhotos({
    @required List<String> paths,
    OnSuccessHandler onSuccess,
    OnCancelHandler onCancel,
    OnErrorHandler onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess(call.arguments);
        case "onCancel":
          return onCancel();
        case "onError":
          return onError(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('facebookSharePhotos', <String, dynamic>{
      'paths': paths,
    });
  }

  static Future<dynamic> facebookShareLink({
    String quote,
    @required String url,
    OnSuccessHandler onSuccess,
    OnCancelHandler onCancel,
    OnErrorHandler onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess(call.arguments);
        case "onCancel":
          return onCancel();
        case "onError":
          return onError(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('facebookShareLink', <String, dynamic>{
      'quote': quote,
      'url': url,
    });
  }
}
