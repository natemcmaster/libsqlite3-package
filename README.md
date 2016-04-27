libsqlite3-package
------------------

Provides native SQLite3 library for different platforms.

Structure
```
sqlite
└── sqlite.nuspec
sqlite.native
├── sqlite.native.nuspec
├── build
│   └── net45
│       └── sqlite.native.props
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
sqlite.uwp.native
├── sqlite.uwp.native.nuspec
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