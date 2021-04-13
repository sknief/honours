# Collection of handy WSL Commandline hacks

## Starting out with WSL
Type `wsl` in powershell to enter the correct terminal

By typing `cd` followed by nothing you return to the root.

`sudo` refers to superuser/admin powers, usually needed when you have to install things.

## Routine before you start working:
You want to start by making sure your system is up to date
  ```
  sudo apt update #to check for updates
  sudo apt upgrade #to install updates
  ```

## To navigate to different drives
Navigating in WSL is a bit strange at first as it follows Linux syntax but windows file organisation.

Hard drives are mounted like this:
```
  /mnt/c
  /mnt/d
```

So if you wanted to `cd` to your laptop, that might look like:
```
cd /mnt/c/Users/sknie/Desktop
```

## Executing Shell Script Files (.sh)
For example, when installing slim via DebianUbuntuInstall.sh
bash is a prerequisite, which you should be able to get via `sudo apt intstall`

```
sudo apt install bash #install
bash --version #check if you've gotten it installed or not  
sudo bash (filename).sh
```

## Running WSL programs such as SLiMgui
Okay, first and foremost you are going to need to install a gui tool such as VcXsrv, so that slim gui can actually link to a display. I'll put a link for that in at a later time point.

You should just be able to type in the program name if you are at `~$`in the terminal.

### Issues with running SLiMgui

```
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0 # in WSL 2
export LIBGL_ALWAYS_INDIRECT=1
```
