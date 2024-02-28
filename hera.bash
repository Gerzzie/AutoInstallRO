#!/bin/bash
# Project Hera Installer - created and maintained by Gerzzie
# General
DEV=0
INSTALLER_VERSION="v1.2.08"
STEPS=18
# Colors
BLUE='\033[0;36m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
NC='\033[0m'
# Credentials
USERID=$(date +%s | sha256sum | base64 | head -c 3 ; echo)
USERPASS=$(date +%s | sha256sum | base64 | head -c 6 ; echo)
RATHENAPASS="G3RZZ13"
RAGSQLPASS=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
# URLs
URL_RA="https://rathena.org/board"
URL_RAGIT="https://github.com/rathena/rathena"
URL_FLUXGIT="https://github.com/rathena/FluxCP"
URL_FULLCLIENT="https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/mainclient.zip"
SERVER_IPLIST=$(ip addr|awk '/eth0/ && /inet/ {gsub(/\/[0-9][0-9]/,""); print $2}')
SERVER_IP=$(echo $SERVER_IPLIST | cut -d ' ' -f 1 )
if [ $DEV -eq 1 ]
then
	VERSION="${INSTALLER_VERSION} - ${YELLOW}Development Script${NC}"
else
	VERSION="${INSTALLER_VERSION}"
fi

echo "\033c"
echo "Welcome to ${BLUE}Project Hera${NC}, an unattended installer by G3RZZ13"
echo "Version: ${VERSION}\n"
echo "This script will now begin to install stuff on your system. Please be patient as this could take a while!\n"



echo "${BLUE}Step 1/${STEPS}:${NC} Updating your OS"
apt-get -qy update > /dev/null
apt-get -qy upgrade > /dev/null
echo ""



echo "${BLUE}Step 2/${STEPS}:${NC} Installing Prerequisites"
apt-get -qy install expect wget sudo > /dev/null
echo ""



echo "${BLUE}Step 3/${STEPS}:${NC} Installing MySQL Stuff"
apt-get -qy install libaio1 libdbd-mariadb-perl libdbi-perl libterm-readkey-perl libhtml-template-perl > /dev/null
export DEBIAN_FRONTEND=noninteractive 
bash -c 'debconf-set-selections <<< "mariadb-server mariadb-server/root_password password ragnarok"'
bash -c 'debconf-set-selections <<< "mariadb-server mariadb-server/root_password_again password ragnarok"'

apt-get -qy install mariadb-server
wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/msi.sh
chmod +x msi.sh
./msi.sh
rm msi.sh



echo "${BLUE}Step 4/${STEPS}:${NC} Installing Apache2 & PHP"
echo " * Installing Apache2"
apt-get -qy install apache2 > /dev/null
echo " * Installing PHP"
apt-get -qy install libapache2-mod-php php-mysql php-gd php-mbstring php-xml > /dev/null
systemctl restart apache2
echo ""



echo "${BLUE}Step 5/${STEPS}:${NC} Installing Desktop VNC packages"
echo "This step can take a while...."
echo " * Installing xfce"
apt-get -qy install xfce4 xfce4-goodies > /dev/null
echo " * Installing VNCServer"
apt-get -qy install gnome-icon-theme tightvncserver > /dev/null
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get -qy install ./google-chrome-stable_current_amd64.deb
echo ""




echo "${BLUE}Step 6/${STEPS}:${NC} Installing rA specific packages"
echo " * Installing git, make, g++"
apt-get -qy install git make libmariadb-dev libmariadbclient-dev libmariadbclient-dev-compat > /dev/null
echo " * Installing Utilities"
apt-get -qy install zlib1g-dev libpcre3-dev nano zip unzip zenity gcc g++ > /dev/null
echo ""



echo "${BLUE}Step 7/${STEPS}:${NC} Creating User: rathena"
echo "${YELLOW}This process is automatic and doesn't require user input.${NC}"
echo "${YELLOW}Please do not type at the password prompt.${NC}"
wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/maincreateuser.sh
chmod +x createuser.sh
./createuser.sh $RATHENAPASS
rm createuser.sh
gpasswd -a rathena sudo
echo ""



