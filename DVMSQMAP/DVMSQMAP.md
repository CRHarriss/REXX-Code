# DVMSQMAP REXX

- [DVMSQMAP REXX](#dvmsqmap-rexx)
  - [Preparing the JCL before use](#preparing-the-jcl-before-use)
  - [Parameters that can be supplied to the DVMSQMAP](#parameters-that-can-be-supplied-to-the-dvmsqmap)
  - [Specification of the Virtual Table / Map](#specification-of-the-virtual-table--map)
  - [Example of Parameter input](#example-of-parameter-input)



## Preparing the JCL before use

Before running the DVMSQREXX in batch you will need to make the following changes:

Add a valid job card

Change AVZx to the name of your DVM Server instance

Change STEPLIB to include DVM Load Library

Add DD statement for your own REXX library in SYSEXEC

Change SYSEXEC to include DVM supplied SAVZEXEC

Note: The SUMMARY DD statement provies a 1 line report on the success (or failure) of each virtual table request

## Parameters that can be supplied to the DVMSQMAP 

SPECIFY THE NAME OF THE DVM SERVER

SSID = AVZD

SPECIFY THE SAVE OPTION (SAVE/REPLACE/NOSAVE)

SAVE = REPLACE

SPECIFY THE REFRESH OPTION (REFRESH/NOREFRESH)

REFRESH = REFRESH

SPECIFY THE NAME OF SOURCE COPYBOOK LIBRARY

SRCDSN = COPYBOOK_DSN

## Specification of the Virtual Table / Map

SEQVT                 Denotes a sequential file mapping

VSAMVT                Denotes a VSAM file (cluster) mapping

VIRTUAL_TABLE_NAME    Name of the MAP / Virtual Table to create

NAME SEQ_FILE_DSN     Sequentail File to associate with VT

COPYBOOK_NAME         Copybook member describing file structure

START_FIELD (Opt)     First field to start mapping from.  If not supplied the REXX will use the 01 level name from the copybook member

## Example of Parameter input

SEQVT = VTNAME SEQ_FILE_DSN COPYBOOK START-FIELD

To change the COPYBOOK datasest/PDS used insert another SRCDSN statement giving the new copybook dsn to be used
