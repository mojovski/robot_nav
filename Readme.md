# Robot Simulator via docker

## Setup


### Hostnames

The communication runs over the hostname "local". You actually can use a different name in the envs/local file, but it should be registered
in your /etc/hosts
```sh
sudo echo "172.17.0.1	local" >> /etc/hosts
```

### Install Requirements

* git, docker, etc (if you dont have them yet...)
* Docker compose:
```sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```



## Build



```sh
docker-compose -f docker-compose.yml build
```


## Run

```sh
cp envs/local .env
source .env
docker-compose -f docker-compose.yml up
```
