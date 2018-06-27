function Invoke-PassphraseGen{

<#
  .SYNOPSIS

    A script to gen passphrases to be used for password cracking with hashcat rules like the ones found here: https://github.com/initstring/passphrase-wordlist.

    PassphraseGen: Invoke-PassphraseGen
    Author: Beau Bullock (@dafthack)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

  .DESCRIPTION

    A script to gen passphrases to be used for password cracking with hashcat rules like the ones found here: https://github.com/initstring/passphrase-wordlist.

  .PARAMETER ThreeWords

    Use this switch to generate passphrases using only 3 words.

  .PARAMETER FourWords

    Use this switch to generate passphrases with 4 words.
    
  .PARAMETER Wordlist
  
    The input list of words that are to be used within passphrases.

  .PARAMETER OutputFile

    The file to output all the passphrases to.

  .PARAMETER TotalLines

    Use this option to specify a number of lines to randomly select from the wordlist for use within passphrases.

  .PARAMETER Threads

    Use this option to specify a number of threads. Uses 10 by default.

  .PARAMETER SleepTimer

    Time to sleep in between checking if a thread has finished or not.

  .EXAMPLE

    C:\PS> Invoke-PassphraseGen -FourWords -Wordlist .\lists\top-100-english-words-4-chars-or-more.txt -OutputFile passphrase-list.txt

    Description
    -----------
    This command will take a list of words and generate a passphrase list using four words in each passphrase.

  .EXAMPLE

    C:\PS> Invoke-PassphraseGen -FourWords -TotalLines 25 -Wordlist .\lists\bitcoin-bip-0039-seed-words.txt -OutputFile passphrase-list.txt

    Description
    -----------
    This command will take a list of words and select 25 random lines from it. Then using those 25 words it will generate a passphrase list using four words in each passphrase.

  .EXAMPLE

    C:\PS> Invoke-PassphraseGen -Threads 20 -FourWords -Wordlist .\lists\top-100-english-words-4-chars-or-more.txt -OutputFile passphrase-list.txt

    Description
    -----------
    This command will take a list of words and generate a passphrase list using four words in each passphrase. A total of 20 threads will be opened up concurrently.


#>


  Param
  (
    [Parameter(Position = 0, Mandatory = $false)]
    [switch]
    $ThreeWords = $false,

    [Parameter(Position = 1, Mandatory = $false)]
    [switch]
    $FourWords = $false,

    [Parameter(Position = 2, Mandatory = $true)]
    [string]
    $Wordlist = "",

    [Parameter(Position = 3, Mandatory = $true)]
    [string]
    $OutputFile = "",

    [Parameter(Position = 4, Mandatory = $false)]
    [string]
    $TotalLines = "",
    
    [Parameter(Position = 5, Mandatory = $false)]
    [string]
    $Threads = 10,

    [Parameter(Position = 6, Mandatory = $false)]
    [string]
    $SleepTimer = 500
  )

    If (($ThreeWords -ne $true) -and ($FourWords -ne $true))
    {
    Write-Host "[*] You must specify either the -ThreeWords or -FourWords option" -ForegroundColor Yellow
    break
    }
    #Select a number of random lines from the file for use
    if ($TotalLines -ne "")
        {
            Write-Host "[*] The -TotalLines option was specified. Now selecting $TotalLines random words from the file at $Wordlist." -ForegroundColor Yellow
            $rawlist = Get-Random -Count $TotalLines -InputObject (Get-Content $Wordlist)
        }
    else
        {
            $rawlist = Get-Content -Path $Wordlist
        }

    $rawlistcount = $rawlist.count

    #Checking there are enough words to create passphrases of the correct length
    if ($ThreeWords -and ($rawlistcount -lt 3)){
        Write-Host "[*] You must specify three or more words in your list for three-word passphrases!" -ForegroundColor Red
        break
    }
    if ($FourWords -and ($rawlistcount -lt 4)){
        Write-Host "[*] You must specify four or more words in your list for four-word passphrases!" -ForegroundColor Red
        break
    }

    #Calculate number of permutations for three and four word passphrases
    if ($ThreeWords -and ($rawlistcount -eq 3)){
    $threespotcombos = (Factorial $rawlistcount)
    }
    else{
    $threespotcombos = (Factorial $rawlistcount)/(Factorial ($rawlistcount - 3))
    }
    if ($FourWords -and ($rawlistcount -eq 4)){
    $fourspotcombos = (Factorial $rawlistcount)
    }
    else{
    $fourspotcombos = (Factorial $rawlistcount)/(Factorial ($rawlistcount - 4))
    }

    #Prompting to continue and specifying how many total permutations will be generated. Obviously, the more permutations the longer it takes to run. 
    if ($ThreeWords){
    Write-Host "[*] Running PassphraseGen with a list that has " -ForegroundColor Yellow -NoNewline; Write-Host $rawlistcount -ForegroundColor Red -NoNewline; Write-Host " lines will result in the following total number of three word passphrases: " -ForegroundColor yellow -NoNewline; Write-Host $threespotcombos -ForegroundColor Red  
    Write-Host "[*] Are you sure you want to continue?" -ForegroundColor Yellow 
        $Readhost = Read-Host " ( y / n ) " 
        Switch ($ReadHost) 
         { 
           Y {Write-host "Permutating all teh thingz now..." -ForegroundColor Green; continue} 
           N {Write-Host "Quitting..." -ForegroundColor red; exit } 
         } 
    }

    if ($FourWords){
    Write-Host "[*] Running PassphraseGen with a list that has " -ForegroundColor Yellow -NoNewline; Write-Host $rawlistcount -ForegroundColor Red -NoNewline; Write-Host " lines will result in the following total number of four word passphrases: " -ForegroundColor yellow -NoNewline; Write-Host $fourspotcombos -ForegroundColor Red 
    Write-Host "[*] Are you sure you want to continue?" -ForegroundColor Yellow 
        $Readhost = Read-Host " ( y / n ) " 
        Switch ($ReadHost) 
         { 
           Y {Write-host "[*] Permutating all teh thingz now..." -ForegroundColor Green; continue} 
           N {Write-Host "[*] Quitting..." -ForegroundColor Red; exit } 
         } 
    }

    #Now we finally create our passphrase list
    $list = @()
    if ($ThreeWords){
        $i = 0
        $out = @()
        $threadtotalcount = $rawlist.count * $rawlist.count
        [int]$perarraycount = (Factorial ($rawlistcount - 2))/(Factorial ($rawlistcount - 3))
        $threadlistempty = @(0) * $perarraycount
        foreach ($c1 in $rawlist) {
        
                        While ($(Get-Job -state running).count -ge $threads){
                        Write-Progress  -Activity "Permutating all teh thingz now..." -Status "Waiting for threads to close" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $threadtotalcount * 100)
                        Start-Sleep -Milliseconds $SleepTimer
                        }
                        
                        foreach ($c2 in $rawlist){
                        
                            While ($(Get-Job -state running).count -ge $threads){
                            Write-Progress  -Activity "Permutating all teh thingz now..." -Status "Waiting for threads to close" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $threadtotalcount * 100)
                            Start-Sleep -Milliseconds $SleepTimer
                            }
                            $i++
                            Start-Job -scriptblock $ThreeWordsThread -ArgumentList $c1, $c2, $rawlist | Out-Null
                            Write-Progress -Activity "Permutating all teh thingz now..." -Status "Starting Threads" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $threadtotalcount * 100)  
                            ForEach ($thread in $(Get-Job -state completed)){$out += Receive-Job $($thread.name); Remove-Job $($thread.name)}
                        }
          }
 
                   While ($(Get-Job -State Running).count -gt 0){
                        $ThreadsStillRunning = ""
                        ForEach ($thread  in $(Get-Job -state running)){$ThreadsStillRunning += ", $($thread.name)"}
                        $ThreadsStillRunning = $ThreadsStillRunning.Substring(2)
                        Write-Progress  -Activity "Permutating all teh thingz now..." -Status "$($(Get-Job -State Running).count) threads remaining" -CurrentOperation "$ThreadsStillRunning" -PercentComplete ($(Get-Job -State Completed).count / $(Get-Job).count * 100)
                        Start-Sleep -Milliseconds $SleepTimer
                        ForEach ($thread in $(Get-Job -state completed)){$out += Receive-Job $($thread.name); Remove-Job $($thread.name)}
                        Start-Sleep -Milliseconds $SleepTimer
                    }
                    Write-Host "[*] Now getting the output from all the threads..." -ForegroundColor Green

                    $out2 = @()
                    $out2 = ForEach ($job in $(Get-Job)){$out2 += Receive-Job $($job.name); Remove-Job $($job.name)}
                    $list += $out
                    $list += $out2

    }
    if ($FourWords){
        $i = 0
        $out = @()
        $threadtotalcount = $rawlist.count * $rawlist.count
        [int]$perarraycount = (Factorial ($rawlistcount - 2))/(Factorial ($rawlistcount - 4))
        $threadlistempty = @(0) * $perarraycount
        foreach ($c1 in $rawlist) {
        
                        While ($(Get-Job -state running).count -ge $threads){
                        Write-Progress  -Activity "Permutating all teh thingz now..." -Status "Waiting for threads to close" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $threadtotalcount * 100)
                        Start-Sleep -Milliseconds $SleepTimer
                        }
                        
                        foreach ($c2 in $rawlist){
                        
                            While ($(Get-Job -state running).count -ge $threads){
                            Write-Progress  -Activity "Permutating all teh thingz now..." -Status "Waiting for threads to close" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $threadtotalcount * 100)
                            Start-Sleep -Milliseconds $SleepTimer
                            }
                            $i++
                            Start-Job -scriptblock $FourWordsThread -ArgumentList $c1, $c2, $rawlist | Out-Null
                            Write-Progress -Activity "Permutating all teh thingz now..." -Status "Starting Threads" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $threadtotalcount * 100)  
                            ForEach ($thread in $(Get-Job -state completed)){$out += Receive-Job $($thread.name); Remove-Job $($thread.name)}
                        }
          }
 
                   While ($(Get-Job -State Running).count -gt 0){
                        $ThreadsStillRunning = ""
                        ForEach ($thread  in $(Get-Job -state running)){$ThreadsStillRunning += ", $($thread.name)"}
                        $ThreadsStillRunning = $ThreadsStillRunning.Substring(2)
                        Write-Progress  -Activity "Permutating all teh thingz now..." -Status "$($(Get-Job -State Running).count) threads remaining" -CurrentOperation "$ThreadsStillRunning" -PercentComplete ($(Get-Job -State Completed).count / $(Get-Job).count * 100)
                        Start-Sleep -Milliseconds $SleepTimer
                        ForEach ($thread in $(Get-Job -state completed)){$out += Receive-Job $($thread.name); Remove-Job $($thread.name)}
                        Start-Sleep -Milliseconds $SleepTimer
                    }
                    Write-Host "[*] Now getting the output from all the threads..." -ForegroundColor Green

                    $out2 = @()
                    $out2 = ForEach ($job in $(Get-Job)){$out2 += Receive-Job $($job.name); Remove-Job $($job.name)}
                    $list += $out
                    $list += $out2

    }
    Write-Host "[*] Writing passphrases to $OutputFile..." -ForegroundColor yellow
    
    #Write the passphrase list to a file
    Out-File -FilePath $OutputFile -InputObject $list -Encoding ascii
}

