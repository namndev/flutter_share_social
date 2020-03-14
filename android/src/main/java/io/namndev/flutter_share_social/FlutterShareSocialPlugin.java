package io.namndev.flutter_share_social;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
//
import androidx.core.content.FileProvider;
import java.util.ArrayList;
import java.util.List;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
//
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.ShareDialog;

/** FlutterShareSocialPlugin */
public class FlutterShareSocialPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
  private final static String FACEBOOK_PACKAGE_NAME = "com.facebook.katana";
  private final static String INSTAGRAM_PACKAGE_NAME = "com.instagram.android";
  
  private final Registrar registrar;
  private final MethodChannel channel;
  private final CallbackManager callbackManager;

  private FlutterShareSocialPlugin(final Registrar registrar, final MethodChannel channel) {
    this.channel = channel;
    this.registrar = registrar;
    this.callbackManager = CallbackManager.Factory.create();
    this.registrar.addActivityResultListener(this);
  }
  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_share_social");
    channel.setMethodCallHandler(new FlutterShareSocialPlugin(registrar, channel));
  }

   @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return callbackManager.onActivityResult(requestCode, resultCode, data);
    }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    final PackageManager pm = registrar.activeContext().getPackageManager();
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "facebookShare":
        try {
            pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
            facebookShare(call.<String>argument("caption"), call.<String>argument("path"));
            result.success(true);
        } catch (PackageManager.NameNotFoundException e) {
            openPlayStore(FACEBOOK_PACKAGE_NAME);
            result.success(false);
        }

        result.success(null);
        break;
      case "facebookSharePhotos":
        try {
            pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
            facebookSharePhotos((ArrayList<String>) call.<List<String>>argument("paths"));
            result.success(true);
        } catch (PackageManager.NameNotFoundException e) {
            openPlayStore(FACEBOOK_PACKAGE_NAME);
            result.success(false);
        }

        result.success(null);
        break;
      case "facebookShareLink":
        try {
            pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
            facebookShareLink(call.<String>argument("quote"), call.<String>argument("url"));
            result.success(true);
        } catch (PackageManager.NameNotFoundException e) {
            openPlayStore(FACEBOOK_PACKAGE_NAME);
            result.success(false);
        }
        break;
      case "instagramShare":
        try {
            pm.getPackageInfo(INSTAGRAM_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
            instagramShare(call.<String>argument("type"), call.<String>argument("path"));
            result.success(true);
        } catch (PackageManager.NameNotFoundException e) {
            openPlayStore(INSTAGRAM_PACKAGE_NAME);
            result.success(false);
        }
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void openPlayStore(String packageName) {
    final Context context = registrar.activeContext();
    try {
        final Uri playStoreUri = Uri.parse("market://details?id=" + packageName);
        final Intent intent = new Intent(Intent.ACTION_VIEW, playStoreUri);
        context.startActivity(intent);
    } catch (ActivityNotFoundException e) {
        final Uri playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=" + packageName);
        final Intent intent = new Intent(Intent.ACTION_VIEW, playStoreUri);
        context.startActivity(intent);
    }
  }

  private void facebookShare(String caption, String mediaPath) {
    final Context context = registrar.activeContext();
    final File media = new File(mediaPath);
    final Uri uri = FileProvider.getUriForFile(context,
            context.getApplicationContext().getPackageName() + ".social.share.fileprovider", media);
    final SharePhoto photo = new SharePhoto.Builder().setImageUrl(uri).setCaption(caption).build();
    final SharePhotoContent content = new SharePhotoContent.Builder().addPhoto(photo).build();
    final ShareDialog shareDialog = new ShareDialog(registrar.activity());
    shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
        @Override
        public void onSuccess(Sharer.Result result) {
            channel.invokeMethod("onSuccess", result.getPostId());
            Log.d("FlutterShareSocialPlugin", "Sharing successfully done.");
        }

        @Override
        public void onCancel() {
            channel.invokeMethod("onCancel", null);
            Log.d("FlutterShareSocialPlugin", "Sharing cancelled.");
        }

        @Override
        public void onError(FacebookException error) {
            channel.invokeMethod("onError", error.getLocalizedMessage());
            Log.d("FlutterShareSocialPlugin", "Sharing error occurred.");
        }
    });

    if (ShareDialog.canShow(SharePhotoContent.class)) {
        shareDialog.show(content);
    }
  }

  private void facebookSharePhotos(ArrayList<String> mediaPaths) {
    final Context context = registrar.activeContext();
    final ArrayList<SharePhoto> photos = new ArrayList();
    for(String mediaPath: mediaPaths){
        final File media = new File(mediaPath);
        final Uri uri = FileProvider.getUriForFile(context,
            context.getApplicationContext().getPackageName() + ".social.share.fileprovider", media);
        final SharePhoto photo = new SharePhoto.Builder().setImageUrl(uri).build();
        photos.add(photo);
    }
    final SharePhotoContent content = new SharePhotoContent.Builder().addPhotos(photos).build();
    final ShareDialog shareDialog = new ShareDialog(registrar.activity());
    shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
        @Override
        public void onSuccess(Sharer.Result result) {
            channel.invokeMethod("onSuccess", null);
            Log.d("FlutterShareSocialPlugin", "Sharing successfully done.");
        }

        @Override
        public void onCancel() {
            channel.invokeMethod("onCancel", null);
            Log.d("FlutterShareSocialPlugin", "Sharing cancelled.");
        }

        @Override
        public void onError(FacebookException error) {
            channel.invokeMethod("onError", error.getMessage());
            Log.d("FlutterShareSocialPlugin", "Sharing error occurred.");
        }
    });

    if (ShareDialog.canShow(SharePhotoContent.class)) {
        shareDialog.show(content);
    }
  }

  private void facebookShareLink(String quote, String url) {
    final Uri uri = Uri.parse(url);
    final ShareLinkContent content = new ShareLinkContent.Builder()
            .setContentUrl(uri).setQuote(quote).build();
    final ShareDialog shareDialog = new ShareDialog(registrar.activity());
    shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
        @Override
        public void onSuccess(Sharer.Result result) {
            channel.invokeMethod("onSuccess", null);
            Log.d("FlutterShareSocialPlugin", "Sharing successfully done.");
        }

        @Override
        public void onCancel() {
            channel.invokeMethod("onCancel", null);
            Log.d("FlutterShareSocialPlugin", "Sharing cancelled.");
        }

        @Override
        public void onError(FacebookException error) {
            channel.invokeMethod("onError", error.getMessage());
            Log.d("FlutterShareSocialPlugin", "Sharing error occurred.");
        }
    });

    if (ShareDialog.canShow(ShareLinkContent.class)) {
        shareDialog.show(content);
    }
  }

  private void instagramShare(String type, String imagePath) {
    final Context context = registrar.activeContext();
    final File image = new File(imagePath);
    final Uri uri = FileProvider.getUriForFile(context,
            context.getApplicationContext().getPackageName() + ".social.share.fileprovider", image);
    final Intent share = new Intent(Intent.ACTION_SEND);
    share.setType(type);
    share.putExtra(Intent.EXTRA_STREAM, uri);
    share.setPackage(INSTAGRAM_PACKAGE_NAME);
    share.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    context.startActivity(Intent.createChooser(share, "Share to"));
  }
}
