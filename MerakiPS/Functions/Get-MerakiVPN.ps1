function Get-MerakiVPN {
    Param(
        [Parameter(Mandatory=$true,HelpMessage='Please enter your Meraki API Key',ValueFromPipelineByPropertyName=$true)]
        $ApiKey,

        [Parameter(Mandatory=$true,HelpMessage='Please enter the Organization ID (EG: 123456)',ValueFromPipelineByPropertyName=$true)]
        [Alias('OrgId','id')]
        $organizationId
    )

    Begin {
        if ([Net.ServicePointManager]::SecurityProtocol -ne [Net.SecurityProtocolType]::Tls12) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }

        $BaseUri = 'https://api.meraki.com/api/v0'
        $Headers = @{
            'X-Cisco-Meraki-API-Key' = $ApiKey;
            'Content-Type' = 'application/json'
        }
    }

    Process {
        try {
            $Uri = '{0}/organizations/{1}/thirdPartyVPNPeers' -f $BaseUri,$organizationId
            $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
            $Response
        }
        catch {
            $_.Exception.Message
        }
    }

    End {}
}
