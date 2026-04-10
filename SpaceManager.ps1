$AdbExe = "$PSScriptRoot\adb.exe"
$WhitelistFile = "$PSScriptRoot\whitelist.txt"
$DisabledLog = "$PSScriptRoot\disabled_log.txt"

$FatalSystemPackages = @(
    "android"
    "android.ext.services"
    "com.android.bluetooth"
    "com.android.captiveportallogin"
    "com.android.carrierconfig"
    "com.android.cellbroadcastservice"
    "com.android.externalstorage"
    "com.android.keychain"
    "com.android.localtransport"
    "com.android.location.fused"
    "com.android.mms.service"
    "com.android.networkstack"
    "com.android.networkstack.permissionconfig"
    "com.android.networkstack.tethering"
    "com.android.networkstack.tethering.xiaomi_msm8953"
    "com.android.pacprocessor"
    "com.android.permissioncontroller"
    "com.android.phone"
    "com.android.providers.blockednumber"
    "com.android.providers.contacts"
    "com.android.providers.downloads"
    "com.android.providers.media"
    "com.android.providers.media.module"
    "com.android.providers.settings"
    "com.android.providers.telephony"
    "com.android.proxyhandler"
    "com.android.se"
    "com.android.server.telecom"
    "com.android.settings"
    "com.android.shell"
    "com.android.statementservice"
    "com.android.systemui"
    "com.android.wifi.resources"
    "com.android.wifi.resources.xiaomi_msm8953"
    "com.dot.packageinstaller"
    "com.google.android.configupdater"
    "com.google.android.ext.shared"
    "com.google.android.gms"
    "com.google.android.gms.dynamite_cronetdynamite"
    "com.google.android.gms.dynamite_dynamiteloader"
    "com.google.android.gms.dynamite_dynamitemodulesa"
    "com.google.android.gms.dynamite_dynamitemodulesc"
    "com.google.android.gms.dynamite_googlecertificates"
    "com.google.android.gms.dynamite_mapsdynamite"
    "com.google.android.gms.dynamite_measurementdynamite"
    "com.google.android.gms.policy_ads_fdr_dynamite"
    "com.google.android.gms.ui"
    "com.google.android.gsf"
    "com.google.android.ims"
    "com.google.android.safetycore"
    "com.google.android.webview"
    "com.google.process.gapps"
    "com.google.process.gservices"
    "com.qti.dpmserviceapp"
    "com.qti.qualcomm.datastatusnotification"
    "com.qualcomm.embms"
    "com.qualcomm.qcrilmsgtunnel"
    "com.qualcomm.qti.cne"
    "com.qualcomm.qti.ims"
    "com.qualcomm.qti.telephonyservice"
    "com.qualcomm.qti.uceShimService"
    "com.qualcomm.timeservice"
    "moe.shizuku.privileged.api"
    "org.codeaurora.ims"
    "vendor.qti.iwlan"
)

$DefaultWhitelistPackages = $FatalSystemPackages + @(
    "com.android.launcher3"
    "com.atomicadd.tinylauncher"
    "rkr.simplekeyboard.inputmethod"
    "android.process.media"
    "com.proximabeta.mf.liteuamo"
    "com.magicalstory.MemoryKiller"
)

function Check-AdbConnection {
    if (-not (Test-Path $AdbExe)) {
        Write-Host "`n[ERROR] File adb.exe tidak ditemukan di folder yang sama!`n" -ForegroundColor Red
        Pause
        Exit
    }

    $AdbOutput = & $AdbExe devices 2>&1
    $ConnectedDevices = $AdbOutput | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "\bdevice$" -and $_ -notmatch "^List" }
    
    if (-not $ConnectedDevices) {
        Write-Host "`n[ERROR] HP tidak terdeteksi. Cek USB Debugging.`n" -ForegroundColor Red
        Write-Host "Debug output:" -ForegroundColor DarkGray
        $AdbOutput | ForEach-Object { Write-Host "  '$_'" -ForegroundColor DarkGray }
        Pause
        Exit
    }
}

function Get-LoadedWhitelist {
    if (Test-Path $WhitelistFile) {
        $SavedList = Get-Content $WhitelistFile | Where-Object { $_ -match "\S" } | ForEach-Object { $_.Trim() }
        $MergedList = [System.Collections.Generic.HashSet[string]]::new()
        $FatalSystemPackages | ForEach-Object { $MergedList.Add($_) | Out-Null }
        $SavedList | ForEach-Object { $MergedList.Add($_) | Out-Null }
        return @($MergedList)
    } else {
        $DefaultWhitelistPackages | Sort-Object -Unique | Set-Content $WhitelistFile
        return $DefaultWhitelistPackages
    }
}

