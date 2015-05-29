#clone mongo-nonx86
cd ~
git clone https://github.com/skrabban/mongo-nonx86
cd mongo-nonx86
#build and run installation (TAKES A LONG TIME)
scons
scons --prefix=/opt/mongo install

#Housekeeping
adduser --firstuid 100 --ingroup nogroup --shell /etc/false --disabled-password --gecos "" --no-create-home mongodb
mkdir /var/log/mongodb/
chown mongodb:nogroup /var/log/mongodb/
mkdir /var/lib/mongodb
chown mongodb:nogroup /var/lib/mongodb
cp debian/init.d /etc/init.d/mongod
cp debian/mongodb.conf /etc/
ln -s /opt/mongo/bin/mongod /usr/bin/mongod
chmod u+x /etc/init.d/mongod
update-rc.d mongod defaults
/etc/init.d/mongod start
