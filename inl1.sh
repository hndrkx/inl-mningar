#!/bin/bash

# Nedan sätter vi alla variabler vi använder i skriptet
FILE="curl-7.61.1.tar.bz2"
DIR="curl-7.61.1"
INSTALLDIR="/opt/curl"
V=$1

# När jag först körde mitt skript insåg jag att jag inte hade alla paket installerade
# för att bygga paketet, därför utökade jag mitt skript så att den kollar om alla
# nödvändiga paket finns installerade och om inte så installeras dem.
# Jag har inte gjort någon koll på vilken dist som körs, utan skriptet förväntar sig
# att man kör ubuntu då mitt skript använder apt.

DEP=("make" "binutils" "gcc")
WDIR=$PWD

# Alla funktioner har fått ett namn som speglar det funktionen gör
download_file() {
	if test -a $1; then
		printf "File $1 Exists. Skipping Download\n"
	else	
		if [[ $2 =~ [qQ] ]]; then
			printf "Downloading file $1\n"
			curl -o $1 https://curl.haxx.se/download/$1 >/dev/null 2>&1
		else
			printf "Downloading file $1\n"
			curl -o $1 https://curl.haxx.se/download/$1 
		fi

	fi
}

extract_file() {
	printf "Extracting file $1\n"
	tar -xf $1
	printf "Extraction complete\n"
}

set_installdir() {
	if [[ $2 =~ "-"+[qQ] ]]; then
		printf "Configuring package. Tims may take some time\n"
		./configure --prefix=$1 >/dev/null 2>&1
	else
		printf "Configuring package. This may take some time\n"
		./configure --prefix=$1
	fi
}

compile_install() {
	if [[ $1 =~ "-"+[qQ] ]]; then
		printf "Installing program\n"
		sudo make install >/dev/null 2>&1
	else
		printf "Installing program\n"
		sudo make install
	fi
}

remove_leftovers() {
	printf "Cleaning up extracted files\n"
	sudo rm -rf $1
}

# Ja kanske lite onödigt att ha en funktion som endast ändrar dir,
# men med denna funktionen vet jag att jag hamnar rätt.
change_dir() {
	if [ $PWD == $WDIR/$1 ]; then
		cd ..
	else
		cd "$1"
	fi
}

# Detta är väl funktionen som kanske inte är helt självklar vad den gör.
# Jag skickar in variabeln $DEP till funktionen som innehåller alla paket som behövs.
# Jag skickar även in variabeln för verbose eller quiet. Denna lägger jag sedan in i 
# en ny variabel "answ" och direkt efter tar jag bort det elementet ut listan med unset.
# Jag deklarerar en ny array där jag slänger in varje paket om det inte finns installerat.
# Efter det frågar skriptet om man vill installera de paket som inte finns.
install_pkg() {
	arr=("$@")
	answ="${arr[-1]}"
	unset 'arr[${#arr[@]}-1]'
	declare -a pkgs_to_install=()
	for package in "${arr[@]}"; do
		if dpkg -s "$package" >/dev/null 2>&1; then
			printf "Package <$package> already installed\n"
		else
			pkgs_to_install+=("$package")
		fi
	done
	if [ ! $pkgs_to_install == "" ]; then
		echo "Packages not found: ${pkgs_to_install[@]}, install? [y/n]?"
		read answer
		if [[ $answer =~ [yY] && $answ =~ "-"+[qQ] ]]; then
			printf "Installing packages, this may take a while\n"
			sudo apt install ${pkgs_to_install[@]} -y >/dev/null 2>&1
		elif [[ $answer =~ [yY] && $answ =~ "-"+[qQ] ]]; then
			sudo apt install ${pkgs_to_install[@]} -y
		else
			printf "Required packages not installed, Exiting.\n"
			exit 1
		fi
	fi
	printf "All dependencies installed\n"
}

# Eftersom skriptet genererar väldigt mycket output valde jag att göra en flagga för quiet
# och en flagga för verbose. Detta får man information om, om man försöker köra skriptet utan
# flagga.

if [ $# -ne 1 ]; then
	printf "Takes exactly 1 argument\n"
	printf '%s\n' '-h or --help for more information'
	exit 1
fi

if [[ $1 == "-h" || $1 == "--help" ]]; then
	printf "Two options available:\n"
	printf '%s\n' '-v for verbose install.' '-q for quiet install.'
	exit 1
elif [[ $1 =~ "-"+[vV] || $1 =~ "-"+[qQ] ]]; then
	install_pkg ${DEP[@]} $V
	download_file $FILE $V
	extract_file $FILE
	change_dir $DIR
	set_installdir $INSTALLDIR $V
	compile_install $V
	change_dir $DIR
	remove_leftovers $DIR
	printf "Done\n"
else
	printf '%s\n' 'Invalid argument, please see -h or --help.'
	exit 1
fi

