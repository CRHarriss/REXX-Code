/* rexx                                                              */
/*-------------------------------------------------------------------*/
arg ssid

/* trace 'r' */

/*-------------------------------------------------------------------*/
/* initalise REXX variables                                          */
/* Parse input from user                                             */
/*-------------------------------------------------------------------*/

call init                           /* init variables                */

call getsysin                       /* read and parse user input     */

call mapvtb

/*-------------------------------------------------------------------*/
/* Write Summary file to report outcomes                             */
/*-------------------------------------------------------------------*/

"EXECIO" summary.0 "DISKW SUMMARY (FINIS STEM summary."

/* set RC bases on successful creation of VTs                        */

if mapfailed
then exit 12
else exit 0

init:

/*-------------------------------------------------------------------*/
/*                                                                   */
/*-------------------------------------------------------------------*/

true = 1
false = 0

mapfailed = false

vtbn = 0
finaldbd = false
finalmap = false

dbdlist = ''
dbdfail = ''

summary.0 = 0

/* defaults for VT creation                                           */

saveopt = 'SAVE'
refreshopt = 'NOREFRESH'

/* permitted options                                                 */

saveopts = 'SAVE NOSAVE REPLACE'
refreshopts = 'REFRESH NOREFRESH'

return

getsysin:

/*-------------------------------------------------------------------*/
/* Check that user has supplied input                                */
/*-------------------------------------------------------------------*/

"EXECIO * DISKR PARMS (FINIS STEM in."

if rc <> 0
then
do
  say 'Read of PARMS failed with RC='rc
  exit 8
end

/*-------------------------------------------------------------------*/
/* Parse and process the user input                                  */
/*-------------------------------------------------------------------*/

do p = 1 to in.0

  parm = translate(in.p)

  select
    when word(parm,1) = 'SSID'
    then
    do

      /* SSID - should only be specified once in pgm parm or input    */

      if ssid <> ''
      then
      do
        say 'SSID' ssid 'already specified'
      end
      else
      do
        parse var parm . '=' ssid .
      end
      say 'SSID    =' ssid
    end
    when word(parm,1) = 'SAVE'
    then
    do

      /* SAVE option - should only be specified once                  */

      parse var parm . '=' save .
      if wordpos(save,saveopts) = 0
      then
      do
        say 'Invalid SAVE option:'save
        exit 8
      end
      saveopt = save
      say 'SAVEOPT =' saveopt
    end
    when word(parm,1) = 'REFRESH'
    then
    do

      /* REFRESH option - should only be specified once               */

      parse var parm . '=' refresh .
      refresh = strip(refresh)
      if wordpos(refresh,refreshopts) = 0 then do
        say 'Invalid REFRESH option:'refresh
        exit 8
      end
      refreshopt = refresh
      say 'REFRESHOPT =' refreshopt
    end

    when word(parm,1) = 'SRCDSN'
    then
    do

      /* Verify the dataset containing the copybook members is valid  */
      /* The dataset must exist and be PO FB 80                       */

      parse var parm . '=' srcdsn .

      srcdsn = strip(srcdsn)

      vdsn = ckpds(srcdsn)

      if vdsn <> true
      then
      do
        say 'SRCDSN' srcdsn 'is invalid'
        exit 8
      end
      /* say 'SRCDSN = ' srcdsn 'and is valid' */


    end

    when word(parm,1) = 'SEQDSN'
    then
    do

      /* verify the dataset to be associated with virtual table       */
      /* The dataset must exist and be PS                             */

      parse var parm . '=' seqdsn .

      seqdsn = strip(seqdsn)

      vseq = ckseq(seqdsn)

      if vseq <> true
      then
      do
        say 'SEQDSN' seqdsn 'is invalid'
        exit 8
      end
    end

    when word(parm,1) = 'SEQVT'
    then
    do

      copystrt = ''
      vterr = false

      parse var parm . '=' vtname seqdsn copyname strtfld .

      say copies('=',80)
      say copies(' ',80)
      say 'Next SEQVT entry supplied being processed'
      say 'vtname   ' vtname
      say 'seqdsn   ' seqdsn
      say 'copyname ' copyname
      say 'strtfld  ' strtfld

      /* verify the virtual table name is valid if required           */

      vtname = strip(vtname)

      if length(vtname) > 30
      then
      do
        say 'Virtual Table name ' vtname ' must not exceed 30 chars'
        vterr = true
      end

      /* verify the dataset to be associated with virtual table       */
      /* The dataset must exist and be PS                             */

      seqdsn = strip(seqdsn)

      vseq = ckseq(seqdsn)

      if vseq <> true
      then
      do
        say 'SEQDSN' seqdsn 'is invalid'
        vterr = true
      end

      /* verify the copybook member is in the copybook pds supplied   */

      if pos(copyname,copylist) = 0
      then
      do
        say 'Copybook Member' copyname ' not found in Copybook PDS'
        vterr = true
      end
      else
      do

        if strtfld = ' '
        then
        do
          /* No Start Field supplied so we need to use copybook to    */
          /* extract the 01 level name for start field                */

          call getstrt copyname

          /* if nothing could be extracted by-pass processing VT req  */

          if copystrt  = ''
          then Vterr = true
          else vterr = false

        end
        else
        do
          copystrt = strtfld
        end
      end

      if vterr = false
      then
      do
        vtbn = vtbn + 1
        vtb.vtbn = vtname seqdsn copystrt copyname srcdsn
        say copies(' ',80)
        say 'Input VT entry ' vtname ' added to list for processing'
        say vtb.vtbn
        say copies(' ',80)
      end
    end
    when left(word(parm,1),1) = '*' then nop
    otherwise
    do
      say 'Invalid PARAMETER on line' p':'parm
      exit 8
    end
  end

