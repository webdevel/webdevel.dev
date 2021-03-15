#!/usr/bin/env awk -f netselect.awk --

BEGIN {
    true = 1
    false = 0
    config["verbose"] = false
    config["version"] = "0.1"
    config["file"] = "pings.txt"
    config["hosts"] = 64
    config["pings"] = 2
    config["uri"] = "http://dl-cdn.alpinelinux.org/alpine/"
    config["list"] = "http://dl-cdn.alpinelinux.org/alpine/MIRRORS.txt"
    config["content"] = URI"v3.13/main\n"URI"v3.13/community"

    parseParameters(ARGV, ARGC, config)

    uris=getUris(config["list"])
    hosts=getHosts(uris)
    stats=ping(hosts, config["hosts"], config["pings"])
    report("WRITING ", config["file"])
    system("printf \'"stats"\' > "config["file"])
}

# @param string hosts
# @param int limit
# @return string
function ping(hosts, limit, pings) {

    return getCommandOutput(\
        "count=0; "\
        "mkfifo /tmp/pings; "\
        "for host in "hosts"; do "\
            "test "true" = $(($count < "limit")) || break; "\
            "count=$((count += 1)); "\
            "(secs=$(ping -q -A -c "pings" -W 1 $host 2>/dev/null "\
                "| grep -o \" [0-9.]\\+/[0-9.]\\+\" "\
                "| cut -d / -f 2 "\
                "| tr -d '\\n'"\
            "); "\
            "test \"\" = \"$secs\" && secs=999.999; "\
            "printf \'%s,%s\\n\' $secs $host >> /tmp/pings & ) &"\
        "done; "\
        "wait; "\
        "cat /tmp/pings | sort -n && rm /tmp/pings",\
        "PINGS\n",\
        0,\
        " "\
    )
}

# @param string uris
# @return string
function getHosts(uris) {

    FS = "/"
    RS = " "

    return getCommandOutput("printf \'"uris"\'", "HOSTS\n", 3, " ")
}

# @param string list
# @return string
function getUris(list) {

    return getCommandOutput("curl --retry 5 "list" 2> /dev/null", "URIS\n", 0, " ")
}

# @param string command
# @param string message
# @param int field
# @param string delimiter
# @local string output
# @return string
function getCommandOutput(command, message, field, delimiter, output) {

    while (command | getline > 0) output = output $field delimiter
    close(command)
    report(message, output)

    return output
}

# @param array parameters
# @param int total
# @param array config
# @local int count
# @local int hasExit
# @local int hasParameter
# @global int true
# @return void
function parseParameters(parameters, total, config, count, hasExit, hasParameter) {

    hasExit = false

    for (count=1; count < total; ++count) {
        if ("--help" == parameters[count]) { printHelp(config); hasExit = true; continue }
        if ("--verbose" == parameters[count]) { config["verbose"] = true; continue }
        if ("--version" == parameters[count]) { print config["version"]; hasExit = true; continue }
        if ("--list" == parameters[count]) { config["list"] = parameters[count + 1]; continue }
        if ("--hosts" == parameters[count]) { config["hosts"] = parameters[count + 1]; continue }
        if ("--file" == parameters[count]) { config["file"] = parameters[count + 1]; continue }
        if ("--pings" == parameters[count]) { config["pings"] = parameters[count + 1]; continue }
    }
    if (hasExit) exit
}

# @param array config
# @return void
function printHelp(config) {
    print sprintf(\
        "  ____________________________________________\n"\
        " /                                            \\\n"\
        "/   Select Pingable Network In Portable Awk   /\n"\
        "\\____________________________________________/\n"\
        "\nUSAGE: awk -f netselect.awk -- [OPTIONS]\n\n"\
        "\t[OPTIONS]\n"\
        "\t--help             Print this help\n"\
        "\t--verbose          Print verbose messages\n"\
        "\t--version          Print version identifier\n"\
        "\t--list URI         Has list of URIs\n"\
        "\t                   default: "config["list"]"\n"\
        "\t--hosts LIMIT      Number of hosts\n"\
        "\t                   default: "config["hosts"]"\n"\
        "\t--file NAME        Write to file\n"\
        "\t                   default: "config["file"]"\n"\
        "\t--pings LIMIT      Pings per host\n"\
        "\t                   default: "config["pings"]"\n"\
    )
}

# @param string message
# @param number|string parameter
# @global array config
# @return void
function report(message, parameter) {
    if (config["verbose"]) print sprintf("\t%s\t%s", message, parameter)
}