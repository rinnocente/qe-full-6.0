# qe-full-6.0
Quantum Espresso 6.0 Dockerfile

This container is different from the one for QE 5.4.0 ( https://github.com/rinnocente/qe-full ) because  :
- it uses an Ubuntu 16.10 base image and therefore gfortran-6
- it takes directly the sources from the official QE repositories and compiles them with gfortran-6 during the docker build phase (you need to have a complete environment with openmpi/blas/fftw if you want to build the image by yourself)


