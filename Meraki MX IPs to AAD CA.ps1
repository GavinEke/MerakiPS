#Requires -Version 5
#Requires -Modules @{ ModuleName="AzureRM.profile"; RequiredVersion="5.8.3" },@{ ModuleName="MerakiPS"; ModuleVersion="1.0.0" }
#Requires -PSEdition Desktop

<#
    Note - This will require AzureRM.profile and MerakiPS modules installed. If you do not have these installed please run the following commands:
        Install-Module -Name AzureRM.profile -RequiredVersion 5.8.3 -AllowClobber
        Install-Module -Name MerakiPS

    Additional Note - This script uses undocumented and unsupported Azure API which Microsoft could cut off access to this API at any time.
#>

# Replace the variables below with your own information
#region Variables
$MerakiApiKey      = '0123456789abcdef0123456789abcdef01234567'
$AADCA_NetworkId   = 'f8b2315b-d2f0-4581-8e1a-bd6bfc789d36'
$AADCA_NetworkName = 'Meraki Site IPs'
#endregion

try {
    Import-Module -Name AzureRM.profile -RequiredVersion 5.8.3 -Force -ErrorAction Stop
    Import-Module -Name MerakiPS -ErrorAction Stop
}
catch {
    Write-Error -Message "Failed to load one of the following modules AzureRM.profile, MerakiPS"
}

# Get Meraki MX IPs
$networks   = Get-MerakiNetwork -organizationId 123456 -ApiKey $MerakiApiKey
$appliances = $networks | Where-Object {$_.type -eq 'combined'} | Get-MerakiAppliance -ApiKey $MerakiApiKey
$routers    = $appliances | Where-Object {($_.wan1Ip -ne $null) -or ($_.wan2Ip -ne $null)}

$iplist = New-Object System.Collections.ArrayList
ForEach ($Item in $routers) {
    if (-not ([string]::IsNullOrEmpty($Item.wan1Ip))) {
        $iplist.Add($Item.wan1Ip)
    }
    if (-not ([string]::IsNullOrEmpty($Item.wan2Ip))) {
        $iplist.Add($Item.wan2Ip)
    }
}
$finallist = ($iplist | Where-Object {$_ -notlike "10.*" -and $_ -notlike "192.168.*"} | Select-Object -Unique)



# Upload IPs to AAD CA
Login-AzureRmAccount
$context      = Get-AzureRmContext
$tenantId     = $context.Tenant.Id
$refreshToken = $context.TokenCache.ReadItems().RefreshToken
$body         = 'grant_type=refresh_token&refresh_token={0}&resource=74658136-14ec-4630-ad9b-26e160ff0fc6' -f $refreshToken
$apiToken     = Invoke-RestMethod "https://login.windows.net/$tenantId/oauth2/token" -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded'

$header = @{
    'Authorization'          = 'Bearer {0}' -f $apiToken.access_token
    'Content-Type'           = 'application/json'
    'X-Requested-With'       = 'XMLHttpRequest'
    'x-ms-client-request-id' = (New-Guid).Guid
    'x-ms-correlation-id'    = (New-Guid).Guid
}

$json = @"
{
    "networkId": "$AADCA_NetworkId",
    "networkName": "$AADCA_NetworkName",
    "cidrIpRanges": ["$($finallist -join '/32", "')"],
    "categories": [],
    "applyToUnknownCountry": false,
    "countryIsoCodes": [],
    "isTrustedLocation": true,
    "namedLocationsType": 1
}
"@

try {
    $IRMParams = @{
        Uri     = "https://main.iam.ad.ext.azure.com/api/NamedNetworksV2/$AADCA_NetworkId"
        Method  = "PUT"
        Headers = $header
        Body    = $json
    }
    $Response = Invoke-RestMethod @IRMParams
    $Response
}
catch {
    $_.Exception.Message
}
