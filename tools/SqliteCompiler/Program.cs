using System;
using System.IO;
using System.Runtime.InteropServices;

namespace SqliteCompiler
{
    public class Program
    {
        private const string SqliteVersion = "3120200";
        
        public static int Main(string[] args)
        {
            try 
            {
                if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                {
                    DarwinBuilder.Compile(SqliteVersion);
                }

                if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                {
                    LinuxBuilder.Compile(SqliteVersion);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return 1;
            }
            return 0;
        }
    }
}
