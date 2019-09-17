# valetudo:20190911

FROM debian:stretch-slim

# Labels
LABEL maintainer="Matthias Pröll (proell.matthias@gmail.com)"
LABEL release-date="2019-09-11"

# Aktualisiere und installiere Pakete
RUN apt update
RUN apt install apt-utils -y
RUN apt install sudo git bash python3 nano vim openssh-client curl wget ccrypt sed dos2unix tree python3-pip python3-venv --no-install-recommends -y
RUN apt-get clean

RUN echo $'clear\n\
echo\n\
echo Erstelle SSH Keys...\n\
ssh-keygen -t ed25519 -C $MAIL -f /root/.ssh/id_ed25519 -q -N ""\n\
\n\
cd /\n\
\n\
mkdir rockrobo /dev/null 2>&1\n\
cd rockrobo\n\
\n\
echo\n\
echo Lade Dustcloud...\n\
git clone --depth 1 https://github.com/dgiese/dustcloud.git\n\
\n\
mkdir valetudo\n\
pushd valetudo\n\
\n\
wget $VALETUDO_RELEASE\n\
\n\
mkdir deployment\n\
pushd deployment\n\
\n\
echo\n\
echo Lade Valetudo...\n\
wget https://github.com/Hypfer/Valetudo/raw/master/deployment/valetudo.conf\n\
mkdir etc\n\
pushd etc\n\
wget https://github.com/Hypfer/Valetudo/raw/master/deployment/etc/hosts\n\
wget https://github.com/Hypfer/Valetudo/raw/master/deployment/etc/rc.local\n\
popd\n\
popd\n\
popd\n\
\n\
mkdir firmware\n\
pushd firmware\n\
\n\
wget $FIRMWARE\n\
\n\
NEWFIRMWARE=$(echo $FIRMWARE | cut -d/ -f5)\n\
\n\
echo\n\
echo Erstelle Firmware...\n\
bash ../dustcloud/devices/xiaomi.vacuum/firmwarebuilder/imagebuilder.sh --firmware=../firmware/$NEWFIRMWARE --public-key=$HOME/.ssh/id_ed25519.pub --valetudo-path=../valetudo --timezone=Europe/Berlin --disable-firmware-updates --ntpserver=$NTPSERVER --replace-adbd\n\
\n\
cd ..\n\
mkdir flasher\n\
cd flasher\n\
python3 -m venv venv\n\
\n\
source venv/bin/activate\n\
pip3 install wheel\n\
wget "https://files.pythonhosted.org/packages/95/08/b4c1c3f40ae437b79d24d976d640d8629bcde6b9c385a2fbbf153597dd24/python-miio-0.4.5.tar.gz"\n\
pip3 install python-miio-0.4.5.tar.gz\n\
rm -f "python-miio-0.4.5.tar.gz"\n\
cd ..\n\
\n\
if [ $AUTOFLASH = 'true' ]; then\n\
    echo Firmware wird geflasht...\n\
    mirobo --ip "$ROBOROCK_IP" --token $TOKEN update-firmware /rockrobo/firmware/output/$NEWFIRMWARE\n\
elif [ $AUTOFLASH = 'false' ]; then\n\
    echo ""\n\
fi\n\
echo\n\
echo Firmware ist fertig und liegt unter /rockrobo/firmware/output/\n\
\n\
' > /run.sh

RUN chmod +x /run.sh

RUN echo $'clear\n\
echo\n\
cd /rockrobo/flasher\n\
source venv/bin/activate\n\
NEWFIRMWARE=$(echo $FIRMWARE | cut -d/ -f5)\n\
echo Flashe Xiaomi Roboter...\n\
mirobo --ip "$ROBOROCK_IP" --token $TOKEN update-firmware /rockrobo/firmware/output/$NEWFIRMWARE\n\
exit\n\
' > /flasher.sh

RUN chmod +x /flasher.sh

CMD tail -f /dev/null

# Starte den Container mit diesem Command:

#docker run \
#-v /Docker/valetudo/data:/rockrobo \
#--name=valetudo \
#--privileged \
#-e "MAIL=your@mail.con" \
#-e "ROBOROCK_IP=192.168.178.51" \
#-e "FIRMWARE=https://cdn.awsbj0.fds.api.mi-img.com/updpkg/v11_003468.fullos.pkg" \
#-e "VALETUDO_RELEASE=https://github.com/Hypfer/Valetudo/releases/download/0.4.0/valetudo" \
#-e "TOKEN=59446e394955794875444d414e307335" \
#-e "NTPSERVER=192.168.178.1" \
#-e "AUTOFLASH=false" \
#-e "LC_ALL=C.UTF-8" \
#-e "LANG=C.UTF-8" \
#valetudo:20190911
