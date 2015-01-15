@ECHO off
rem ---------------------------------------------------------------------------------
rem - ro: Un script pentru crearea si dublarea copiilor de rezerva ale unui proiect.-
rem - en: A script for creating and doubling of  backup copies of a project.        -
rem ---------------------------------------------------------------------------------
rem @Ver 6.2
rem @Date:   15.01.2015, 16:00
rem @Author: Dumitru Uzun (DUzun.Me)
REM @Repo:   https://github.com/duzun/Bak.Bat
rem @Web:    https://duzun.me
rem --------------------------------------------------------------------------
REM @Dependencies: UPX.exe, RAR.exe, attrib.exe
rem --------------------------------------------------------------------------
if     '%1'=='/goto' goto %2
if not '%1'=='/goto' goto smain
goto end
rem --------------------------------------------------------------------------
:defaults
rem Defaults

if "%bak_ext%."    =="." set bak_ext=ppr, prj, dpr, bpr, pas, dcu, ddp, c, h, cpp, php, inc, js, css, bat, cmd, cfg, ini, inf, csv, xls, doc, htm, html, exe, com, dfm, ico
if "%bak_upx%."    =="." set bak_upx=exe, com, dll, w?x, bpl
if "%bak_clean%."  =="." set bak_clean=*.ex~, *.~???, *.tmp, *.tds, *.qst, *.fpd, *.sym, *.ilc, *.ild, *.tds, *.ppu
if "%bak_dir%."    =="." set bak_dir=%date:/=-%
if "%bak_subdirs%."=="." set bak_subdirs=
if "%bak_dsk%."    =="." set bak_dsk=c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
if "%bak_dbl_dir%."=="." set bak_dbl_dir=
if "%bak_dbl%."    =="." set bak_dbl=Bak_Projects
goto e
rem --------------------------------------------------------------------------
:menu
    Echo ------------------------------------
    Echo.
    Echo    Make a choice:
    Echo.
    Echo B: BackUp
    Echo P: Pack (Rar)
    Echo X: Pack EXEs (Upx)
    Echo D: Double
    Echo C: Clean ~temp
    Echo A: ALL (BackUp and Double)
    Echo.
    Echo.
    Echo M: Make setting files
    Echo U: Copy "%bak_main%" to upper dirs
REM     Echo I: Init vars
REM     Echo S: Show vars
REM     Echo V: Cleanse vars
    Echo.
    Echo E: Exit

    REM Win XP
    REM choice /C:ecbdpxamusvi /T:e,%bak_timeout% /N

    REM Win 8
    choice /C:ecbdpxamusvi /D e /T %bak_timeout% /N

    cls
    set bak_timeout=3
    if not errorlevel 2  ( %bak_func% end        & exit )
    if not errorlevel 3  ( %bak_func% clean      & goto menu )
    if not errorlevel 4  ( %bak_func% bak        & goto menu )
    if not errorlevel 5  ( %bak_func% dbl        & goto menu )
    if not errorlevel 6  ( %bak_func% pak        & goto menu )
    if not errorlevel 7  ( %bak_func% upx        & goto menu )
    if not errorlevel 8  ( %bak_func% all        & goto menu )
    if not errorlevel 9  ( %bak_func% mkfiles    & goto menu )
    if not errorlevel 10 ( %bak_func% meup       & goto menu )
    set bak_timeout=400
    if not errorlevel 11 ( %bak_func% show       & goto menu )
    if not errorlevel 12 ( %bak_func% del_vars   & goto menu )
    if not errorlevel 13 ( %bak_func% settings . & goto menu )
goto e
rem --------------------------------------------------------------------------
:main
    %bak_func% settings .
    title %bak_dn% console: Project %bak_lng%

    if '%1'=='/dbl' %bak_func% dbl
    if '%1'=='/bak' %bak_func% bak
    if '%1'=='/pak' %bak_func% pak
    if '%1'=='/upx' %bak_func% upx
    if "%1."=="."   %bak_func% menu
goto end
rem --------------------------------------------------------------------------
:set_my_lang
REM    echo %~pnx3
REM    echo %~nx3
   set bak_ln=%~nx3
