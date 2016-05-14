using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace SqliteCompiler
{
	public class Command
	{
        public string WorkingDirectory { get; set; }
        public string Executable { get; set; }
        public string Args { get; set; }

        public Dictionary<string, string> Environment { get; } = new Dictionary<string, string>();

		public void Run()
		{
 			var psi = new ProcessStartInfo
            {
                FileName = Executable,
                Arguments = Args
            };

            foreach (var item in Environment)
            {
                psi.Environment[item.Key] = item.Value;
            }

            if (!string.IsNullOrWhiteSpace(WorkingDirectory))
            {
                psi.WorkingDirectory = WorkingDirectory;
                Console.WriteLine($"log  : working directory: {WorkingDirectory}");
            }

            var process = new Process
            {
                StartInfo = psi,
                EnableRaisingEvents = true
            };

            using (process)
            {
            	Console.WriteLine($"log  : exec '{Executable} {Args}'");
                process.Start();

                process.WaitForExit();

                if(process.ExitCode != 0)
                {
                	throw new Exception($"Exit code {process.ExitCode}");
                }
            }
		}
	}
}