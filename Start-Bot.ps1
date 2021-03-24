# Start-Process powershell -Verb runAs
Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$BotName,
    [Parameter(Mandatory=$false, Position=1, ValueFromPipeline=$true)][String]$botkey
    )
Process{
Write-Verbose "I parametri sono: BotName = $BotName / BotKey = $botkey "
Write-Verbose "Running Path: $runningPath"
   $runningPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
            
   $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
   if ($botkey -ne $null) {
        $String = " -file $runningPath\$BotName.ps1 -botkey $botkey -verbose -noprofile -noexit"
        $newProcess.Arguments  =  $String ;
   }
   else {
        $String = " -file $runningPath\$BotName.ps1 -verbose -noprofile -noexit"
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
