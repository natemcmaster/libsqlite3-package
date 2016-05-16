using System;

namespace PackageBuilder
{
    public class NativePackage
    {
        public static void Build(string version, string linux, string osx)
        {
            ZipTool.DownloadAndExtract(
                $"https://www.sqlite.org/2016/sqlite-dll-win32-x86-{ version }.zip",
                Tuple.Create("sqlite3.dll", "runtimes/win7-x86/native/sqlite3.dll"));
                
            ZipTool.DownloadAndExtract(
                $"https://www.sqlite.org/2016/sqlite-dll-win64-x64-{ version }.zip",
                Tuple.Create("sqlite3.dll", "runtimes/win7-x64/native/sqlite3.dll"));   

            ZipTool.OpenAndExtract(linux,
                Tuple.Create("libsqlite3.so", "runtimes/linux-x64/native/libsqlite3.so"));

            ZipTool.OpenAndExtract(osx,
                Tuple.Create("libsqlite3.dylib", "runtimes/osx-x64/native/libsqlite3.dylib"));
        }
    }
}