function New-KindManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [int] $WorkerNodes = 3,
        [Parameter(Mandatory=$false, Position=0)]
        [int] $ControlPlaneNodes = 1   
    )
    process {
        
    }
}

function Get-KindConfig {
    [CmdletBinding()]
    process {
        $configPath = Join-Path -Path $HOME -ChildPath ".ninja" -AdditionalChildPath "kube"
        $configPath = Join-Path -Path $configPath -ChildPath ".\images.yaml"
        if(!(Test-Path($configPath) -eq $true)){
            Invoke-WebRequest -Uri "https://github.com/DotNet-Ninja/DotNet-Ninja.PowerShell/Data/kind.config/0.17.0/images.yaml" -OutFile $configPath
        }
        
    }
}