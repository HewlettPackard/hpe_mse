FROM centos:7

# This container is aimed at deploying HPE NDS NA TAS/MSE VNF
MAINTAINER Dominique Domet de Mont <dominique.domet-de-mont@hpe.com>

# Expected optional arguments: 
# bits: directory delivering HPE bits as RPM packages and installation scripts
# keys: directory delivering ssh keys id_rsa and id_rsa.pub for root and ocadmin
ARG bits=bits
ARG keys=keys

USER root
RUN echo "root:hwroot" | chpasswd
RUN /usr/bin/yum install --assumeyes file which iproute initscripts createrepo yum-plugin-versionlock openssh-clients openssh-server firewalld

# Force OS signature to RedHat for USPM
RUN echo "Red Hat Enterprise Linux Server release 7.4 (Maipo)" > /etc/redhat-release

# Directory holding the product bits and installers
ENV ISO_REPO /var/opt/OC/iso/
RUN /usr/bin/mkdir --parents $ISO_REPO

# Build a YUM repository hpe from the HPE products bits
ADD ./$bits/*.rpm $ISO_REPO
RUN /usr/bin/createrepo --database $ISO_REPO
WORKDIR /etc/yum.repos.d/
RUN echo [hpe] 				 > hpe.repo
RUN echo name=HPE products 		>> hpe.repo
RUN echo baseurl=file://$ISO_REPO 	>> hpe.repo
RUN echo enabled=1 			>> hpe.repo
RUN echo gpgcheck=0 			>> hpe.repo

# Remove any non-accessible yum repository (USPM requirement)
RUN /usr/bin/rm --force /etc/yum.repos.d/CentOS-Media.repo

# do not restrict locales in glibc-common via yum.conf: LC_CTYPE: cannot change locale (en_US): No such file or directory
RUN sed -i "s/^override_install_langs=.*/override_install_langs=all/" /etc/yum.conf
RUN /usr/bin/yum reinstall --assumeyes glibc-common

# Add installers scripts known in the path
ADD ./$bits/*.sh $ISO_REPO
RUN echo PATH=$PATH:$ISO_REPO >> ~/.bash_profile
RUN echo export PATH >> ~/.bash_profile
# Start mandatory services
RUN echo /usr/sbin/service sshd start >> ~/.bash_profile
RUN echo /usr/sbin/service firewalld start >> ~/.bash_profile
# Disable ssh nologin for non root users (ubuntu known issue)
RUN echo /usr/bin/rm --force /var/run/nologin >> ~/.bash_profile

# Set FQDN hostname 
RUN echo '[ "$(hostname)" == "$(hostname --fqdn)" ] || hostname $(hostname --fqdn)' >> ~/.bash_profile

# Install deployment engines 
RUN /usr/bin/yum install --assumeyes hpoc-nivr-nfv  hpoc-uspm-nfv-config hpoc-uspm-nfv-ems hpocmp-nfv-ocmp hpoc-tls-certificates openssl

# Enable promptless root ssh by dropping keys
RUN /usr/bin/mkdir --parents /root/.ssh/
RUN /usr/bin/chmod 0700 /root/.ssh/
WORKDIR /root/.ssh/
ADD ./$keys/id_rsa ./
ADD ./$keys/id_rsa.pub ./
RUN /usr/bin/chmod 0600 id_rsa*
RUN /usr/bin/cp -f id_rsa.pub authorized_keys
# Enable promptless ocadmin ssh by dropping keys
RUN /usr/bin/mkdir --parents /home/ocadmin/.ssh/
RUN /usr/bin/chmod 0700 /home/ocadmin/.ssh/
WORKDIR /home/ocadmin/.ssh/
ADD ./$keys/id_rsa ./
ADD ./$keys/id_rsa.pub ./
RUN /usr/bin/chmod 0600 id_rsa*
RUN /usr/bin/cp -f id_rsa.pub authorized_keys
RUN /usr/bin/chown -R ocadmin:ocadmin /home/ocadmin/.ssh
# The server key must be the same for all nodes
WORKDIR /etc/ssh/
ADD ./$keys/ssh_host_* ./
RUN /usr/bin/chmod 0644 ssh_host_*_key.pub
RUN /usr/bin/chmod 0600 ssh_host_*_key

# Start deployment engines 
RUN service nivr-nfv start && service uspm-nfv start && service ocmp-nfv start && service ocsnf-nfv start 

# Ready to display logs
WORKDIR /var/log

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD /usr/sbin/init

# sudo docker build  -t ndsna/tas:latest .
# sudo docker run --name <name> --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro --hostname <name>.locadomain -d ndsna/tas:latest
# sudo docker ps
# sudo docker cp docker.properties <ems>:/etc/opt/OC/hpoc-nivr-nfv/nivr-cluster-nfv.properties
# sudo docker exec -t -i <ems> /bin/bash