param
(
    $TfsPath="C:\Program Files\Microsoft Team Foundation Server 15.0",
    $AppThemesPath="auto"
)

#=================================================== FUNCTIONS ===================================================


function Set-AppThemesPathParameter
{
    $MatchFolders = Get-ChildItem "$TfsPath\Application Tier\Web Services\_static\tfs" -Filter Dev15.*

    if($MatchFolders -eq $null)
    {
        Write-Host "Error, Any file with the pattern 'Dev15*' was found under $TfsPath\Application Tier\Web Services\_static\tfs}"
        Write-Host "AppThemesPath parameter can be automatically set" -ForegroundColor Red
        Exit
    }
    elseif($MatchFolders.GetType().Name -eq "Object[]")
    {
        Write-Host "Error, Several files with the pattern 'Dev15*' were found under {$TfsPath\Application Tier\Web Services\_static\tfs}" -ForegroundColor Red
        Write-Host "AppThemesPath parameter can be automatically set" -ForegroundColor Red
        Exit
    }
    else
    {
        $DevFolder=$MatchFolders.Name
        $AppThemesPath="$TfsPath\Application Tier\Web Services\_static\tfs\$DevFolder\App_Themes"
        Write-Host "AppThemesPath [$AppThemesPath]"
        return $AppThemesPath
    }
}


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


if($AppThemesPath -eq "auto")
{
    $AppThemesPath = Set-AppThemesPathParameter
}


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