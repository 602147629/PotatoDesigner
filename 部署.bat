@echo off
echo �����ļ�������

::���ӹ������

rd /s /q "PotatoDesigner Guest/share"
mklink /j "PotatoDesigner Guest/share" "PotatoDesigner Host/share"

rd /s /q "Framwork Guest/share"
mklink /j "Framwork Guest/share" "Framwork Host/share"

rd /s /q "Plugin GuestManager Guest/share"
mklink /j "Plugin GuestManager Guest/share" "Plugin GuestManager Host/share"

rd /s /q "Plugin UIDesigner Guest/share"
mklink /j "Plugin UIDesigner Guest/share" "Plugin UIDesigner Host/share"

rd /s /q "Plugin FileSync Guest/share"
mklink /j "Plugin FileSync Guest/share" "Plugin FileSync Host/share"

::���ͻ�������Ŀ¼��ͻ��˹����ռ�����

rd /s /q "PotatoDesigner Guest/src/designer"
mklink /j "PotatoDesigner Guest/src/designer" "WorkSpace Guest"

::�������ռ��빤�̱���������

rd /s /q "Plugin Console\bin"
mklink /j "Plugin Console\bin" "WorkSpace Host\plugins\Console"

rd /s /q "Plugin Window\bin"
mklink /j "Plugin Window\bin" "WorkSpace Host\plugins\Window"

rd /s /q "Plugin UIDesigner Guest\bin"
mklink /j "Plugin UIDesigner Guest\bin" "WorkSpace Guest\plugins\UIDesigner"

rd /s /q "Plugin GuestManager Guest\bin"
mklink /j "Plugin GuestManager Guest\bin" "WorkSpace Guest\plugins\GuestManager"

rd /s /q "Plugin FileSync Guest\bin"
mklink /j "Plugin FileSync Guest\bin" "WorkSpace Guest\plugins\FileSync"

rd /s /q "Plugin UIDesigner Host\bin"
mklink /j "Plugin UIDesigner Host\bin" "WorkSpace Host\plugins\UIDesigner"

rd /s /q "Plugin GuestManager Host\bin"
mklink /j "Plugin GuestManager Host\bin" "WorkSpace Host\plugins\GuestManager"

rd /s /q "Plugin FileSync Host\bin"
mklink /j "Plugin FileSync Host\bin" "WorkSpace Host\plugins\FileSync"

pause >nul