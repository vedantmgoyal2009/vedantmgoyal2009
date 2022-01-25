# [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'This script is not intended to have any outputs piped')]

# # Set error action to continue, hide progress bar of webclient.downloadfile
# $ErrorActionPreference = "Continue"
# $ProgressPreference = 'SilentlyContinue'

# # Clone microsoft/winget-pkgs repository, copy YamlCreate.ps1 to the Tools folder, set settings for YamlCreate.ps1
# git config --global user.name 'winget-pkgs-automation-bot[bot]' # Set git username
# git config --global user.email '93540089+winget-pkgs-automation-bot[bot]@users.noreply.github.com' # Set git email
# $token = $((Invoke-RestMethod -Method Post -Headers @{Authorization = "Bearer $($env:JWT_RB | ruby.exe)"; Accept = "application/vnd.github.v3+json"} -Uri "https://api.github.com/app/installations/$env:THIS_ID/access_tokens").token)
# git clone https://x-access-token:$($this_authorization)@github.com/microsoft/winget-pkgs.git --quiet # Clones the repository silently
# $currentDir = Get-Location # Get current directory
# Set-Location .\winget-pkgs\Tools # Change directory to Tools
# git remote rename origin upstream # Rename origin to upstream
# git remote add origin https://x-access-token:$($this_authorization)@github.com/vedantmgoyal2009/winget-pkgs.git # Add fork to origin
# Copy-Item -Path $currentDir\YamlCreate.ps1 -Destination .\YamlCreate.ps1 -Force # Copy YamlCreate.ps1 to Tools directory
# git commit --all -m "Update YamlCreate.ps1 (Unattended)" # Commit changes
# Set-Location $currentDir # Go back to previous working directory
# New-Item -ItemType File -Path "$env:LOCALAPPDATA\YamlCreate\Settings.yaml" -Force | Out-Null # Create Settings.yaml file
# @"
# TestManifestsInSandbox: always
# SaveToTemporaryFolder: never
# AutoSubmitPRs: always
# ContinueWithExistingPRs: never
# SuppressQuickUpdateWarning: true
# EnableDeveloperOptions: true
# "@ | Set-Content -Path $env:LOCALAPPDATA\YamlCreate\Settings.yaml # YamlCreate settings
# Write-Host "Cloned repository, copied YamlCreate.ps1 to Tools directory, and set YamlCreate settings."

$token = "abcdef...uvwxyz"

$UpgradeObject = @()

ForEach ($Package in $(Get-ChildItem ..\test\ -Recurse -File | Get-Content -Raw | ConvertFrom-Json)) {
    $_Object = New-Object -TypeName System.Management.Automation.PSObject
    $_Object | Add-Member -MemberType NoteProperty -Name "PackageIdentifier" -Value $Package.Identifier
    $VersionRegex = $Package.VersionRegex
    $InstallerRegex = $Package.InstallerRegex
    If (-not [System.String]::IsNullOrEmpty($Package.AdditionalInfo)) {
        $Package.AdditionalInfo.PSObject.Properties | ForEach-Object {
            Set-Variable -Name $_.Name -Value $_.Value
        }
    }
    $Paramters = @{Method = $Package.Update.Method; Uri = $Package.Update.Uri}
    # If (-not [System.String]::IsNullOrEmpty($Package.Update.Headers)) {
    #     $Package.Update.Headers.PSObject.Properties | ForEach-Object -Begin { $Headers = @{} } -Process { $Headers.Add($_.Name, ("Write-Output $($_.Value)" | Invoke-Expression)) } -End { $Paramters.Headers = $Headers }
    # }
    If (-not [System.String]::IsNullOrEmpty($Package.Update.Body)) {
        $Paramters.Body = $Package.Update.Body
    }
    If (-not [System.String]::IsNullOrEmpty($Package.Update.UserAgent)) {
        $Paramters.UserAgent = $Package.Update.UserAgent
    }
    If ($Package.Update.InvokeType -eq 'RestMethod') {
        $Response = Invoke-RestMethod @Paramters
    } ElseIf ($Package.Update.InvokeType -eq 'WebRequest') {
        $Response = Invoke-WebRequest @Paramters
    }
    If (-not [System.String]::IsNullOrEmpty($Package.PostResponseScript)) {
        $Package.PostResponseScript | Invoke-Expression # Run PostResponseScript
    }
    $Package.ManifestFields.PSObject.Properties | ForEach-Object {
        $_Object | Add-Member -MemberType NoteProperty -Name $_.Name -Value ($_.Value | Invoke-Expression)
    }
    Write-Output -InputObject $_Object
    # If ($_Object.PackageVersion -gt $Package.PreviousVersion) {
    #     $UpgradeObject += @([PSCustomObject] $_Object)
    # }
}
