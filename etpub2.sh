#!/bin/sh
### BEGIN INIT INFO
# Provides:          etpro
# Required-Start:    $network $remote_fs $local_fs 
# Required-Stop:     $network $remote_fs $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Stop/start etpub
### END INIT INFO

set -e

PATH=/sbin:/usr/sbin:/bin:/usr/bin
NAME=$(basename $0)
DESC="$NAME server"

USR="et"
DIR_BASE="/srv/et/etbin"
DIR_SRV="/srv/et/etpub2"

PORT=27960
# MOD=nitmod || legacy || etpro || etmain || nq || silent
MOD="legacy"

DAEMON_ARGS_DED="+set dedicated 2 +set net_port $PORT"
DAEMON_ARGS_PATHS="+set fs_basepath \"$DIR_BASE\" +set fs_homepath \"$DIR_SRV\""
DAEMON_ARGS_BASE=" +set fs_game $MOD +set com_hunkMegs 128 +set com_zoneMegs 24 +set vm_game 0 +set ttycon 0"
DAEMON_ARGS_EXEC="+exec cfg/etl_server.cfg"
DAEMON_ARGS="$DAEMON_ARGS_DED $DAEMON_ARGS_PATHS $DAEMON_ARGS_BASE $DAEMON_ARGS_EXEC"

DAEMON="$DIR_BASE/etlded"
PIDFILE=/var/run/$NAME.pid


# Functions
do_start()
{
    cd $DIR_BASE
    start-stop-daemon --start --oknodo --chuid $USR --make-pidfile --pidfile $PIDFILE --background --exec $DAEMON -- $DAEMON_ARGS
    RETVAL=$?
}
do_stop()
{
    start-stop-daemon --stop --oknodo --user $USR --pidfile $PIDFILE --retry 5
    RETVAL=$?
}


# Param-Switch
case "$1" in
    start)
        do_start
        ;;
    stop)
        do_stop
        ;;
    status)
        echo -n "Status: "
        if [[ -f $PIDFILE ]] ; then
          ps -p `cat $PIDFILE` > /dev/null 2>/dev/null && echo "Running" || echo "Stopped"
        else
          echo "Stopped"
        fi
        ;;
    reload|force-reload)
        ;;
    restart|force-reload)
        do_stop
        do_start
        ;;
    *)
        echo "Usage: $(basename $0) {start|stop|status|restart}" >&2
        exit 3
        ;;
esac

exit $RETVAL