function Set-SavedWhitelist($TargetList) {
    $MergedList = [System.Collections.Generic.HashSet[string]]::new()
    $FatalSystemPackages | ForEach-Object { $MergedList.Add($_) | Out-Null }
    $TargetList | ForEach-Object { $MergedList.Add($_) | Out-Null }
    @($MergedList) | Sort-Object | Set-Content $WhitelistFile
}

function Get-UserInstalledPackages {
    Write-Host "  Mengambil daftar app..." -ForegroundColor DarkGray
    & $AdbExe shell pm list packages -3 | ForEach-Object { $_ -replace "package:","" -replace "`r","" } | Where-Object { $_ -match "\S" } | Sort-Object
}

function Get-AllDevicePackages {
    & $AdbExe shell pm list packages | ForEach-Object { $_ -replace "package:","" -replace "`r","" } | Where-Object { $_ -match "\S" } | Sort-Object
}

function Show-DashboardHeader($Subtitle = "") {
    Clear-Host
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   SPACE MANAGER v2.0 - ADB Game Mode" -ForegroundColor Cyan
    if ($Subtitle) { Write-Host "   $Subtitle" -ForegroundColor DarkGray }
    Write-Host "============================================" -ForegroundColor Cyan
}

function Show-MainMenu {
    Show-DashboardHeader
    $IsGameModeActive = Test-Path $DisabledLog
    Write-Host ""
    Write-Host "  Game Mode : " -NoNewline
    if ($IsGameModeActive) { Write-Host "[ ON ]" -ForegroundColor Green } else { Write-Host "[ OFF ]" -ForegroundColor DarkGray }
    Write-Host ""
    Write-Host "  [1] List app & kelola whitelist" -ForegroundColor White
    Write-Host "  [2] Kelola whitelist manual" -ForegroundColor White
    Write-Host "  [3] GAME MODE ON  - disable semua kecuali whitelist" -ForegroundColor Green
    Write-Host "  [4] GAME MODE OFF - restore semua app" -ForegroundColor Yellow
    Write-Host "  [5] Status" -ForegroundColor White
    Write-Host "  [0] Keluar" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Pilih: " -NoNewline -ForegroundColor Cyan
}

function Manage-AppList {
    Show-DashboardHeader "List App Terinstall"
    $CurrentWhitelist = Get-LoadedWhitelist
    $InstalledPackages = Get-UserInstalledPackages
    $PackageArray = @($InstalledPackages)

    Write-Host ""
    $Index = 1
    foreach ($Pkg in $PackageArray) {
        $CleanedPkg = $Pkg.Trim()
        $IsSystemFatal = $FatalSystemPackages -contains $CleanedPkg
        $IsWhitelisted = $CurrentWhitelist -contains $CleanedPkg
        if ($IsSystemFatal) {
            Write-Host ("  {0,3}. [SYS] {1}" -f $Index, $CleanedPkg) -ForegroundColor DarkGray
        } elseif ($IsWhitelisted) {
            Write-Host ("  {0,3}. [WL ] {1}" -f $Index, $CleanedPkg) -ForegroundColor Green
        } else {
            Write-Host ("  {0,3}. [   ] {1}" -f $Index, $CleanedPkg) -ForegroundColor White
        }
        $Index++
    }

    Write-Host ""
    Write-Host "  [SYS]=fatal  [WL]=whitelist (boleh jalan)  [ ]=diblokir saat game mode" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Nomor untuk toggle whitelist (pisah koma), Enter=kembali: " -NoNewline -ForegroundColor Cyan
    $UserInput = Read-Host

    if ($UserInput -match "\S") {
        $WhitelistSet = [System.Collections.Generic.HashSet[string]]::new()
        $CurrentWhitelist | ForEach-Object { $WhitelistSet.Add($_) | Out-Null }
        $InputNumbers = $UserInput -split "," | ForEach-Object { $_.Trim() }
        foreach ($Num in $InputNumbers) {
            if ($Num -match "^\d+$") {
                $PackageIndex = [int]$Num - 1
                if ($PackageIndex -ge 0 -and $PackageIndex -lt $PackageArray.Count) {
                    $SelectedPkg = $PackageArray[$PackageIndex].Trim()
                    if ($FatalSystemPackages -contains $SelectedPkg) {
                        Write-Host "  [!] $SelectedPkg adalah system fatal, tidak bisa diubah." -ForegroundColor Red
                    } elseif ($WhitelistSet.Contains($SelectedPkg)) {
                        $WhitelistSet.Remove($SelectedPkg) | Out-Null
                        Write-Host "  [-] Dihapus: $SelectedPkg" -ForegroundColor Red
                    } else {
                        $WhitelistSet.Add($SelectedPkg) | Out-Null
                        Write-Host "  [+] Ditambah: $SelectedPkg" -ForegroundColor Green
                    }
                }
            }
        }
        Set-SavedWhitelist @($WhitelistSet)
        Write-Host "  Whitelist disimpan." -ForegroundColor Green
        Start-Sleep 1
    }
}

