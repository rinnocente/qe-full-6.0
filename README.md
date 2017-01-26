# qe-full-6.0
Quantum Espresso 6.0 Dockerfile all sources/all binaries

This container   :
- uses an Ubuntu 16.10 base image and therefore gfortran-6
- takes directly the sources from the official QE repositories and compiles them with gfortran-6 during the docker build phase


**Quantum Espresso** is a widely used package for electronic structure calculations.

Further information is  available on its website : [www.quantum-espresso.org](http://www.quantum-espresso.org/).

---
### Only local access allowed :

You can use locally the container without logging in  typing :

```
$ docker run -it -u qe rinnocente/qe-full-6.0 /bin/bash
```

in this way you will be inside the container as user ```qe```. Change its password
that initially is set to *mammamia* , with the **passwd** command.

### Also remote access via **ssh** :
If you want to access directly the container from outside your machine or you want to share the container with collaborators, then you have to start it in background with a running **sshd** (but first change the password for user ``qe`` with a local access).

You can run the container in background  with **sshd** typing :

```
  $ CONT=`docker run -P -d -t rinnocente/qe-full-6.0`
```
in this way (-P) the std ssh port (=22) is mapped on a free port of the host. We can access the container discovering the port of the host on which the container ssh service is mapped :
```
  $ PORT=`docker port $CONT 22 |sed -e 's#.*:##'`
  $ ssh -p $PORT qe@127.0.0.1
```
the initial password for the 'qe' user is 'mammamia', don't forget to change it immediately.

The **QE** container has the  full QuantumEspresso distribution plus binaries, and parallel binaries.
As with smaller images it still has the files for a quick test.
When you are inside the container you can simply run the test typing :
```
  $ ./pw.x <relax.in
```
The normal way in which you use this container is sharing an input-output directory between your host  and the container. In this case you create a subdir in your host :
```
  $ mkdir ~/qe-in-out
```
and when you run the container you share this directory with the container as a volume :
```
 $ CONT=`docker run -v ~/qe-in-out:/home/qe/qe-in-out -P -d -t rinnocente/qe-full-6.0`
 $ PORT=`docker port $CONT|sed -e 's#.*:##'`
 $ ssh -p $PORT qe@127.0.0.1
```
Using the rootfs of the container (managed with a union file system) is not recommended for
important I/O because the UFS can be quite inefficient.

---
The container does not die when you logout the ssh session because it is backgrounded.

You need to explicitly stop it if you want to re-use it later :
```
$ docker stop $CONT
```

Or even remove it if you don't want to re-use it :
```
$ docker rm -f $CONT
```
---
The Dockerfile is on github : [Dockerfile](https://github.com/rinnocente/qe-full-6.0/blob/master/Dockerfile )


### NB. this container is reachable via ssh through **your host port $PORT**, eventually from Internet at large.

---
This is a full package with all sources, all  serial binaries and also all the parallel binaries (with openmpi) :


![qe](http://www.quantum-espresso.org/wp-content/uploads/2011/12/Quantum_espresso_logo.jpg)

