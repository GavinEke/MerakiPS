function Get-MerakiAppliance {
    Param(
        [Parameter(Mandatory=$true,HelpMessage='Please enter your Meraki API Key',ValueFromPipelineByPropertyName=$true)]
        $ApiKey,

        [Parameter(Mandatory=$true,HelpMessage='Please enter the Network ID (EG: N_123456789123456789 or L_123456789123456789)',ValueFromPipelineByPropertyName=$true)]
        [Alias('NetworkId')]
        $id
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
            $Uri = '{0}/networks/{1}/devices' -f $BaseUri,$id
            $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
            $Response
        }
        catch {
            $_.Exception.Message
        }
    }

    End {}
}
