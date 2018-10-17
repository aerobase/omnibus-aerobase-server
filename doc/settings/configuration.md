# Configuration options

Aerobase Server is configured by setting relevant options in
`/etc/aerobase/aerobase.rb`. For a complete list of available options, visit the
[aerobase.rb.template](https://github.com/Aerobase/omnibus-aerobase-server/blob/master/config/templates/aerobase-config-template/aerobase.rb.template.erb).


### Configuring the external URL for Aerobase

In order for Aerobase to display correct repository clone links to your users
it needs to know the URL under which it is reached by your users, e.g.
`http://aerobase.example.com`. Add or edit the following line in
`/etc/aerobase/aerobase.rb`:

```ruby
external_url "http://aerobase.example.com"
```

Run `sudo aerobase-ctl reconfigure` for the change to take effect.

### Configuring Aerobase services (Windows Only) to your branding name
_**Warning**_
Renaming services after first installation is not supported. 
You must uninstall previous services (Aerobase *) before renaming.

In order for Aerobase to install service names as your company label, Add or edit the following line in
`/etc/aerobase/aerobase.rb`:

```ruby
global['srv_label'] = "YOURCOMPNAME"
```

Run `sudo aerobase-ctl reconfigure` for the change to take effect.

### Loading external configuration file from non-root user

Aerobase packages loads all configuration from `/etc/aerobase/aerobase.rb` file.
This file has strict file permissions and is owned by the `root` user. The reason for strict permissions
and ownership is that `/etc/aerobase/aerobase.rb` is being executed as Ruby code by the `root` user during `aerobase-ctl reconfigure`. This means
that users who have write access to `/etc/aerobase/aerobase.rb` can add configuration that will be executed as code by `root`.

In certain organizations it is allowed to have access to the configuration files but not as the root user.
You can include an external configuration file inside `/etc/aerobase/aerobase.rb` by specifying the path to the file:

```ruby
from_file "/home/admin/external_unifiedpush.rb"

```

Please note that code you include into `/etc/aerobase/aerobase.rb` using `from_file` will run with `root` privileges when you run `sudo aerobase-ctl reconfigure`.
Any configuration that is set in `/etc/aerobase/aerobase.rb` after `from_file` is included will take precedence over the configuration from the included file.

### Storing Documents data in an alternative directory

By default, Aerobase stores documents data under
`/var/opt/aerobase/unifiedpush-server/documents/`: uploads are stored in
`/var/opt/aerobase/unifiedpush-server/documents/`.  You can change the location of
the above directories by editing the following lines to
`/etc/aerobase/aerobase.rb`.

```ruby
unifiedpush_server['documents_directory'] = "/var/opt/aerobase/unifiedpush-server/documents"
unifiedpush_server['uploads_directory'] = "/var/opt/aerobase/unifiedpush-server/uploads"
```

Note that the target directory and any of its subpaths must not be a symlink.

Run `sudo aerobase-ctl reconfigure` for the change to take effect.

### Changing the name of the Aerobase user / group

By default, Aerobase uses the user name `aerobase` for ownership of the Aerobase data itself.

We do not recommend changing the user/group of an existing installation because it can cause unpredictable side-effects.
If you still want to do change the user and group, you can do so by adding the following lines to
`/etc/aerobase/aerobase.rb`.

```ruby
user['username'] = "aerobase"
user['group'] = "aerobase"
```

Run `sudo aerobase-ctl reconfigure` for the change to take effect.

Note that if you are changing the username of an existing installation, the reconfigure run won't change the ownership of the nested directories so you will have to do that manually. Make sure that the new user can access `documents` as well as the `uploads` directory.

### Specify numeric user and group identifiers

Aerobase creates users for Aerobase-server, PostgreSQL, Cassandra, and NGINX. You can
specify the numeric identifiers for these users in `/etc/aerobase/aerobase.rb` as
follows.

```ruby
user['uid'] = 1234
user['gid'] = 1234
postgresql['uid'] = 1235
postgresql['gid'] = 1235
nginx['uid'] = 1237
nginx['gid'] = 1237
```

Run `sudo aerobase-ctl reconfigure` for the changes to take effect.

## Only start Aerobase services after a given filesystem is mounted

If you want to prevent Aerobase services (NGINX, PostgresSQL.)
from starting before a given filesystem is mounted, add the following to
`/etc/aerobase/aerobase.rb`:

```ruby
# wait for /var/opt/aerobase to be mounted
high_availability['mountpoint'] = '/var/opt/aerobase'
```

Run `sudo aerobase-ctl reconfigure` for the change to take effect.

### Enable HTTPS

See [doc/settings/nginx.md](nginx.md#enable-https).

#### Redirect `HTTP` requests to `HTTPS`.

See [doc/settings/nginx.md](nginx.md#redirect-http-requests-to-https).

#### Change the default port and the ssl certificate locations.

See
[doc/settings/nginx.md](nginx.md#change-the-default-port-and-the-ssl-certificate-locations).

### Use non-packaged web-server

For using an existing Nginx, Passenger, or Apache webserver see [doc/settings/nginx.md](nginx.md#using-a-non-bundled-web-server).

### Using a non-packaged PostgreSQL database management server

To connect to an external PostgreSQL or MySQL DBMS see [doc/settings/database.md](database.md).

### Setting the NGINX listen address or addresses

See [doc/settings/nginx.md](nginx.md#setting-the-nginx-listen-address-or-addresses).

### Inserting custom NGINX settings into the Aerobase server block

See [doc/settings/nginx.md](nginx.md).

### Inserting custom settings into the NGINX config

See [doc/settings/nginx.md](nginx.md).
