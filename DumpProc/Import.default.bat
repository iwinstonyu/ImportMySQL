@echo off

Setlocal EnableDelayedExpansion 

rem mysqldump所在路径
set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 5.7\bin"

rem 源数据库地址
set SRC_DB_IP=172.24.140.38
set SRC_DB_PORT=3308
set SRC_DB_USER=lp
set SRC_DB_NAME=lobby_slg_cn_qa1

echo MYSQL_PATH: %MYSQL_PATH%
echo SRC_DB: %SRC_DB_IP% %SRC_DB_PORT% %SRC_DB_USER% %SRC_DB_NAME%
echo.

if  "%time:~0,1%"==" " (  
    set str_date_time=%date:~0,4%%date:~5,2%%date:~8,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
) else (   
    set str_date_time=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
)

set src_file=%~dp0src_%SRC_DB_NAME%_%str_date_time%.sql
set tar_file=%~dp0tar_%SRC_DB_NAME%_%str_date_time%.sql
set log_file=%~dp0log_%str_date_time%.log
echo src_file: %src_file%
echo tar_file: %tar_file%
echo log_file: %log_file%
echo.

echo Start export data to: %src_file%
cd /d %MYSQL_PATH%
mysqldump -h172.24.140.38 -ulp -p -P3308 -ntd -R --add-drop-trigger %SRC_DB_NAME% > %src_file%
cd /d %~dp0
echo.

echo Start clear definer
echo Start generate target file to: %tar_file%
Import.py -s%src_file% -t%tar_file%
echo.

:end
pause