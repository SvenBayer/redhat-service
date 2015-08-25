#!/bin/bash
# chkconfig: 345 99 01
# description: your-service-name Service
# @author sven.bayer

# Include function library
. /etc/rc.d/init.d/functions

PROGRAM_NAME="{THE_NAME_OF_YOUR_PROGRAM_NAMERAM}"
ABSOLUTE_PATH_TO_YOUR_PROGRAM="{THE_PATH_TO_YOUR_PROGRAM_NAMERAM}"
PID_FILE="/var/run/$PROGRAM_NAME.pid"
LOG_FILE="/var/log/$PROGRAM_NAME.log"
LOCK_FILE="/var/lock/subsys/$PROGRAM_NAME"

# Start the service.
start() {
  if ! [ -f $PID_FILE ]; then
    echo "Starting $PROGRAM_NAME as service."
    echo "\n$(date)\n" >> $LOG_FILE
    $ABSOLUTE_PATH_TO_YOUR_PROGRAM/$PROGRAM_NAME &>> $LOG_FILE &    echo $! > $PID_FILE
    touch $LOCK_FILE
    num_of_tries=0
    while [ ! -f $PID_FILE -a $num_of_tries -lt 10 ]; do
      sleep 1
      num_of_tries=$((num_of_tries + 1))
    done
    success
    echo "Started $PROGRAM_NAME successfully!"
  else
    failure
    echo "$PID_FILE still exists!\n"
    exit 7
  fi
}

# Stop the service.
stop() {
  echo "Stopping $PROGRAM_NAME: "
  kill -9 $(cat $PID_FILE)
  return_value_pid=$?
  rm -f $LOCK_FILE
  return_value_lock_file=$?
  if [ $return_value_pid -eq 0 ] && [ $return_value_lock_file -eq 0 ]; then
    echo "Stopped successfully"
  fi
  rm -f $PID_FILE
  return $return_value
}

# Give the status of the program.
rh_status() {
  status -p $PID_FILE $PROGRAM_NAME
}

# Give the status before quit.
rh_status_q() {
  rh_status >/dev/null 2>&1
}

# Restart the service.
restart() {
  stop
  start
}

# Application logic of the service.
case "$1" in
   start)
    rh_status_q && exit 0
    $1
    ;;
  stop)
    rh_status_q || exit 0
    $1
    ;;
  restart)
    $1
    ;;
  status)
    rh_status
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart}"
    exit 2
esac
exit $?
