function reboot_and_ping
    set -l destination $argv[1]
    set -l host (string split "@" $destination)[-1]

    echo "Rebooting $host..."
    ssh $destination systemctl reboot

    # Wait for shutdown: ping until it fails
    echo "Waiting for $host to shut down..."
    while ping -c 1 -W 1 $host &>/dev/null
        sleep 1
    end
    echo "$host is down"

    # Wait for network: ping until it succeeds
    echo "Waiting for $host to come back..."
    while not ping -c 1 -W 1 $host &>/dev/null
        sleep 1
    end
    echo "$host is reachable"

    # Wait for full startup: SSH until it succeeds
    echo "Waiting for SSH on $host..."
    while not ssh -o ConnectTimeout=5 $destination uptime &>/dev/null
        sleep 1
    end
    echo "$host is back online"
end
