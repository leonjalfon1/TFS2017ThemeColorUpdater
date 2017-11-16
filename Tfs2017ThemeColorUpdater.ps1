param
(
    $CurrentPrimaryColor="#0078d7",
    $CurrentSecondaryColor="#106ebe",
    $CurrentThirdColor="#005a9e",
    $CurrentFourthColor="#015a9e",

    $NewPrimaryColor="#e60000",
    $NewSecondaryColor="#cc0000",
    $NewThirdColor="#b30000",
    $NewFourthColor="#b30000",

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


function Create-AppThemesBackup
{
    Write-Host "Creating a Backup..."

    if(-not(Test-Path "$AppThemesPath-Backup")){ Copy-Item -Path $AppThemesPath -Recurse -Destination "$AppThemesPath-Backup" } 
    else { Write-Host "Backup already exist" -ForegroundColor Gray} 

    Write-Host "" 
    Write-Host "Backup successfully created!" -ForegroundColor Yellow
}


function Update-CssFiles
{
    Write-Host ""
    Write-Host "" 
    Write-Host "Updating css files..."

    $CssFiles = Get-ChildItem -Recurse -Path $AppThemesPath | Where-Object { $_.Extension -eq ".css"}

    foreach($file in $CssFiles)
    {
        $FilePath = $file.FullName
        Write-Host "Updating File {$FilePath}..." -ForegroundColor Gray
        (Get-Content $FilePath) -replace $CurrentPrimaryColor,$NewPrimaryColor | out-file $FilePath
        (Get-Content $FilePath) -replace $CurrentSecondaryColor,$NewSecondaryColor | out-file $FilePath
        (Get-Content $FilePath) -replace $CurrentThirdColor,$NewThirdColor | out-file $FilePath
        (Get-Content $FilePath) -replace $CurrentFourthColor,$NewFourthColor | out-file $FilePath
    }

    Write-Host "" 
    Write-Host "Files successfully updated!" -ForegroundColor Yellow
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


if(-not (Test-Path $AppThemesPath))
{
    Write-Host "Error, Folder {$AppThemesPath} not found" -ForegroundColor Red
}
else
{
    Create-AppThemesBackup
    Update-CssFiles
    Stop-TFS
    Start-TFS

    Write-Host ""
    Write-Host "" 
    Write-Host "Process successfully finished!" -ForegroundColor Green
    Write-Host ""
    Write-Host "" 
}


#=================================================================================================================