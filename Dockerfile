#
# cartoDB Dockerfile
#
# https://github.com/future-analytics/docker-cartodb
#

# Pull base image.
FROM futureanalytics/cartodb:latest

# Install.
#RUN \
#  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
#  apt-get update && \
#  apt-get -y upgrade && \
#  apt-get install -y build-essential && \
#  apt-get install -y software-properties-common && \
#  apt-get install -y curl git man unzip vim wget && \
#  rm -rf /var/lib/apt/lists/*

# Add files.
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/.scripts /root/.scripts

# Set environment variables.
ENV HOME /root

# Set locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Install build tools
apt-get update
apt-get install -y autoconf binutils-doc bison build-essential flex
apt-get install -y python-software-properties

# PostgreSQL
add-apt-repository ppa:cartodb/postgresql-9.3
add-apt-repository ppa:cartodb/pg-schema-trigger
sed -i 's/vivid/precise/g' /etc/apt/sources.list.d/cartodb-ubuntu-pg-schema-trigger-vivid.list
sed -i 's/vivid/precise/g' /etc/apt/sources.list.d/cartodb-ubuntu-postgresql-9_3-vivid.list
apt-get update

apt-get install -y libpq5 libpq-dev postgresql-client-9.3 postgresql-client-common
apt-get install postgresql-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3 postgresql-plpython-9.3
apt-get install postgresql-9.3-pg-schema-triggers

sed -i 's/peer/trust/g' /etc/postgresql/9.3/main/pg_hba.conf
/etc/init.d/postgresql start
createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres
createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres

# cartDB psql extension
git clone https://github.com/CartoDB/cartodb-postgresql.git
cd cartodb-postgresql
git checkout cdb
make all install
PGUSER=postgres make installcheck
/etc/init.d/postgresql restart

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]
