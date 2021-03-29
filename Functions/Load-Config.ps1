$ConfigFile = "config.json"

# Load and parse the JSON configuration file
try {
	$Config = Get-Content ".\$ConfigFile" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
} catch {
	Write-Error -Message "The Base configuration file is missing!" -Stop
}

# Check the configuration
if (!($Config)) {
	Write-Error -Message "The Base configuration file is missing!" -Stop
}