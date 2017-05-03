using System.Reflection;
using System.Runtime.InteropServices;
using Xunit;

namespace LibSqlitePackage
{
    public class PInvokeTest
    {
        [Fact]
        public void sqlite3_libversion()
        {
            string version = Marshal.PtrToStringAnsi(NativeMethod.sqlite3_libversion());
            Assert.Equal("3.14.0", version);
        }

        private AssemblyName s_thisAssemblyName = typeof(PInvokeTest).GetTypeInfo().Assembly.GetName();
    }
}
