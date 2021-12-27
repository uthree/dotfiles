if [[ $(grep Microsoft /proc/version) ]]; then
    echo '\e[34;1mDetected wsl.\e[0m'
    if [[ ! -v INSIDE_GENIE ]]; then
        echo '\e[34;Starting genie...\e[0m'
        exec /usr/bin/genie -s
    fi
fi