function Manage-WhitelistManual {
    Show-DashboardHeader "Whitelist Manager"
    $CurrentWhitelist = Get-LoadedWhitelist | Sort-Object
    $UserWhitelistArray = @($CurrentWhitelist | Where-Object { $FatalSystemPackages -notcontains $_ })

    Write-Host ""
    Write-Host "  [FATAL SYSTEM - terkunci, selalu aktif]" -ForegroundColor DarkGray
    $FatalSystemPackages | Sort-Object | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

    Write-Host ""
    Write-Host "  [USER WHITELIST - boleh jalan saat game mode]" -ForegroundColor Green
    $Index = 1
    foreach ($Pkg in $UserWhitelistArray) {
        Write-Host ("  {0,3}. {1}" -f $Index, $Pkg) -ForegroundColor Green
        $Index++
    }

    Write-Host ""
    Write-Host "  [A] Tambah  [H] Hapus  [R] Reset default  [Enter] Kembali" -ForegroundColor White
    Write-Host "  Pilih: " -NoNewline -ForegroundColor Cyan
    $SelectedOption = Read-Host

    $WhitelistSet = [System.Collections.Generic.HashSet[string]]::new()
    $CurrentWhitelist | ForEach-Object { $WhitelistSet.Add($_) | Out-Null }

    if ($SelectedOption -eq "A" -or $SelectedOption -eq "a") {
        Write-Host "  Package name: " -NoNewline -ForegroundColor Cyan
        $NewPackage = (Read-Host).Trim()
        if ($NewPackage -match "\S") {
            $WhitelistSet.Add($NewPackage) | Out-Null
            Set-SavedWhitelist @($WhitelistSet)
            Write-Host "  [+] Ditambah: $NewPackage" -ForegroundColor Green
            Start-Sleep 1
        }
    } elseif ($SelectedOption -eq "H" -or $SelectedOption -eq "h") {
        Write-Host "  Nomor yang dihapus (pisah koma): " -NoNewline -ForegroundColor Cyan
        $InputNumbers = (Read-Host) -split "," | ForEach-Object { $_.Trim() }
        foreach ($Num in $InputNumbers) {
            if ($Num -match "^\d+$") {
                $PackageIndex = [int]$Num - 1
                if ($PackageIndex -ge 0 -and $PackageIndex -lt $UserWhitelistArray.Count) {
                    $TargetPkg = $UserWhitelistArray[$PackageIndex]
                    $WhitelistSet.Remove($TargetPkg) | Out-Null
                    Write-Host "  [-] Dihapus: $TargetPkg" -ForegroundColor Red
                }
            }
        }
        Set-SavedWhitelist @($WhitelistSet)
        Start-Sleep 1
    } elseif ($SelectedOption -eq "R" -or $SelectedOption -eq "r") {
        Write-Host "  Reset ke default? [Y/N]: " -NoNewline -ForegroundColor Yellow
        if ((Read-Host) -eq "Y") {
            $DefaultWhitelistPackages | Sort-Object -Unique | Set-Content $WhitelistFile
            Write-Host "  Reset selesai." -ForegroundColor Green
            Start-Sleep 1
        }
    }
}

function Execute-RemoteShellScript($LinesArray, $RemoteFilePath) {
    $TempFile = "$env:TEMP\space_tmp.sh"
    ($LinesArray -join "`n") | Set-Content $TempFile -Encoding UTF8
    & $AdbExe push $TempFile $RemoteFilePath 2>&1 | Out-Null
    & $AdbExe shell "sh $RemoteFilePath; rm $RemoteFilePath" 2>&1 | Out-Null
    Remove-Item $TempFile
}

