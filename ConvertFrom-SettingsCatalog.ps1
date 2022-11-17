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
	[stringp[]]
	$ProfileId
)

#
}