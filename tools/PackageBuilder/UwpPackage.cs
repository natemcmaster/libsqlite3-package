using System;

namespace PackageBuilder
{
    public class UwpPackage
    {
        public static void Build(string version)
        {
            ZipTool.DownloadAndExtract(
                $"https://www.sqlite.org/2016/sqlite-uwp-{ version }.vsix",
                Tuple.Create(
                    "Redist/Retail/x86/sqlite3.dll",
                    "runtimes/win10-x86/native/sqlite3.dll"),
                Tuple.Create(
                    "Redist/Retail/x64/sqlite3.dll",
                    "runtimes/win10-x64/native/sqlite3.dll"),
                Tuple.Create(
                    "Redist/Retail/ARM/sqlite3.dll",
                    "runtimes/win10-arm/native/sqlite3.dll"));
        }
    }
}