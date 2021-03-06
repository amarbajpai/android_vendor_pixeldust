#!/sbin/sh
#
# Backup and restore addon $S files
#

export C=/tmp/backupdir
export S=$S

# Scripts in $S/addon.d expect to find backuptool.functions in /tmp
cp -f /tmp/install/bin/backuptool.functions /tmp

# Preserve $S/addon.d in /tmp/addon.d
preserve_addon_d() {
  mkdir -p /tmp/addon.d/
  cp -a $S/addon.d/* /tmp/addon.d/
  chmod 755 /tmp/addon.d/*.sh
}

# Restore $S/addon.d in /tmp/addon.d
restore_addon_d() {
  cp -a /tmp/addon.d/* $S/addon.d/
  rm -rf /tmp/addon.d/
}

# Execute $S/addon.d/*.sh scripts with $1 parameter
run_stage() {
for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
  $script $1
done
}

case "$1" in
  backup)
    mkdir -p $C
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
  ;;
  restore)
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    rm -rf $C
    sync
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
