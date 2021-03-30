


function Get-WikiQuote {
    [OutputType([String])]
    Param
    (
        # Topic of the Quote
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)] [ValidateNotNullOrEmpty()][String[]]$Topic,
        [Parameter(Position = 1)][Int]$Count = 1 ,
        [Parameter(Position = 2)][Int]$Length = 150
    )
    Begin {
    }
    Process {
        Foreach ($Item in $Topic) {
            $URL = "https://en.wikiquote.org/wiki/$Item"
            Try {
                $WebRequest = Invoke-WebRequest $URL
                $WebRequest.ParsedHtml.getElementsByTagName('ul')  |`
                    Where-Object { $_.parentElement.id -eq "mw-content-text" -and $_.innertext.length -lt $Length } |`
                    Get-Random -Count $Count | ForEach-Object { 
                    [Environment]::NewLine            
                    $_.innertext
                }
            }
            catch {
                $_.exception
            }
        }
    }
    End {
    }
}
function UploadFoto($Photo) {
    #$reqAction = New-Object NetTelegramBotApi.Requests.SendChatAction($update.Message.Chat.Id, "upload_photo");
    #$bot.MakeRequestAsync($reqAction).Wait();
    #[System.Threading.Thread]::Sleep(500)
    $fileStream = [System.IO.File]::OpenRead($Photo)
    $req = New-Object NetTelegramBotApi.Requests.SendPhoto($update.Message.Chat.Id, $( New-Object NetTelegramBotApi.Requests.FileToSend($fileStream, "Under-construction.png")))
    $bot.MakeRequestAsync($req).Wait();
    #$req.Caption = "Telegram_logo.png"
    $fileStream.close()
}
function CatFact {
    (ConvertFrom-Json(Invoke-WebRequest -Uri 'https://catfact.ninja/fact?max_length=140').Content).fact
    #$reqAction = New-Object NetTelegramBotApi.Requests.SendMessage($update.Message.Chat.Id, $CatFact);
    #$bot.MakeRequestAsync($reqAction).Wait();
}
function CatFact1() {
    (ConvertFrom-Json (Invoke-WebRequest -Uri 'http://catfacts-api.appspot.com/api/facts')).facts
    #$reqAction = New-Object NetTelegramBotApi.Requests.SendMessage($update.Message.Chat.Id, $CatFact);
    #$bot.MakeRequestAsync($reqAction).Wait();
}
function wip() {
    $reqAction = New-Object NetTelegramBotApi.Requests.SendMessage($update.Message.Chat.Id, "Under Construction");
    $bot.MakeRequestAsync($reqAction).Wait();
    UploadFoto($WipPhoto)
}
Function CmdHelp {
    Write-log -Path $LogFile -Level Info -LogMessage "The command is /help"
    #[array]$arr = @(,@())
    $k = [object]@{keyboard = @(@("/help"), @("/CatFact"), @("/Yes"), @("/No"), @("/Whine"), @("/Photo"), @("/Restart") ); resize_keyboard = $false  ; one_time_keyboard = $false ; selective = $false }            
    $k.resize_keyboard = $true
    $k.one_time_keyboard = $true
    SendMessage -Message "Here is all my commands" -ToChatID $json.result[$i].message.chat.id -reply_markup ($k | ConvertTo-Json)
}
Function CmdRestart { 
    if ($json.result[$i].message.from.username -in ($AdminUserNames)) {
        # SaveToDB
        Write-log -Path $LogFile -Level Info -LogMessage "The command is /Restart"
        $Now = (get-date -format "yyyy-MM-dd hh:mm:ss").tostring()
        SendMessage -Message "$Now - Restarting the bot" -ToChatID $json.result[$i].message.chat.id -reply_to_message_id $json.result[$i].message.message_id
            
        $command = ".\$Script:PSScriptRoot\Bot.ps1 -botname $BotName -botkey $BotKet -FilePath $FilePath -verbose"
        Invoke-Expression "cmd /c start powershell -Command { $command } -noexit" 
            
        #$argList = "-file `"$ScriptName`" -noprofile -noexit"
        #Start-Process powershell -argumentlist $argList
        #Start-Process powershell.exe "-noexit -File",('"{0}"' -f $MyInvocation.MyCommand.Path ) 
        #& "d:\long path name\script name.ps1" "Long Argument 1" "Long Argument 2"
          
        <# & powershell.exe " -file $ScriptName -BotName $BotName -verbose "
            
            $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
            $String = " -file $runningPath\Start-Bot.ps1 -BotName $BotName -verbose "
            $newProcess.Arguments  =  $String
            $proc = [System.Diagnostics.Process]::Start($newProcess)
            Start-Sleep -Seconds 5
            #powershell -command "$runningPath\$ScriptName" 
            #break
            #>
        exit
    }
    SendMessage -Message "Sorry, you are not my Admin." -ToChatID $json.result[$i].message.chat.id -reply_to_message_id $json.result[$i].message.message_id
    
}