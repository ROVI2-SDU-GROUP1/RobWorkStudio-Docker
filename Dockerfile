FROM stefanrvo/robworkstudio_depends:latest

#Docker file for running RobworkStudio

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

ENV 	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8

RUN svn checkout https://svnsrv.sdu.dk/svn/RobWork/trunk RobWork --username Guest --password '' --non-interactive


#####################
#Compile RobWork

RUN 	mkdir rw_build && \
	cd rw_build && \
	cmake -DCMAKE_BUILD_TYPE=Release ../RobWork/RobWork && \
	make -j$(nproc)	

######################

######################
#Compile RobworkStudio

RUN 	mkdir rws_build && \
	cd rws_build && \
	cmake -DCMAKE_BUILD_TYPE=Release ../RobWork/RobWorkStudio && \
	make -j$(nproc)

#######################

#######################
#Apply patches to robworkhardware

ADD u*.diff ./
RUN 	cd RobWork && \
 	patch -p0 -i ../ur_bind_patch.diff && \
	patch -p0 -i ../urscript_patch.diff

########################


#######################
#Compile RobWorkHardware

RUN 	mkdir rwh_build && \
	cd rwh_build && \
	cmake -DBUILD_camera=OFF -DCMAKE_BUILD_TYPE=Release ../RobWork/RobWorkHardware && \
	make -j$(nproc)

#######################

#Add environment variables for compiling stuff which dependts on robwork
ENV 	RW_ROOT=/home/rw_user/RobWork/RobWork/ \
	RWHW_ROOT=/home/rw_user/RobWork/RobWorkHardware/ \
	RWS_ROOT=r/home/rw_user/RobWork/RobWorkStudio/ \
	RobWork_DIR=/home/rw_user/RobWork/RobWork/cmake \
	RobWorkStudio_DIR=/home/rw_user/RobWork/RobWorkStudio/cmake

ENTRYPOINT [ "RobWork/RobWorkStudio/bin/release/RobWorkStudio" ]