echo "${BLUE}Step 8/${STEPS}:${NC} Setting Up Desktop Stuff"
mkdir -p /usr/share/hera/
cd /usr/share/hera/
wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/files.zip
unzip -qq files.zip
cd links
mkdir -p /home/rathena/Desktop
cp -R * /home/rathena/Desktop
cd /usr/share/hera/scripts
chmod +x *
cd /home/rathena/Desktop
chmod +x *
echo ""



echo "${BLUE}Step 9/${STEPS}:${NC} Creating VNC Server Start-up Files"
cd /usr/local/bin
wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/myvncserver
chmod +x myvncserver
cd /lib/systemd/system/
wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/myvncserver.service
systemctl daemon-reload
systemctl enable myvncserver.service
echo ""



echo "${BLUE}Step 10/${STEPS}:${NC} Installing Project Hera Files"
chown -R rathena:rathena /home/rathena
chown -R rathena:rathena /usr/share/hera
cd /home/rathena
sudo -u rathena sh -c "wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/vnc.sh"
sudo -u rathena sh -c "chmod +x vnc.sh"
sudo -u rathena sh -c "./vnc.sh $RATHENAPASS"
rm vnc.sh
sudo -u rathena sh -c "myvncserver stop"
mkdir -p /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/
touch /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "<channel name=\"xfce4-desktop\" version=\"1.0\">" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "  <property name=\"backdrop\" type=\"empty\">" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "    <property name=\"screen0\" type=\"empty\">" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "      <property name=\"monitor0\" type=\"empty\">" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"brightness\" type=\"empty\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"color1\" type=\"empty\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"color2\" type=\"empty\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"color-style\" type=\"empty\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"image-path\" type=\"string\" value=\"/usr/share/hera/img/bg.png\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"image-show\" type=\"empty\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"last-image\" type=\"empty\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "        <property name=\"last-single-image\" type=\"string\" value=\"/usr/share/hera/img/bg.png\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "      </property>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "    </property>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "  </property>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "  <property name=\"desktop-icons\" type=\"empty\">" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "    <property name=\"icon-size\" type=\"uint\" value=\"32\"/>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "  </property>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
echo "</channel>" >> /home/rathena/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

touch /home/rathena/.config/mimeapps.list
echo "[Default Applications]" >> /home/rathena/.config/mimeapps.list
echo "text/plain=mousepad.desktop" >> /home/rathena/.config/mimeapps.list
echo "" >> /home/rathena/.config/mimeapps.list
echo "[Added Associations]" >> /home/rathena/.config/mimeapps.list
echo "text/plain=mousepad.desktop;" >> /home/rathena/.config/mimeapps.list
echo ""
chown -R rathena:rathena /home/rathena/



echo "${BLUE}Step 11/${STEPS}:${NC} Grabbing rA Source Files"
sudo -u rathena sh -c "git clone -q ${URL_RAGIT} /home/rathena/Desktop/rAthena/"
echo ""



echo "${BLUE}Step 12/${STEPS}:${NC} Performing Initial rA Compile"
echo "This step will take time.. please be patient"
echo "You may see warnings here - this is normal"
cd /home/rathena/Desktop/rAthena
sudo -u rathena sh -c "./configure > /dev/null"
sudo -u rathena sh -c "make server > /dev/null"
sudo -u rathena sh -c "chmod a+x login-server && chmod a+x char-server && chmod a+x map-server"
echo ""



echo "${BLUE}Step 13/${STEPS}:${NC} Creating MySQL Database"
mysqladmin -u root -pragnarok create ragnarok
mysql -u root -pragnarok -e "CREATE USER ragnarok@localhost IDENTIFIED BY '${USERPASS}';"
mysql -u root -pragnarok -e "GRANT ALL PRIVILEGES ON ragnarok.* TO 'ragnarok'@'localhost';"
mysql -u root -pragnarok -e "FLUSH PRIVILEGES;"
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/main.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/logs.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/item_cash_db.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/item_cash_db2.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/item_db.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/item_db2.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/item_db2_re.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/item_db_re.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_db.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_db2.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_db2_re.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_db_re.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_skill_db.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_skill_db2.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_skill_db2_re.sql
mysql -u root -pragnarok ragnarok  < /home/rathena/Desktop/rAthena/sql-files/mob_skill_db_re.sql
mysql -u root -pragnarok -e "USE ragnarok; UPDATE login SET userid = '${USERID}', user_pass = '${USERPASS}' where sex = 'S';"
echo ""



