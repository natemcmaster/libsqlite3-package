using System;
using System.IO;
using System.Runtime.InteropServices;

namespace SqliteCompiler
{
	public class DarwinBuilder
	{
		public static void Compile(string version)
		{
			var objDir=Path.Combine(Directory.GetCurrentDirectory(), "obj/osx");

			try 
			{
				Directory.Delete(objDir, true);
			} catch {}

			Directory.CreateDirectory(objDir);

			new Command
			{ 
				Executable = "curl",
				Args = $"-sSL https://sqlite.org/2016/sqlite-autoconf-{version}.tar.gz -o src.tgz",
				WorkingDirectory = objDir
			}.Run();

			new Command
			{ 
				Executable = "tar",
				Args = $"zvxf src.tgz",
				WorkingDirectory = objDir
			}.Run();

            var srcDir=Path.Combine(objDir, "sqlite-autoconf-"+version);
			var cppflags = Environment.GetEnvironmentVariable("CPPFLAGS") ?? "";
			cppflags += " -DSQLITE_ENABLE_COLUMN_METADATA=1 ";
			cppflags += " -DSQLITE_MAX_VARIABLE_NUMBER=250000 ";

			new Command {
				Environment = {
					{"CPPFLAGS", cppflags}
				},
				Executable = Path.Combine(srcDir, "configure"),
				WorkingDirectory = srcDir,
				Args = $"--prefix=\"{objDir}\" --disable-dependency-tracking --enable-dynamic-extensions"
			}.Run();


			new Command {
				Executable = "make",
				WorkingDirectory = srcDir,
				Args = "install"
			}.Run();

			var suffix = RuntimeInformation.ProcessArchitecture == Architecture.X64
				? "x64"
				: "x86";

			var destDir = Path.Combine(Directory.GetCurrentDirectory(), $"artifacts/osx-{suffix}/");
			var dest = Path.Combine(destDir, "libsqlite3.dylib");

			Directory.CreateDirectory(destDir);

			if (File.Exists(dest))
			{
				File.Delete(dest);
			}

			File.Copy(
				Path.Combine(objDir, "lib/libsqlite3.0.dylib"), 
				dest);
		}
	}
}