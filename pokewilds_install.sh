#!/bin/bash
# install_pokewilds.sh - Script d'installation pour Termux
echo "Installation start"

pkg update && pkg upgrade -y
pkg install -y x11-repo
pkg install -y termux-x11-nightly
pkg install -y pulseaudio
pkg install -y proot-distro
pkg install -y wget
pkg install -y tigervnc
pkg install -y xorg-server-xvfb
pkg install -y xorg-xhost

echo "Making Termux folder"
mkdir -p /data/data/com.termux/files/usr/tmp/.X11-unix
chmod 1777 /data/data/com.termux/files/usr/tmp/.X11-unix

echo "Making VNC folder"
mkdir -p ~/.vnc
cat > ~/.vnc/config << 'EOL'
rfbport=5901
geometry=1280x800
depth=24
dpi=96
EOL

# Installation de Ubuntu via proot-distro
proot-distro install ubuntu-oldlts

# Creation du script d'installation Ubuntu
cat > ubuntu_setup.sh << 'EOL'
#!/bin/bash
# Configuration de l'environnement Ubuntu
apt update && apt upgrade -y
apt install -y openjdk-17-jdk
apt install -y build-essential
apt install -y libgl1-mesa-dev
apt install -y libxrandr2
apt install -y libxcursor1
apt install -y libxinerama1
apt install -y libopenal1
apt install -y libalut0
apt install -y libgles2
apt install -y libglfw3
apt install -y libglfw3-dev
apt install -y libgl1-mesa-dri
apt install -y mesa-utils
apt install -y unzip
apt install -y tightvncserver
# Installation de Pokewilds
wget https://github.com/SheerSt/pokewilds/releases/download/v0.8.11/pokewilds-otherplatforms.zip
unzip pokewilds-otherplatforms.zip
rm pokewilds-otherplatforms.zip
mv pokewilds-v* pokewilds/
EOL

# Rendre le script executable
chmod +x ubuntu_setup.sh

# Executer le script dans proot-distro
proot-distro login ubuntu-oldlts -- bash /data/data/com.termux/files/home/ubuntu_setup.sh

# Script de lancement avec Termux-X11
cat > pokewilds_x11.sh << 'EOL'
#!/bin/bash
# Fonction pour nettoyer les processus
cleanup() {
    echo "Cleaning ongoing..."
    pkill -f "X"
    rm -rf /data/data/com.termux/files/usr/tmp/.X11-unix/*
    rm -rf /data/data/com.termux/files/usr/tmp/.X*-lock
}

# Gestion de l'arrêt propre
trap cleanup EXIT

echo "Prior cleaning..."
cleanup
sleep 2

echo "Pokewilds starting..."
# Demarrage de pulseaudio
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
# Lancement de Termux-X11
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 &
# Attente pour s'assurer que Termux-X11 est lance
sleep 2
# Lancement de Pokewilds dans proot-distro
XDG_RUNTIME_DIR=${TMPDIR} proot-distro login ubuntu-oldlts --bind $PREFIX/tmp/.X11-unix:/tmp/.X11-unix --bind $PREFIX/tmp:/tmp -- bash -c '
export DISPLAY=:0
export XDG_RUNTIME_DIR=/tmp
export PULSE_SERVER=127.0.0.1
export LIBGL_ALWAYS_SOFTWARE=true
export __GLX_VENDOR_LIBRARY_NAME=mesa
export MESA_GL_VERSION_OVERRIDE=3.3
cd ~/pokewilds
java -Dorg.lwjgl.opengl.Display.allowSoftwareOpenGL=true \
     -Dorg.lwjgl.system.allocator=system \
     -Dorg.lwjgl.glfw.window.fullscreen=true \
     -jar pokewilds.jar
'

echo "Press ENTER to quit..."
read

EOL

# Script de lancement avec VNC
cat > pokewilds_vnc.sh << 'EOL'
#!/data/data/com.termux/files/usr/bin/bash

# Fonction pour nettoyer les processus
cleanup() {
    echo "Cleaning ongoing..."
    pkill -f "Xvnc"
    pkill Xvfb
    pkill -f "Xtightvnc"
    rm -rf /data/data/com.termux/files/usr/tmp/.X11-unix/*
    rm -rf /data/data/com.termux/files/usr/tmp/.X*-lock
    rm -f ~/.vnc/*.pid
    rm -f ~/.vnc/*.log
}

# Gestion de l'arrêt propre
trap cleanup EXIT

echo "Prior cleaning..."
cleanup
sleep 2

# Configuration de base
mkdir -p ~/.vnc
cat > ~/.vnc/config << EOF
rfbport=5901
geometry=1280x800
depth=24
dpi=96
EOF

echo "Initializing display..."
mkdir -p /data/data/com.termux/files/usr/tmp/.X11-unix
chmod 1777 /data/data/com.termux/files/usr/tmp/.X11-unix

export DISPLAY=:1
echo "Xvfb starting..."
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2
cleanup
echo "VNC server initializing..."
vncserver :1
sleep 3

echo "VNC port checking..."
netstat -an | grep 5901

echo "VNC server should be available at 127.0.0.1:5901"

xhost +local:

echo "Pokewilds starting..."
proot-distro login ubuntu-oldlts --isolated --bind /data/data/com.termux/files/usr/tmp/.X11-unix:/tmp/.X11-unix -- bash -c '
export DISPLAY=:1
export LIBGL_ALWAYS_SOFTWARE=true
export __GLX_VENDOR_LIBRARY_NAME=mesa
export MESA_GL_VERSION_OVERRIDE=3.3
cd pokewilds
java -Dorg.lwjgl.opengl.Display.allowSoftwareOpenGL=true \
     -Dorg.lwjgl.system.allocator=system \
     -Dorg.lwjgl.glfw.window.fullscreen=true \
     -jar pokewilds.jar
'

echo "Press ENTER to quit..."
read

EOL

# Rendre les scripts executables
chmod +x pokewilds_x11.sh
chmod +x pokewilds_vnc.sh

echo "Installation finished !"
echo "To launch the game with Termux-X11 : ./pokewilds_x11.sh"
echo "To launch the game with VNC : ./pokewilds_vnc.sh"
