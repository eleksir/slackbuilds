config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

getent group unbound >/dev/null 2>&1
if [ $? -ne 0 ]; then
  groupadd -g 304 unbound
  chown :unbound /var/lib/unbound
fi

getent passwd unbound >/dev/null 2>&1
if [ $? -ne 0 ]; then
  useradd -r -u 304 -g unbound -d /var/lib/unbound/ -s /sbin/nologin -c 'Unbound DNS resolver' unbound
  chown unbound: /var/lib/unbound
fi

preserve_perms etc/rc.d/rc.unbound.new
config etc/unbound/unbound.conf.new
config var/lib/unbound/unbound.conf.d/forward.conf.new
config var/lib/unbound/unbound.conf.d/forward-default.conf.new
config var/lib/unbound/unbound.conf.d/local-data.conf.new
config var/lib/unbound/unbound.conf.d/stub-zones.conf.new
config var/lib/unbound/unbound.conf.d/auth-zones.conf.new
config var/lib/unbound/zones/localhost.zone.new
config var/lib/unbound/named.root.new
config etc/cron.monthly/unbound.new
