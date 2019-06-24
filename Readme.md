# Robot Navgiation and Simulator via docker

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
./build.sh
```


## Run a test with an existing bag file



* Create a map using the test for mapping:
```sh
sudo echo "172.17.0.1	local" >> /etc/hosts
cp envs/local .env 
source .env
docker-compose -f docker-compose/core.yml -f docker-compose/slam.yml up 
docker exec -it intuitiv_ros_core bash -c 'source /opt/ros/kinetic/setup.bash;rosbag play -r 1.0 --clock /bags/some_record.bag'
```
**NOTE:** The cartographer parameters are not optimized and the map will not look good after running.


You can also execute these steps with the predefined test "mapping" via calling:

```sh
cd tests
python run-test --testdir mapping
```


Then start rviz on your host machine (prefer to use predefined confg file):
```sh
rviz -d ./ros_modules/config_node/configuration_files/simple_vis.rviz
```


## Running with Gazebo



Start gazebo:
```sh
sudo echo "172.17.0.1	local" >> /etc/hosts
cp envs/gazebo .env 
source .env
docker-compose -f docker-compose/core.yml -f docker-compose/slam.yml -f docker-compose/gazebo.yml up 
```
Cheeck the visualization via rviz:
```sh
rviz -d ./ros_modules/config_node/configuration_files/simple_vis.rviz
```


**NOTE:** There is no move-base integrated yet. This means, even if you can see the map built up from the initial robot pose,
you wont be able to drive the robot- >TODO: integrate move base.