end

return

ckpds:

/*-------------------------------------------------------------------*/
/* Check dataset supplied is PDS FB 80                               */
/*-------------------------------------------------------------------*/

arg pds

valid = true
copylist = ''

pds = strip(pds)

x = outtrap(stem.)

"listds '"pds"' members"

x = outtrap(off)


if rc > 0
then
do
  say 'dataset not found'
  exit 8
end

do i = 1 to stem.0

  stem.i = strip(stem.i)

  if i = 3
  then
  do
    parse var stem.i recfm lrecl . dsorg

    if dsorg <> 'PO'
    then
    do
      say 'DSN='pds' is not partitioned'
      valid = false
      leave
    end

    if left(recfm,1) <> 'F'
    then
    do
      say 'DSN='pds' is not FIXED format'
      valid = false
      leave
    end

    if lrecl <> '80'
    then
    do
      say 'DSN='pds' LRECL is' syslrecl
      valid = false
      leave
    end
  end

  if i > 6
  then
  do
    /* extract member name */
    copymem  = strip(stem.i)
    copylist = copylist copymem
  end

end


return valid

ckseq:

/*-------------------------------------------------------------------*/
/* Check dataset supplied is a Sequential dataset                    */
/*-------------------------------------------------------------------*/

arg seq

valid = true

seq = strip(seq)

"ALLOC F($LDSI$) DA('" || seq || "') SHR REUSE"

ldsi = listdsi('$LDSI$' 'FILE')

if ldsi <> 0
then
do
  say 'LISTDSI failed for DSN='seq', REASON='sysreason
  valid = false
end

if sysdsorg <> 'PS'
then
do
  say 'DSN='pds' is not sequential'
  valid = false
end

"FREE F($LDSI$)"

return valid

getstrt:

/*-------------------------------------------------------------------*/
/* Check copybook member exists and extract first 01 level name      */
/* Dataset with the copybooks must have been previously specified    */
/*-------------------------------------------------------------------*/

arg copymem

startfld = 0

pdsin =  srcdsn'('||copymem||')'

"ALLOC FILE(INFILE) DSN('"pdsin"') SHR REUSE"

"EXECIO * DISKR INFILE (STEM INREC. FINIS"

DO I = 1 TO INREC.0 /* read all the lines of the member */

  y = pos('01 ',inrec.i)

  if y > 0
  then
  do

    /* Extract the start field - assumed to be the first 01 level  */
    /* extract the variable following 01 with trailing dot removed */

    getfld = SUBSTR(inrec.i,y+3)
    lgthfld = pos('.',getfld)
    lgthfld = lgthfld - 1
    copystrt = substr(getfld, 1, lgthfld)

    leave

  end
  else copystrt = ''
end

return

mapvtb:

/*--------------------------------------------------------------------*/
/* Read through valid entries save and create a map on the DVM server */
/*--------------------------------------------------------------------*/

do mapvt = 1 to vtbn

  if mapvt = vtbn
  then finalmap = true

  parse var vtb.mapvt mvtb mseq mstrt mcopy msrcdsn .

  m = map('SEQ',mvtb, mseq, mstrt, mcopy, msrcdsn)

end

return

/*-------------------------------------------------------------------*/
/*                                                                   */
/*-------------------------------------------------------------------*/

map:
arg type, p1, p2, p3, p4, p5

p1 = strip(p1)
p2 = strip(p2)
p3 = strip(p3)
p4 = strip(p4)
p5 = strip(p5)

say copies('=',80)
say copies(' ',80)
say 'Beginning to process all Virtual Tables correctly specified'
say copies(' ',80)
say 'Mapping' type 'with' p1 p2 p3 p4
say copies('=',80)
drop sysin.
select
  when type = 'SEQ'
  then
  do
    src = p5'('p4')'
    say src
    sysin.1  = 'SSID           =' ssid
    sysin.2  = 'FUNCTION       = STOD'
    sysin.3  = 'SOURCE         =' src
    sysin.4  = 'MAP NAME       =' p1
    sysin.5  = 'SEQ FILE       =' p2
    sysin.6  = 'START FIELD    =' p3
    sysin.7  = 'END FIELD      =     '
    sysin.8  = 'SAVE OPTION    =' saveopt
    sysin.0 = 8

    if finalmap
    then
    do
      sysin.9  = 'REFRESH OPTION =' refreshopt
      sysin.0  = 9
    end
  end
  otherwise nop
end

"EXECIO" sysin.0 "DISKW SYSIN (FINIS STEM sysin."

domap = true

fail = false

/* call DVM supplied program to create map */

   mrc= avzmbtpa('O')

    if mrc > 0
    then
    do
      say 'Map failed with RC='mrc
      mapfailed = true
      fail = true
    end

if fail
then status = 'FAILED'
else status = 'SUCCESS'

if type = 'SEQ'
then type = 'MAP'

sln = status type left(p1,30)
summary.0 = summary.0 + 1
lnum = summary.0
summary.lnum = sln

return mrc
