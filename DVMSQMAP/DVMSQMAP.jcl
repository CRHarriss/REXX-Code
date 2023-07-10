//*        Before running review the associated markdown file
//JOBCARD
//*
//MAP      EXEC PGM=IKJEFT01,DYNAMNBR=100,
//             PARM='%DVMSQMAP AVZx'
//STEPLIB  DD  DISP=SHR,DSN=dvm-load-library
//SYSTSPRT DD  SYSOUT=*
//SUMMARY  DD  SYSOUT=*
//SYSEXEC  DD  DISP=SHR,DSN=your-user-rexx-library
//         DD  DISP=SHR,DSN=dvm-supplied-savxexec-library
//SYSTSIN  DD  DUMMY
//SYSIN    DD  DSN=&&SYSIN,UNIT=VIO,DISP=(NEW,DELETE),
//             SPACE=(TRK,1),RECFM=FB,LRECL=80
//PARMS    DD  *
SSID = AVZx
SAVE = REPLACE
REFRESH = REFRESH
SRCDSN = COPYBOOK_PDS_DSN
SEQVT = VTname seq_file_dsn copymem start-field
/*
//
