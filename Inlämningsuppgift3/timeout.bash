#!/bin/bash

# Kollar så att skriptet får 2 eller fler argument, annars exit 1
if [[ $# -lt 2 ]]; then
	echo "$0 takes exactly 2 or more arguments"
	exit 1
fi

# Kollar så skriptet får fler än 1 argument och att första variabeln är en siffra
# Startar en sleep i bakgrunden utifrån första argumentet och shiftar sedan bort det argumentet.
if [[ $# -gt 1 && $1 = [[:digit:]]* ]]; then
	sleep $1 &
	shift
else
	echo "First argument must be only numbers"
	exit 1
fi

# Sparar pid från sleep i variabeln pid
pid=$!

# Eftersom första argumentet är shiftat så kör den resterande kommand i bakgrunden, exempelvis "ls ~/"
$@ & 2>/dev/null

# Sparar pid från ovanstående i variabeln pid2
pid2=$!


# För en whileloop så länge som pid lever
# Om inte pid2 lever så kör jag en wait på jobb 2 för att kunna printa slutstatus för jobb 1.
while $(kill -0 $pid); do
	if $(! kill -0 $pid2); then
		wait %2
		echo "SLUTSTATUS: $?"
		exit $?
	fi
done 2>/dev/null

# Om pid inte längre lever så går vi ur loopen och dödar pid2 och skriver ut TIMEOUT och exitar med code 1.
kill $pid2 2>/dev/null
echo "TIMEOUT"
exit 1
