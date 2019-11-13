# Set PSScriptRoot
If (-not ($PSScriptRoot)) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

# Dot source the modules functions
$FunctionFiles = Get-ChildItem -Path "$PSScriptRoot\Functions\*.ps1"
$FunctionFiles | ForEach-Object {. $_.FullName}
Export-ModuleMember -Function $FunctionFiles.BaseName
