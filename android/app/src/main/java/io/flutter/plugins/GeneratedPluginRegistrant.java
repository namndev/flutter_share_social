package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.namndev.flutter_share_social.FlutterShareSocialPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterShareSocialPlugin.registerWith(registry.registrarFor("io.namndev.flutter_share_social.FlutterShareSocialPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
