# Configuration Aerobase Cluster
This section covers configuring Aerobase to run in a cluster. There’s a number of things you have to do when setting up a cluster, specifically:

1. Configure a shared external database
2. Set up a load balancer
3. Supplying a private network FQDN to each cluster node

### Recommended Network Architecture
The recommended network architecture for deploying Aerobase is to set up an HTTP/HTTPS load balancer on a public IP address that routes requests to Aerobase servers sitting on a private network. This isolates all clustering connections and provides a nice means of protecting the servers.

### Configuring the cluster contactpoints
```ruby
global['contactpoints'] = 'IP1, IP2'
```
Run `sudo aerobase-ctl reconfigure` for the change to take effect.

### Scale Out Aerobase servers 
By default aerobase cluster is configured in a replicated mode. In order to scale out (horizontally) `cache_owners` value must be set to `aerobase.rb` config.
Recommended scale factor is (N/2)-1 when N is the number of cluster nodes.