echo "${BLUE}Step 14/${STEPS}:${NC} Configuring FluxCP"
rm /var/www/html/index.html
git clone -q ${URL_FLUXGIT} /var/www/html/
cd /var/www/html/
wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/diff.diff
echo "diff --git a/config/application.php b/config/application.php" >> /var/www/html/diff.diff
echo "--- a/config/application.php" >> /var/www/html/diff.diff
echo "+++ b/config/application.php" >> /var/www/html/diff.diff
echo "@@ -3,7 +3,7 @@" >> /var/www/html/diff.diff
echo " // the default, and should be changed as needed." >> /var/www/html/diff.diff
echo " return array(" >> /var/www/html/diff.diff
echo " 	'ServerAddress'				=> 'localhost',				// This value is the hostname:port under which Flux runs. (e.g., example.com or example.com:80)" >> /var/www/html/diff.diff
echo "-	'BaseURI'					=> 'fluxcp',						// The base URI is the base web root on which your application lies." >> /var/www/html/diff.diff
echo "+	'BaseURI'					=> '',						// The base URI is the base web root on which your application lies." >> /var/www/html/diff.diff
echo " 	'InstallerPassword'			=> 'secretpassword',		// Installer/updater password." >> /var/www/html/diff.diff
echo " 	'RequireOwnership'			=> true,					// Require the executing user to be owner of the FLUX_ROOT/data/ directory tree? (Better for security)" >> /var/www/html/diff.diff
echo " 															// WARNING: This will be mostly IGNORED on non-POSIX-compliant OSes (e.g. Windows)." >> /var/www/html/diff.diff
echo "diff --git a/config/servers.php b/config/servers.php" >> /var/www/html/diff.diff
echo "--- a/config/servers.php" >> /var/www/html/diff.diff
echo "+++ b/config/servers.php" >> /var/www/html/diff.diff
echo "@@ -15,7 +15,7 @@ return array(" >> /var/www/html/diff.diff
echo " 				// -- It specifies the encoding to convert your MySQL data to on the website (most likely needs to be utf8)" >> /var/www/html/diff.diff
echo " 			'Hostname'   => '127.0.0.1'," >> /var/www/html/diff.diff
echo " 			'Username'   => 'ragnarok'," >> /var/www/html/diff.diff
echo "-			'Password'   => 'ragnarok'," >> /var/www/html/diff.diff
echo "+			'Password'   => '${USERPASS}'," >> /var/www/html/diff.diff
echo " 			'Database'   => 'ragnarok'," >> /var/www/html/diff.diff
echo " 			'Persistent' => true," >> /var/www/html/diff.diff
echo " 			'Timezone'   => null // Example: '+0:00' is UTC." >> /var/www/html/diff.diff
echo "@@ -36,7 +36,7 @@ return array(" >> /var/www/html/diff.diff
echo " 				// -- It specifies the encoding to convert your MySQL data to on the website (most likely needs to be utf8)" >> /var/www/html/diff.diff
echo " 			'Hostname'   => '127.0.0.1'," >> /var/www/html/diff.diff
echo " 			'Username'   => 'ragnarok'," >> /var/www/html/diff.diff
echo "-			'Password'   => 'ragnarok'," >> /var/www/html/diff.diff
echo "+			'Password'   => '${USERPASS}'," >> /var/www/html/diff.diff
echo " 			'Database'   => 'ragnarok'," >> /var/www/html/diff.diff
echo " 			'Persistent' => true," >> /var/www/html/diff.diff
echo " 			'Timezone'   => null // Possible values is as described in the comment in DbConfig." >> /var/www/html/diff.diff
git apply diff.diff
rm /var/www/html/diff.diff
usermod -a -G www-data rathena
chown -R www-data:www-data /var/www/html
chmod -R 0774 /var/www/html
ln -s /var/www/html /home/rathena/Desktop/FluxCP
echo ""



