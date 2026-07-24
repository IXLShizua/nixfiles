{
  lib,
  telegram-desktop,
  gst_all_1,
}:

let
  gstreamerPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];

  gstreamerPluginPath = lib.makeSearchPath "lib/gstreamer-1.0" (map lib.getLib gstreamerPlugins);
in
telegram-desktop.overrideAttrs (previousAttrs: {
  qtWrapperArgs = (previousAttrs.qtWrapperArgs or [ ]) ++ [
    "--unset"
    "GST_PLUGIN_PATH"

    "--unset"
    "GST_PLUGIN_PATH_1_0"

    "--unset"
    "GST_PLUGIN_SYSTEM_PATH"

    "--set"
    "GST_PLUGIN_SYSTEM_PATH_1_0"
    gstreamerPluginPath
  ];
})
