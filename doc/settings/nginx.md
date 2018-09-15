# NGINX settings
## Enable HTTPS
_**Warning**_

The Nginx config will tell browsers and clients to only communicate with your Aerobase instance over a secure connection for the next 24 months. By enabling HTTPS you'll need to provide a secure connection to your instance for at least the next 24 months.
By default, Aerobase does not use HTTPS. If you want to enable HTTPS for aerobase.example.com, add the following statement to /etc/aerobase/aerobase.rb:

    # note the 'https' below
    external_url "https://aerobase.example.com"

Because the hostname in our example is 'aerobase.example.com', aerobase will look for key and certificate files called /etc/aerobase/ssl/aerobase.example.com.key and /etc/aerobase/ssl/aerobase.example.com.crt, respectively. Create the /etc/aerobase/ssl directory and copy your key and certificate there.

    sudo mkdir -p /etc/aerobase/ssl
    sudo chmod 700 /etc/aerobase/ssl
    sudo cp aerobase.example.com.key aerobase.example.com.crt /etc/aerobase/ssl/

For self-signed certificate, we can create the SSL key and certificate files in one motion by typing:

    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/aerobase/ssl/aerobase.example.com.key -out /etc/aerobase/ssl/aerobase.example.com.crt

Now run `sudo aerobase-ctl reconfigure`. When the reconfigure finishes your Aerobase instance should be reachable at https://aerobase.example.com.

## Redirect HTTP requests to HTTPS

By default, when you specify an external_url starting with 'https', Nginx will no longer listen for unencrypted HTTP traffic on port 80. If you want to redirect all HTTP traffic to HTTPS you can use the `redirect_http_to_https` setting.

    external_url "https://aerobase.example.com"
    nginx['redirect_http_to_https'] = true

## Change the default port and the SSL certificate locations
If you need to use an HTTPS port other than the default (443), just specify it as part of the external_url.

    external_url "https://aerobase.example.com:2443"

In addition proxy-https configuration should be changed to wildfly-standalone-full.xml

    # vi /opt/aerobase/embedded/cookbooks/unifiedpush/templates/default/wildfly-standalone-full.xml:
    <socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:0}">
        ...
        <socket-binding name="proxy-https" port="2443"/>
        ...
    </socket-binding-group>
    
To set the location of ssl certificates create /etc/aerobase/ssl directory, place the .crt and .key files in the directory and specify the following configuration:

    nginx['ssl_certificate'] = "/etc/aerobase/ssl/aerobase.example.crt"
    nginx['ssl_certificate_key'] = "/etc/aerobase/ssl/aerobase.example.com.key"

## Setting the NGINX listen address or addresses

By default NGINX will accept incoming connections on all local IPv4 addresses. You can change the list of addresses in /etc/aerobase/aerobase.rb.

    nginx['listen_addresses'] = ["0.0.0.0", "[::]"] # listen on all IPv4 and IPv6 addresses

## Setting the NGINX listen port

By default NGINX will listen on the port specified in external_url or implicitly use the right port (80 for HTTP, 443 for HTTPS). If you are running Aerobase behind a reverse proxy, you may want to override the listen port to something else. For example, to use port 8181:
`nginx['listen_port'] = 8181`

## Using a non-bundled web-server

By default, Aerobase is installed with bundled Nginx.
Aerobase allows webserver access through user `aerobase-www` which resides
in the group with the same name. To allow an external webserver access to
Aerobase, external webserver user needs to be added `aerobase-www` group.

To use another web server like Apache or an existing Nginx installation you
will have to perform the following steps:

1. **Disable bundled Nginx**

    In `/etc/aerobase/aerobase.rb` set:

    ```ruby
    nginx['enable'] = false
    ```

## Adding additional NGINX Server Blocks
By default, Aerobase http config block contains an include directive which tells NGINX where additional website configuration files are located.
If you installed from the official Aerobase repository, this line will say include /var/opt/aerobase/nginx/conf.d/*.conf; as it does in the http block below. 
Each website you host with NGINX should have its own configuration file in /var/opt/aerobase/nginx/conf.d/.
```bash
http {
    ...
    ...
    ...

    include /var/opt/aerobase/nginx/conf.d/*.conf;
}
```

## Adding additional Location Blocks to Aerobase Server
The location setting lets you configure how NGINX will respond to requests for resources within the server.
You can pugin additional locations file to aerobase server by setting a value to custom_aerobase_config in /etc/aerobase/aerobase.rb; as it does in the server block below.

```ruby
nginx['custom_aerobase_config'] = "include /var/opt/aerobase/nginx/conf.d/additional-location.import;"
```
Now run `sudo aerobase-ctl reconfigure`.
