if [ "$SSH_AGENT_PID" ]; then
    command ssh-agent -k
fi
