# bgpstream-docker
This is a Docker Image w/ BGPStream + PyBGPStream pre-installed.
They were both built from source (with some minor tweaks to the build system - glibtoolize replaced w/ libtoolize, pthread_yield check relaced w/ sched_yield).

To spin up the container, just run `./bgp_docker.sh`. You will have access to the directory in which the script is placed from within the image, so you can generate some nice txt dumps on your local filesystem, or write python code in your text editor of choice, and then run it inside the container. There's a snippet `pybgpstream-demo.py` that you can run to verify that everything works correctly.

> I will admit that the Dockerfile is a little heinous, but I needed this working ASAP for my class CS4251 (Computer Networking II) as the `brew` installation of BGPStream was not working properly.




