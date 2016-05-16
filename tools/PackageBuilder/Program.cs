using System;
using System.IO;

namespace PackageBuilder
{
    public class Program
    {
        private const string SqliteVersion = "3120200";

        private static void PrintUsage()
        {
            Console.WriteLine(@"
Usage: packagebuilder --osx [filepath] --linux [filepath]
Options:
--osx [filepath]        Path to a zip containing libsqlite3.dylib for osx-x64
--linux [filepath]      Path to a zip containing libsqlite3.so for linux-x64
");
        }
        
        public static int Main(string[] args)
        {
            try 
            {
                string osx = null, linux = null;
                for (var i = 0; i < args.Length; i++)
                {
                    switch(args[i])
                    {
                        case "--osx":
                            osx = args[++i];
                        break;
                        case "--linux":
                            linux = args[++i];
                        break;
                        default:
                            throw new ArgumentException("Unrecognized argument " + args[i]);
                    }
                }

                if (osx == null || linux == null)
                {
                    throw new Exception("Missing an argument");
                }

                var slnRoot = Directory.GetCurrentDirectory();
                try 
                {
                    Directory.SetCurrentDirectory(Path.Combine(slnRoot, "src/sqlite.uwp.native"));
                    UwpPackage.Build(SqliteVersion);

                    Directory.SetCurrentDirectory(Path.Combine(slnRoot, "src/sqlite.native"));
                    NativePackage.Build(SqliteVersion,
                        osx:      Path.Combine(slnRoot, osx),
                        linux: Path.Combine(slnRoot, linux)
                        );
                }
                finally
                {
                    Directory.SetCurrentDirectory(slnRoot);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                PrintUsage();
                return 1;
            }
            return 0;
        }
    }
}
