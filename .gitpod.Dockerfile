FROM ubuntu:latest
LABEL org.opencontainers.image.authors="Nicolo Genesio <nicolo.genesio@iit.it>"

# Define here which packages to install
ARG ICUB_COMMON_PKG=https://github.com/robotology/icub-main/releases/download/v1.17.0/icub-common_1.17.0-1focal_amd64.deb

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials
RUN apt update
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo psmisc lsb-release \
        tmux nano wget build-essential git cmake cmake-curses-gui autoconf locales gdebi terminator

# Set the locale
RUN locale-gen en_US.UTF-8

# Install graphics
RUN apt install -y xfce4 xfce4-goodies xserver-xorg-video-dummy xserver-xorg-legacy x11vnc && \
    sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

# Install python
RUN apt install -y python3 python3-dev python3-pip python3-setuptools && \
    if [ ! -f "/usr/bin/python" ]; then ln -s /usr/bin/python3 /usr/bin/python; fi

# Install icub-common metapackage

RUN sh -c 'echo "deb http://www.icub.org/ubuntu focal contrib/science" > /etc/apt/sources.list.d/icub.list'
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
RUN apt update
RUN apt install icub-common

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    echo "<html><head><meta http-equiv=\"Refresh\" content=\"0; url=vnc.html?autoconnect=true&reconnect=true&reconnect_delay=1000&resize=scale&quality=9\"></head></html>" > /opt/novnc/index.html

# Set up script to launch graphics and vnc
ARG START_VNC_SESSION=/usr/bin/start-vnc-session.sh
RUN echo "pkill -9 -f \"vnc\" && pkill -9 -f \"xf\" && pkill -9 Xorg" >> ${START_VNC_SESSION} && \
    echo "rm -f /tmp/.X1-lock" >> ${START_VNC_SESSION} && \
    echo "nohup X \${DISPLAY} -config /etc/X11/xorg.conf > /dev/null 2>&1 &" >> ${START_VNC_SESSION} && \
    echo "nohup startxfce4 > /dev/null 2>&1 &" >> ${START_VNC_SESSION} && \
    echo "nohup x11vnc -localhost -display \${DISPLAY} -N -forever -shared -bg > /dev/null 2>&1" >> ${START_VNC_SESSION} && \
    echo "nohup /opt/novnc/utils/launch.sh --web /opt/novnc --vnc localhost:5901 --listen 6080 > /dev/null 2>&1 &" >> ${START_VNC_SESSION} && \
    chmod +x ${START_VNC_SESSION}

ARG XORG_CONF=/etc/X11/xorg.conf
RUN echo "Section \"Monitor\"" >> ${XORG_CONF} && \
    echo "Identifier \"Monitor0\"" >> ${XORG_CONF} && \
    echo "HorizSync 28.0-80.0" >> ${XORG_CONF} && \
    echo "VertRefresh 48.0-75.0" >> ${XORG_CONF} && \
    echo "Modeline \"1920x1080_60.00\" 172.80 1920 2040 2248 2576 1080 1081 1084 1118 -HSync +Vsync" >> ${XORG_CONF} && \
    echo "EndSection" >> ${XORG_CONF} && \
    echo "Section \"Device\"" >> ${XORG_CONF} && \
    echo "Identifier \"Card0\"" >> ${XORG_CONF} && \
    echo "Driver \"dummy\"" >> ${XORG_CONF} && \
    echo "VideoRam 256000" >> ${XORG_CONF} && \
    echo "EndSection" >> ${XORG_CONF} && \
    echo "Section \"Screen\"" >> ${XORG_CONF} && \
    echo "DefaultDepth 24" >> ${XORG_CONF} && \
    echo "Identifier \"Screen0\"" >> ${XORG_CONF} && \
    echo "Device \"Card0\"" >> ${XORG_CONF} && \
    echo "Monitor \"Monitor0\"" >> ${XORG_CONF} && \
    echo "SubSection \"Display\"" >> ${XORG_CONF} && \
    echo "Depth 24" >> ${XORG_CONF} && \
    echo "Modes \"1920x1080_60.00\"" >> ${XORG_CONF} && \
    echo "EndSubSection" >> ${XORG_CONF} && \
    echo "EndSection" >> ${XORG_CONF}

# Create user gitpod
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod && \
    # passwordless sudo for users in the 'sudo' group
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Switch to gitpod user
USER gitpod

# Create the Desktop dir
RUN mkdir -p /home/gitpod/Desktop

# Switch back to root
USER root

# Manage x11vnc, noVNC, and yarp ports
EXPOSE 5901 6080 10000/tcp 10000/udp

# Set environmental variables
ENV DISPLAY=:1

# Clean up unnecessary installation products
RUN rm -Rf /var/lib/apt/lists/*

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
