
$command = ".\$Script:PSScriptRoot\Bot.ps1 -botname 'APsBOT_Base' -botkey '1705298974:AAGJQb4M1tqExKQPgs_L_78kHrLoZkGF9GY' -FilesPath 'C:\Tmp\' -verbose"
Invoke-Expression "cmd /c start powershell -Command { $command } -noexit" 
