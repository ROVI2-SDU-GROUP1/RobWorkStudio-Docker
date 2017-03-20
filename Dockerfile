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

#Fix issue with boots and qt4 interaction
RUN echo "#ifndef Q_MOC_RUN" | cat - /usr/include/boost/type_traits/detail/has_binary_operator.hpp > tmp_file \
	&& mv tmp_file /usr/include/boost/type_traits/detail/has_binary_operator.hpp && echo "#endif" >> /usr/include/boost/type_traits/detail/has_binary_operator.hpp


#Create needed locale
RUN locale-gen en_US.UTF-8  

#Create user for running and compiling robwork

RUN useradd -ms /bin/bash rw_user
USER rw_user
WORKDIR /home/rw_user

#Svn is useless and won't checkout if the locales is not set to utf-8..

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN svn checkout https://svnsrv.sdu.dk/svn/RobWork/trunk RobWork --username Guest --password '' --non-interactive

#Apply ur patch
ADD ur_bind_patch.diff ur_bind_patch.diff
RUN cd RobWork && patch -p0 -i ../ur_bind_patch.diff
#####################
#Create Robwork build directory

RUN mkdir rw_build

#Run cmake

RUN cd rw_build && cmake -DCMAKE_BUILD_TYPE=Release ../RobWork/RobWork

#Compile Robwork

RUN cd rw_build && make -j$(nproc)
######################

######################
#Create RobworkStudio build directory

RUN mkdir rws_build

#Run cmake

RUN cd rws_build && cmake -DCMAKE_BUILD_TYPE=Release ../RobWork/RobWorkStudio

#Compile RobworkStudio

RUN cd rws_build && make -j$(nproc)
#######################

#######################
#Create RobWorkHardware build directory

RUN mkdir rwh_build

#Run cmake

RUN cd rwh_build && cmake -DBUILD_camera=OFF -DCMAKE_BUILD_TYPE=Release ../RobWork/RobWorkHardware

#Compile RobWorkHardware

RUN cd rwh_build && make -j$(nproc)
#######################

#Add environment variables
ENV RW_ROOT=/home/rw_user/RobWork/RobWork/
ENV RWHW_ROOT=/home/rw_user/RobWork/RobWorkHardware/
ENV RWS_ROOT=r/home/rw_user/RobWork/RobWorkStudio/
ENV RobWork_DIR=/home/rw_user/RobWork/RobWork/cmake
ENV RobWorkStudio_DIR=/home/rw_user/RobWork/RobWorkStudio/cmake

ENTRYPOINT [ "RobWork/RobWorkStudio/bin/release/RobWorkStudio" ]

