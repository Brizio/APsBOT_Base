
Param( 
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][String]$BotName ,
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)][String]$botkey ,
    [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true)][String]$FilesPath = "C:\Tmp\",
    [Parameter(Mandatory = $false, Position = 3, ValueFromPipeline = $true)][switch]$TestBot = $false
)
Process {
    ########################################################################
    # Inizialization
    $ConfigFile = "config.json"
    if (Test-Path $ConfigFile) {
        #Config File Found Loading ...
        $ConfigJson = (Get-Content ".\config.json" -Raw) | ConvertFrom-Json
        #$ConfigJson.BotSettings
        [string]$ScriptName = $ConfigJson.BotSettings.BotName
        [string]$BotName = $ConfigJson.BotSettings.BotName
        [string]$FilesPath = $ConfigJson.BotSettings.FilesPath
        [array]$AdminUserNames = $ConfigJson.BotSettings.AdminUserNames
        [switch]$FileBackupAtLaunch = $true
    } else {
        # Getting Confing From Ps Command Parameters
        [string]$ScriptName = $BotName
        [string]$BotName = $BotName
        [array]$AdminUserNames = 'FabryMazzu'
        [switch]$FileBackupAtLaunch = $true
    }
    $host.ui.RawUI.WindowTitle = $ScriptName + ' - ' + $FilesPath + ' - Started @ ' + (Get-Date -format 'yyyy-MM-dd hh:mm:ss').tostring()
    $runningPath = Split-Path -Path $SCRIPT:MyInvocation.MyCommand.Path -Parent
    # $runningPath = "$ENV:OneDrive\_MyPs\PS-Repo\MyProjects\Bots\AloneBot"
    #$dtInizio = (Get-Date -format 'yyyy-MM-dd hh:mm:ss').tostring()
    $dtlog = (Get-Date -format 'yyyyMMdd').tostring()
    $Error.Clear()
    Start-Sleep -Seconds 1
    <##########################>
    # Set local Resources 
    $FilesPath = $FilesPath + "$BotName"
    $LogPath = "$runningPath\logs\"
    $ExtFunctionsPath = "$runningPath\Functions\"
    $ResFilesPath = "$runningPath\ResourceFiles\"
    $LogFile = "$LogPath\log-$dtlog.log"
    $ErrorsFile = "$LogPath\Errors-$dtlog.log"
    if (-not (Test-Path $FilesPath)) { mkdir $FilesPath | Out-Null }
    $ArchivePath = "$FilesPath\Archive\"
    $TmpStoragePath = "$FilesPath\TmpStorage\"
    $BckPath = "$FilesPath\Bck\"
    #Files
    $UserDBFile = "$FilesPath\Users.json"
    $ChatDBFile = "$FilesPath\Chats.json"
    $MessageDBFile = "$FilesPath\jsons-$dtlog.json"
    $TranscriptFile = "$FilesPath\Transcript-$dtlog.txt"
    $imageFile = "$ResFilesPath\t_logo.png"
    $WipPhoto = "$ResFilesPath\Under-construction.png"

    <##########################>
    #Create Folders
    if (-not (Test-Path -Path $LogPath) ) { New-Item -Path $LogPath -ItemType container  | Out-Null }
    if (-not (Test-Path -Path $ExtFunctionsPath) ) { New-Item -Path $ExtFunctionsPath -ItemType container  | Out-Null }
    if (-not (Test-Path -Path $ResFilesPath) ) { New-Item -Path $ResFilesPath -ItemType container  | Out-Null }
    if (-not (Test-Path -Path $ArchivePath) ) { New-Item -Path $ArchivePath -ItemType container  | Out-Null }
    if (-not (Test-Path -Path $TmpStoragePath) ) { New-Item -Path $TmpStoragePath -ItemType container  | Out-Null }
    if (-not (Test-Path -Path $BckPath) ) { New-Item -Path $BckPath -ItemType container  | Out-Null }
    <##########################>
    # Bot Param
        $Timeout = $ConfigJson.RunningSettings.Timeout
        $Offset = $ConfigJson.RunningSettings.Offset
        $SecondsToSleep = $ConfigJson.RunningSettings.SecondsToSleep
        $Backlog = $ConfigJson.RunningSettings.Backlog
    #Set Verbose Output
        if ($verbose) { $VerbosePreference = 'continue' }
    # Init Variables
        $Firststart = $true
        [string]$uploadedPhotoId = $null
        [string]$uploadedDocumentId = $null
    <##########################>
    # Load Bot Api
    . $ExtFunctionsPath\Load-BotLinks.ps1
    <##########################
    # Load External functions
    ##########################>
    . $ExtFunctionsPath\Utils.ps1
    . $ExtFunctionsPath\Test-URI.ps1
    . $ExtFunctionsPath\Write-log.ps1
    #LogInit
    Init-LogFile
    ####################################################
    # Command Functions
    . $ExtFunctionsPath\Load-BotFunctions.ps1
    . $ExtFunctionsPath\Load-CommandFunctions.ps1
    ####################################################
    ####################################################
    # Bot initialization
    ## Load DayMessageDB
    Load-MessageDB
    ## Load UserDB
    Load-UserDB
    ## Load ChatDB
    Load-ChatDB
    # Backup DBFiles
    if ($FileBackupAtLaunch) { Backup-DBFiles } 
    # Test Connection
    do {
        $Res = Test-InternetConnection
        if ($Res -eq 'KO') { 
            Write-log -Path $LogFile -Level Error -LogMessage 'Internet connection Down...'
            Write-Verbose -Message 'Internet connection Down...' 
            Start-Sleep -Seconds $timeout
        } 
    } while ($Res -eq 'KO')

    # Test Bot Init
    $json = Invoke-WebRequest -Uri $getMeLink -Body @{offset = 0; timeout = $timeout } | ConvertFrom-Json
    if ($json.ok -ne 'True') {
        #Grave errore ed esco
        Write-log -Path $LogFile -Level Error -LogMessage 'GetMe() FAILED. Do you forget to add your AccessToken ?'
        Write-Verbose -Message 'GetMe() FAILED. Do you forget to add your AccessToken ?'
        Write-Verbose -Message '(Press ENTER to quit)'
        return
    }
    Else {
        # Log connection succeeded
        Write-log -Path $LogFile -Level Info -LogMessage ( $json.result.first_name + ' ' + $json.result.username + '  connected!')
        Write-log -Path $LogFile -Level Info -LogMessage ('Find ' + $json.result.username + ' in Telegram and send him a message - it will be displayed here')
        Write-Verbose -Message '(Press ctrl + c to stop listening and quit)'
    }
    # Everythings it's working fine, start running
    $BotID = $json.result.id
    $BotName = $json.result.first_name
    $BotUsername = $json.result.username
    Write-log -Path $LogFile -Level Info -LogMessage ( "BotID = $BotID , BotName = $BotName , BotUsername = $BotUsername ")
    if ($TestBot) {
        Write-log -Path $LogFile -Level Info -LogMessage ('Bot Init successiful, Exit for test param')
        Exit 
    }
    # Set last Offset to avoid backlog
    if (-not $Backlog) { 
        # getting the update from the end of the queque. All previous updates will forgotten
        $offset = -1
        $json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset = $offset; timeout = $timeout } | ConvertFrom-Json
        $offset = $json.result[-1].update_id + 1
    }
    <####################################################>
    <#  BOT STARTs                                      #>
    <####################################################>
    while ($true) {
        # Test Connection
        do {
            $Res = Test-InternetConnection
            if ($Res -eq 'KO') { Start-Sleep -Seconds $timeout } 
        } while ($Res -eq 'KO')
        $StartTime = Get-Date -Format 'dd/MM/yyyy hh:mm:ss'
        Write-Verbose -Message "// Start time : $StartTime //"
        # Runtime functions update  
        . $ExtFunctionsPath\Load-BotFunctions.ps1
        . $ExtFunctionsPath\Load-CommandFunctions.ps1
        Write-Verbose -Message '// Re-Load BotFunctions //'
        ## If this is a new day I have to initialize the log files and some variables
        $ThisDay = (Get-Date -format 'yyyyMMdd').tostring()
        if ( $dtlog -ne $ThisDay ) { 
            $dtlog = $ThisDay
            $MessageDBFile = "$LogPath\messages-$dtlog.json"
            $LogFile = "$LogPath\log-$dtlog.log"
            $ErrorsFile = "$LogPath\Errors-$dtlog.log"
            $TranscriptFile = "$LogPath\Transcript-$dtlog.txt"
            Init-LogFile
        }

        Do {
            $json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset = $offset; timeout = $timeout } | ConvertFrom-Json
            if (-not $json) { Write-Verbose -Message '(Press ctrl + c to stop listening and quit)'; Start-Sleep -Seconds $SecondsToSleep }
        } Until ($json)

        $l = $json.result.length
        $i = 0
        Write-Verbose -Message "// Found json of length = $l" 
        ## Write in Json File
        # Cycle append
        ## ToDo : Find the wai to add a single Json Item in the best way
        ## Message Json
        Load-MessageDB
        $DayMessageDBClone = $DayMessageDB
        if ($null -eq $DayMessageDBClone ) { 
            $FinalJson = $json.result 
        }
        Else {
            $FinalJson = $DayMessageDBClone + $json.result 
        } 
        $FinalJson | ConvertTo-Json -depth 100 | Out-File -FilePath $MessageDBFile
        Write-Verbose -Message '// Message Json file append' 

        while ($i -lt $l) {

            <##############################################################>
            ## Add User in the Json
            if (-not (Test-Path -Path $UserDBFile)) { Write-Verbose -Message "// Critical Error, Uninitialized File:  $UserDBFile " }
            # $PreviousUserJson =  Get-Content $UserDBFile -raw | ConvertFrom-Json
            $UserClone = $UserDB  # $PreviousUserJson
            # if ($PreviousUserJson -eq $null) { $FinalUserJson = $json.result[$i].message.from ; $FinalUserJson | ConvertTo-Json -depth 100 | Out-File $UserDBFile } Else { 
            if ( $json.result[$i].message.from.id -notin $UserDB.id ) { 
                $UserDB = $UserClone + $json.result[$i].message.from   
                $UserDB | ConvertTo-Json -depth 100 | Out-File -FilePath $UserDBFile -Force
                Write-Verbose -Message '// Json User file append' 
            } # }
            
            ## Add Chat in the Json
            if (-not (Test-Path -Path $ChatDBFile)) { Write-Verbose -Message "// Critical Error, Uninitialized File:  $ChatDBFile " }
            # $PreviousChatJson =  Get-Content $ChatDBFile -raw | ConvertFrom-Json
            $ChatClone = $ChatDB
            #if ($PreviousChatJson -eq $null) { $FinalChatJson = $json.result[$i].message.chat ; $FinalChatJson | ConvertTo-Json -depth 100 | Out-File $ChatDBFile } Else { 
            if ( $json.result[$i].message.chat.id -notin $ChatDB.id ) { 
                $ChatDB = $ChatClone + $json.result[$i].message.chat 
                $ChatDB | ConvertTo-Json -depth 100 | Out-File -FilePath $ChatDBFile 
                Write-Verbose -Message '// Json Chat file append' 
            } #}

            <##############################################################>
            
            Write-Verbose -Message 'Json message: ' 
            $unixTime = $json.result[$i].message.date
            Write-Verbose -Message ([TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($unixTime)))
            Write-Verbose -Message ($json.result[$i].message | ConvertTo-Json)
            
            
            ##############################################################
            ## Keyboard buttons
            if ( $json.result[$i].message.entities.type -eq 'bot_command') { Write-Verbose -Message ('// Command From Keybord Pressed: ' + $json.result[$i].message.entities.offset + ' Length: ' + $json.result[$i].message.entities.length) }
            #Verify if the message come from a private chat
            if ($json.result[$i].message.from.id -eq $json.result[$i].message.chat.id) {
                If ($json.result[$i].message.from.username) { Write-log -Path $LogFile -Level Info -LogMessage ('Private message from: ' + $json.result[$i].message.from.username ) }
                Else { Write-log -Path $LogFile -Level Info -LogMessage ('Private message from userid: ' + $json.result[$i].message.from.id ) }
            }
            # Optional json parts
            if ($null -ne $json.result[$i].message.sticker.file_id) { Write-Verbose -Message 'Message sticker.file_id: ' ; Write-Verbose -Message $json.result[$i].message.sticker.file_id } 
            if ($null -ne $json.result[$i].message.voice.file_id) { GetFile -file_id $json.result[$i].message.voice.file_id }
            if ($null -ne $json.result[$i].message.document.file_id) { GetFile -file_id $json.result[$i].message.document.file_id -file_name $json.result[$i].message.document.file_name }
            
            #Verify if the message contains Text & Commands
            if ($null -ne $json.result[$i].message.text) { 
                Write-Verbose -Message $json.result[$i].message.text 
                $MessageText = $json.result[$i].message.text
                ## Aggiungo al transcript
                $TranscriptLine = ' ' + $json.result[$i].message.date + ' CID: ' + $json.result[$i].message.chat.id + ' ChatUsername: ' + $json.result[$i].message.chat.username + ' FromUsername: ' + $json.result[$i].message.from.username + ' Message: ' + $json.result[$i].message.text 
                $TranscriptLine | Out-File -FilePath $TranscriptFile -Append -Encoding utf8 
            }
            ### Elaboro il messaggio
            Switch ($MessageText) {
                <#...#>
                'Ciao' { SendMessage -Message 'Hello World!' -ToChatID $json.result[$i].message.chat.id }
                { $_ -in 'A', 'B', 'C' } { SendMessage -Message "Complimenti hai scritto una delle prime 3 lettere dell'alfabeto!" -ToChatID $json.result[$i].message.chat.id }
                'Test1' { SendMessage -Message ('Complimenti @' + $json.result[$i].message.from.username + ' stai eseguendo il Test1') -ToChatID $json.result[$i].message.chat.id -reply_to_message_id $json.result[$i].message.message_id -parse_mode 'Markdown' }
                'CatFact' { SendMessage -Message (CatFact) -ToChatID $json.result[$i].message.chat.id }
                'Excuse' { SendMessage -Message (Get-Excuse) -ToChatID $json.result[$i].message.chat.id}
                Default {}
            }
            ### Process bot's commands 
            switch -wildcard ($MessageText) {
                '/help' {
                    CmdHelp
                    Break 
                }

                '/Restart' {
                    if (($json.result[$i].message.from.username -in $AdminUserNames) -and (-not $Firststart)) { CmdRestart }
                    else {
                        SendMessage -Message  'Sorry, you are not my Admin.' -ToChatID $json.result[$i].message.chat.id -reply_to_message_id $json.result[$i].message.message_id
                    }
                }
                "/help@$botname" {
                    CmdHelp
                    Break 
                }

                "/Restart@$botname" {
                    if (($json.result[$i].message.from.username -in $AdminUserNames) -and (-not $Firststart)) { CmdRestart }
                    else {
                        SendMessage -Message  'Sorry, you are not my Admin.' -ToChatID $json.result[$i].message.chat.id -reply_to_message_id $json.result[$i].message.message_id
                    }
                }
                '/*' {
                    Write-log -Path $LogFile -Level Info -LogMessage ('The command is not in the list --> ' + $MessageText) 
                    Write-Verbose -Message ('The command is not in the list --> ' + $MessageText) 
                }
                default {
                    # "This is not a command."
                    # Write-log -Path $LogFile -Level Info -LogMessage ("This is not a command.")
                }
            }
            $offset = $json.result[$i].update_id + 1
            Write-Verbose -Message "New offset: $offset"
            $i++
        }
        $c++
        $Firststart = $False
        Write-Verbose -Message "// Update $c complete //"
        $CurTime = Get-Date -Format 'dd/MM/yyyy hh:mm:ss'
        Write-Verbose -Message "// Current time: $CurTime //"
        # Write-Err -ErrorsFile $ErrorsFile 
    }

    # $VerbosePreference = $oldverbose
}
<#

    #Log the message text in the Transcriptline
    try { 
        [System.Console]::WriteLine("Msg from {0} {1} ({2}) in chat {5} at {4}: {3}",$message.from.FirstName,$message.from.LastName,$json.result[$i].message.from.username,$message.text,$message.Date,$message.chat.Title) ;
        $Transcriptline = $message.Date.tostring() + " ; " + $json.result[$i].message.from.username.tostring() + " ; " + $message.text.ToString() 
        $Transcriptline | Add-Content $TranscriptFile ;
    }
    catch {
        Write-Error $Error.Item(-1)
        Write-log -Path $LogFile -Level Error -LogMessage ("Errore durante la creazione di Transcriptline")
    }

                    #
                    
                    }
                }
            }
            if(!$psISE) {
                $stopME = [System.Console]::KeyAvailable
            }                         
        }
        Write-Verbose "Key pressed."
    }
    catch {
        Write-Error $Error
        "Errore generico durante il loop" | Add-Content $LogFile 
    }
    finally
    {
        SaveToDB
        Write-log -Path $LogFile -Level warning -LogMessage ("Ctrl+c pressed.")
    }

#>