goto e
rem --------------------------------------------------------------------------
:smain
    set bak_main=%~dpnx0
    set bak_nm=%~nx0
    set bak_dn=%~n0
    set bak_rt=%~dp0
    if '%1'=='/meup' "%bak_main%" /goto meup
    set bak_func=call "%bak_main%" /goto
    set my_baks=bak_ext, bak_upx, bak_dir, bak_dsk, bak_dbl_dir, bak_dbl, bak_net, bak_clean
    set bak_timeout=400
    set bak_log=bak_log.txt

    if '%1'=='/mkfiles' %bak_func% mkfiles
REM     If Exist Clearn.bat call Clearn.bat
goto main
rem --------------------------------------------------------------------------
:all
    %bak_func% show
    %bak_func% pak
    %bak_func% dbl
goto e
rem --------------------------------------------------------------------------
:pak
  if not "%3."=="." (
    %bak_func% bak %3
    Echo. & Echo  ~ Packing files . . . ~
    Echo.
    start /wait /D.\"%bak_dn%" /MIN rar -m5 -s a "%bak_dir%.rar" "%bak_dir%"
    if exist ".\%bak_dn%\%bak_dir%.rar" rd /S /Q ".\%bak_dn%\%bak_dir%"
    REM start "Net %bak_dn%" %bak_func% net ".\%bak_dn%\%bak_dir%.rar"
    goto e
  )
  %bak_func% pak .
goto e
rem --------------------------------------------------------------------------
:net
   echo on
   if not "%bak_net%."=="." for %%i in (%bak_net%) do if exist "%%i\." (
      if not exist "%%i\%bak_name%\." md "%%i\%bak_name%"
      if not exist "%%i\%bak_name%\%bak_dn%\." md "%%i\%bak_name%\%bak_dn%"
      if exist "%%i\%bak_name%\%bak_dn%\." (
         Echo. & Echo  ~ Network %bak_dn% . . . %%i & Echo.
         copy %3 "%%i\%bak_lng%\%bak_dn%\"
         if not errorlevel 1 Echo Net: %3 - "%%i\%bak_lng%\%bak_dn%\">>%bak_log%
      )
   )
   exit
goto e
rem --------------------------------------------------------------------------
:upx
  if not "%3."=="." (
    Echo. & Echo  ~ UPX EXEs . . . ~
    Echo.
    for %%n in (%bak_upx%) do for %%m in (%3\*.%%n) do if exist "%%m" (
       start /wait /b /high upx -k -9 --best --compress-icons=0 "%%m"
    )
    goto e
  )
  %bak_func% upx .
goto e
rem --------------------------------------------------------------------------
:bak
  if not "%3."=="." (
    rem - Begining bak -----------------------------------------------------------
    if "%3" == "." (
      If not exist .\%bak_dn%\. %bak_func% mkfiles .
      if not exist ".\%bak_dn%\%bak_dir%\." md ".\%bak_dn%\%bak_dir%"
      if not exist ".\%bak_dn%\%bak_dir%\." %bak_func% error Unable to create dir: \n "%bak_rt%"\%bak_dn%\%bak_dir%\.


      Echo. & Echo  ~ Backing Up Files . . . ~
      Echo.
      %bak_func% log_prep
    )
    rem - Current dir bak --------------------------------------------------------
    %bak_func% upx %3
    %bak_func% clean %3

    if not exist ".\%bak_dn%\%bak_dir%\%3\." md ".\%bak_dn%\%bak_dir%\%3"
    for %%n in (%bak_ext%) do for %%m in (%3\*.%%n) do if exist "%%m" (
       copy "%%m" ".\%bak_dn%\%bak_dir%\%%m">nul
       Echo "%%m" -> ".\%bak_dn%\%bak_dir%\%%m">>%bak_log%
       Echo %%m
    )
    if not exist ".\%bak_dn%\%bak_dir%\%3\%bak_dn%\." (
            md ".\%bak_dn%\%bak_dir%\%3\%bak_dn%"
            attrib +h .\%bak_dn%\%bak_dir%\%3\%bak_dn%
    )
    for %%n in (%bak_ext%) do for %%m in (%3\%bak_dn%\*.%%n) do if exist "%%m" (
       copy "%%m" ".\%bak_dn%\%bak_dir%\%%m">nul
       Echo "%%m" -> ".\%bak_dn%\%bak_dir%\%%m">>%bak_log%
       rem Echo %%m
    )
    rem - Recursive bak ----------------------------------------------------------
    %bak_func% recur %3 subdirs bak
    goto e
  )
  %bak_func% bak .
