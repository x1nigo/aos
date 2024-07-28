#!/usr/bin/env bash

dotfilesrepo="https://github.com/x1nigo/dotfiles.git"

intro() {
	echo "
----------------------------
W E L C O M E !
----------------------------

This is a minimal post-install script for Alpine Linux. Presumably,
you already have a user account + password.

Note: This should be run in the /root directory.

Once ready, just hit <ENTER>. Otherwise, hit <CTRL-C> to quit.
"
read -r enter
}

user_info() {
	printf "%s" "To which user shall this apply to? "
 	read -r user
    	addgroup $user input
}

set_privileges() {
	echo "permit nopass :wheel" >> /etc/doas.d/doas.conf
}

set_xorg() {
	setup-xorg-base
}

install_pkgs() {
	sed '/^#/d;/^$/d' progs.txt > /tmp/progs.txt
	while IFS=$'\n' read -r prog; do
		apk add "$prog"
	done < /tmp/progs.txt
}

compile_pkgs() {
	srcdir="/home/$user/.local/src"
	mkdir -p /home/$user/.local/src
	for dir in $(echo "dwm st dmenu"); do
		git -C "$srcdir" clone https://github.com/x1nigo/$dir.git
		cd "$srcdir"/"$dir" && make clean install
	done
}

get_dotfiles() {
	git -C "$srcdir" clone "$dotfilesrepo"
	cd "$srcdir"/dotfiles
	shopt -s dotglob && cp -vr * /home/$user/

	ln -s /home/$user/.config/shell/shrc /home/$user/.shrc
	ln -s /home/$user/.config/nvim/init.vim /home/$user/.vimrc
}

update_udev() {
	mkdir -p /etc/X11/xorg.conf.d
	echo "Section \"InputClass\"
	Identifier \"touchpad\"
	Driver \"libinput\"
	MatchIsTouchpad \"on\"
		Option \"Tapping\" \"on\"
		Option \"NaturalScrolling\" \"on\"
EndSection" > /etc/X11/xorg.conf.d/30-touchpad.conf
}

cleanup() {
	cd
	rm -r ~/aos
	rm -r "$srcdir"/dotfiles
	rm -r /home/$user/.git
	rm -r /home/$user/README.md
	find /home/$user/.local/bin -type f -exec chmod +x {} \;
 	shopt -s dotglob && chown -R $user:wheel /home/$user
}

outro() {
	echo "
----------------------------
D O N E !
----------------------------

Congratulations! You now have a working linux system on your device. Hit
<ENTER> to reboot. User <CTRL-C> to cancel.
"
read -r enter
reboot
}

main() {
	intro
 	user_info
	set_privileges
	set_xorg
	install_pkgs
	compile_pkgs
	get_dotfiles
	update_udev
	cleanup
	outro
}

main
