using System;
using System.IO;
using System.Runtime.InteropServices;

namespace SqliteCompiler
{
    public class LinuxBuilder
    {
        public static void Compile(string version)
        {
            var intermediatePath = Path.Combine(Directory.GetCurrentDirectory(), "obj/linux");

            try 
            {
                Directory.Delete(intermediatePath, true);
            } catch {}

            Directory.CreateDirectory(intermediatePath);

            var srcDir = GetSource(version, intermediatePath);

            Compile(srcDir, RuntimeInformation.ProcessArchitecture, intermediatePath);

            if (RuntimeInformation.ProcessArchitecture == Architecture.X64)
            {
                Compile(srcDir, Architecture.X86, intermediatePath);
            }
        }

        private static string GetSource(string version, string dest)
        {
            new Command
            { 
                Executable = "curl",
                Args = $"-sSL https://sqlite.org/2016/sqlite-autoconf-{version}.tar.gz -o src.tgz",
                WorkingDirectory = dest
            }.Run();

            new Command
            { 
                Executable = "tar",
                Args = $"zvxf src.tgz",
                WorkingDirectory = dest
            }.Run();

            return Path.Combine(dest, $"sqlite-autoconf-{version}");
        }

        private static void Compile(string srcDir, Architecture arch, string intermediatePath)
        {
            var cppflags = Environment.GetEnvironmentVariable("CPPFLAGS") ?? "";
            cppflags += " -DSQLITE_ENABLE_COLUMN_METADATA=1 ";
            cppflags += " -DSQLITE_MAX_VARIABLE_NUMBER=250000 ";

            var configCommand = new Command {
                    Environment = {
                        {"CPPFLAGS", cppflags}
                    },
                    Executable = Path.Combine(srcDir, "configure"),
                    WorkingDirectory = srcDir,
                    Args = $"--prefix=\"{intermediatePath}\" --disable-dependency-tracking --enable-dynamic-extensions"
                };

            if (arch == Architecture.X86)
            {
                configCommand.Environment.Add("CFLAGS", "-m32");
                configCommand.Environment.Add("CXXFLAGS", "-m32");
                configCommand.Environment.Add("LDFLAGS", "-m32");
                configCommand.Args += " --host=i686-linux-gnu";
            }
            configCommand.Run();

	    new Command {
                Executable = "make",
                WorkingDirectory = srcDir,
                Args = "clean"
            }.Run();

            new Command {
                Executable = "make",
                WorkingDirectory = srcDir,
                Args = "install"
            }.Run();

            var suffix = arch == Architecture.X86
                ? "x86"
                : "x64";

            var destDir = Path.Combine(Directory.GetCurrentDirectory(), $"artifacts/linux-{suffix}/");
            var dest = Path.Combine(destDir, "libsqlite3.so");

            Directory.CreateDirectory(destDir);

            if (File.Exists(dest))
            {
                File.Delete(dest);
            }

            File.Copy(
                Path.Combine(intermediatePath, "lib/libsqlite3.so.0.8.6"), 
                dest);
        }
    }
}
