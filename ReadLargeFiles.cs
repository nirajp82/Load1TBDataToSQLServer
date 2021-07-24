async Task ReadLargeFileUsingStream(string fileName,string newFileName)
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

//Array Of Dictionary

private static long Add(int capacity, string key)
 {
      //var value = Interlocked.Increment(ref _uniqueId);
      _uniqueId += 1;
      var keyIdMapper = FindDict(capacity, _uniqueId);
      keyIdMapper.Add(key, _uniqueId);
      return _uniqueId;
 }

private static long GetId( string key)
{            
   foreach (var dict in _keyIdMapperList)
   {
      if (dict.ContainsKey(key))
         return dict[key];
   }

    return default;
}

private static IDictionary<string, long> FindDict(int capacity, long _uniqueId) 
{
    var currentDictIndex = _uniqueId / capacity;
    if (_keyIdMapperList[currentDictIndex] == null) 
        _keyIdMapperList[currentDictIndex] = new Dictionary<string, long>(capacity);

    return _keyIdMapperList[currentDictIndex];
}
