function Get-MerakiOrganization {
    Param(
        [Parameter(Mandatory=$true,HelpMessage='Please enter your Meraki API Key',ValueFromPipelineByPropertyName=$true)]
        $ApiKey
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
            $Uri = '{0}/organizations' -f $BaseUri
            $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
            $Response
        }
        catch {
            $_.Exception.Message
        }
    }

    End {}
}