goto e
rem --------------------------------------------------------------------------
:dbl
  if not "%3."=="." (
    rem - Current dir dbl --------------------------------------------------------
    for %%d in (%bak_dsk%) do if exist %%d:\nul for %%b in (%bak_dbl%) do if exist "%%d:\%%b\." if /I not "%bak_rt%" == "%%d:\%%b" (
        Echo. & Echo %%d:\%%b
        if not exist "%%d:\%%b%bak_dest%\%3\."  md "%%d:\%%b%bak_dest%\%3"
        for %%n in (%bak_ext%) do for %%m in (%3\*.%%n) do if exist "%%m" if /I not "%bak_rt%"=="%%d:\%%b%bak_dest%" (
    	   copy "%%m" "%%d:\%%b%bak_dest%\%%m">nul & Echo %%d:\%%b%bak_dest%\%%m >> %bak_log% & Echo %%d:\%%b%bak_dest%\%%m
        )

        if not exist "%%d:\%%b%bak_dest%\%3\%bak_dn%\." (
            md "%%d:\%%b%bak_dest%\%3\%bak_dn%"
            attrib +h %%d:\%%b%bak_dest%\%3\%bak_dn%
        )
        for %%n in (%bak_ext%) do for %%m in (%3\%bak_dn%\*.%%n) do if exist "%%m" if /I not "%bak_rt%"=="%%d:\%%b%bak_dest%" (
    	   copy "%%m" "%%d:\%%b%bak_dest%\%%m">nul
           Echo %%d:\%%b%bak_dest%\%%m >> %bak_log%
           rem Echo %%d:\%%b%bak_dest%\%%m
        )
    )
    rem - Recursive dbl ----------------------------------------------------------
    %bak_func% recur %3 subdirs dbl
    goto e
  )
  %bak_func% dbl_prep
  %bak_func% dbl .
  set bak_dest=
goto e
rem --------------------------------------------------------------------------
:dbl_prep
        if "%bak_dbl%."=="." goto e
        set bak_dest=
        rem if not "%bak_dbl%."    =="." set bak_dest=%bak_dest%\%bak_dbl%
        if not "%bak_dbl_dir%."=="." set bak_dest=%bak_dest%\%bak_dbl_dir%
        if not "%bak_lng%."    =="." set bak_dest=%bak_dest%\%bak_lng%

        Echo. & Echo  ~ Doubling Files . . . ~
        for %%d in (%bak_dsk%) do if exist %%d:\nul for %%b in (%bak_dbl%) do if exist "%%d:\%%b\." (
            if not exist "%%d:\%%b\%bak_dbl_dir%\." md "%%d:\%%b\%bak_dbl_dir%"
            if not exist "%%d:\%%b%bak_dest%\." md "%%d:\%%b%bak_dest%"
        )
        %bak_func% log_prep
goto e
rem --------------------------------------------------------------------------
:settings
    %bak_func% del_vars
    if "%3."=="." %bak_func% settings .\
    if     exist %~dp3\%bak_nm% %bak_func% settings %~dp3.
    if not exist %~dp3\%bak_nm% if exist %~dp3\%bak_dn%\. %bak_func% settings %~dp3.

    for %%n in (%my_baks%) do if exist "%~dpnx3\%bak_dn%\%%n.bat" call "%~dpnx3\%bak_dn%\%%n.bat"
    %bak_func% defaults

    %bak_func% set_my_lang %~dpnx3.
    set bak_lng=%bak_lng%\%bak_ln%