echo "${BLUE}Step 15/${STEPS}:${NC} Installing phpMyAdmin"
wget -q https://files.phpmyadmin.net/phpMyAdmin/4.7.3/phpMyAdmin-4.7.3-english.zip
unzip -qq phpMyAdmin-4.7.3-english.zip
rm phpMyAdmin-4.7.3-english.zip
mv phpMyAdmin-4.7.3-english phpmyadmin
cd phpmyadmin
mv config.sample.inc.php config.inc.php
echo "<?php" > /var/www/html/phpmyadmin/config.inc.php
BLOWFISH=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
echo "\$cfg['blowfish_secret'] = '${BLOWFISH}';" >> /var/www/html/phpmyadmin/config.inc.php
echo "\$i=0;" >> /var/www/html/phpmyadmin/config.inc.php
echo "\$i++;" >> /var/www/html/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['host'] = 'localhost';" >> /var/www/html/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['AllowRoot'] = false;" >> /var/www/html/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;" >> /var/www/html/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['auth_type']     = 'cookie';" >> /var/www/html/phpmyadmin/config.inc.php
chown -R www-data:www-data /var/www/html
chmod 0660 /var/www/html/phpmyadmin/config.inc.php
echo ""



echo "${BLUE}Step 16/${STEPS}:${NC} Creating Full Downloadable Client"
echo "This step will take a few minutes.. please be patient"
echo "${YELLOW}Skipping....${NC}"
#mkdir -p /var/www/html/downloads/
#cd /var/www/html/downloads/
#wget -q ${URL_FULLCLIENT}
#unzip -qq client.zip
#rm client.zip
#mkdir -p /var/www/html/downloads/client/data/
#echo "<?xml version=\"1.0\" encoding=\"euc-kr\" ?>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "<clientinfo>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "	<desc>Ragnarok Client Information</desc>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "	<servicetype>korea</servicetype>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "	<servertype>primary</servertype>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "	<connection>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "		<display>Ragnarok Online</display>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "      		<address>${SERVER_IP}</address>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "      		<port>6900</port>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "      		<version>55</version>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "      		<langtype>1</langtype>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "		<loading>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "			<image>loading00.jpg</image>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "			<image>loading01.jpg</image>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "		</loading>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "		<aid>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "			<admin>2000000</admin>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "		</aid>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "   	</connection>" >> /var/www/html/downloads/client/data/clientinfo.xml
#echo "</clientinfo>" >> /var/www/html/downloads/client/data/clientinfo.xml
#cd /var/www/html/downloads/client/
#wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/mainroclient.exe

# use rsu.pack to create client grf

#cd /var/www/html/downloads/
#zip -qqrm fullclient.zip client
#cd /var/www/html/downloads/
#rm -rf client/
#cd /var/www/html/data/schemas/logindb/
#wget -q https://raw.githubusercontent.com/Gerzzie/AutoInstallRO/main/maincp_cmspages.20170808161901.sql
#chown -R www-data:www-data /var/www/html
#cd /home/



echo "${BLUE}Step 17/${STEPS}:${NC} Preparing auto-config import files"
echo "//Project Hera\n" >> /home/rathena/Desktop/rAthena/conf/import/char_conf.txt
echo "userid: ${USERID}" >> /home/rathena/Desktop/rAthena/conf/import/char_conf.txt
echo "passwd: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/char_conf.txt
echo "char_ip: ${SERVER_IP}" >> /home/rathena/Desktop/rAthena/conf/import/char_conf.txt

echo "//Project Hera\n" >> /home/rathena/Desktop/rAthena/conf/import/map_conf.txt
echo "userid: ${USERID}" >> /home/rathena/Desktop/rAthena/conf/import/map_conf.txt
echo "passwd: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/map_conf.txt
echo "map_ip: ${SERVER_IP}" >> /home/rathena/Desktop/rAthena/conf/import/map_conf.txt

