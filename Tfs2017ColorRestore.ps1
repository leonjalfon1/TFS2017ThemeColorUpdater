param
(
    $CurrentWelcomeColor="#106ebe",
    $CurrentPrimaryColor="#0078d7",
    $CurrentSecondaryColor="#005a9e",
    $NewWelcomeColor="#D7000C",
    $NewPrimaryColor="#D7000C",
    $NewSecondaryColor="#AC000A",
    $TfsPath="C:\Program Files\Microsoft Team Foundation Server 15.0",
    $AppThemesPath="C:\Program Files\Microsoft Team Foundation Server 15.0\Application Tier\Web Services\_static\tfs\Dev15.M125.1\App_Themes"
)

#=================================================== FUNCTIONS ===================================================


function Restore-AppThemesFolder
{
    Write-Host "Restoring default theme colors..."

    if(Test-Path $AppThemesPath){ Remove-Item -Path $AppThemesPath -Recurse -Force} 
    Move-Item -Path "$AppThemesPath-Backup" -Destination $AppThemesPath -Force

    Write-Host "" 
    Write-Host "Theme colors successfully restored!" -ForegroundColor Yellow
}


function Stop-TFS
{
    Write-Host ""
    Write-Host "" 
    Write-Host "Restarting TFS, Shuting Down..."



    # Setup the Process startup info
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "$TfsPath\Tools\TfsServiceControl.exe"
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
}


function Start-TFS
{
    Write-Host ""
    Write-Host "" 
    Write-Host "Restarting TFS, Starting TFS..."


    # Setup the Process startup info
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "$TfsPath\Tools\TfsServiceControl.exe"
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
}


#====================================================== INIT =====================================================


if(-not (Test-Path "$AppThemesPath-Backup"))
{
    Write-Host "Error, Backup not found {$AppThemesPath-Backup}" -ForegroundColor Red
}
else
{
    Restore-AppThemesFolder
    Stop-TFS
    Start-TFS

    Write-Host ""
    Write-Host "" 
    Write-Host "Process successfully finished!" -ForegroundColor Green
    Write-Host ""
    Write-Host "" 
}

#=================================================================================================================