using System;
using System.Runtime.InteropServices;

namespace LibSqlitePackage
{
    public static class NativeMethod
    {
        public const string FakeSqliteName = "testsqlite3"; // prevents binding from global installation of sqlite3
        [DllImport(FakeSqliteName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr sqlite3_libversion();
    }
}