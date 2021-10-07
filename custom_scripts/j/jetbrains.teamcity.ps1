$result = Invoke-WebRequest -Headers $header -Uri "https://data.services.jetbrains.com/products/releases?latest=true&type=release&code=TC" -UseBasicParsing -Method Get | ConvertFrom-Json | Select-Object -ExpandProperty TC
if ($result.build -gt $package.last_checked_tag) {
    $version = "$($result.version) (build $($result.build))"
    $urls.Add($result.downloads.windows.link -replace "https://download.jetbrains.com","https://download-cdn.jetbrains.com")
}
else
{
    Write-Host -ForegroundColor 'DarkYellow' "No updates found for`: $($package.pkgid)"
}
