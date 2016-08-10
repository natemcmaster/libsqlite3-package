libsqlite3-package
------------------

[![Travis build status](https://img.shields.io/travis/natemcmaster/libsqlite3-package.svg?label=travis-ci&branch=dev&style=flat-square)](https://travis-ci.org/natemcmaster/libsqlite3-package/branches)
[![AppVeyor build status](https://img.shields.io/appveyor/ci/natemcmaster/libsqlite3-package/dev.svg?label=appveyor&style=flat-square)](https://ci.appveyor.com/project/natemcmaster/libsqlite3-package/branch/dev)

[![master branch](https://img.shields.io/nuget/v/SQLite.svg?style=flat-square&label=stable)](https://www.nuget.org/packages/SQLite/)
[![dev branch](https://img.shields.io/myget/libsqlite3/vpre/SQLite.svg?style=flat-square&label=nightly)](https://www.myget.org/gallery/libsqlite3/) 

Automates creating a NuGet package of SQLite3 native library for macOS, Linux, Universal Windows apps, and Windows.

Releases are published to <https://www.nuget.org/packages/SQLite>

Nightly builds are available on MyGet: <https://www.myget.org/gallery/libsqlite3>

## Usage

.NET Framework and .NET Core apps can install this package and use SQLite via the C API and P/Invoke.
The installation of the package ensures that "sqlite3" is always available as a native component.
See <https://www.sqlite.org/c3ref/intro.html> for full reference on the SQLite C API.

Example:
```c#
public static class NativeMethod
{
     [DllImport("sqlite3", CallingConvention = CallingConvention.Cdecl)]
     public static extern IntPtr sqlite3_libversion();
}
```
```c#
string version = Marshal.PtrToStringAnsi(NativeMethod.sqlite3_libversion());
```

Used by:
 - [Microsoft.Data.Sqlite](https://github.com/aspnet/Microsoft.Data.Sqlite)