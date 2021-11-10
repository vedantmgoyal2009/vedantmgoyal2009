$domainUrl = "https://statics.teams.cdn.office.net"
$existing_version = ($package.last_checked_tag -split ',')[0]
$lastCheckedBuild = [int]($package.last_checked_tag -split ',')[1]
$versionPrefix = ($existing_version | Select-String -Pattern "[0-9.]{7}").Matches.Value
$architectures = @('x64', 'x86', 'arm64')
$pathsAndFilenames = @{
    x64   = @{
        path     = 'production-windows-x64';
        filename = 'Teams_windows_x64.exe'
    }
    x86   = @{
        path     = 'production-windows';
        filename = 'Teams_windows.exe'
    }
    arm64 = @{
        path     = 'production-windows-arm64';
        filename = 'Teams_windows_arm64.exe'
    }
}
for (($i = 1), ($j = $lastCheckedBuild + 1); $i -lt 2; ($i++), ($j += $j.ToString() -match "(0[1-9]|((1|2|3)[0-9])|4[0-8])$" ? 1 : 52)) {
    $result =
    try {
        (Invoke-WebRequest -Uri ($domainUrl + "/" + $pathsAndFilenames[$architectures[0]].path + "/" + $versionPrefix + $j.ToString() + "/" + $pathsAndFilenames[$architectures[0]].filename) -Method HEAD -ErrorAction SilentlyContinue).StatusCode
    }
    catch {
        $_.Exception.Response.StatusCode.value__
    }
    if ($result -eq 200) {
        $urls.Clear()
        $update_found = $true
        $version = $versionPrefix + $j.ToString()
        $jsonTag = "$($version),$($j.ToString())"
        foreach ($arch in $architectures) {
            $urls.Add($domainUrl + "/" + $pathsAndFilenames[$arch].path + "/" + $versionPrefix + $j.ToString() + "/" + $pathsAndFilenames[$arch].filename) | Out-Null
        }
    }
    else {
        $package.last_checked_tag = "$($existing_version),$($j.ToString())"
    }
}
