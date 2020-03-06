@echo off

Setlocal EnableDelayedExpansion 

rem mysqldump所在路径
set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 5.7\bin"

rem 源数据库地址
set SRC_DB_IP=127.0.0.1
set SRC_DB_PORT=3307
set SRC_DB_USER=test
set SRC_DB_NAME=db1

rem 目的数据库地址
set TAR_DB_IP=127.0.0.1
set TAR_DB_PORT=3307
set TAR_DB_USER=test
set TAR_DB_NAME=db2

rem 不导出数据的表
set NO_DATA_TABLE=table1 table2
set NO_DATA_TABLE_CMD=
for %%a in (%NO_DATA_TABLE%) do (
	set NO_DATA_TABLE_CMD=!NO_DATA_TABLE_CMD! --ignore-table=!SRC_DB_NAME!.%%a 
)

echo MYSQL_PATH: %MYSQL_PATH%
echo SRC_DB: %SRC_DB_IP% %SRC_DB_PORT% %SRC_DB_USER% %SRC_DB_NAME%
echo TAR_DB: %TAR_DB_IP% %TAR_DB_PORT% %TAR_DB_USER% %TAR_DB_NAME%
echo NO_DATA_TABLE_CMD: %NO_DATA_TABLE_CMD%
echo.

if  "%time:~0,1%"==" " (  
    set str_date_time=%date:~0,4%%date:~5,2%%date:~8,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
) else (   
    set str_date_time=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
)

set src_file=%~dp0src_%SRC_DB_NAME%_%str_date_time%.sql
set tar_file=%~dp0tar_%TAR_DB_NAME%_%str_date_time%.sql
set log_file=%~dp0log_%str_date_time%.log
echo src_file: %src_file%
echo tar_file: %tar_file%
echo log_file: %log_file%
echo.

echo Start export data to: %src_file%
cd /d %MYSQL_PATH%
mysqldump -h%SRC_DB_IP% -u%SRC_DB_USER% -p -P%SRC_DB_PORT% --databases %SRC_DB_NAME% --routines --add-drop-database --events --no-data > %src_file%
mysqldump -h%SRC_DB_IP% -u%SRC_DB_USER% -p -P%SRC_DB_PORT% --databases %SRC_DB_NAME% --hex-blob %NO_DATA_TABLE_CMD% >> %src_file%
cd /d %~dp0
echo.

echo Start replace name of database and clear definer
echo Start generate target file to: %tar_file%
Import.py -s%src_file% -t%tar_file% -d%SRC_DB_NAME% -e%TAR_DB_NAME%
echo.

set /P makesure=确认将数据导入目标数据库吗?(Y/[N])
if /I "%makesure%" NEQ "Y" (
	echo 取消导入数据
	goto end
) else (
	echo 开始导入数据
)
echo.

echo Start import data from: %tar_file%
cd /d %MYSQL_PATH%
mysql -h%TAR_DB_IP% -u%TAR_DB_USER% -p -P%TAR_DB_PORT% < %tar_file% >%log_file% 2>&1
cd /d %~dp0
echo.

:end
pause