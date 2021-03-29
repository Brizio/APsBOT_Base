Function SendMessage {
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$Message ,
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)][String]$ToChatID,
    [Parameter(Mandatory=$false, Position=2)][String]$parse_mode,
    [Parameter(Mandatory=$false, Position=3)][Boolean]$disable_notification,
    [Parameter(Mandatory=$false, Position=4)][Int]$reply_to_message_id, 
    [Parameter(Mandatory=$false, Position=5)][pscustomObject]$reply_markup   ### ToCheck 
    )
    Write-log -Path $LogFile -Level Info -LogMessage ("SendMessage: " + $Message + " To: " + $ToChatID )
    $TmpJson = Invoke-WebRequest -Uri $sendMessageLink -Body @{chat_id=$ToChatID ; text=$Message ; parse_mode=$parse_mode ; disable_notification=$disable_notification ;reply_to_message_id=$reply_to_message_id ;reply_markup=$reply_markup} | ConvertFrom-Json
    # Return $json  
}
Function forwardMessage {
## TOCheck
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id ,
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)][String]$from_chat_id,
    [Parameter(Mandatory=$false, Position=2)][Boolean]$disable_notification,
    [Parameter(Mandatory=$true, Position=3)][int]$message_id
    )
    Write-log -Path $LogFile -Level Info -LogMessage ("forwardMessage: " + $from_chat_id + " To: " + $chat_id )
    $TmpJson = Invoke-WebRequest -Uri $forwardMessageLink -Body @{chat_id=$chat_id;from_chat_id=$from_chat_id;disable_notification=$disable_notification ;message_id=$message_id} | ConvertFrom-Json
    # Return $json  
}
Function sendPhoto {
## TOCheck
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id ,
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)][String]$photo,
    [Parameter(Mandatory=$false, Position=2, ValueFromPipeline=$true)][String]$caption,
    [Parameter(Mandatory=$false, Position=3)][Boolean]$disable_notification,
    [Parameter(Mandatory=$false, Position=4)][int]$reply_to_message_id
    )
    Write-log -Path $LogFile -Level Info -LogMessage ("sendPhoto: " + $SendMessage + " To: " + $ToChatID )
    $TmpJson = Invoke-WebRequest -Uri $forwardMessageLink -Body @{chat_id=$chat_id;from_chat_id=$from_chat_id;disable_notification=$disable_notification ;message_id=$message_id} | ConvertFrom-Json
    # Return $json  
}
Function sendAudio {
## TODO
}
Function sendDocument {
## TODO
}
Function GetFile {
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$file_id ,
    [Parameter(Mandatory=$False, Position=1, ValueFromPipeline=$true)][String]$file_name,
	[Parameter(Mandatory=$False, Position=2, ValueFromPipeline=$true)][String]$Destination
    )
    Write-log -Path $LogFile -Level Info -LogMessage ("GetFile id: " + $file_id)
    $TmpJson = Invoke-WebRequest -Uri $getFileLink -Body @{file_id=$file_id} | ConvertFrom-Json
    Write-Verbose ( $TmpJson | ConvertTo-Json)
	if (-not $Destination) {$Destination = $TmpStoragePath }									   
    $TmpFilePath =  $TmpJson.result.file_path
    if ($file_name) {
        Invoke-WebRequest -Uri ($getFilePathLink + "/" + $TmpFilePath) -OutFile ($Destination + "\" + $file_name)
    }
    else {
        Invoke-WebRequest -Uri ($getFilePathLink + "/" + $TmpFilePath) -OutFile ($Destination + "\" + $file_id)
    }
}
Function getChat {
## TOCheck
    Param( [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id )
    $TmpJson = Invoke-WebRequest -Uri $getChatLink -Body @{chat_id=$chat_id} | ConvertFrom-Json
    Return $TmpJson.result
}
Function sendChatAction {
## TODO
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id ,
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$action 
    )
    $TmpJson = Invoke-WebRequest -Uri $sendChatActionLink -Body @{chat_id=$chat_id;action=$action} | ConvertFrom-Json
    Return $TmpJson
}
Function getChatMembersCount {
## TOCheck
    Param( [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id )
    $TmpJson = Invoke-WebRequest -Uri $getChatMembersCountLink -Body @{chat_id=$chat_id} | ConvertFrom-Json
    [Int]$MembriChat = $TmpJson.result
    Return $MembriChat
}
Function getChatMember {
## TODO
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id ,
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)][String]$user_id 
    )
    $TmpJson = Invoke-WebRequest -Uri $getChatMembersLink -Body @{chat_id=$chat_id;user_id=$user_id} | ConvertFrom-Json
    Return $TmpJson.result
}
Function getChatAdministrators {
## TODO
    Param( [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id )
    $TmpJson = Invoke-WebRequest -Uri $getChatAdministratorsLink -Body @{chat_id=$chat_id;user_id=$user_id} | ConvertFrom-Json
    Return $TmpJson.result
}
Function restrictChatMember {
## TODO
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id ,
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)][int]$user_id ,
    [Parameter(Mandatory=$false, Position=2)][int]$until_date ,
    [Parameter(Mandatory=$false, Position=3)][Boolean]$can_send_messages ,
    [Parameter(Mandatory=$false, Position=3)][Boolean]$can_send_media_messages ,
    [Parameter(Mandatory=$false, Position=3)][Boolean]$can_send_other_messages ,
    [Parameter(Mandatory=$false, Position=3)][Boolean]$can_add_web_page_previews 
    )
    $TmpJson = Invoke-WebRequest -Uri $getChatMembersLink -Body @{chat_id=$chat_id;} | ConvertFrom-Json
    [Int]$MembriChat = $TmpJson.result
    Return $MembriChat
}
Function kickChatMember {
## TODO
    Param( 
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id ,
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)][String]$user_id ,
    [Parameter(Mandatory=$False, Position=1, ValueFromPipeline=$true)][String]$until_date 
    )

      
}
Function leaveChat {
## TOCheck
    Param( [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][String]$chat_id )
    $TmpJson = Invoke-WebRequest -Uri $leaveChatLink -Body @{chat_id=$chat_id} | ConvertFrom-Json
}