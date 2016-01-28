# Builds a Docker image with pyURDME stable version built from
# git sources. The image is at:
#
#     https://registry.hub.docker.com/u/fenicsproject/
#
# Authors:
# Raingsei V, Haisocheat <raingsei.hai@gmail.com>

FROM phusion/baseimage:0.9.12
MAINTAINER fenics-project <fenics@fenicsproject.org>

ENV HOME /root

# Install add-apt-repository
RUN apt-get -qq update && \
    apt-get -qqy install python-software-properties

# Install the basic environment and fenics from the PPA
RUN add-apt-repository -y ppa:fenics-packages/fenics && \
    apt-get -qq update && \
    apt-get -qqy install xauth fenics ipython

# Cleanup to save space
RUN apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the HOME environment variable, otherwise import dolfin crashes
RUN echo "/root" > /etc/container_environment/HOME

# Set LIBGL_ALWAYS_INDIRECT to suppress libGL warning message.
RUN echo "y" > /etc/container_environment/LIBGL_ALWAYS_INDIRECT

RUN apt-get update
RUN apt-get install -y \
    gcc \
    git \
    python-h5py \
    python-scipy \
    python-matplotlib \
    python-pytest \
    python-numpydoc \
    sphinx-common \
    python-sklearn

# Fix mpi library because pyURDME uses <mpi.h> instead of <mpi/mpi.h>

RUN cp /usr/include/mpi/mpi-ext.h /usr/include/
RUN cp /usr/include/mpi/mpi.h /usr/include/
RUN cp /usr/include/mpi/mpi_portable_platform.h /usr/include/
RUN cp /usr/include/mpi/mpif-common.h /usr/include/
RUN cp /usr/include/mpi/mpif-config.h /usr/include/
RUN cp /usr/include/mpi/mpif-mpi-io.h /usr/include/

# clone and install pyURDME
RUN git clone https://github.com/pyurdme/pyurdme && cd pyurdme && ./install_ubuntu.sh



