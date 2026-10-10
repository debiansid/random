#!/system/bin/sh
FLAG="/data/data/com.google.android.inputmethod.latin/shared_prefs/flag_value.xml"
[ -f "$FLAG" ] && sed -i "s/enable_auto_space_setting\" value=\"false\"/enable_auto_space_setting\" value=\"true\"/g" "$FLAG"
