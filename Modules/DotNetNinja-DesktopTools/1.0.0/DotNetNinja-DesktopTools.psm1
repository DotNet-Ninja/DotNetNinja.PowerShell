function Move-DesktopItems {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Destination = $null
    )    
    process {
        $desktop = [System.Environment]::GetFolderPath("Desktop")
        if($null -ne $Destination){
            $Destination = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "Desktop-Archive"
        }
        $datestamp = ((Get-Date).Year.ToString() + "-" + (Get-Date).Month.ToString().PadLeft(2, '0') + "-" + (Get-Date).Day.ToString().PadLeft(2, '0'))
        $general = Join-Path $Destination $datestamp
        $webUrlTarget = Join-Path $Destination "WebUrls"

        if(!(Test-Path $webUrlTarget)){
            New-Item -ItemType Directory -Path $webUrlTarget | Out-Null
        }

        if(!(Test-Path $general)){
            New-Item -ItemType Directory -Path $general | Out-Null
        }
        
        # Delete Shortcuts
        Get-ChildItem $desktop -Filter *.lnk | Remove-Item

        # Move Bookmarks
        Get-ChildItem $desktop -Filter *.url | Move-Item -Destination $webUrlTarget

        #Move Files & Folders
        Get-ChildItem $desktop | Move-Item -Destination $general
    }    
}

function Get-ItemSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]
        [string] $Path = "."      
    )
    
    process {
        (Get-ChildItem -Path $Path -Recurse -Force | Measure-Object -Sum Length).Sum
    }
    
}

function Format-ByteSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [long] $Value    
    )
        
    process {
        [float] $v = 0.0
        [string] $suffix = "B"
        switch($Value)
        {
            {$PSItem -le 1024 }
            {
                $v=$Value
                break
            }
            {$PSItem -le 1048576 }
            {
                $v=$Value/1024
                $suffix = "KB"
                break
            }
            {$PSItem -le 1073741824 }
            {
                $v=$Value/1048576
                $suffix = "MB"
                break
            }
            {$PSItem -le 1099511627776 }
            {
                $v=$Value/1073741824
                $suffix = "GB"
                break
            }
            default
            {
                $v=$Value/1099511627776
                $suffix = "TB"
                break
            }
        }
        return $v.ToString("n2") + " $suffix"                
    }
    
}

function Deploy-Modules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Source = ".",
        [Parameter(Mandatory=$false, Position=1)]
        [string] $Destination = $null
    )
    
    process {
        if([System.String]::IsNullOrWhiteSpace($Destination)){
            Write-Verbose "Determining Powershell Modules Path"
            $Destination = $env:PSModulePath.Split(";") | Where-Object {$_.Contains("\Users\", [System.StringComparison]::InvariantCultureIgnoreCase) -and $_.EndsWith("PowerShell\Modules", [System.StringComparison]::InvariantCultureIgnoreCase)} | Select-Object -First 1
            Write-Verbose "Found PowerShell Modules Path $Destination"
        }    
        Write-Host "Deploying to $Destination"
        $modules = Get-ChildItem $Source -Recurse | Where-Object {$_.Name -eq "Modules"} | Select-Object -First 1
        Get-ChildItem $modules | Copy-Item -Destination $Destination -Force -Recurse
        Get-ChildItem $Destination
    }
    
}

Export-ModuleMember -Function Move-DesktopItems
Export-ModuleMember -Function Get-ItemSize
Export-ModuleMember -Function Format-ByteSize
Export-ModuleMember -Function Deploy-Modules
