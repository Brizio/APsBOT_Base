function Get-Excuse {

    (Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses -OutVariable OnlineEexcuses).content.split([Environment]::NewLine) -split '\r?\n' | Get-Random
 
    #$count = (Invoke-WebRequest http://pages.cs.wisc.edu/~ballard/bofh/excuses -OutVariable OnlineEexcuses).content.split([Environment]::NewLine) | Measure-Object –Line
    #$Excuses = $OnlineEexcuses.content.split([Environment]::NewLine) 
    # $Ran = Get-Random $count.Lines 
    # Get-Random -InputObject ( $OnlineEexcuses.content.split([Environment]::NewLine) )
    #Get-Random -InputObject ($OnlineEexcuses -split '\r?\n')
}

 
Get-Excuse