
# Test-InternetConnection -verbose
function Test-InternetConnection {
#Test connection to internet
Param( 
    [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)][String]$InternetSite = "http://www.google.it/"
    )
    process{
        $InternetCheck = Invoke-WebRequest -Uri $InternetSite
        
        if ($InternetCheck.StatusCode -ne 200) {
            Write-Verbose ("Error: Internet code is : " + $InternetOK.StatusCode )
            Return "KO"
            }
        Else {
            Write-Verbose ("Internet is : " +  $InternetCheck.StatusDescription )
            Write-Verbose ("Internet code is : " + $InternetCheck.StatusCode )
            Return "OK"
        }
    }
}
 
 function Write-Err {
    Param  (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ErrorsFile
        )
    if ($Error ) {
        $CurTime = Get-Date -f "dd/MM/yyyy hh:mm:ss"
        "// Current time: $CurTime //" | Out-File $ErrorsFile -Append
        foreach ($Er in $Error) {
            "// Error Exception " | Out-File $ErrorsFile -Append
            $Er.Exception | Out-File $ErrorsFile -Append
            $Er.InvocationInfo.PositionMessage | Out-File $ErrorsFile -Append
            "// Complete line " | Out-File $ErrorsFile -Append
            $Er.InvocationInfo.line | Out-File $ErrorsFile -Append
            "###################" | Out-File $ErrorsFile -Append
            " " | Out-File $ErrorsFile -Append
           # $er | Out-File $ErrorsFile -Append
        }
    }
    $Error.Clear()
}

Function Copy-NewVer {
    Param( 
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][PsObject]$File ,
    [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $True)][System.String]$NewPath 
    )
    $newBasename =""
    $Item = Get-Item $File
    If (! $NewPath) { $NewPath = $Item.DirectoryName }
    $NewPathDir = Get-Item $NewPath 
    if ($Item.PSIsContainer -or (! $Item.Exists) -or (! $NewPathDir.PSIsContainer)) {
        Write-Verbose ($File + " is not a File or " + $NewPath + " is not a valid Directory ")
        return $false
        exit
        }

    if ($Item.FullName.split('`.',@("RemoveEmptyEntries"))[-2] -match "v(\d+)") {
        $newBasename = $Item.BaseName.substring(0,$Item.BaseName.Length - $matches[0].Length -1) 
        [int]$Ver = $matches[0].substring(1)
    } 
    else  { $newBasename = $Item.BaseName ; $Ver = 0 } 

        do 
            {
            $Ver++
            $VerStr = ".v"+$Ver
            } while (Test-Path ( $NewPathDir.FullName + "\" + $newBasename+ $VerStr+ $Item.Extension))  #Verifico Esistenza in destinazione
                
        $NewName = $NewPathDir.FullName + "\" + $newBasename+ $VerStr+ $Item.Extension
        Write-Verbose "NewName : $NewName"  # | add-content $LogFile #Log del nome file 
        Write-Verbose "NewPath : $NewPath"  # | add-content $LogFile #Log del nuovo percorso
        Copy-Item $Item $NewName
        return $True
 }

 Function Backup-DBFiles {
    Write-Verbose "Archiving Json Files in Bck.zip"
    Compress-Archive $ChatDBFile,$UserDBFile -DestinationPath "$BckPath\Bck.zip" -Force
    Copy-NewVer "$BckPath\Bck.zip" 
}
Function Load-MessageDB {
    ## Load DayMessageDB
    if (-not (Test-Path $MessageDBFile)) {New-Item $MessageDBFile -ItemType File | Out-Null}
    else { $DayMessageDB =  Get-Content $MessageDBFile -raw | ConvertFrom-Json  } 
}
Function Load-UserDB {
    ## Load UserDB
    if (-not (Test-Path $UserDBFile)) {Copy-Item "$ResFilesPath\User.json.Master" "$UserDBFile" | Out-Null}
    else { $UserDB =  Get-Content $UserDBFile -raw | ConvertFrom-Json  }
}
Function Load-ChatDB {
    ## Load ChatDB
    if (-not (Test-Path $ChatDBFile)) {Copy-Item "$ResFilesPath\Chat.json.Master" "$ChatDBFile" | Out-Null}
    else { $ChatDB =  Get-Content $ChatDBFile -raw | ConvertFrom-Json  }
}
Function Init-LogFile {
    if (-not (Test-Path -Path $LogFile)) {
        '##################' | Add-Content -Path $LogFile
        "### INIZIO Script $dtInizio" | Add-Content -Path $LogFile
        "### INIZIO TranScript $dtInizio" | Add-Content -Path $TranscriptFile
    }
}
# Write-Errors -ErrorsFile $ErrorsFile
<#
try{
    # your code goes here
}
catch{
    $exception = $_.Exception.Message
    Out-File -FilePath 'c:\myscript.log' -Append -InputObject $exception
}

Try {
	Set-Mailbox -Identity MyUserName -PrimarySmtpAddress User4.test4@foo.com -ea STOP
}
Catch {
	$_ | Out-File C:\errors.txt -Append
}

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\output.txt -append
# do some stuff
Stop-Transcript

#>





