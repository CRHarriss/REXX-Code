//*
//* * Before running this JCL make the following changes:
//*
//*   Add a valid job card
//*   Change AVZx to the name of your DVM Server instance
//*   Change STEPLIB to include DVM Load Library
//*   Add DD statement for your own REXX library in SYSEXEC
//*   Change SYSEXEC to include DVM supplied SAVZEXEC
//*
//* * Parameters that can be supplied to the REXX
//*
//* * SPECIFY THE NAME OF THE DVM SERVER
//* *
//* SSID = AVZD
//* *
//* * SPECIFY THE SAVE OPTION (SAVE/REPLACE/NOSAVE)
//* *
//* SAVE = REPLACE
//* *
//* * SPECIFY THE REFRESH OPTION (REFRESH/NOREFRESH)
//* *
//* REFRESH = REFRESH
//* *
//* * SPECIFY THE NAME OF SOURCE COPYBOOK LIBRARY
//* *
//* SRCDSN = COPYBOOK_DSN
//* *
//* * SPECIFY THE VIRTUAL TABLE CRITERIA
//* *
//* * THE ORDER OF PARAMETERS IS:
//* *
//* *   SEQVT                 Denotes a sequential file mapping
//* *   VIRTUAL_TABLE_NAME    Name of the MAP / Virtual Table to create
//* *   NAME SEQ_FILE_DSN     Sequentail File to associate with VT
//* *   COPYBOOK_NAME         Copybook member describing file structure
//* *   START_FIELD (Opt)     First field to start mapping from
//* *                         If not supplied will use 01 level name
//* *
//* Example
//* *
//* SEQVT = VTNAME SEQ_FILE_DSN COPYBOOK START-FIELD
//* *
//* To change the COPYBOOK datasest/PDS used insert another
//* SRCDSN statement giving the new copybook dsn to be used
//* *
//* *
//* *
//MAP      EXEC PGM=IKJEFT01,DYNAMNBR=100,
//             PARM='%DVMSQMAP AVZx'
//STEPLIB  DD  DISP=SHR,DSN=dvm-load-library
//SYSTSPRT DD  SYSOUT=*
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
