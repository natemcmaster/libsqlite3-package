libsqlite3-package
------------------

Provides native SQLite3 library for different platforms.

Structure
```
sqlite
└── sqlite.nuspec
sqlite.native
├── build
│   └── net45
│       └── sqlite.native.props
├── sqlite.native.nuspec
└── runtimes
    ├── linux-x64
    │   └── native
    │       └── libsqlite3.so
    ├── linux-x86
    │   └── native
    │       └── libsqlite3.so
    ├── osx-x64
    │   └── native
    │       └── libsqlite3.dylib
    ├── win7-x64
    │   └── native
    │       └── sqlite3.dll (compiled for Win32)
    └── win7-x86
        └── native
            └── sqlite3.dll (compiled for Win32)
sqlite.uap.native
├── sqlite.uap.native.nuspec
└── runtimes
    ├── win10-arm
    │   └── native
    │       └── sqlite3.dll (compiled for WinRT)
    ├── win10-x64
    │   └── native
    │       └── sqlite3.dll (compiled for WinRT)
    └── win10-x86
        └── native
            └── sqlite3.dll (compiled for WinRT)
```