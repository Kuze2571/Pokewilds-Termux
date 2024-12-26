# Pokewilds-Termux
Termux configuration to run Pokewilds on Android.

Follow those steps if you want to install Pokewilds on your Android device using Termux (not graranteed to work on every device).

## Termux setup
First you have to install Termux and Termux-x11 for the screen or the RealVNC Viewer app (play store).

Termux app and Termux-x11 can be found on their creators github, just download and install the corresponding to your device's architecture.
If you are not sure which one to chose just take the on named "universal" :
- https://github.com/termux/termux-app/releases
- https://github.com/termux/termux-x11/releases

## Installation
To install Pokewilds you just have to download the script "**pokewilds_install.sh**" and put it on your device 'Download' folder.
Once done, follow the steps below :
```
cp /sdcard/Download/pokewilds_install.sh .  #Copy the file from your device to the Termux folder
sh pokewilds_install.sh  #Run the script
```
During the installation process you will be prompted to know what to do with the sources.list, you can just tap enter if you want.

It will take a little time then, grab a tea and relax.

Once finished, we can either use Termux-x11 or RealVNC depending on your preference.

## VNC server

### Termux-x11
You can launch the game with Termux-x11 directly by typing :

```
./pokewilds_x11.sh
```

Then launch the Termux-x11 app and adjust the screen fitting to your needs.

### RealVNC Viewer
You can launch the game with Termux-x11 directly by typing :

```
./pokewilds_vnc.sh
```

The first time you use it, it will ask you to define a password. Define one and remember it, then it will prompt you to define a view only password, this is as you wish.

Once done, you can open the RealVNC Viewer app and click on the green icon with the white "+" in the right down corner.

In the "Address" section type :

```
127.0.0.1:5901
```

Then name it as you want. Click on it and type the password you defined before, you should see the game's screen pop up.


## Info
Feel free to tweak the script, especially the screen size and stuff to fit your needs.

To quit the game, hit "CTRL+C".

If you want to launch the game from your screen you can use Termux-widgets, I'll describe this part later.

Have a good one.
