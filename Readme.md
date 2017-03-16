#Dockerfile for running RobworkStudio inside a docker container.

#####Building
`docker build . -t robwork`
#####Running
to show the window, we need to mount the X11 socket inside docker

`
docker run -ti \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"
`

#TODO: mount a data directory inside docker to make it possible to have persistent data
