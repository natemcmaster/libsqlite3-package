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
                    Directory.SetCurrentDirectory(Path.Combine(slnRoot, "src/sqlite.uwp.native"));
                    UwpPackage.Build(SqliteVersion);

                    Directory.SetCurrentDirectory(Path.Combine(slnRoot, "src/sqlite.native"));
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