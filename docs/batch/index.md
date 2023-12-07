---
title: "title test"
meta:
  - a: "b"
  - c: 100
---

## Sleep
psshutdown

sleep_timer.bat
```bat
cmd /c psshutdown -a
set /P MINUTE="min:"
set /a TIME=60*%MINUTE%
cmd /c psshutdown -d -t %TIME%
pause
```

sleep_timer_as_admin.bat
```bat
set PROGRAM_PATH=%~dp0
powershell start-process "%PROGRAM_PATH%sleep_timer.bat" -verb runas
```


## Shutdown

```bat
cmd /c shutdown -a
set /P MINUTE="min:"
set /a TIME=60*%MINUTE%
cmd /c shutdown -s -t %TIME%
pause
```


## hibernate
hibernate_timer.bat
```bat
cmd /c psshutdown -a
set /P MINUTE="min:"
set /a TIME=60*%MINUTE%
cmd /c psshutdown -h -t %TIME%
pause
```

hibernate_timer_as_admin.bat
```bat
set PROGRAM_PATH=%~dp0
powershell start-process "%PROGRAM_PATH%hibernate_timer.bat" -verb runas
```