#######################################
#        Functions SendMail           #
#######################################
#
# Version 1.0
#
################## Included Functions LIST ##################
################## START ##################
#  Send-Alert
#  Send-Mail
#  Send-SimpleMail 
#  Load-pwd
#
################## END ##################

Function Load-pwd 
{ }

Function Send-Alert {
    <#
 .Synopsis
 .Description
 .Parameter Subject  = "MyAlert"
 .Parameter Body     = "Test1."
 .Example
 .Example
 .Link
 #>
    param( 
        [String] $Subject = "Alert",
        [String] $Body = "MyAlert."
    )
    Begin {
        #Check Connection!!
        #Check Param format ?
    }
    process {
    
        # Load-pwd

        $User = "briziom83@gmail.com"
        $Pass = ConvertTo-SecureString -String "**********" -AsPlainText -Force
        $Cred = New-Object System.Management.Automation.PSCredential $user, $pass
        #$Cred = Get-Credential -UserName $User -Message "Inserire le credenziali di Gmail"

        $mailParam = @{
            Subject                    = $Subject
            Body                       = $Body
            To                         = "MazzucchelliFabrizio@gmail.com"
            From                       = "briziom83@gmail.com"
            Priority                   = "Hight"
            DeliveryNotificationOption = "OnFailure"
            SmtpServer                 = "smtp.gmail.com"
            Port                       = 587
            Credential                 = $Cred
        }
        Send-MailMessage @mailParam -UseSsl # -Verbose

    }
}

Function Send-Mail {
    <#
 .Synopsis
 .Description
 .Parameter From
 .Parameter To
 .Parameter Cc
 .Parameter Bcc
 .Parameter Subject
 .Parameter Body
 .Parameter BodyAsHtml
 .Parameter Attachments
 .Example
 .Example
 .Link
 #>
    param( 
        [String] $From = "briziom83@gmail.com",
        [String] $To = "briziom83@gmail.com",
        [String] $Cc = "",
        [String] $Bcc = "",
        [String] $Subject = "TestMail",
        [String] $Body = "TestMail from Function Send-Mail." ,
        [Switch] $BodyAsHtml = $true ,
        [String] $Attachments   
    )
    Begin {
        #Check Connection!!
        #Check ?
    }
    process {
        # Load-pwd

        $User = "briziom83@gmail.com"
        $Pass = ConvertTo-SecureString -String "**********" -AsPlainText -Force
        # $Cred = New-Object System.Management.Automation.PSCredential $user, $pass
        $Cred = Get-Credential -UserName $User -Message "Inserire le credenziali di Gmail"

        $mailParam = @{
            To         = $To
            From       = $From
            Subject    = $Subject
            Body       = $Body
            SmtpServer = "smtp.gmail.com"
            Port       = 587
            Credential = $Cred
        }
        Send-MailMessage @mailParam -UseSsl # -Verbose
    }
}

Function Send-SimpleMail {
    <#
 .Synopsis
 .Description
 .Parameter From
 .Parameter To
 .Parameter Subject
 .Parameter Body
 .Example
 .Example
 .Link
 #>
    param( 
        [String] $To = "briziom83@gmail.com",
        [String] $From = "briziom83@gmail.com",
        [String] $Subject = "TestMail",
        [String] $Body = "TestMail from Function Send-Mail."
    )
    Begin {
        #Check Connection!!
        #Check ?
    }
    process {
        # Load-pwd

        $User = "briziom83@gmail.com"
        $Pass = ConvertTo-SecureString -String "**********" -AsPlainText -Force
        # $Cred = New-Object System.Management.Automation.PSCredential $user, $pass
        $Cred = Get-Credential -UserName $User -Message "Inserire le credenziali di Gmail"

        $mailParam = @{
            To         = $To
            From       = $From
            Subject    = $Subject
            Body       = $Body
            SmtpServer = "smtp.gmail.com"
            Port       = 587
            Credential = $Cred
        }
        Send-MailMessage @mailParam -UseSsl # -Verbose
    }
}




## Test
# Load-pwd "briziom83@gmail.com"
# Send-Alert -Subject "" -Body ""
# Send-Alert  -Body "https://www.google.it/salcazzo"


# Send-Mail ......

# Send-SimpleMail .....



