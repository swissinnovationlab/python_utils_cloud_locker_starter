FROM archlinux AS build
RUN pacman -Syu --noconfirm base base-devel linux linux-firmware nano syslinux networkmanager usbutils xf86-video-intel xorg xorg-xinit xterm i3 python python-pip openssh slim ttf-dejavu ttf-liberation gnu-free-fonts firefox neovim openbsd-netcat kitty ufw x11vnc

FROM build AS prod
COPY ./cloud_lockers_starter.py /opt/
RUN /usr/bin/touch ~/.bashrc
CMD /usr/bin/python /opt/cloud_lockers_starter.py -o "~/git/swissinnovationlab/cloud_lockers" -p "locker" -P -t "$GIT_TOKEN" -b
