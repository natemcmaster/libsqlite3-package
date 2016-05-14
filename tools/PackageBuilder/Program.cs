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
Usage: packagebuilder --osx [filepath] --linux-x86 [filepath] --linux-x64 [filepath]
Options:
--osx [filepath]        Path to a zip containing libsqlite3.dylib
--linux-x86 [filepath]  Path to a zip containing libsqlite3.so for x86
--linux-x64 [filepath]  Path to a zip containing libsqlite3.so for x64
");
        }
        
        public static int Main(string[] args)
        {
            try 
            {
                string osx = null, linuxX86 = null, linuxX64 = null;
                for (var i = 0; i < args.Length; i++)
                {
                    switch(args[i])
                    {
                        case "--osx":
                            osx = args[++i];
                        break;
                        case "--linux-x86":
                            linuxX86 = args[++i];
                        break;
                        case "--linux-x64":
                            linuxX64 = args[++i];
                        break;
                        default:
                            throw new Exception("Unrecognized argument " + args[i]);
                    }
                }

                if (osx == null || linuxX64 == null || linuxX86 == null)
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
                        linuxX64: Path.Combine(slnRoot, linuxX64),
                        linuxX86: Path.Combine(slnRoot, linuxX86)
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
