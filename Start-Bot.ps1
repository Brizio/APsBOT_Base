#      .\Start-Bot.ps1 Bot
# Start-Process powershell -Verb runAs
Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$BotName,
    [Parameter(Mandatory=$false, Position=1, ValueFromPipeline=$true)][String]$BotKey,
    [Parameter(Mandatory=$false, Position=2, ValueFromPipeline=$true)][String]$FilesPath="" ,
    [Parameter(Mandatory=$false, Position=3, ValueFromPipeline=$true)][switch]$TestBot=$false 
    )
Process{
Write-Verbose "I parametri sono: BotName = $BotName / BotKey = $BotKey "
Write-Verbose "Running Path: $runningPath"
   $runningPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
            
   $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
   if ($botkey -ne $null) {
          $String = " -file $runningPath\Bot.ps1 -BotName $BotName -botkey $BotKey -FilesPath $FilesPath -TestBot $TestBot -verbose"
          $newProcess.Arguments  =  $String ;
          #$String = " -file $runningPath\Bot.ps1 -BotName $BotName -botkey $BotKey -FilesPath $FilesPath -TestBot $TestBot -verbose"
          ## TODO Call script alternative
          #& "$runningPath\$BotName.ps1" -botkey $botkey -FilesPath $FilesPath -TestBot $TestBot -verbose
   }
   else {
          $String = " -file $runningPath\Bot.ps1 -BotName $BotName -FilesPath $FilesPath -TestBot $TestBot -verbose"
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