echo "//Project Hera\n" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo "//use_sql_db: yes" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo "login_server_pw: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo "ipban_db_pw: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo "char_server_pw: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo "map_server_pw: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo "log_db_pw: ${USERPASS}" >> /home/rathena/Desktop/rAthena/conf/import/inter_conf.txt
echo ""

touch /home/rathena/Desktop/Info.txt
echo "Project Hera\n" >> /home/rathena/Desktop/Info.txt
echo "Server IP: ${SERVER_IP}\n" >> /home/rathena/Desktop/Info.txt
echo "-- MySQL --" >> /home/rathena/Desktop/Info.txt
echo "root password is 'ragnarok', but can only be accessed locally from this system." >> /home/rathena/Desktop/Info.txt
echo "For all other MySQL uses, please use the following credentials:" >> /home/rathena/Desktop/Info.txt
echo "User: ragnarok" >> /home/rathena/Desktop/Info.txt
echo "Password: ${USERPASS}\n" >> /home/rathena/Desktop/Info.txt

echo "-- SSH User --" >> /home/rathena/Desktop/Info.txt
echo "User: rathena" >> /home/rathena/Desktop/Info.txt
echo "Password: $RATHENAPASS\n" >> /home/rathena/Desktop/Info.txt

echo "-- FluxCP --" >> /home/rathena/Desktop/Info.txt
echo " * Access FluxCP from this server using the browser and going to http://localhost" >> /home/rathena/Desktop/Info.txt
echo " or" >> /home/rathena/Desktop/Info.txt
echo " * Access FluxCP from anywhere by browsing to http://${SERVER_IP}/" >> /home/rathena/Desktop/Info.txt
echo "The Installer Password is the default for FluxCP, which is secretpassword\n" >> /home/rathena/Desktop/Info.txt

echo "-- phpMyAdmin --" >> /home/rathena/Desktop/Info.txt
echo " * Access phpMyAdmin from this server using the browser and going to http://localhost/phpmyadmin" >> /home/rathena/Desktop/Info.txt
echo " or" >> /home/rathena/Desktop/Info.txt
echo " * Access phpMyAdmin from anywhere by browsing to http://${SERVER_IP}/phpmyadmin" >> /home/rathena/Desktop/Info.txt
echo "Access from root user is disabled, so you will need to login as 'ragnarok' with your MySQL password.\n" >> /home/rathena/Desktop/Info.txt

#echo "-- Full Client --" >> /home/rathena/Desktop/Info.txt
#echo "A full client will be made available to you on your downloads page straight" >> /home/rathena/Desktop/Info.txt
#echo " after completing the FluxCP installation process. This is located at:" >> /home/rathena/Desktop/Info.txt
#echo " * URL: http://${SERVER_IP}/?module=pages&action=content&page=downloads" >> /home/rathena/Desktop/Info.txt
#echo " * Filesystem: FluxCP Desktop Shortcut -> downloads folder" >> /home/rathena/Desktop/Info.txt



echo "${BLUE}Step 18/${STEPS}:${NC} Finishing up!"
sudo -u rathena sh -c "myvncserver start"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "${YELLOW}*****************************************************************${NC}"
echo ""
echo "${BLUE}All done!${NC}"
echo "${GREEN} -- System Stuff${NC}"
echo "Linux User 'rathena' Password: ${RATHENAPASS}"
echo "Server IP: ${SERVER_IP}"
echo ""
echo "${GREEN} -- MySQL Stuff${NC}"
echo "MySQL user: ragnarok"
echo "MySQL password: ${USERPASS}"
echo "phpMyAdmin: http://${SERVER_IP}/phpmyadmin"
echo ""
echo "${GREEN} -- VNC Stuff${NC}"
echo "VNC Password: G3RZZ13"
echo "We recommend TightVNC Viewer: http://www.tightvnc.com/download.php"
echo "In the Remote Host box, type ${SERVER_IP}:1"
echo ""
echo "${GREEN} -- FluxCP Stuff${NC}"
echo "Control Panel: http://${SERVER_IP}/"
#echo "After FluxCP installation, full installer will be available via your site."
echo ""
echo "${BLUE}You can now login via VNC and click Start rAthena on the desktop.${NC}"
echo "${YELLOW}*****************************************************************${NC}"
