SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false

REPLACE="
"

print_modname() {
  ui_print ""
  ui_print "••••••••••••••••••••••••••••••••••••••"
  ui_print "    Fix Multimedia and Fingerprint"
  ui_print "••••••••••••••••••••••••••••••••••••••"
  ui_print ""
  ui_print "• Module by Syoker"
  ui_print ""
  
  sleep 2
}

volume_keytest() 
{
  ui_print "• Volume Key Test"
  ui_print "  Please press any key volume:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > "$TMPDIR"/events) || return 1
  return 0
}

volume_key() {
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > "$TMPDIR"/events
      if (`cat "$TMPDIR"/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
          break
      fi
  done
  if (`cat "$TMPDIR"/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
      return 1
  else
      return 0
  fi
}

remove_Multimedia() {
  ui_print "  Removing fix"
  ui_print ""
  rm $MODPATH/system/etc/vintf/manifest/manifest_media_c2_software.xml
  sleep 2
}


remove_Fingerprint() {
  ui_print "  Removing fix"
  ui_print ""
  rm $MODPATH/system/product/overlay/Traceur__auto_generated_rro_vendor_src.apk
  rm $MODPATH/system/product/overlay/Telecom__auto_generated_rro_vendor_src.apk
  rm $MODPATH/system/product/overlay/TeleService__auto_generated_rro_vendor_src.apk
  rm $MODPATH/system/product/overlay/framework-res__auto_generated_rro_vendor_src.apk
  rm $MODPATH/system/product/overlay/SecureElement__auto_generated_rro_vendor_src.apk
  rm $MODPATH/system/product/overlay/SettingsGoogle__auto_generated_rro_vendor_src.apk
  rm $MODPATH/system/product/overlay/SystemUIGoogle__auto_generated_rro_vendor_src.apk
  sleep 2
}

on_install() {

  REPLY=volume_key

  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  if volume_keytest; then
    ui_print "  Key test function complete"
    ui_print ""
    sleep 2

    ui_print "• Do you want to install the multimedia fix?"
    ui_print "  Key up (+): Yes"
    ui_print "  Key down (-): No"
    
    if "$REPLY"; then
      remove_Multimedia
    else
      ui_print "  Extracting fix to system/product/etc/manifest"
      ui_print ""
      sleep 2
    fi

    ui_print "• Do you want to install the fingerprint fix?"
    ui_print "  Key up (+): Yes"
    ui_print "  Key down (-): No"
    
    if "$REPLY" ; then
      remove_Fingerprint
    else 
      ui_print "  Extracting fix to system/product/overlay"
      ui_print ""
      sleep 2
    fi
  
  else
    ui_print "  You have not pressed any key, aborting installation."
    ui_print ""
    sleep 2
    exit 1
  fi

  ui_print "- Deleting package cache"
  rm -rf /data/system/package_cache/*
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}