goto e
rem --------------------------------------------------------------------------
:recur
    set bak_recur=
    if exist "%3\%bak_dn%\bak_%4.bat" call "%3\%bak_dn%\bak_%4.bat"
    if "%bak_recur%."=="." goto e
    for %%n in (%bak_recur%) do if exist %3\%%n\. %bak_func% %5 %3\%%n
    set bak_recur=
goto e
rem --------------------------------------------------------------------------
:meup
for /R "%bak_rt%" %%i in (%bak_nm%) do if exist "%%i" if not '%bak_main%'=='%%i' (
   echo "%%i"
   attrib -s -h -r "%%i"
   type "%bak_main%" > "%%i" && echo REM Updated: %date%, %time% >> "%%i"
   attrib +h "%%i"
)
goto e
rem --------------------------------------------------------------------------
:log_prep
      echo ------------------------------------------------>>%bak_log%
      echo %date%, %time%>>%bak_log%
      if exist %bak_log% attrib +h %bak_log%>nul
goto e
rem --------------------------------------------------------------------------
:mkfiles
  if not "%3."=="." (
    if not exist %3\%bak_dn%\. (
        md %3\%bak_dn%
        attrib +h %3\%bak_dn%
    )
    if not exist %3\%bak_dn%\. %bak_func% error Unable to create the "%bak_dn%" dir!
    for %%n in (%my_baks%) do if not exist "%3\%bak_dn%\%%n.bat" echo set %%n=%%%%n%%> "%3\%bak_dn%\%%n.bat"
    if not exist "%3\%bak_dn%\bak_subdirs.bat" echo set bak_recur=> "%3\%bak_dn%\bak_subdirs.bat"
    goto e
  )
  %bak_func% mkfiles .
goto e
rem --------------------------------------------------------------------------
:error
REM  Display error mesages!
REM  Use "\n" to print from a new line
Cls
Echo.
Echo ~   Error!!!   ~
Echo.
set bak_error_msg=
  :error_l
    if "%3"=="\n" (
       if "%bak_error_msg%."=="." set bak_error_msg=.
       Echo %bak_error_msg%
       set bak_error_msg=
    )
    if not "%3"=="\n" set bak_error_msg=%bak_error_msg%%3
    shift
  if not "%3."=="." goto error_l
  if "%bak_error_msg%."=="." Echo %bak_error_msg%
  set bak_error_msg=
  Echo.
  pause
  %bak_func% end
  exit
goto end
rem --------------------------------------------------------------------------
:show
    echo.
    echo    bak_ext=~%bak_ext%~
    echo    bak_upx=~%bak_upx%~
    echo    bak_clean=~%bak_clean%~
    echo    bak_dir=~%bak_dir%~
    echo    bak_lng=~%bak_lng%~
    echo    bak_dbl=~%bak_dbl%~
	echo    bak_dbl_dir=~%bak_dbl_dir%~
	echo    bak_dsk=~%bak_dsk%~
REM     echo    bak_log=~%bak_log%~
goto e
rem --------------------------------------------------------------------------
:clean
    if not "%3."=="." (
      If not exist .\%bak_dn%\. %bak_func% mkfiles %3
      if not exist %3\%bak_dn%\tmp\. md %3\%bak_dn%\tmp
      if not exist %3\%bak_dn%\tmp\. goto e

      for %%m in (%bak_clean%) do if exist "%%m" (
         copy /Y "%%m" %3\%bak_dn%\tmp\ > nul
         if not errorlevel 1 (
            del "%%m"
            echo Del: %%m
         )
      )
      goto e
    )
    %bak_func% clean .
goto e
rem --------------------------------------------------------------------------
:del_vars
    set bak_lng=
    set bak_ext=
    set bak_upx=
    set bak_clean=
    set bak_dir=
    set bak_dbl=
    set bak_dbl_dir=
    set bak_dsk=
    set bak_error_msg=
goto e
rem --------------------------------------------------------------------------
:end
    set my_baks=
    set bak_func=
    set bak_log=
    set bak_timeout=
    set bak_main=
    set bak_nm=
    set bak_dn=
    set bak_rt=
    set bak_ln=

rem pause>nul
goto del_vars
rem exit
rem --------------------------------------------------------------------------
:e
REM Updated: Thu 01/15/2015, 16:02:01.98 
