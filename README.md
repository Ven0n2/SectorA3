# SectorA3

Punkty narożne sektorów zostały wygenerowane poprzez umieszczenie atrap w edytorze. Na przykład cywile.

Manekiny są połączone z polami z "Synchronizuj". Połączenia nie mogą się krzyżować.


Następnie otwierasz konsolę debugowania w edytorze za pomocą Ctrl + D i piszesz:
copyToClipboard str call compile preprocessFileLineNumbers "getFaces.sqf";
i naciśnij "LOCAL EXEC.". Sektory znajdują się w schowku i można je wkleić do sectorConfig.hpp po #define SECTORS.

Liczbę zajętych sektorów można odczytać za pomocą zmiennych commy_westSectorCount i commy_eastSectorCount.


~https://armaworld.de/forum/thread/4125-alternativer-sector-control-spielmodus/
