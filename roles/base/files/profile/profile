# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
		if [ -d $HOME/.profile.d ]; then
		  for i in $HOME/.profile.d/*.bash; do
			if [ -r $i ]; then
			  . $i
			fi
		  done
		  unset i
		fi
    fi
fi

if [ -d $HOME/.profile.d ]; then
  for i in $HOME/.profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

# echo instead of <<< is required for /bin/sh compliance.
if [ -d ${HOME}/.local/bin ] && ! ( echo "$PATH" | egrep -q "[:]?${HOME}/.local/bin[:]?"); then
	export PATH="${HOME}/.local/bin:$PATH"
fi

systemctl --user import-environment PATH
