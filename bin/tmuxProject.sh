#!/usr/bin/env bash


TIMEOUT=60
REPO_OWNER=Voltserver
GIT=git

# Checks if tmux session with name of $1 exits
# Arguments
#  $1 - name of session to check for
# Return
#  true (0) - session exists
#  false (1) - session does not exist
session_exists() 
{
   local sessions=$(tmux list-sessions | grep $1)
   if [ ! -z "$sessions" ]; then
      true
   else
      false
   fi
}


session_list()
{
   return $(tmux list-sessions | sed 's/:.*//')
}

num_sessions()
{
   return session_list | wc -l
}

session_diff()
{
   return $(echo session_list $1 | uniq -u)
}

# Creates new windows in session $1
# Creates the code and build windows
# Arguments
#  $1 - socket
#  $2 - session name
#  $3 - start directory
setup_windows()
{
   local socket=$1
   local sessionName=$2
   local startDir=$3
   
   if session_exists $sessionName; then
      TMUX="" tmux -S $socket new-window -a -c $startDir -t "$sessionName:terminal" -n code
      TMUX="" tmux -S $socket new-window -a -c $startDir -t "$sessionName:code" -n build
      tmux -S $socket send-keys -t "$sessionName:code" "cd $startDir && clear" C-m
      tmux -S $socket send-keys -t "$sessionName:build" "cd $startDir && clear" C-m
   fi
      
}

# Creates a new tmux session with a name of $1 
# if it doesn't already exist
# Arguments
#  $1 - session name
create_session()
{
   local socket=$(echo $TMUX | cut -d',' -f1)
   local sessionName=$1
   local startDir=$HOME/src/$sessionName/
   local cloneRepoFlag=false
   local timeoutFlag=false
   
   # Check for session with same name
   if ! session_exists $sessionName; then
      # Check if directory exists
      if [ ! -d $startDir ]; then
         # flag if repo needs to be cloned and set start dir to just $HOME/src/
         cloneRepoFlag=true
      fi
      
      # Create session
      TMUX="" tmux -S $socket new-session -d -s $sessionName -n terminal

      # Setup windows
      setup_windows $socket $sessionName $startDir

      # Check if repo needs to be cloned
      if $cloneRepoFlag; then
         local elapsedTime=0
         local repoURL=git@github.com:$REPO_OWNER/$sessionName.git
         tmux -S $socket send-keys -t "$sessionName:terminal" "cd ~/src/" C-m
         sleep 1 # sleep to let command execute
         tmux -S $socket send-keys -t "$sessionName:terminal" -l "$GIT clone $repoURL"
         tmux -S $socket switch-client -t "$sessionName:terminal"

         # Wait for directory to exist (with timeout) 
         while [ ! -d $startDir ]; do
            if [ $elapsedTime -ge $TIMEOUT ]; then
               timeoutFlag=true
               break
            fi
            ((elapsedTime++))
            sleep 1
         done

         # Wait for git clone to finish (with timeout)
         cd $startDir
         while ! git status; do
            if [ $elapsedTime -ge $TIMEOUT ]; then
               timeoutFlag=true
               break
            fi
            ((elapsedTime++))
            sleep 1
         done 

         if ! $timeoutFlag; then
            # if not timed out, cd to proper dir
            tmux -S $socket send-keys -t "$sessionName" "cd $startDir && clear" C-m       # windows is left blank, defaults to active window
            tmux -S $socket send-keys -t "$sessionName:code" "cd $startDir && clear" C-m
            tmux -S $socket send-keys -t "$sessionName:build" "cd $startDir && clear" C-m
         else
            # display error on timeout
            tmux display-message "failed to checkout repository: $repoURL"
         fi
      else
         # cd to proper directory and change session
         tmux -S $socket send-keys -t "$sessionName:terminal" "cd $startDir && clear" C-m
         tmux -S $socket switch-client -t "$sessionName:terminal"
      fi

   else
      tmux display-message "Session already exists"
   fi
}


create_session $1

