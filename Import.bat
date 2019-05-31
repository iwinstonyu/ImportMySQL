@echo off

Setlocal EnableDelayedExpansion 

set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 5.7\bin"

set SRC_DB_IP=172.24.140.38
set SRC_DB_PORT=3308
set SRC_DB_USER=lp
set SRC_DB_NAME=lobby_slg

set TAR_DB_IP=127.0.0.1
set TAR_DB_PORT=3307
set TAR_DB_USER=lp
set TAR_DB_NAME=lobby_new

echo MYSQL_PATH: %MYSQL_PATH%
echo SRC_DB: %SRC_DB_IP% %SRC_DB_PORT% %SRC_DB_USER% %SRC_DB_NAME%
echo TAR_DB: %TAR_DB_IP% %TAR_DB_PORT% %TAR_DB_USER% %TAR_DB_NAME%
echo.

if  "%time:~0,1%"==" " (  
    set str_date_time=%date:~0,4%_%date:~5,2%_%date:~8,2%_0%time:~1,1%_%time:~3,2%_%time:~6,2%
) else (   
    set str_date_time=%date:~0,4%_%date:~5,2%_%date:~8,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
)
set str_date_time=2019_05_31_14_28_58

set src_file=%~dp0src_%SRC_DB_NAME%_%str_date_time%.sql
set tar_file=%~dp0tar_%TAR_DB_NAME%_%str_date_time%.sql
set log_file=%~dp0log_%str_date_time%.log
echo src_file: %src_file%
echo tar_file: %tar_file%
echo log_file: %log_file%
echo.

echo Start export data to: %src_file%
cd /d %MYSQL_PATH%
mysqldump -h%SRC_DB_IP% -u%SRC_DB_USER% -p -P%SRC_DB_PORT% --databases %SRC_DB_NAME% --routines --add-drop-database --events --hex-blob > %src_file%
cd /d %~dp0
echo.

echo Start replace name of database and clear definer
echo Start generate target file to: %tar_file%
quick.py -s%src_file% -t%tar_file% -d%SRC_DB_NAME% -e%TAR_DB_NAME%
echo.

echo Start import data from: %tar_file%
cd /d %MYSQL_PATH%
mysql -h%TAR_DB_IP% -u%TAR_DB_USER% -p -P%TAR_DB_PORT% < %tar_file% >%log_file% 2>&1
cd /d %~dp0
echo.

pause