function Get-MerakiSwitchPort {
    Param(
        [Parameter(Mandatory=$true,HelpMessage='Please enter your Meraki API Key',ValueFromPipelineByPropertyName=$true)]
        $ApiKey,

        [Parameter(Mandatory=$true,HelpMessage='Please enter the switch name (EG SW01)',ValueFromPipelineByPropertyName=$true)]
        $SwitchName
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
            $switch = Get-MerakiSwitches | Where-Object { $_.Name -eq $SwitchName }
            $Uri = '{0}/devices/{1}/switchPorts' -f $BaseUri,$switch.serial
            $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
            $Response
        }
        catch {
            $_.Exception.Message
        }
    }

    End {}
}
