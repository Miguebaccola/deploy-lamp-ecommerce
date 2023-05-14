#!/bin/bash
#variables
REPO="The-DevOps-Journey-101"
USERID=$(id -u)


	if [ "${USERID}" -ne 0 ]; then
		echo -e "\e[31m el usuario debe ser root \e[0m"
		exit
	fi

		###update
	echo -e "\e[32m actualizando paquetes \e[0m"
	sleep 2s
	apt update

	echo -e "\e[32m instalando paquetes \e[0m"
        sleep 2s
 	apt install -y git
	echo -e "\e[32m paquetes instalados \e[0m"
	sleep 3s
	
	### base de datos
	if dpkg -s mariadb-server > /dev/null 2>&1; then
		echo -e "\e[32m mariadb esta realmente instalado \e[0m"
	sleep 2s
	else
		echo -e "\e[32m instalando mariadb ... \e[0m"
		apt install -y mariadb-server
		systemctl start mariadb
		systemctl enable mariadb
		echo -e "\e[32m servicios de mariadb iniciados \e[0m"
	sleep 2s
		echo -e "\e[32m creando base de datos \e[0m"
	sleep 2s
		mysql -e "
			CREATE DATABASE ecomdb;
			CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
			GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
			FLUSH PRIVILEGES;"
		cat > db-load-script.sql <<-EOF
 	USE ecomdb;
 	CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,price varchar(255) default NULL, ImageUrl varchar (255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
	INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
	EOF
		echo -e "\e[32m base de datos generada \e[0m"
	sleep 2s
		mysql < db-load-script.sql
		echo -e "\e[32m script sql ejecutado \e[0m"
	sleep 2s
	fi
	
	###APACHE
	if dpkg -s apache2 > /dev/null 2>&1; then
		echo -e "\e[32m apache esta realmente instalado \e[0m"
	sleep 2s
	else
		echo -e "\e[32m instalando apache2 ... \e[0m"
		apt install -y apache2
		sudo apt install -y php libapache2-mod-php php-mysql
		systemctl start apache2
		systemctl enable apache2
		mv /var/www/html/index.html /var/www/html/index.html.bkp
		echo -e "\e[32m servicios de apache iniciados \e[0m"
	sleep 2s
	fi

	if [ -d "$REPO" ]; then
		echo -e "\e[32m la carpeta $REPO existe \e[0m"
		rm -rf $REPO
		echo -e "\e[32m se removio la carpeta \e[0m"
	sleep 2s
	fi

	###web
	echo -e "\e[32m instalando pagina web \e[0m"
	sleep 2s
	git clone https://github.com/roxsross/$REPO.git
	cp -r $REPO/CLASE-02/lamp-app-ecommerce/* /var/www/html
	sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
	ls -lrt /var/www/html/
	echo -e "\e[32m pagina web instalada \e[0m"

	sleep 2s
	###test
	echo -e "\e[32m testeando pagina web \e[0m"
	sleep 2s
	curl localhost
	echo -e "\e[32m pagina web funcionando \e[0m"
	echo -e "\e[36m ========================= \e[0m"
	sleep 2s
	systemctl reload apache2
