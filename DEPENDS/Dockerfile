#Create image with all dependencies for robwork and CAROS
FROM ros:kinetic-robot

#Docker file for running RobworkStudio

#Install dependencies

RUN apt-get -y update
RUN apt-get -y install 	subversion \
		       	gcc g++ cmake libatlas-base-dev \
		  	libxerces-c3.1 libxerces-c-dev \
			libboost-dev libboost-date-time-dev \
			libboost-filesystem-dev \
			libboost-program-options-dev \
			libboost-regex-dev libboost-serialization-dev \
			libboost-system-dev libboost-test-dev \
			libboost-thread-dev swig libqt4-dev \
			libopencv-dev git \
			ros-kinetic-cv-bridge \
			ros-kinetic-image-transport \
			ros-kinetic-image-geometry \
			ros-kinetic-desktop-full \
			ros-kinetic-openni2-launch \
			ros-kinetic-cv-bridge \
			nano

