dpkg --add-architecture i386
apt update
apt -y install libmysqlclient-dev:i386 gcc-multilib lib32z1 lib32stdc++6
mkdir -p /usr/share/man/man6