function Enable-GameMode {
    Show-DashboardHeader "GAME MODE ON"
    if (Test-Path $DisabledLog) {
        Write-Host "`n  [!] Sudah aktif. Overwrite? [ENTER/N]: " -NoNewline -ForegroundColor Yellow
        if ((Read-Host) -eq "N") { return }
    }

    $CurrentWhitelist = Get-LoadedWhitelist
    $AllPackages = Get-AllDevicePackages
    $PackagesToDisable = @($AllPackages | Where-Object { $CurrentWhitelist -notcontains $_.Trim() })

    Write-Host "  Akan disable: $($PackagesToDisable.Count) app" -ForegroundColor Yellow
    Write-Host "  ENTER=mulai  N=batal: " -NoNewline -ForegroundColor Cyan
    if ((Read-Host) -eq "N") { return }

    $PackagesToDisable | Set-Content $DisabledLog

    Write-Host "  Menjalankan..." -ForegroundColor DarkGray
    $ScriptLines = @("#!/system/bin/sh") + ($PackagesToDisable | ForEach-Object { "pm disable-user --user 0 $($_.Trim()) >/dev/null 2>&1" })
    Execute-RemoteShellScript $ScriptLines "/data/local/tmp/space_on.sh"

    Write-Host "  GAME MODE ON! $($PackagesToDisable.Count) app diblokir." -ForegroundColor Green
    Write-Host "  Tekan Enter..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

function Disable-GameMode {
    Show-DashboardHeader "GAME MODE OFF"

    if (Test-Path $DisabledLog) {
        $PackagesToEnable = @(Get-Content $DisabledLog | Where-Object { $_ -match "\S" })
    } else {
        Write-Host "  Scan disabled packages..." -ForegroundColor DarkGray
        $PackagesToEnable = @(& $AdbExe shell pm list packages -d | ForEach-Object { $_ -replace "package:","" -replace "`r","" } | Where-Object { $_ -match "\S" })
    }

    Write-Host "  Restore: $($PackagesToEnable.Count) app" -ForegroundColor Yellow
    Write-Host "  ENTER=restore  N=batal: " -NoNewline -ForegroundColor Cyan
    if ((Read-Host) -eq "N") { return }

    Write-Host "  Menjalankan..." -ForegroundColor DarkGray
    $ScriptLines = @("#!/system/bin/sh") + ($PackagesToEnable | ForEach-Object { "pm enable $($_.Trim()) >/dev/null 2>&1" })
    Execute-RemoteShellScript $ScriptLines "/data/local/tmp/space_off.sh"

    if (Test-Path $DisabledLog) { Remove-Item $DisabledLog }

    Write-Host "  GAME MODE OFF. $($PackagesToEnable.Count) app di-restore." -ForegroundColor Green
    Write-Host "  Tekan Enter..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

function Display-SystemStatus {
    Show-DashboardHeader "Status"
    $CurrentWhitelist = Get-LoadedWhitelist
    $IsGameModeActive = Test-Path $DisabledLog
    $DisabledPackages = @(& $AdbExe shell pm list packages -d | ForEach-Object { $_ -replace "package:","" -replace "`r","" } | Where-Object { $_ -match "\S" })

    Write-Host ""
    Write-Host "  Game Mode    : " -NoNewline
    if ($IsGameModeActive) { Write-Host "ON" -ForegroundColor Green } else { Write-Host "OFF" -ForegroundColor Yellow }
    Write-Host "  Fatal System : $($FatalSystemPackages.Count) app (terkunci)" -ForegroundColor DarkGray
    Write-Host "  Whitelist    : $($CurrentWhitelist.Count) app" -ForegroundColor Green
    Write-Host "  Disabled now : $($DisabledPackages.Count) app" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Tekan Enter..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

Check-AdbConnection
if (-not (Test-Path $WhitelistFile)) {
    $DefaultWhitelistPackages | Sort-Object -Unique | Set-Content $WhitelistFile
    Write-Host "  [+] Whitelist default dibuat." -ForegroundColor Green
    Start-Sleep 1
}

while ($true) {
    Show-MainMenu
    $MenuSelection = Read-Host
    switch ($MenuSelection) {
        "1" { Manage-AppList }
        "2" { Manage-WhitelistManual }
        "3" { Enable-GameMode }
        "4" { Disable-GameMode }
        "5" { Display-SystemStatus }
        "0" { Write-Host "`n  Bye!`n" -ForegroundColor Cyan; Exit }
        default { Write-Host "  Input tidak valid." -ForegroundColor Red; Start-Sleep 1 }
    }
}