using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using Xunit;

namespace LibSqlitePackage
{
    public class PInvokeTest
    {
        public PInvokeTest()
        {
            string folder = null, prefix = null, suffix = null;
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                folder = "bin/runtimes/win7-x64/native/sqlite3.dll";
                prefix = string.Empty;
                suffix = ".dll";
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                folder = "artifacts/osx-x64/libsqlite3.dylib";
                prefix = "lib";
                suffix = ".dylib";
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                folder = "artifacts/linux-x64/libsqlite3.so";
                prefix = "lib";
                suffix = ".so";
            }

            // copy the native library into the application base path so that .NET Core will p/invoke to ItCanInvokeNativeMethods
            var sqlitePath = Path.Combine(AppContext.BaseDirectory, prefix + NativeMethod.FakeSqliteName + suffix);
            File.Delete(sqlitePath);

            var src = Path.Combine(Directory.GetCurrentDirectory(), "..", folder);
            Console.WriteLine($"Copying [{src}] to [{sqlitePath}]");
            File.Copy(src, sqlitePath);
        }


        [Fact]
        public void sqlite3_libversion()
        {
            string version = Marshal.PtrToStringAnsi(NativeMethod.sqlite3_libversion());
            Assert.Equal("3.13.0", version);
        }

        private AssemblyName s_thisAssemblyName = typeof(PInvokeTest).GetTypeInfo().Assembly.GetName();
    }
}