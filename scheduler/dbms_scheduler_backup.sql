
-- Create directory object for backups
CREATE OR REPLACE DIRECTORY dpump_dir AS '/u01/oracle/backups';
GRANT READ, WRITE ON DIRECTORY dpump_dir TO system;

-- Create DBMS_SCHEDULER job for daily backup
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'daily_backup_job',
    job_type        => 'EXECUTABLE',
    job_action      => '/u01/app/oracle/product/19.0.0/dbhome_1/bin/expdp',
    number_of_arguments => 5,
    auto_drop       => FALSE,
    enabled         => FALSE
  );

  -- Set parameters for expdp command
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 1, 'system/1234');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 2, 'DIRECTORY=dpump_dir');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 3, 'DUMPFILE=hos_backup_%U.dmp');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 4, 'LOGFILE=hos_backup.log');
  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('daily_backup_job', 5, 'FULL=Y');

  -- Set schedule: daily at 1:00 AM
  DBMS_SCHEDULER.SET_ATTRIBUTE('daily_backup_job', 'repeat_interval', 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0');

  -- Enable the job
  DBMS_SCHEDULER.ENABLE('daily_backup_job');
END;
/
