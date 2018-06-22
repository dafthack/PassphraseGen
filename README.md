# PassphraseGen
PassphraseGen is a script for generating custom passphrase lists to be used for password cracking with hashcat rules like the ones found here: https://github.com/initstring/passphrase-wordlist. 

Included in this repo are a few wordlists located in the "lists" folder that can be used to generate passphrases including the top English words, an EFF passphrase wordlist, and the Bitcoin BIP-039 seed wordlist.

There is also an option that allows for selecting a number of random words from a list for use with the tool. The more words you have in your list the greater amount of time it will take the tool to generate the passphrases. See the "Sample Benchmarks" section below for some example run times. 

## Examples

Provided a list of the following four words the script will generate the following passphrases: 

**Wordlist**
```
hacker
password
pwnage
noob
```
**Passphrases Output**
```
hacker password pwnage noob
hacker password noob pwnage
hacker pwnage password noob
hacker pwnage noob password
hacker noob password pwnage
hacker noob pwnage password
password hacker pwnage noob
password hacker noob pwnage
password pwnage hacker noob
password pwnage noob hacker
password noob hacker pwnage
password noob pwnage hacker
pwnage hacker password noob
pwnage hacker noob password
pwnage password hacker noob
pwnage password noob hacker
pwnage noob hacker password
pwnage noob password hacker
noob hacker password pwnage
noob hacker pwnage password
noob password hacker pwnage
noob password pwnage hacker
noob pwnage hacker password
noob pwnage password hacker
```

This example will take a list of words and generate a passphrase list using four words in each passphrase.
```PowerShell
Invoke-PassphraseGen -FourWords -Wordlist .\lists\top-100-english-words-4-chars-or-more.txt -OutputFile passphrase-list.txt
```

This example will take a list of words and select 25 random lines from it. Then using those 25 words it will generate a passphrase list using four words in each passphrase.

```PowerShell
Invoke-PassphraseGen -FourWords -TotalLines 25 -Wordlist .\lists\bitcoin-bip-0039-seed-words.txt -OutputFile passphrase-list.txt
```

### Sample Benchmarks
Here are some sample benchmarks of generating passphrase lists with PassphraseGen on a fairly decent laptop... Your mileage may vary. 

```
15 words, four-per-passphrase (Total of 32760 passphrases)  : 1 min 30 secs  --- 826 KB
25 words, four-per-passphrase (Total of 303600 passphrases) : 1 hour 10 mins --- 8.07 MB
```

### Options

```
ThreeWords   -    Use this switch to generate passphrases using only 3 words.
FourWords    -    Use this switch to generate passphrases with 4 words.
Wordlist     -    The input list of words that are to be used within passphrases.
OutputFile   -    The file to output all the passphrases to.
TotalLines   -    Use this option to specify a number of lines to randomly select from the wordlist for use within passphrases.
```
