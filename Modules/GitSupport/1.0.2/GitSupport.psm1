function Initialize-GitHubRepository{ 
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $RepositoryUrl
    )
    $CodeDirectory = "C:\Code"

    # Example Repository Url: https://github.com/DotNet-Ninja/DotNetNinja.ApiTemplate.git
    $location = (Get-Location).Path
    if($location -ne $CodeDirectory){
        do{
            Write-Host
            $response = Read-Host -Prompt "$location is not in your default source code location of $CodeDirectory.  Clone here anyway? (y/n)"
            if($response.Length -gt 0){
                $sanitized = $response.Substring(0,1).ToLower()
            }
            else{
                $sanitized = $response
            }
            if($sanitized -eq "n"){
                return
            }
        }
        while($response -ne "y")
    }

    $CloneDirectory = $RepositoryUrl.Substring(0, $RepositoryUrl.LastIndexOf(".git")).Substring($RepositoryUrl.LastIndexOf("/")+1)

    Write-Message "Cloning Repository '$RepositoryUrl'"
    git clone $RepositoryUrl

    Write-Message "Renaming GutHub Generated Files."
    Set-Location $CloneDirectory
    Rename-Item .\LICENSE License.txt
    Rename-Item .\README.MD readme.txt
    git add .
    Rename-Item .\readme.txt ReadMe.md
    git add .
    Write-Message "Committing changes and pushing to server ..."
    git commit -m"Renamed GitHub generated files"
    git push
    Write-Message "Creating Branch gh-pages and pushing to server ..."
    git checkout -b gh-pages
    git push -u origin gh-pages
    git checkout main

    Write-Message "Repository $CloneDirectory is initialized.  Happy Coding!"
}
function Initialize-AzureDevOpsRepository{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $RepositoryUrl
    )
    $CodeDirectory = "C:\Code"

    # Example Repository Url: https://chaosmonkey@dev.azure.com/chaosmonkey/Zocial.Identity/_git/Zocial.Identity
    $location = (Get-Location).Path
    if($location -ne $CodeDirectory){
        do{
            Write-Host
            $response = Read-Host -Prompt "$location is not in your default source code location of $CodeDirectory.  Clone here anyway? (y/n)"
            if($response.Length -gt 0){
                $sanitized = $response.Substring(0,1).ToLower()
            }
            else{
                $sanitized = $response
            }
            if($sanitized -eq "n"){
                return
            }
        }
        while($response -ne "y")
    }


    $CloneDirectory = $RepositoryUrl.Substring($RepositoryUrl.LastIndexOf("/")+1)

    Write-Message "Cloning Repository '$RepositoryUrl'"
    git clone $RepositoryUrl

    Write-Message "Setting git user: Larry House - chaos.monkey@hotmail.com"
    git config user.name "Larry House"
    git config user.email "chaos.monkey@hotmail.com"

    Write-Message "Renaming Azure DevOps Generated Files."
    Set-Location $CloneDirectory
    Rename-Item .\README.MD readme.txt
    git add .
    Rename-Item .\readme.txt ReadMe.md
    git add .
    Write-Message "Committing changes and pushing to server ..."
    git commit -m"Renamed Azure DevOps generated files"
    git push

    Write-Message "Repository $CloneDirectory is initialized.  Happy Coding!"
}

function Initialize-BitbucketRepository{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $RepositoryUrl
    )
    $CodeDirectory = "C:\Code"

    # Example Repository Url: https://chaosmonkey@dev.azure.com/chaosmonkey/Zocial.Identity/_git/Zocial.Identity
    $location = (Get-Location).Path
    if($location -ne $CodeDirectory){
        do{
            Write-Host
            $response = Read-Host -Prompt "$location is not in your default source code location of $CodeDirectory.  Clone here anyway? (y/n)"
            if($response.Length -gt 0){
                $sanitized = $response.Substring(0,1).ToLower()
            }
            else{
                $sanitized = $response
            }
            if($sanitized -eq "n"){
                return
            }
        }
        while($response -ne "y")
    }

    $CloneDirectory = $RepositoryUrl.Substring(0, $RepositoryUrl.LastIndexOf(".git")).Substring($RepositoryUrl.LastIndexOf("/")+1)

    Write-Message "Cloning Repository '$RepositoryUrl'"
    git clone $RepositoryUrl

    Write-Message "Renaming Bitbucket Generated Files."
    Set-Location $CloneDirectory
    Rename-Item .\README.MD readme.txt
    git add .
    Rename-Item .\readme.txt ReadMe.md
    git add .
    Write-Message "Committing changes and pushing to server ..."
    git commit -m"Renamed Bitbucket generated files"
    git push

    Write-Message "Repository $CloneDirectory is initialized.  Happy Coding!"
}

function Set-DefaultDiffTool{
    git config --global diff.tool bc3
    git config --global difftool.bc3.path "c:/program files/beyond compare 4/bcomp.exe"
    git config --global difftool.prompt false

    git config --global merge.tool bc3
    git config --global mergetool.prompt false
    git config --global mergetool.bc3.path "c:/program files/beyond compare 4/bcomp.exe"
}

function Start-GitRemoteUI{
    $url = Get-GitRemoteUrl
    if([string]::IsNullOrEmpty($url)){
        Write-Warning "No remote url found."
        return
    }
    $repoHost = "Repository"
    if($url.Contains("dev.azure.com")){
        $repoHost = "Azure DevOps";
    }
    if($url.Contains("github.com")){
        $repoHost = "GitHub";
    }    
    if($url.Contains("bitbucket.org")){
        $repoHost = "Bitbucket";
    }
    Write-Message "Launching $repoHost ($url)"
    Start-Process ($url)
}

function Get-GitRemoteUrl{
    $url = git remote get-url origin
    return $url
}

Set-Alias Start-RepositoryWebUI Start-GitRemoteUI

function Write-Message{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Message
    )
    Write-Host $Message -ForegroundColor Green
}

Export-ModuleMember -Function Initialize-GitHubRepository
Export-ModuleMember -Function Initialize-AzureDevOpsRepository
Export-ModuleMember -Function Set-DefaultDiffTool
Export-ModuleMember -Function Start-GitRemoteUI
Export-ModuleMember -Function Get-GitRemoteUrl