#!/bin/ksh 
#### this script is run and owned by root and exists at /opt/tools/admin/failover/


RSYNCRES=0
TOTALRES=0
NOTIFY=you@yourdomain.com
LOGFILE=/var/tmp/$$.rsync.out

### add --dry-run to LCL_RSYNCCMD to do test runs #LCL_RSYNCCMD="/usr/local/bin/rsync --dry-run"
LCL_RSYNCCMD="/usr/bin/rsync"
#LCL_RSYNCCMD="/usr/local/bin/rsync --dry-run"
RMT_RSYNCCMD=/usr/bin/rsync

echo "Start Date: `date`" >> ${LOGFILE}

###################################
NotifyAdmin () {
  cat ${LOGFILE} | mailx -s "MAJOR `basename $0` failed" $NOTIFY

#  rm ${LOGFILE}

  exit ${TOTALRES}
}  #End NotifyAdmin

  

###################################
rsyncAll () {

typeset RMTHOST=$1

##### use --dry-run to test it
#${LCL_RSYNCCMD} --dry-run -x --delete -e ssh --stats --verbose --rsync-path=${RMT_RSYNCCMD} -Pa /opt/sshjump ${RMTHOST}:/opt
#${LCL_RSYNCCMD} --dry-run -x --delete -e ssh --stats --verbose --links --rsync-path=${RMT_RSYNCCMD} -Pa /opt/sshjump ${RMTHOST}:/opt >> ${LOGFILE} 2>&1

echo "Using command: ${LCL_RSYNCCMD}  -x --delete -e ssh --stats --verbose --links ${EXLUDE_OPTION} --rsync-path=${RMT_RSYNCCMD} -Pa /opt/sshjump ${RMTHOST}:/opt " >> ${LOGFILE} 

${LCL_RSYNCCMD}  -x --delete -e ssh --stats --verbose --links ${EXLUDE_OPTION} --rsync-path=${RMT_RSYNCCMD} -Pa /opt/sshjump ${RMTHOST}:/opt >> ${LOGFILE} 2>&1

RSYNCRES=$?
TOTALRES=`expr ${RSYNCRES}  + ${TOTALRES}`
echo "Rsync Results=${RSYNCRES}" >> ${LOGFILE}
RSYNCRES=0

echo "End Date: `date`" >> ${LOGFILE}

### Force emailing the results for testing
#TOTALRES=2

} ## End rsyncAll

###################################
####   Main Program
###################################


HOSTNM=`hostname | cut -d "." -f1`

rsyncAll yourHAhost

#TOTALRES=2	#Uncomment for debugging

if [ $TOTALRES -gt 0 ]
then
  NotifyAdmin
fi

#rm ${LOGFILE}

exit $TOTALRES

