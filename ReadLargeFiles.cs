Async Task ReadLargeFileUsingStream(string fileName,string newFileName)
{
 using (var writer = new StreamWriter(newFileName))
  {
    
    //Following line of code throws out of memory exception after reading 13.5 GB file 
    using (var fs = file.openread(filename))
    using (var bs = new bufferedstream(fs))
    using (var sr = new streamreader(bs))
    { 	 
      while ((string line = await sr.readlineasync().configureawait(false)) != null)
      {
        var newVal = "";//TODO;
        writer.WriteLine($"{line},{newVal}");
    	  #Logic...
      }
    }
  }
}


//Read all the lines of the file as a IEnumerable, 
//Following code reads 16 GB file and creates new in around 6 minutes.
void ReadLargeFileUsingIEnumerable(string fileName, string newFileName)
{
  using (var writer = new StreamWriter(newFileName))
  {
    IEnumerable<string> lines = File.ReadLines(fileName);
    foreach (var line in lines)                
    {
      writer.WriteLine($"{line},{newVal}");
    }
  }
}