$FourWordsThread = {
    Param($c1, $c2, $rawlist)#, $threadlistempty)
    #$threadlist = $threadlistempty
    $threadlist = @()
            #$k = 0
            foreach ($c3 in $rawlist) {
                foreach ($c4 in $rawlist) {
                    
                    if (($c1 -ne $c2) -and ($c2 -ne $c3) -and ($c3 -ne $c4) -and ($c4 -ne $c1) -and ($c1 -ne $c3) -and ($c2 -ne $c4))
                    {
                        $threadlist += "$c1 $c2 $c3 $c4"
                        #$threadlist[$k] = "$c1 $c2 $c3 $c4"
                        #$k++
                    }
                }
            }       

    #if ($threadlist[0] -ne 0) {
    $threadlist
    #}
}


$ThreeWordsThread = {
    Param($c1, $c2, $rawlist)
    $threadlist = @()
        foreach ($c3 in $rawlist) {
            if (($c1 -ne $c2) -and ($c2 -ne $c3) -and ($c3 -ne $c1))
            {
                $threadlist += "$c1 $c2 $c3"
            }
        }
    $threadlist
}

function Factorial ([bigint]$x) {
    #From Doug Finke https://gist.github.com/dfinke/583f201fc05715ae322d
    if($x -le 1) {
        return $x
    } else {
        return $x * (Factorial ($x=$x-1))
    }
}

