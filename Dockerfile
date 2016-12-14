#
# Quantum Espresso 6.0 version : 
#       a program for electronic structure calculations
#       ssh version, using gfortran-6
#
#
# For many reasons we need to fix the ubuntu release:
FROM ubuntu:16.10
#
MAINTAINER roberto innocente <inno@sissa.it>
#
# this directive was inserted  not long ago (https://github.com/docker/docker/issues/14634)
# it permits to define ARGs to be used only during the build and not in operations.
# if it is not supported then the "DEBIAN_FRONTEND=noninteractive" definition
# should be placed in front of every apt install to silence the warning messages
# apt  would produce
#
ARG DEBIAN_FRONTEND=noninteractive
#
# we replace the standard http://archive.ubuntu.com repository
# that is very slow, with the new mirror method :
# deb mirror://mirror.ubuntu.com/mirrors.txt ...
#
# mirror method seems broken in yakkety
#ADD  http://people.sissa.it/~inno/qe/sources.list-16.10 /etc/apt/
#RUN  chmod 644 /etc/apt/sources.list
#
# we update the apt database
# and because for the docker repository we use the https transport
# we install it
#
RUN  apt-get update 
#
# we update the package list 
# and install vim openssh, sudo, wget, gfortran, openblas, blacs,
# fftw3, openmpi , ...
# and run ssh-keygen -A to generate all possible keys for the host
#
RUN apt install -yq vim \
		openssh-server \
		sudo \
		wget \
   	        ca-certificates \
		gfortran-6 \
		libgfortran-6-dev \
		openmpi-bin  \
		libopenmpi-dev \
                libopenblas-base \
         	libopenblas-dev \
   	        libfftw3-3 \
		libfftw3-bin \
 		libfftw3-dev \
   	        libfftw3-double3  \
		libblacs-openmpi1 \
		libblacs-mpi-dev \
		net-tools \
		make \
		autoconf \
	&& ssh-keygen -A
#
# we create the user 'qe' and add it to the list of sudoers
RUN  adduser -q --disabled-password --gecos qe qe \
           && echo "qe 	ALL=(ALL:ALL) ALL" >>/etc/sudoers \
#
# we add /home/qe to the PATH of user 'qe'
	   && echo "export PATH=/home/qe/bin:${PATH}" >>/home/qe/.bashrc \
	   && mkdir -p /home/qe/.ssh/  \
	   && chown qe:qe /home/qe/.ssh
#
# we move to /home/qe
WORKDIR /home/qe
#
# we copy the 'qe' files 
# then we unpack them

# This is a possibilitiy download and compile sources.
# But .. if you do it in a dockerfile then you need in your computer the
# same environment you are going to setup in the container.
RUN wget  --no-verbose  http://qe-forge.org/gf/download/frsrelease/224/1044/qe-6.0.tar.gz \
         http://qe-forge.org/gf/download/frsrelease/224/1043/qe-6.0-examples.tar.gz \
         http://qe-forge.org/gf/download/frsrelease/224/1042/qe-6.0-test-suite.tar.gz \
         http://qe-forge.org/gf/download/frsrelease/224/1041/qe-6.0-emacs_modes.tar.gz \
         http://people.sissa.it/~inno/qe/qe.tgz \
	&& tar xzf qe-6.0.tar.gz \
	&& tar xzf qe-6.0-examples.tar.gz -C qe-6.0 \
	&& tar xzf qe-6.0-test-suite.tar.gz -C qe-6.0 \
	&& tar xzf qe-6.0-emacs_modes.tar.gz \
        && tar xzf qe.tgz \
	&& chown -R qe:qe /home/qe   \
	&& (echo "qe:mammamia"|chpasswd) \
	&& rm qe-6.0.tar.gz \
	      qe-6.0-examples.tar.gz \
	      qe-6.0-test-suite.tar.gz \
	      qe-6.0-emacs_modes.tar.gz \
	      qe.tgz
#

RUN sed -i 's#^StrictModes.*#StrictModes no#' /etc/ssh/sshd_config \
	&& service   ssh  restart  
#
WORKDIR  /home/qe/qe-6.0
#
RUN ./configure \
    && make all \
    && mkdir ../mpibin \
    && cp bin/* ../mpibin/
#
RUN ./configure -disable-parallel \
    && make all \
    && mkdir ../bin \
    && cp bin/* ../bin/ 
#
RUN wget http://people.sissa.it/~inno/qe/qe.tgz \
    && tar xzf qe.tgz \
    && rm qe.tgz


EXPOSE 22

#
# the container can be now reached via ssh
CMD [ "/usr/sbin/sshd","-D" ]

