function New-KindConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $KubeVersion = "1.25",
        [Parameter(Mandatory=$false, Position=1)]
        [int] $WorkerNodes = 3,
        [Parameter(Mandatory=$false, Position=2)]
        [int] $ControlPlaneNodes = 1  
    )
    process {
        $settings = Get-KindConfigData
        $image = $settings.images["0.17.0"][$KubeVersion]
        $content = "
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:"
        for($index=1; $index -le $ControlPlaneNodes; $index ++){
            $node = "
    - role: control-plane
      image: $image"
            $content = $content + $node
        }
        for($index=1; $index -le $WorkerNodes; $index ++){
            $node = "
    - role: worker
      image: $image"
            $content = $content + $node
        }

        Write-Output $content
    }
}

function Get-KindConfigData {
    process {
        $configPath = Join-Path -Path $HOME -ChildPath ".ninja" -AdditionalChildPath "kube"
        $configPath = Join-Path -Path $configPath -ChildPath ".\images.yaml"
        if(!(Test-Path($configPath))){
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DotNet-Ninja/DotNetNinja.PowerShell/main/Data/kind.config/0.17.0/images.yaml" -OutFile $configPath
        }
        $config = Get-Content $configPath | ConvertFrom-Yaml
        Write-Output $config
    }
}

function New-KindCluster {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $KubeVersion = "1.25",
        [Parameter(Mandatory=$false, Position=1)]
        [int] $WorkerNodes = 3,
        [Parameter(Mandatory=$false, Position=2)]
        [int] $ControlPlaneNodes = 1,
        [Parameter(Mandatory=$false, Position=3)]
        [string] $Name = "KindCluster"
    )
    process {
        $cleanName = $Name.ToLower()
        $tmp = New-TemporaryFile
        New-KindConfig -KubeVersion $KubeVersion -WorkerNodes $WorkerNodes -ControlPlaneNodes $ControlPlaneNodes | Set-Content $tmp.FullName
        kind create cluster --config $tmp --name $cleanName
    }
}

function Get-KubeVersions {
    process {
        $settings = Get-KindConfigData
        Write-Output $settings.images["0.17.0"].Keys | Sort-Object -Descending
    }
}

function Remove-KindCluster{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Name = "KindCluster"
    )
    process {
        $cleanName = $Name.ToLower()
        kind delete cluster --name $cleanName
    }
}

function Install-IngressNginx {    
    process {
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.4.0/deploy/static/provider/baremetal/deploy.yaml
        kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=300s
        kubectl wait --for=condition=Complete job -l app.kubernetes.io/component=admission-webhook -n ingress-nginx --timeout=300s
    }
}

Export-ModuleMember -Function New-KindConfig
Export-ModuleMember -Function Get-KindConfigData
Export-ModuleMember -Function New-KindCluster
Export-ModuleMember -Function Get-KubeVersions
Export-ModuleMember -Function Remove-KindCluster
Export-ModuleMember -Function Install-IngressNginx
