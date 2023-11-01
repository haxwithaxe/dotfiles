# Description
This is a snapshot of my personal playbook for installing dotfiles. This snapshot has been sanitized of all (encrypted) credentials and other privacy related info. It is a perpetual work in progress as I improve and optimize my environment. When I redo this eventually I will probably use feature based roles rather than use case based roles. They get pretty chunky and complex when they are job oriented.

There are four roles. `base`, `interactive`, `workstation`, and `laptop`. Each adds onto the one before so that a laptop gets everything in `base`, `interactive`, and `workstation`.

Unless stated otherwise all variables are expected to be set separately for each host.


## Base
Includes:
* Basic tools
* Commandline sugar
* Vim/neovim sugar
* A bashrc fragment that sends out a notification at login. It sounds horrible but it's not bad when no one is supposed to be logging into these machines on a regular basis. It does not run when ssh **commands** are sent so ansible and docker context switches using the ssh transport don't  trigger it.
* ntfyr - For the notifications.
* haxmail - For easy email alerts/reports.

See [host_vars/noninteractive.yml](host_vars/noninteractive.yml) for an example host_vars file.

### Variables
Extra host specific settings and files can be specified in the host_vars.
* `host_bash_alias_files` - specifies a list of bash alias definitions found in [files/bash_alias](roles/base/files/bash_alias).
* `host_bash_completion_files` - specifies a list of bash completion definitions found in [files/bash_completion](roles/base/files/bash_completion).
* `host_bashrc_files` - specifies a list of bashrc additions found in [files/bashrc](roles/base/files/bashrc).
* `host_psrc_files` - specifies a list of psrc modules found in [files/psrc](roles/base/files/psrc). This is being replaced with liquidprompt soon.
- `host_bash_profile_files` - A list of ``.profile`` fragments to install. See [files/profile](roles/base/files/profile) for options.
- `force` - Set all force variables to `true`. Defaults to `false`.
- `force_bash_completion` - Force installing bash completion files. Defaults to `false`.
- `force_bash` - Force installing all things bash related. Defaults to `false`.
- `force_neovim` - Force install the neovim config. Defaults to `false`.
- `force_vim_plugins` - Force git to redownload the source. Defaults to `false`.

Additionally:
* `device_type` - This is currently only used to set the color of the bash prompt. If no value is given the prompt is red. If `server` is given the prompt is gold. If `workstation` the prompt is light blue.
* `users` - A list of users to apply sugar to. Each user can have the following keys:
  * `name` (required) - The user's username. 
  * `home_dir` - The user's home directory. Defaults to ``/home/{{ user.name }}``.
  * `user.interactive` - Defaults to `no`.




## Interactive
For interactive commandline only hosts. Such as a bastion or development server.

Includes:
* More CLI sugar
* More vim/neovim sugar
* Some more advanced/heavy utilities

### Variables
See `users` and `user.*` from the base role.

See [host_vars/interactive.yml](host_vars/interactive.yml) for an example of a host_vars file.


## Workstation
Anything with a GUI that runs linux.

Includes:
* i3 settings
* GTK and QT theming
* QMK build environment
* Desktop utilities
* Development tools (ansible, docker, extra shiny vim plugins, etc)


