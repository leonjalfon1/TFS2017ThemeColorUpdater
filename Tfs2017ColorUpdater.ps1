$AppThemesDefaultPath="C:\Program Files\Microsoft Team Foundation Server 15.0\Application Tier\Web Services\_static\tfs\Dev15.M125.1\App_Themes"

if(-not (Test-Path $AppThemesDefaultPath))
{
    Write-Host "Error, Folder {$AppThemesDefaultPath} not found" -ForegroundColor Red
}
else
{
    $CssFiles = Get-ChildItem -Recurse -Path $AppThemesDefaultPath | Where-Object { $_.Extension -eq ".css"}

    foreach($file in $CssFiles)
    {
        $FilePath = $file.FullName
        Write-Host "Updating File {$FilePath}..." -ForegroundColor Gray
        (Get-Content $FilePath) -replace "#0078d7","#D7000C" | out-file $FilePath
        (Get-Content $FilePath) -replace "#005a9e","#AC000A" | out-file $FilePath
        (Get-Content $FilePath) -replace "#106ebe","#D7000C" | out-file $FilePath
    }
}

Write-Host "Files successfully updated!" -ForegroundColor Green


Write-Host ""
Write-Host "" 
Write-Host "Restarting TFS, Shuting Down..."



# Setup the Process startup info
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "C:\Program Files\Microsoft Team Foundation Server 15.0\Tools\TfsServiceControl.exe"
$pinfo.Arguments = "quiesce"
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.WorkingDirectory = Get-Location

# Create a process object using the startup info
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $pinfo

# Start the process
$process.Start() | Out-Null
$process.WaitForExit()


Write-Host $process.StandardOutput.ReadToEnd() -ForegroundColor Gray
Write-Host "TFS Stopped!" -ForegroundColor Yellow


Write-Host ""
Write-Host "" 
Write-Host "Restarting TFS, Starting TFS..."


# Setup the Process startup info
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "C:\Program Files\Microsoft Team Foundation Server 15.0\Tools\TfsServiceControl.exe"
$pinfo.Arguments = "unquiesce"
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.WorkingDirectory = Get-Location

# Create a process object using the startup info
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $pinfo

# Start the process
$process.Start() | Out-Null
$process.WaitForExit()


Write-Host $process.StandardOutput.ReadToEnd() -ForegroundColor Gray
Write-Host "TFS Started!" -ForegroundColor Yellow


Write-Host ""
Write-Host "" 
Write-Host "Process successfully finished!" -ForegroundColor Green