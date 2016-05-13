using System;
using System.IO;
using System.IO.Packaging;
using System.IO.Compression;
using System.Net.Http;

namespace PackageBuilder
{
    public class ZipTool
    {
        public static void DownloadAndExtract(
            string uri,
            params Tuple<string, string>[] files)
        {
            Console.WriteLine($"info : downloading {uri}");
            using (var client = new HttpClient())
            using (var archiveStream = client.GetStreamAsync(uri).Result)
            using (var archive = new ZipArchive(archiveStream))
            {
                foreach (var file in files)
                {
                    Console.WriteLine($"info : extract {file.Item1} -> {Path.Combine(Directory.GetCurrentDirectory(), file.Item2)}");
                    var entry = archive.GetEntry(file.Item1);
                    if (entry == null)
                    {
                        throw new FileNotFoundException("Could not find file '" + file.Item1 + "'.");
                        
                    }

                    Directory.CreateDirectory(Path.GetDirectoryName(file.Item2));

                    using (var entryStream = entry.Open())
                    using (var fileStream = File.OpenWrite(file.Item2))
                    {
                        entryStream.CopyTo(fileStream);
                    }
                }
            }
        }
    }
}