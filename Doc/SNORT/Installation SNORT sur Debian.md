<p align="center">
    <img src="snort.jpg" alt="PartageRO" style="width: 400px;" />
</p>

# <h1 align="center">Tutoriel d'installation de Snort</h1>
 

## Étape 1 : Mise à jour des paquets de base
Ouvrez un terminal et exécutez les commandes suivantes pour mettre à jour vos paquets de base :

```apt update apt upgrade```


## Étape 2 : Installation des paquets requis
Installez les paquets nécessaires avec la commande suivante :

```apt install -y build-essential autotools-dev libpcre3 libpcre3-dev libpcap-dev libdumbnet-dev bison flex zlib1g-dev liblzma-dev libssl-dev pkg-config hwloc libhwloc-dev cmake git sudo apt install libluajit-5.1-dev```


## Étape 3 : Installation et configuration de Libdaq
Clonez le dépôt Libdaq, configurez-le et installez-le en utilisant les commandes suivantes :

```cd /root git clone https://github.com/snort3/libdaq.git cd libdaq ./bootstrap ./configure make sudo make install```

## Étape 4 : Installation de Snort
Clonez le dépôt Snort et configurez-le en utilisant les commandes suivantes :

```git clone https://github.com/snort3/snort3.git cd /root/snort3 ./configure_cmake.sh```


## Étape 5 : Définir les chemins des bibliothèques 
Définissez les chemins des bibliothèques en utilisant les commandes suivantes :

```export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH```


## Étape 6 : Configuration finale
Configurez et construisez Snort en utilisant les commandes suivantes :

``` cd /root/snort3/build cmake … make ```


## Étape 7 : Vérification de la configuration
Vérifiez que Snort est correctement installé en utilisant les commandes suivantes :

```ls /usr/local/bin/snort```

Si la commande précédente ne renvoie rien, essayez celle-ci :

```ls /root/snort3/build/src/snort```


## Étape 8 : Fin
Installez Snort et vérifiez sa version en utilisant les commandes suivantes :

```sudo make install snort -V```


Et voilà, vous avez installé Snort et Libdaq sur votre système !

Pour plus d'informations, vous pouvez consulter les dépôts GitHub de Snort et de Libdaq.

Sources :

[GitHub - snort3/snort3: Snort++](https://github.com/snort3/snort3)

[Github - snort3/libdaq: Libdaq ](https://github.com/snort3/libdaq)