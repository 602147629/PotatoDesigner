@echo off
echo �����ļ�������

::�������ռ��빤�̱���������

del /Q "Plugin Console\bin"
mklink /j "Plugin Console\bin" "WorkSpace Host\plugins\Console"

pause >nul