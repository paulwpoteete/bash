###################################
### PWP Modifications v20200101 ###
###################################
# These settings modify the bash prompt to allow for ease of use.

# Update PATH with standard directories
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# Enable programmable completion features
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# History control
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Set history length
HISTSIZE=1000000000
HISTFILESIZE=2000000000

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set color prompt
color_prompt=yes
force_color_prompt=yes

# Alert alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Function to verify ownership after sudo operations
function func_write {
  echo "Attempting to Write History and Verify Ownership..."
  IFS=$'\n'
  var_own=$(ls -lA ~/ | awk '{ print $3,$4 }' | grep -v $USER | wc -l)
  if [ $var_own -gt 1 ]; then
  sudo umount /home/$USER/.gvfs 2>/dev/null
  sudo chown $USER.$USER /home/$USER -Rc 2>/dev/null
  fi
  unset IFS
}

# Logout, exit, and x aliases
alias logout='func_write && history >> ~/.history.save && logout'
alias x='func_write && history >> ~/.history.save && \exit'
alias exit='func_write && history >> ~/.history.save && exit'

# Determine system type
var_system=$(uname -s | grep -ic linux)

# Define color variables
rb='\e[1m\e[49m\e[31m'  # Root Bold
rn='\e[0m\e[49m\e[31m'  # Root Norm
ub='\e[1m\e[100m\e[37m' # User Bold
un='\e[0m\e[100m\e[37m' # User Norm

# Set PROMPT_COMMAND and aliases based on system type
var_date=$(date +%a,%Y%m%d.%H%Mhrs)
var_ip=$(/sbin/ifconfig -a | grep inet | grep -Ev ":|127.0.0.1" | awk '{ printf $2", " }' | rev | cut -c 3- | rev)

if [ $var_system -eq 1 ]; then
  #var_ram=$(free -h --si | grep Mem | awk '{ print $4 }')
  var_ram=`free | awk '/Mem/{printf("%.0f%\n", $3/$2 * 100)}'`
  var_cpu=`ps -eo %cpu | awk '{s+=$1} END {print int(s) "%"}'`

  PROMPT_COMMAND='if [ ${EUID} == 0 ]; then echo -en "$rn[OS:`uname -s` Login:$var_date FreeRAM:$var_ram $rb\0IP:$var_ip$rn]\e[0m\n"; else echo -en "$ub[OS:`uname -s`$un Term:$var_date CPU:$var_cpu RAM:$var_ram $ub\0IP:$var_ip$un]\e[0m\n"; fi'
  
  # Aliases for Linux systems
  alias ll='ls -lh --color --group-directories-first'
  alias grep='grep --color -E'
  alias find='time find'
  alias mv='mv -i'
  alias cp='cp -i'
  alias vi='vim'
  alias apt-get='sudo apt-get'
  alias dpkg='sudo dpkg'
  alias aptitude='sudo aptitude'
  alias screen='screen -L'
  alias dd='dd status=progress'
  alias nmap='nmap --open'
  alias d='dict'
  alias rsyncr='rsync -huvr --remove-source-files --progress'

  PS1="\[\033[0;31m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; fi)\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;33m\]\\$ \[\e[0m\]"
else
  PROMPT_COMMAND='if [ ${EUID} == 0 ]; then echo -en "$rn[OS:`uname -s` Login:$var_date $rb\0IP:$var_ip$rn]\e[0m\n"; else echo -en "$un[OS:`uname -s` Term:$var_date $ub\0IP:$var_ip$un]\e[0m\n"; fi'
  
  # Aliases for BSD systems
  alias ll='ls -lh --color'
  alias grep='grep --color -E'
  alias find='time find'
  alias mv='mv -i'
  alias cp='cp -i'
  alias vi='vim'
  alias dd='dd status=progress'
  alias nmap='nmap --open'

  PS1="\[\033[0;31m\]+-\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]-\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; fi)\[\033[0;31m\]]-[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]+-\[\033[0m\]\[\e[01;33m\]\\$ \[\e[0m\]"
fi
