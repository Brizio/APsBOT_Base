#######################################
#        Functions Logging            #
#######################################
#
# Version 1.0 ()
#
################## Included Functions LIST ##################
################## START ##################
#  Write-Log
#  Write-LogAdvanced
#  Write-LogVerbose
#  Set-MyLogFile
#  Get-MyLogFile
################## END ##################

 Function Write-Log 
{
 <#
 .Synopsis
 .Description
 .Parameter Logfile
 .Parameter Message
 .Example
 .Example
 .Link
 #>
param( 
    [String] $Logfile, 
    [String] $Message
     )
Begin{
    #Check Logfile ?
    }
process {
    if ($Logfile -eq "") { $Logfile = Get-MyLogFile }
    $dt = (get-date -format "yyyy-MM-dd hh:mm:ss").tostring()
    "$dt - $Message" | add-content $LogFile
    }
} 


Function Write-LogAdvanced
{
 <#
 .Synopsis
 .Description
 .Parameter Logfile
 .Parameter Subject
 .Parameter Message
 .Example
 .Example
 .Link
 #>
param( 
    [String] $Logfile, 
    [String] $Subject, 
    [String] $Message,
    [switch] $Verbose
     )
Begin{
    #Check Logfile ?
    }
process {
    if ($Logfile -eq "") { $Logfile = Get-MyLogFile }
    $dt = (get-date -format "yyyy-MM-dd hh:mm:ss").tostring()
    "$dt - $Subject - $Message" | add-content $LogFile
    If ($Verbose) {"$dt - Logged in $Logfile --> $dt - $Subject - $Message"}
    }
}


Function Get-MyLogFile
{
 <#
 .Synopsis
 .Description
 .Example
 .Example
 .Link
 #>
param( 
     )
Begin{
    #Check Logfile ?
    }
process {
    $Global:MyLogFile 
    } 
}

Function Set-MyLogFile
{
 <#
 .Synopsis
 .Description
 .Parameter Logfile
 .Example
 .Example
 .Link
 #>
param( 
    [Parameter(Mandatory=$True)]
    [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]    #Check if the path is relative or absolute
    [String] $Logfile,
    [Switch] $Force
     )
Begin{
    #Check Logfile ?
    }
process {
    $varName= "MyLogFile"
    If ($varName -eq $null) {
        Set-Variable -Name $varName -Value ($Logfile) -Scope Global
        # $Global:MyLogFile = $Logfile
        }
    Elseif ($Force ) {
        #Sovrascrittura della variabile
        Set-Variable -Name $varName -Value ($Logfile) -Scope Global
        # $Global:MyLogFile = $Logfile
        }
    Else {
        # Variabile trovata già valorizzata e comando non forzato
        Write-Host "ATTENZIONE - Attualmente la Variabile MyLogFile è già impostata a : $Global:MyLogFile" -ForegroundColor Red
        }
    } 
}



## Test
# Get-MyLogFile
# Explorer Get-MyLogFile

# Set-MyLogFile ".\TestLog.log"
# Set-MyLogFile "C:\MyTemp\TestLog1.log"
# Set-MyLogFile "C:\MyTemp\TestLog.log" -Force



# Write-Log -Logfile "C:\MyTemp\TestLog1.log" -Message "Test1"
# Write-Log "C:\MyTemp\TestLog1.log" "Test1"
# Write-Log "" "Test1"


# Write-LogAdvanced "" "Sub1" "Test1" -Verbose