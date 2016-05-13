using System;

namespace PackageBuilder
{
    public class NativePackage
    {
        public static void Build(string version)
        {
            ZipTool.DownloadAndExtract(
                $"https://www.sqlite.org/2016/sqlite-dll-win32-x86-{ version }.zip",
                Tuple.Create("sqlite3.dll", "runtimes/win7-x86/native/sqlite3.dll"));
                
            ZipTool.DownloadAndExtract(
                $"https://www.sqlite.org/2016/sqlite-dll-win64-x64-{ version }.zip",
                Tuple.Create("sqlite3.dll", "runtimes/win7-x64/native/sqlite3.dll"));   
        }
    }
}