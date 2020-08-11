#!/usr/bin/env bash

# Options:
# no option: install
# -u uninstall
# -d test dependencies

bashrc="$HOME/.bashrc"

# Termux puts include/ share/ src/ on top level, directly below $PREFIX. To remedy this, we use $PREFIX2 (as specified below) for all subfolders of usr/ and $PREFIX1 for etc/ ...
PREFIX1="$PREFIX"
if [ "$PREFIX1" = /data/data/com.termux/files/usr ]; then
	PREFIX2=/data/data/com.termux/files
else
	PREFIX2="$PREFIX1"
fi

_warn() {
	echo >&2 ":: $*"
}

cmd_exists() {
	which "$1" &>/dev/null || busybox which "$1" &>/dev/null
}

prep_man() {
	if cmd_exists makewhatis; then
		if [ -f "$PREFIX1/etc/man.conf" ]; then
			# extend manpath via man.conf
			if ! grep -qs "$PREFIX2/usr/local/man" "$PREFIX1/etc/man.conf"; then
				if ! [ -s "$PREFIX1/etc/man.conf" ]; then
					cat - >> "$PREFIX1/etc/man.conf" << EOF
manpath $PREFIX2/usr/share/man
manpath $PREFIX2/usr/X11R6/man
EOF
				fi # -s man.conf
				cat - >> "$PREFIX1/etc/man.conf" << EOF
manpath $PREFIX2/usr/local/man
EOF
			fi # grep
		fi # -f man.conf

		# update man db
		makewhatis
	elif cmd_exists mandb; then
		# update man db
		mandb
	fi

	# add man completion (add $PREFIX2/usr/local/man to bash completion)
	man_compl="$PREFIX2/usr/share/bash-completion/completions/man"
	manpath_old="local manpath=\"$PREFIX2/usr/share/man\""
	manpath_new="${manpath_old:0: -1}:$PREFIX2/usr/local/man\""
	if grep -qs "^\(\s*\)$manpath_old\s*$" "$man_compl"; then
		sed -i "s|^\(\s*\)$manpath_old\s*$|\1$manpath_new|" "$man_compl"
	fi
}

prep_completion() {
	# add argument completion
	if ! grep -q "$PREFIX2/usr/local/bash-completion/completions/*" "$bashrc"; then
		echo 'for f in $PREFIX2/usr/local/bash-completion/completions/*; do [[ -f "$f" ]] && source "$f"; done' >> "$bashrc"
	fi
}

uninst() {
	rm "$PREFIX2/usr/local/bin/collage"
	rm "$PREFIX2/usr/local/man/man1/collage.1.gz"
	rm "$PREFIX2/usr/local/bash-completion/completions/collage"
}

check_deps() {
	(
		IFS=,
		while read cmd dep; do
			if ! cmd_exists "$cmd"; then
				_warn "WARNING! $dep is not installed!"
			fi
		done < prep/install.deps.csv
	)
}

inst() {
	# install bash script, man file and bash completion
	install -D "collage" "$PREFIX2/usr/local/bin/collage"
	if [ -f "collage.1" ]; then
		install -D -m 0644 "collage.1" "$PREFIX2/usr/local/man/man1/collage.1"
		gzip -f "$PREFIX2/usr/local/man/man1/collage.1"
		prep_man
	fi
	if [ -f "completion" ]; then
		install -D -m 0644 "completion" "$PREFIX2/usr/local/bash-completion/completions/collage"
		prep_completion
	fi
}

main() {
	if [ "$1" = "-u" ]; then
		uninst
	elif [ "$1" = "-d" ]; then
		check_deps
	else
		inst
	fi
}

main "$@"
