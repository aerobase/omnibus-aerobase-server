# Maintenance commands

## After installation

### Get service status

Run `sudo unifiedpush-ctl status`; the output should look like this:

```
run: logrotate: (pid 7664) 2438s; run: log: (pid 26348) 182254s
run: nginx: (pid 6415) 6038s; run: log: (pid 26325) 182260s
run: postgresql: (pid 6421) 6037s; run: log: (pid 26203) 182272s
run: unifiedpush-server: (pid 6519) 6036s; run: log: (pid 26380) 182248s
```

### Tail process logs

See [doc/settings/logs.md.](doc/settings/logs.md)

### Starting and stopping

After unifiedpush-server is installed and configured, your server will have a Runit
service directory (`runsvdir`) process running that gets started at boot via
`/etc/inittab` or the `/etc/init/unifiedpush-server.conf` Upstart resource.  You
should not have to deal with the `runsvdir` process directly; you can use the
`unifiedpush-ctl` front-end instead.

You can start, stop or restart Unifiedpush Server and all of its components with the
following commands.

```shell
# Start all Unifiedpush components
sudo unifiedpush-ctl start

# Stop all Unifiedpush components
sudo unifiedpush-ctl stop

# Restart all Unifiedpush components
sudo unifiedpush-ctl restart
```

Note that on a single-core server it may take up to a minute to restart Unifiedpush.

It is also possible to start, stop or restart individual components.

```shell
sudo unifiedpush-ctl restart unifiedpush
```
