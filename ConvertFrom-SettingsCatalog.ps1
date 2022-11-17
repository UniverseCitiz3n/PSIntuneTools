function ConvertFrom-SettingsCatalog {
[cmdletbinding()]
param(
	# Auth to MS Graph
	[Parameter(Mandatory)]
	[hashtable]
	$AuthToken,
	# Settings Catalog profile name
	[Parameter(Mandatory)]
	[string[]]
	$ProfileName,
	# Settings Catalog profile id
	[Parameter()]
	[string[]]
	$ProfileId
)

#Get SC profile
$GraphUrl = 'https://graph.microsoft.com'
$graphApiVersion = 'beta'
$Resource = 'deviceManagement/configurationPolicies';
$Filter   = '`$select=id,name,description,platforms,technologies,lastModifiedDateTime,settingCount,roleScopeTagIds,isAssigned&`$filter=(platforms%20eq%20%27windows10%27%20or%20platforms%20eq%20%27macOS%27%20or%20platforms%20eq%20%27iOS%27)'
$ListOfProfiles = @()
$RequestSplat = @{
	Header = $AuthToken
	Uri    = "$GraphUrl/$graphApiVersion/$Resource`?$Filter"
}
try{
$Profiles = Invoke-RestMethod @RequestSplat
if ($($Profiles | Get-Member).Name -contains '@odata.nextLink') {
		$ListOfProfiles += $Profiles
		while ($Profiles.'@odata.nextLink') {
			$NextBatchRequest = $Profiles.'@odata.nextLink'
			$Profiles = Invoke-RestMethod -Uri $NextBatchRequest -Headers $AuthToken -Method Get
			$ListOfProfiles += $Profiles
		}
		$ListOfProfiles
	}
} catch {
        $ex = $_.Exception
        $errorResponse = $ex.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd();
        Throw "
        ScriptLineNumber $($_.InvocationInfo.ScriptLineNumber)
        OffsetInLine $($_.InvocationInfo.OffsetInLine)
        Response content: $responseBody
        Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }

if (-not($null -eq $ProfileName)) {
	$Profiles = foreach ($Profile in $ProfileName) {
		$ListOfProfiles.value | Where-Object { $PSitem.name -like $Profile -or $PSitem.displayname -like $Profile }
	}
}
if (-not($null -eq $ProfileId)) {
	$Profiles = foreach ($Profile in $ProfileId) {
		$ListOfProfiles.value | Where-Object { $PSitem.id -like $Profile }
	}
}
Write-Host "Found $($($Profiles | Measure-Object).count) profiles"

}