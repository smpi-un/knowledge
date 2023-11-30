# Python 実行ファイル化

どれもウン百メガ〜ウンギガになるので実用的なんかな？


## nuitka(Windows)
```bat
.\.venv\Scripts\nuitka.bat --follow-imports src\main.py
```

## nuitka(Linux)
```sh
#!/bin/sh
./.venv/bin/nuitka3-run  --onefile --follow-imports src/main.py
```

## pyinstaller(Windows)
```bat
.\.venv\Scripts\pyinstaller .\src\main.py --onefile
```

## pyinstaller(Linux)
```sh
#!/bin/sh
./.venv/bin/pyinstaller ./src/main.py --onefile
```