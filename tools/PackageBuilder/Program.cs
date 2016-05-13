using System;
using System.IO;

namespace PackageBuilder
{
    public class Program
    {
        private const string SqliteVersion = "3120200";
        
        public static int Main(string[] args)
        {
            try 
            {
                var slnRoot = Directory.GetCurrentDirectory();
                try 
                {
                    Directory.SetCurrentDirectory("src/libsqlite3.uwp.native");
                    UwpPackage.Build(SqliteVersion);
                }
                finally
                {
                    Directory.SetCurrentDirectory(slnRoot);
                }
                
                try 
                {
                    Directory.SetCurrentDirectory("src/libsqlite3.native");
                    NativePackage.Build(SqliteVersion);
                }
                finally
                {
                    Directory.SetCurrentDirectory(slnRoot);
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