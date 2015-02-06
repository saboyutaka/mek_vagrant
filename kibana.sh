#!/bin/bash

### BEGIN INIT INFO
# Provides:          kibana
# Required-Start:    $network $named
# Required-Stop:     $network $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts kibana
# Description:       starts kibana
### END INIT INFO

export NAME=kibana
export TMP=/tmp/kibana
export LOG_DIR=/var/log/kibana
export PID=${TMP}/${NAME}.pid
export LOG=${LOG_DIR}/${NAME}.log

test -d $TMP || mkdir $TMP
test -d $LOG_DIR || mkdir $LOG_DIR

case $1 in
  'start' )
    $0 status >/dev/null 2>&1 && echo "${NAME} is already running." && exit 1
    nohup /opt/kibana-4.0.0-beta3/bin/kibana 0<&- &> $LOG &
    echo $! > $PID
    ;;
  'stop' )
    $0 status >/dev/null 2>&1 || echo "${NAME} is not running." || exit 1
    test -f $PID && cat $PID | xargs kill -s SIGKILL && rm $PID
    ;;
  'restart' )
    $0 stop
    sleep 1
    $0 start
    ;;
  'status' )
    test -f $PID || echo "${NAME} not running." || exit 1
    PID=`cat $PID`
    kill -s 0 $PID >/dev/null 2>&1 && echo "${NAME} is running." && exit 0
    echo "${NAME} not running."
    exit 1
    ;;
  *)
    echo "Usage: $0 start|stop|restart|status"
    ;;
esac
