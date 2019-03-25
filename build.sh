#!/bin/bash



echo "Building cartographer"
sleep 1


echo "Shall I also build the ceff_simulator? [y/n]"
printf "[y]:"
read build_simulator
if [ "$build_simulator" == "" ]; then

	build_simulator="y"
fi

if [[ $build_simulator = "y" ]]
then
	echo "Delete existing cartographer_ros if exists?[y/n]"
	printf "[y]:"
	read delete_cartographer_ros
	if [[ $delete_cartographer_ros = "y" ]]
	then
	    rm -rf ./cartographer_ros
	fi	

	#git clone https://github.com/mojovski/cartographer_ros.git /tmp/cartographer_ros
	git clone https://github.com/googlecartographer/cartographer_ros.git 
	cd ./cartographer_ros
	#git checkout extrapolation_into_past_issue
	docker build -t slam_kinetic -f Dockerfile.kinetic .
	cd ..

    
fi






cp ./envs/local .env
source .env

#build all within the docker-compose env
echo "Building docker-compose stuff"
sleep 1

docker-compose -f docker-compose/core.yml -f docker-compose/slam.yml -f docker-compose/gazebo.yml build


