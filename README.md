Don't use it as is, modify the Dockerfile and install your own language if you need it. The docker-compose also has to be modified to build and use the moodle image you want.
The Dockerfile_moosh file is used to build an image with Moosh inside. It is not production ready, as php Composer has to be installed. I recommend to use it as an init container to install the plugins and make the initial settings you need.