### Variables
* `arduino_version` - The version number of the arduino IDE/SDK to install for the `gui_user`.
* `chrome.profiles` and `firefox.profiles` - See [this section](#Browser Profiles) for details.
* `force` - Set all `force_*` variables to `true`. Defaults to `false`.
* `force_dropbox` - Force downloading and installing dropbox even if ansible thinks it doesn't need to. Defaults to `false`. Dropbox is in the process of being replaced with Syncthing.
* `force_networkmanager` - Force installing the network manager applet to the autostart folder. Defaults to `false`.
* `gui_user` - The user to configure the GUI for.
  * `gui_user.name` - The user's username.
  * `gui_user.home_dir` - The user's home directory.
* `host_xsessionrc_files` - Specifies a list of xsessionrc fragments found in [files/xsessionrc](roles/workstation/files/xsessionrc).
* `screen_lock` - The type of screen lock to install for `gui_user`. The options are ``advanced`` and ``basic``. 
  * ``advanced`` - Uses `xautolock` and `i3lock`. It gives a grace period between the screen sleeping and locking the screen. This can be a little flaky.
  * ``basic`` - Uses `xss-lock` and `i3lock` it just locks the screen as soon as it goes to sleep.
* `use_networkmanager` - If `true` install NetworkManager. Defaults to `false`.
* `use_nm_applet` - If `true` install `nm-applet` and add it to autostart. Defaults to `false`.
* See below for more variables.

Example:
```yaml
...
gui_user:
  name: "hax"
  home_dir: "/home/hax"
...
```


### QMK
The QMK part of the playbook requires the `github_user` and `qmk_git_branch` variables.

Example:
```yaml
...
github_user: haxwithaxe
qmk_git_branch: haxwithaxe
...
```


### Browser Profiles
There are scripts that manage multiple simultaneous browser profiles. The following example shows configuring a `default` and a `clean` profile for both chromium and firefox. This creates `chrome-default`, `chrome-clean`, `firefox-default`, and `firefox-clean` symlinks to `chrome-profile` and `firefox-profile` scripts respectively. These profile management scripts keep the browsers from getting confused when starting new windows. `chrome-anon` and `firefox-anon` scripts are installed as well. Those are specialized for launching their browsers in "incognito" or "private" mode with a fresh profile every time.

`firefox-anon` and `chrome-anon` are always installed.

Example:
```yaml
...
chrome:
  profiles:
    - default
    - clean

firefox:
  profiles:
    - default
    - clean
...
```


### i3

#### Config
`~/.config/i3/config` settings:
* `i3_config.displays` - Specify a map of display variables.
* `i3_config.workspaces` - Set static workspace:display map.

Example:
```yaml
...
i3_config:
  displays:
    PRIMARY: eDP1
  workspaces:
    1: PRIMARY
    2: PRIMARY
    3: PRIMARY
...
```


#### i3bar
i3bar (using conky) settings:
* `i3bar.battery_name` - The name of the battery device if any exists. Unset and unused by default since this is a laptop thing.
* `i3bar.cpu_usage` - A list of CPU cores to show usage for. Each has the following keys:
    * `label` - The name to display.
    * `index` - The CPU core index to show usage for (eg `0`).
* `i3bar.cpu_temp` - A list of CPU cores to show the temperature for. Each has the following keys (These values are passed to hwmon like `hwmon <device> temp <subdevice>`):
  * `device` - The hwmon device (eg `0`).
  * `subdevice` - The hwmon subdevice (eg `1`)
* `i3bar_critical_temp_default` - The default critical temperature in celcius. Some devices don't report a critical temperature so this is the fallback. Defaults to 80.
* `i3bar.disk_space` - A list of mount points to show disk usage for. Each has the following keys:
  * `label` - The name to display.
  * `mount` - The mount point (eg `/` or `/home`).
  * `low_perc` - The free space percent to change to the danger color at (eg `10` for 10%).
* `i3bar.diskio` - A list of storage devices (without a leading "/dev/") to show IO stats for.
* `i3bar.wired_state` - A list of wired network interfaces to show stats for.


Example:
```yaml
...
i3bar:
  cpu_usage:
    - label: "c0"
      index: 0
  cpu_temp:
    - device: 0
      subdevice: 1
  disk_space:
    - label: "/"
      mount: "/"
      low_perc: 10
    - label: "h"
      mount: "/home"
      low_perc: 10
  diskio:
    - "sda"
  wired_state:
    - "enp1s0"
...
```


#### Secrets
```yaml
...
i3_secrets:
  conky:
    zipcode: <zipcode>
    weather_api_key: "<openweathermap.org API key>"
...
```


### host_vars Example
```yaml
---

device_type: "workstation"

users: 
  - name: "hax"
    home_dir: "/home/hax"
  - name: "root"
    home_dir: "/root"

host_bash_alias_files:
  - netshoot
  - random-port

host_bashrc_files:
  - docker

# Workstation vars
gui_user:
  name: "hax"
  home_dir: "/home/hax"

chrome:
  profiles:
    - default
    - clean  # no plugins 

firefox:
  profiles:
    - default
    - clean  # no plugins

i3_config:
  displays:
    PRIMARY: eDP1
  workspaces:
    1: PRIMARY
    2: PRIMARY
    3: PRIMARY

i3bar:
  wired_state:
    - "eth0"
  diskio:
    - "sda"
  disk_space:
    - label: "/"
      mount: "/"
      low_perc: 10
    - label: "h"
      mount: "/home"
      low_perc: 10
  cpu_usage:
    - label: "c0"
    - index: 0
  cpu_temp:
    - device: 0
      subdevice: 1

github_user: haxwithaxe
qmk_git_branch: haxwithaxe

xsessionrc:
  files:
    - always-on
    - disable-capslock
    - hp-zr24w-resolution
    - i3.env
    - merge-pastebuffers
    - set-background
    - xkb-fixes
    - xmodmap
    - xss-lock
```


## Laptop
You'll never guess ...

Mostly just touch pad, lid state, and battery stuff.

### Variables
There are no laptop specific variables. A laptop host_vars file can use any of the variables from the other roles which get layered on before this one.
