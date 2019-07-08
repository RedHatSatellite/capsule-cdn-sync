# Capsule CDN Sync

This program is used to configure the capsule to sync the rpm directly from the Red Hat cdn server instead of satellite server. It also deploy the manifest certificates on the capsule server which are needed for capsule - CDN communication and authentication. 

## Use case / Scenario

Suppose there is an on-premise deployed satellite server and capsule servers are deployed on the cloud-like AWS or Azure. In this case, syncing the capsule server through satellite will consume a lot of bandwidth and also sync will take time depending on the network latency. 
Using capsule-cdn-sync tool capsule server can be configured to sync the content directly from the CDN server.

## Installation

On preinstalled satellite capsule server clone this project. 
```bash
# git clone https://github.com/patilsuraj767/capsule-cdn-sync.git
# cd capsule-cdn-sync
# bundle install
```

## Usage

Copy the manifest from satellite server to the capsule server or directly download it from the Red Hat customer portal.

After this go inside the cloned repository and run the below command.

```bash
# cd bin/
# chmod 777 capsule-cdn-sync
# ./capsule-cdn-sync /path/to/the/manifest.zip
```
capsule-cdn-sync leverages the Alternate Content Sources functionality of the pulp. It creates the `/etc/pulp/content/sources/conf.d/cdn.conf` file where the alternate source is definded(cdn urls). 
It also creates the `/root/.manifest-certs` directory where all the entitlement certs are stored which are needed by capsule for communicating with the CDN server.  

## Limitations
Currently, this tool is not fully functional because manifest does not contain the accurate path to the CDN repository. It has `$releaseserver` and `$basearch` variables Example - `/content/dist/rhel/server/7/$releasever/$basearch/os` due to which we cannot create functional alternate source i.e. `/etc/pulp/content/sources/conf.d/cdn.conf`

But now the further plan to overcome this is to communicate with the satellite API to get the repositories which are synced on the capsule and then create the accurate alternate CDN source from it.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
