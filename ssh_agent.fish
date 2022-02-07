# SYNOPSIS
#   ssh_agent [options]
#
# USAGE
#   Options
#

setenv SSH_ENV $HOME/.ssh/environment

function uninstall --on-event uninstall_ssh_agent

end


function addsshkeys
  set added_keys (ssh-add -l)
  for key in (find ~/.ssh/ -not -name "*.pub" -a -iname "id_*")
    if test ! (echo $added_keys | grep -o -e $key)
      ssh-add "$key"
    end
  end
end





function start_agent
  if [ -n "$SSH_AGENT_PID" ]
        ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
        if [ $status -eq 0 ]
            test_identities
        end
  else
      if [ -f $SSH_ENV ]
            . $SSH_ENV > /dev/null
        end
      ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
      if [ $status -eq 0 ]
          test_identities
      else
        echo "Initializing new SSH agent ..."
          ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
        echo "succeeded"
    chmod 600 $SSH_ENV 
    . $SSH_ENV > /dev/null
        addsshkeys
  end
  end
end


function test_identities                                                                                                                                                                
    ssh-add -l | grep "The agent has no identities" > /dev/null
    if [ $status -eq 0 ]
        ssh-add
        if [ $status -eq 2 ]
            start_agent
        end
    end
end


function fish_title
    if [ $_ = 'fish' ]
  echo (prompt_pwd)
    else
        echo $_
    end
end


# Source SSH settings, if they exist
if status --is-interactive
    if test -f "$SSH_ENV"
        . "$SSH_ENV" > /dev/null
        # Check if agent is still running, if not, start a new one
        ps -ef | grep $SSH_AGENT_PID | grep "ssh-agent -c\$" > /dev/null; or start_agent;
    else
        echo "Environment file doesn't exist"
        start_agent
    end
end


function init --on-event init_ssh_agent
  test_identities
end
