# Start-Process powershell -Verb runAs
Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$BotName,
    [Parameter(Mandatory=$false, Position=1, ValueFromPipeline=$true)][String]$BotKey,
    [Parameter(Mandatory=$false, Position=2, ValueFromPipeline=$true)][String]$FilePath ,
    [Parameter(Mandatory=$false, Position=3, ValueFromPipeline=$true)][switch]$TestBot 
    )
Process{
Write-Verbose "I parametri sono: BotName = $BotName / BotKey = $BotKey "
Write-Verbose "Running Path: $runningPath"
   $runningPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
            
   $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
   if ($botkey -ne $null) {
          $String = " -file $runningPath\Bot.ps1 -BotName $BotName -botkey $BotKey -FilePath $FilePath -TestBot $TestBot -verbose"
          $newProcess.Arguments  =  $String ;
          ## TODO Call script alternative
          #& "$runningPath\$BotName.ps1" -botkey $botkey -FilePath $FilePath -TestBot $TestBot -verbose
   }
   else {
          $String = " -file $runningPath\Bot.ps1 -BotName $BotName -FilePath $FilePath -TestBot $TestBot -verbose"
          $newProcess.Arguments  =  $String;
   }
   #$newProcess.Verb = "runas";
   
   # Start the new process
$proc = [System.Diagnostics.Process]::Start($newProcess);
$procid = $proc  | Select-Object -ExpandProperty id
return $proc
}

# $procid 
# $proc


#  .\Start-Bot.ps1 AloneBot
