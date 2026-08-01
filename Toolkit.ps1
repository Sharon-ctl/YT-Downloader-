<#
.SYNOPSIS
    YTDL Toolkit v1.0.0 -- Professional Media Download Manager
.DESCRIPTION
    A zero-knowledge-required Windows application for downloading video, audio,
    playlists, subtitles, thumbnails, livestreams, and metadata from supported
    websites using yt-dlp and FFmpeg.
.NOTES
    Author:  YTDL Toolkit Contributors
    License: MIT
    Requires: Windows 10+, PowerShell 5.1+
#>

# ===============================================================================
#  GLOBAL CONSTANTS AND CONFIGURATION
# ===============================================================================
#region GlobalConstants

$Script:Version          = '1.0.0'
$Script:AppName          = 'YTDL Toolkit'
$Script:Author           = 'YTDL Toolkit Contributors'
$Script:License          = 'MIT'
$Script:GitHubUrl        = 'https://github.com/ytdl-toolkit/ytdl-toolkit'
$Script:ToolkitRoot      = $PSScriptRoot
$Script:ToolsDir         = Join-Path $Script:ToolkitRoot 'tools'
$Script:ConfigDir        = Join-Path $Script:ToolkitRoot 'config'
$Script:DownloadBaseDir  = Join-Path $Script:ToolkitRoot 'downloads'
$Script:LogDir           = Join-Path $Script:ToolkitRoot 'logs'
$Script:CacheDir         = Join-Path $Script:ToolkitRoot 'cache'
$Script:TempDir          = Join-Path $Script:ToolkitRoot 'temp'
$Script:YtDlpPath        = Join-Path $Script:ToolsDir 'yt-dlp.exe'
$Script:FFmpegDir        = Join-Path $Script:ToolsDir 'ffmpeg'
$Script:FFmpegPath       = Join-Path $Script:FFmpegDir 'ffmpeg.exe'
$Script:FFprobePath      = Join-Path $Script:FFmpegDir 'ffprobe.exe'
$Script:ConfigFile       = Join-Path $Script:ConfigDir 'config.ini'
$Script:ArchiveFile      = Join-Path $Script:ToolkitRoot 'archive.txt'
$Script:HistoryFile      = Join-Path $Script:ToolkitRoot 'history.txt'
$Script:LogFile          = $null
$Script:IsOffline        = $false
$Script:Config           = @{}
$Script:CurrentTheme     = 'Classic'
$Script:SessionStartTime = Get-Date

# Download subdirectories
$Script:DownloadDirs = @{
    Videos      = Join-Path $Script:DownloadBaseDir 'Videos'
    Music       = Join-Path $Script:DownloadBaseDir 'Music'
    Playlists   = Join-Path $Script:DownloadBaseDir 'Playlists'
    Livestreams = Join-Path $Script:DownloadBaseDir 'Livestreams'
    Shorts      = Join-Path $Script:DownloadBaseDir 'Shorts'
    Subtitles   = Join-Path $Script:DownloadBaseDir 'Subtitles'
    Metadata    = Join-Path $Script:DownloadBaseDir 'Metadata'
}

# yt-dlp download URL
$Script:YtDlpDownloadUrl = 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe'
$Script:YtDlpApiUrl      = 'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest'

# FFmpeg download URL (gyan.dev)
$Script:FFmpegDownloadUrl = 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'

# SponsorBlock category mapping
$Script:SponsorBlockCategories = [ordered]@{
    'sponsor'     = 'Sponsors'
    'intro'       = 'Intros'
    'outro'       = 'Outros'
    'selfpromo'   = 'Self Promotion'
    'interaction' = 'Interaction Reminders'
    'preview'     = 'Preview / Recap'
    'filler'      = 'Filler Content'
}

# Supported audio formats
$Script:AudioFormats = @('mp3', 'flac', 'wav', 'm4a', 'aac', 'opus', 'vorbis')

# Supported video codecs
$Script:VideoCodecs = @('best', 'h264', 'h265', 'av1', 'vp9')

# Console encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

#endregion

# ===============================================================================
#  THEME DEFINITIONS
# ===============================================================================
#region Themes

$Script:Themes = @{
    'Classic' = @{
        Primary   = 'Gray'
        Accent    = 'Yellow'
        Heading   = 'White'
        Success   = 'Green'
        Warning   = 'Yellow'
        Error     = 'Red'
        Info      = 'Cyan'
        Muted     = 'DarkGray'
        Border    = 'DarkYellow'
        Value     = 'DarkCyan'
        MenuNum   = 'Yellow'
        MenuText  = 'Gray'
        Progress  = 'Green'
        BgColor   = 'Black'
    }
    'Blue' = @{
        Primary   = 'Cyan'
        Accent    = 'Blue'
        Heading   = 'White'
        Success   = 'Green'
        Warning   = 'Yellow'
        Error     = 'Red'
        Info      = 'Cyan'
        Muted     = 'DarkGray'
        Border    = 'DarkCyan'
        Value     = 'Cyan'
        MenuNum   = 'Cyan'
        MenuText  = 'White'
        Progress  = 'Cyan'
        BgColor   = 'Black'
    }
    'Green' = @{
        Primary   = 'Green'
        Accent    = 'DarkGreen'
        Heading   = 'White'
        Success   = 'Green'
        Warning   = 'Yellow'
        Error     = 'Red'
        Info      = 'Cyan'
        Muted     = 'DarkGray'
        Border    = 'DarkGreen'
        Value     = 'Green'
        MenuNum   = 'Green'
        MenuText  = 'White'
        Progress  = 'Green'
        BgColor   = 'Black'
    }
    'Purple' = @{
        Primary   = 'Magenta'
        Accent    = 'DarkMagenta'
        Heading   = 'White'
        Success   = 'Green'
        Warning   = 'Yellow'
        Error     = 'Red'
        Info      = 'Cyan'
        Muted     = 'DarkGray'
        Border    = 'DarkMagenta'
        Value     = 'Magenta'
        MenuNum   = 'Magenta'
        MenuText  = 'White'
        Progress  = 'Magenta'
        BgColor   = 'Black'
    }
    'White' = @{
        Primary   = 'DarkGray'
        Accent    = 'DarkBlue'
        Heading   = 'Black'
        Success   = 'DarkGreen'
        Warning   = 'DarkYellow'
        Error     = 'DarkRed'
        Info      = 'DarkCyan'
        Muted     = 'Gray'
        Border    = 'DarkGray'
        Value     = 'DarkBlue'
        MenuNum   = 'DarkBlue'
        MenuText  = 'DarkGray'
        Progress  = 'DarkGreen'
        BgColor   = 'White'
    }
}

$Script:Colors = $Script:Themes['Classic']

function Set-Theme {
    param([string]$ThemeName)
    if ($Script:Themes.ContainsKey($ThemeName)) {
        $Script:CurrentTheme = $ThemeName
        $Script:Colors = $Script:Themes[$ThemeName]
        $Host.UI.RawUI.BackgroundColor = $Script:Colors.BgColor
        $Host.UI.RawUI.ForegroundColor = $Script:Colors.Primary
    }
}

#endregion

# ===============================================================================
#  UI FRAMEWORK
# ===============================================================================
#region UI

function Write-Color {
    param(
        [string]$Text,
        [string]$Color = 'Gray',
        [switch]$NoNewline
    )
    if ($NoNewline) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Success','Warning','Error','Info','Working')]
        [string]$Type = 'Info'
    )
    $symbols = @{
        Success = @{ Symbol = '[OK]'; Color = $Script:Colors.Success }
        Warning = @{ Symbol = '[!!]'; Color = $Script:Colors.Warning }
        Error   = @{ Symbol = '[XX]'; Color = $Script:Colors.Error   }
        Info    = @{ Symbol = '[ii]'; Color = $Script:Colors.Info    }
        Working = @{ Symbol = '[..]'; Color = $Script:Colors.Muted   }
    }
    $s = $symbols[$Type]
    Write-Color "  $($s.Symbol) " $s.Color -NoNewline
    Write-Color $Message $Script:Colors.Primary
    Write-Log $Type.ToUpper() $Message
}

function Show-Banner {
    $width = 60
    $border = '+' + ('=' * ($width - 2)) + '+'
    Write-Host ""
    Write-Color "  $border" $Script:Colors.Border
    $title = "$Script:AppName  v$Script:Version"
    $pad = $width - 4 - $title.Length
    $left = [math]::Floor($pad / 2)
    $right = [math]::Ceiling($pad / 2)
    Write-Color "  |$(' ' * $left)$title$(' ' * $right)|" $Script:Colors.Border
    $subtitle = 'Your Media Download Assistant'
    $pad2 = $width - 4 - $subtitle.Length
    $left2 = [math]::Floor($pad2 / 2)
    $right2 = [math]::Ceiling($pad2 / 2)
    Write-Color "  |$(' ' * $left2)$subtitle$(' ' * $right2)|" $Script:Colors.Border
    Write-Color "  $border" $Script:Colors.Border
}

function Show-SectionHeader {
    param([string]$Title)
    $line = '=' * 56
    Write-Host ""
    Write-Color "  $Title" $Script:Colors.Heading
    Write-Color "  $line" $Script:Colors.Border
}

function Show-MenuItem {
    param(
        [string]$Number,
        [string]$Text,
        [string]$Extra = ''
    )
    $pad = if ($Number.Length -lt 2) { ' ' } else { '' }
    Write-Color "  $pad" $Script:Colors.Primary -NoNewline
    Write-Color "$Number" $Script:Colors.MenuNum -NoNewline
    Write-Color ". " $Script:Colors.Muted -NoNewline
    Write-Color $Text $Script:Colors.MenuText -NoNewline
    if ($Extra) {
        Write-Color "  $Extra" $Script:Colors.Muted
    } else {
        Write-Host ""
    }
}

function Read-UserChoice {
    param(
        [string]$Prompt = 'Select option',
        [int]$Max = 99,
        [int]$Min = 1,
        [switch]$AllowZero,
        [switch]$AllowEmpty
    )
    Write-Host ""
    Write-Color "  $Prompt" $Script:Colors.Accent -NoNewline
    Write-Color ": " $Script:Colors.Muted -NoNewline
    $input_val = Read-Host
    if ($null -eq $input_val) { return '' }
    $input_val = $input_val.Trim()

    if ($AllowEmpty -and [string]::IsNullOrEmpty($input_val)) { return '' }

    if ($input_val -match '^\d+$') {
        $num = [int]$input_val
        $low = if ($AllowZero) { 0 } else { $Min }
        if ($num -ge $low -and $num -le $Max) {
            return $input_val
        }
    }
    $minVal = if ($AllowZero) { 0 } else { $Min }
    Write-Color "  Invalid choice. Please enter a number between $minVal and $Max." $Script:Colors.Warning
    return $null
}

function Read-UserInput {
    param(
        [string]$Prompt,
        [switch]$Required,
        [switch]$IsUrl,
        [switch]$AllowEmpty
    )
    Write-Host ""
    Write-Color "  $Prompt" $Script:Colors.Accent -NoNewline
    Write-Color ": " $Script:Colors.Muted -NoNewline
    $val = Read-Host
    if ($null -eq $val) { $val = '' }
    $val = $val.Trim()
    if ($Required -and [string]::IsNullOrEmpty($val)) {
        Write-Color "  This field is required." $Script:Colors.Warning
        return $null
    }
    if ($IsUrl -and -not [string]::IsNullOrEmpty($val)) {
        if (-not (Test-UrlValid $val)) {
            Write-Color "  Invalid URL. Please enter a valid web address." $Script:Colors.Warning
            return $null
        }
    }
    return $val
}

function Show-Confirmation {
    param(
        [string]$Message = 'Proceed?',
        [switch]$DefaultNo
    )
    $hint = if ($DefaultNo) { '[y/N]' } else { '[Y/n]' }
    Write-Color "  $Message $hint " $Script:Colors.Accent -NoNewline
    $answer = Read-Host
    if ($null -eq $answer) { $answer = '' }
    $answer = $answer.Trim().ToLower()
    if ([string]::IsNullOrEmpty($answer)) {
        return (-not $DefaultNo)
    }
    return ($answer -eq 'y' -or $answer -eq 'yes')
}

function Show-MediaInfoCard {
    param([hashtable]$Info)
    $width = 60
    $border = '+' + ('=' * ($width - 2)) + '+'

    Write-Host ""
    Write-Color "  $border" $Script:Colors.Border

    $headerText = 'Media Information'
    $hPad = $width - 4 - $headerText.Length
    $hL = [math]::Floor($hPad / 2); $hR = [math]::Ceiling($hPad / 2)
    Write-Color "  |$(' ' * $hL)$headerText$(' ' * $hR)|" $Script:Colors.Border
    Write-Color "  $border" $Script:Colors.Border

    $fields = [ordered]@{
        'Title'      = $Info.Title
        'Uploader'   = $Info.Uploader
        'Duration'   = $Info.Duration
        'Views'      = $Info.Views
        'Resolution' = $Info.Resolution
        'Video'      = $Info.VideoCodec
        'Audio'      = $Info.AudioCodec
        'Est. Size'  = $Info.EstimatedSize
        'Website'    = $Info.Website
    }

    foreach ($key in $fields.Keys) {
        $val = $fields[$key]
        if ([string]::IsNullOrEmpty($val)) { $val = 'N/A' }
        $label = ($key + ':').PadRight(13)
        $maxValLen = $width - 4 - 13 - 2
        if ($val.Length -gt $maxValLen) { $val = $val.Substring(0, $maxValLen - 3) + '...' }
        $padding = $width - 4 - 13 - $val.Length
        if ($padding -lt 0) { $padding = 0 }

        Write-Host "  | " -ForegroundColor $Script:Colors.Border -NoNewline
        Write-Host $label -ForegroundColor $Script:Colors.Muted -NoNewline
        Write-Host $val -ForegroundColor $Script:Colors.Value -NoNewline
        Write-Host "$(' ' * $padding) " -NoNewline
        Write-Host "|" -ForegroundColor $Script:Colors.Border
    }
    Write-Color "  $border" $Script:Colors.Border
}

function Show-ProgressBar {
    param(
        [string]$Title,
        [double]$Percent,
        [string]$Downloaded = '',
        [string]$Total = '',
        [string]$Speed = '',
        [string]$ETA = '',
        [switch]$Complete
    )
    
    if ($Complete) {
        Write-Progress -Activity "Downloading $Title" -Completed
        return
    }

    $statusParts = @()
    if ($Downloaded -and $Total) { $statusParts += "$Downloaded / $Total" }
    elseif ($Downloaded) { $statusParts += $Downloaded }
    if ($Speed) { $statusParts += $Speed }
    if ($ETA) { $statusParts += "ETA $ETA" }
    $status = $statusParts -join ' | '

    if ($Percent -ge 0 -and $Percent -le 100) {
        Write-Progress -Activity "Downloading $Title" -Status $status -PercentComplete ([int]$Percent)
    } else {
        Write-Progress -Activity "Downloading $Title" -Status $status
    }
}

function Clear-Screen {
    Clear-Host
    Show-Banner
}

function Wait-User {
    param([string]$Message = 'Press any key to continue...')
    Write-Host ""
    Write-Color "  $Message" $Script:Colors.Muted
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    Write-Host ""
}

#endregion

# ===============================================================================
#  LOGGING
# ===============================================================================
#region Logging

function Initialize-Log {
    if (-not (Test-Path $Script:LogDir)) {
        New-Item -ItemType Directory -Path $Script:LogDir -Force | Out-Null
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $Script:LogFile = Join-Path $Script:LogDir "session_$timestamp.log"

    $header = @(
        "======================================================="
        " $Script:AppName v$Script:Version -- Session Log"
        " Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        " System:  $([Environment]::OSVersion.VersionString)"
        " PS Ver:  $($PSVersionTable.PSVersion)"
        "======================================================="
        ""
    )
    $header | Out-File -FilePath $Script:LogFile -Encoding UTF8
}

function Write-Log {
    param(
        [string]$Level = 'INFO',
        [string]$Message
    )
    if (-not $Script:LogFile) { return }
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] [$Level] $Message"
    try {
        $entry | Out-File -FilePath $Script:LogFile -Encoding UTF8 -Append
    } catch { }
}

function Invoke-LogRotation {
    param([int]$MaxAgeDays = 30)
    if (-not (Test-Path $Script:LogDir)) { return }
    $cutoff = (Get-Date).AddDays(-$MaxAgeDays)
    Get-ChildItem -Path $Script:LogDir -Filter '*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object {
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            Write-Log 'INFO' "Rotated old log: $($_.Name)"
        }
}

function Export-Diagnostics {
    $diagDir = Join-Path $Script:TempDir 'diagnostics'
    if (Test-Path $diagDir) { Remove-Item $diagDir -Recurse -Force }
    New-Item -ItemType Directory -Path $diagDir -Force | Out-Null

    if (Test-Path $Script:ConfigFile) {
        Copy-Item $Script:ConfigFile -Destination $diagDir -ErrorAction SilentlyContinue
    }
    Get-ChildItem -Path $Script:LogDir -Filter '*.log' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 5 |
        ForEach-Object { Copy-Item $_.FullName -Destination $diagDir -ErrorAction SilentlyContinue }

    $sysInfo = @(
        "OS: $([Environment]::OSVersion.VersionString)"
        "PS: $($PSVersionTable.PSVersion)"
        "Toolkit: $Script:Version"
        "yt-dlp: $(Get-YtDlpVersion)"
        "FFmpeg: $(Get-FFmpegVersion)"
        "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    )
    $sysInfo | Out-File -FilePath (Join-Path $diagDir 'system_info.txt') -Encoding UTF8

    $zipPath = Join-Path $Script:ToolkitRoot "diagnostics_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    try {
        Compress-Archive -Path "$diagDir\*" -DestinationPath $zipPath -Force
        Remove-Item $diagDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Status "Diagnostics exported to: $zipPath" -Type Success
        return $zipPath
    } catch {
        Write-Status "Failed to create diagnostics archive: $($_.Exception.Message)" -Type Error
        return $null
    }
}

#endregion

# ===============================================================================
#  CONFIGURATION
# ===============================================================================
#region Config

$Script:DefaultConfig = [ordered]@{
    General = [ordered]@{
        DownloadFolder        = 'downloads'
        Theme                 = 'Classic'
        AutoUpdate            = 'true'
        AutoOpenFolder        = 'false'
        RetryCount            = '3'
        DiskWarningThresholdGB = '2'
    }
    Video = [ordered]@{
        PreferredCodec      = 'best'
        PreferredResolution = 'best'
    }
    Audio = [ordered]@{
        PreferredFormat  = 'mp3'
        PreferredQuality = '320'
    }
    Downloads = [ordered]@{
        EmbedMetadata    = 'true'
        EmbedThumbnails  = 'true'
        ArchiveMode      = 'true'
        FilenameTemplate = '%(title)s.%(ext)s'
    }
    Network = [ordered]@{
        CookieBrowser = 'none'
        Proxy         = ''
    }
    SponsorBlock = [ordered]@{
        Enabled    = 'false'
        Categories = 'sponsor,intro,outro,selfpromo,interaction,preview'
    }
}

function Read-Config {
    if (-not (Test-Path $Script:ConfigFile)) {
        Initialize-Config
    }
    $config = [ordered]@{}
    $currentSection = ''
    foreach ($line in (Get-Content $Script:ConfigFile -ErrorAction SilentlyContinue)) {
        $line = $line.Trim()
        if ([string]::IsNullOrEmpty($line) -or $line.StartsWith(';') -or $line.StartsWith('#')) {
            continue
        }
        if ($line -match '^\[(.+)\]$') {
            $currentSection = $Matches[1]
            if (-not $config.Contains($currentSection)) {
                $config[$currentSection] = [ordered]@{}
            }
        }
        elseif ($line -match '^([^=]+)=(.*)$' -and $currentSection) {
            $key = $Matches[1].Trim()
            $val = $Matches[2].Trim()
            $config[$currentSection][$key] = $val
        }
    }
    $Script:Config = $config
    return $config
}

function Write-Config {
    param([System.Collections.Specialized.OrderedDictionary]$Config = $Script:Config)
    if (-not (Test-Path $Script:ConfigDir)) {
        New-Item -ItemType Directory -Path $Script:ConfigDir -Force | Out-Null
    }
    $lines = @("; $Script:AppName Configuration", "; Auto-generated -- $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", "")
    foreach ($section in $Config.Keys) {
        $lines += "[$section]"
        foreach ($key in $Config[$section].Keys) {
            $lines += "$key=$($Config[$section][$key])"
        }
        $lines += ""
    }
    $lines | Out-File -FilePath $Script:ConfigFile -Encoding UTF8 -Force
    Write-Log 'INFO' 'Configuration saved.'
}

function Initialize-Config {
    Write-Log 'INFO' 'Creating default configuration...'
    $Script:Config = [ordered]@{}
    foreach ($section in $Script:DefaultConfig.Keys) {
        $Script:Config[$section] = [ordered]@{}
        foreach ($key in $Script:DefaultConfig[$section].Keys) {
            $Script:Config[$section][$key] = $Script:DefaultConfig[$section][$key]
        }
    }
    Write-Config -Config $Script:Config
}

function Repair-Config {
    $config = Read-Config
    $repaired = $false
    foreach ($section in $Script:DefaultConfig.Keys) {
        if (-not $config.Contains($section)) {
            $config[$section] = [ordered]@{}
            $repaired = $true
        }
        foreach ($key in $Script:DefaultConfig[$section].Keys) {
            if (-not $config[$section].Contains($key)) {
                $config[$section][$key] = $Script:DefaultConfig[$section][$key]
                $repaired = $true
            }
        }
    }
    if ($repaired) {
        $Script:Config = $config
        Write-Config -Config $config
        Write-Log 'INFO' 'Configuration repaired with missing defaults.'
    }
    return $repaired
}

function Get-Setting {
    param([string]$Section, [string]$Key)
    if ($Script:Config.Contains($Section) -and $Script:Config[$Section].Contains($Key)) {
        return $Script:Config[$Section][$Key]
    }
    if ($Script:DefaultConfig.Contains($Section) -and $Script:DefaultConfig[$Section].Contains($Key)) {
        return $Script:DefaultConfig[$Section][$Key]
    }
    return $null
}

function Set-Setting {
    param([string]$Section, [string]$Key, [string]$Value)
    if (-not $Script:Config.Contains($Section)) {
        $Script:Config[$Section] = [ordered]@{}
    }
    $Script:Config[$Section][$Key] = $Value
    Write-Config -Config $Script:Config
    Write-Log 'INFO' "Setting updated: [$Section] $Key = $Value"
}

#endregion

# ===============================================================================
#  ERROR HANDLING
# ===============================================================================
#region ErrorHandling

$Script:ErrorMessages = @{
    'is not available'             = @{ Message = 'This video is not available.';              Suggestion = 'It may have been removed or is not available in your region.' }
    'Private video'                = @{ Message = 'This video is private.';                    Suggestion = 'The owner has restricted access. You may need to sign in.' }
    'Video unavailable'            = @{ Message = 'This video is unavailable.';                Suggestion = 'It may have been deleted or removed by the uploader.' }
    'removed by the uploader'      = @{ Message = 'This video has been deleted.';              Suggestion = 'The uploader has removed this content.' }
    'who has blocked it'           = @{ Message = 'This video is blocked in your country.';    Suggestion = 'The content owner has geo-restricted this video. Try a VPN or proxy.' }
    'Sign in to confirm your age'  = @{ Message = 'This video is age-restricted.';             Suggestion = 'Use Settings > Browser Cookies to enable cookie-based authentication.' }
    'members-only'                 = @{ Message = 'This is members-only content.';             Suggestion = 'You need an active membership. Enable browser cookies in Settings.' }
    'Join this channel'            = @{ Message = 'This content requires a channel membership.'; Suggestion = 'Enable browser cookies in Settings if you are a member.' }
    'HTTP Error 403'               = @{ Message = 'Access forbidden (403).';                   Suggestion = 'The server denied access. Try browser cookies or a different URL.' }
    'HTTP Error 404'               = @{ Message = 'Content not found (404).';                  Suggestion = 'The URL may be incorrect or the content has been removed.' }
    'HTTP Error 429'               = @{ Message = 'Too many requests (429).';                  Suggestion = 'You are being rate-limited. Wait a few minutes and try again.' }
    'Unsupported URL'              = @{ Message = 'This URL is not supported.';                Suggestion = 'yt-dlp may not support this website. Check the supported sites list.' }
    'Unable to extract'            = @{ Message = 'Could not extract video information.';      Suggestion = 'The website structure may have changed. Try updating yt-dlp.' }
    'No video formats'             = @{ Message = 'No downloadable formats were found.';       Suggestion = 'The video may be DRM-protected or use an unsupported format.' }
    'Premieres in'                 = @{ Message = 'This video has not premiered yet.';         Suggestion = 'The video will be available after the scheduled premiere time.' }
    'ffmpeg'                       = @{ Message = 'FFmpeg encountered an error.';              Suggestion = 'Try reinstalling FFmpeg from the Maintenance menu.' }
    'Merge'                        = @{ Message = 'Failed to merge video and audio streams.';  Suggestion = 'Try reinstalling FFmpeg or choose a different format.' }
    'already been downloaded'      = @{ Message = 'This video was already downloaded.';        Suggestion = 'Check your archive. Disable Archive Mode in Settings to re-download.' }
    'disk'                         = @{ Message = 'Disk operation failed.';                    Suggestion = 'Check available disk space and write permissions.' }
    'No space left'                = @{ Message = 'Your disk is full.';                        Suggestion = 'Free up disk space and try again.' }
    'Permission denied'            = @{ Message = 'Permission denied.';                        Suggestion = 'The toolkit does not have write access. Try a different folder or run as admin.' }
    'network'                      = @{ Message = 'A network error occurred.';                 Suggestion = 'Check your internet connection and try again.' }
    'timed out'                    = @{ Message = 'The connection timed out.';                 Suggestion = 'The server took too long to respond. Check your connection and try again.' }
    'SSL'                          = @{ Message = 'A secure connection error occurred.';       Suggestion = 'There may be a network issue. Check your connection or try disabling proxy.' }
}

function ConvertTo-FriendlyError {
    param([string]$ErrorText)
    foreach ($pattern in $Script:ErrorMessages.Keys) {
        if ($ErrorText -match [regex]::Escape($pattern)) {
            return $Script:ErrorMessages[$pattern]
        }
    }
    return @{
        Message    = 'An unexpected error occurred.'
        Suggestion = 'Check the log file for details or try again.'
    }
}

function Show-Error {
    param(
        [string]$RawError,
        [string]$CustomMessage = ''
    )
    if ($CustomMessage) {
        Write-Color "`n  ERROR: $CustomMessage" $Script:Colors.Error
        Write-Log 'ERROR' $CustomMessage
    }
    if ($RawError) {
        $friendly = ConvertTo-FriendlyError $RawError
        if (-not $CustomMessage) {
            Write-Color "`n  ERROR: $($friendly.Message)" $Script:Colors.Error
        }
        Write-Color "  TIP:   $($friendly.Suggestion)" $Script:Colors.Info
        Write-Log 'ERROR' "$($friendly.Message) | Raw: $RawError"
    }
}

function Invoke-WithRetry {
    param(
        [scriptblock]$Action,
        [string]$Description = 'Operation',
        [int]$MaxRetries = -1
    )
    if ($MaxRetries -lt 0) {
        $MaxRetries = [int](Get-Setting 'General' 'RetryCount')
        if ($MaxRetries -le 0) { $MaxRetries = 3 }
    }

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            $result = & $Action
            return $result
        } catch {
            $errorMsg = $_.Exception.Message
            Write-Color "  Attempt $attempt of $MaxRetries failed: $errorMsg" $Script:Colors.Warning
            Write-Log 'WARN' "$Description attempt $attempt failed: $errorMsg"
            if ($attempt -lt $MaxRetries) {
                Write-Color "  Retrying in 3 seconds..." $Script:Colors.Muted
                Start-Sleep -Seconds 3
            }
        }
    }

    Write-Color "`n  All $MaxRetries attempts failed." $Script:Colors.Error
    if (Show-Confirmation "Try again manually?") {
        return Invoke-WithRetry -Action $Action -Description $Description -MaxRetries $MaxRetries
    }
    return $null
}

#endregion

# ===============================================================================
#  STARTUP CHECKS
# ===============================================================================
#region Startup

function Test-WindowsVersion {
    Write-Status "Checking Windows version..." -Type Working
    $osVer = [Environment]::OSVersion.Version
    if ($osVer.Major -lt 10) {
        Write-Status "Windows $($osVer.Major).$($osVer.Minor) detected. Windows 10 or later is recommended." -Type Warning
        Write-Log 'WARN' "Unsupported Windows version: $($osVer.ToString())"
        return $false
    }
    Write-Status "Windows $($osVer.Major).$($osVer.Minor) -- OK" -Type Success
    return $true
}

function Test-Internet {
    Write-Status "Checking internet connection..." -Type Working
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connectResult = $tcp.BeginConnect('8.8.8.8', 53, $null, $null)
        $success = $connectResult.AsyncWaitHandle.WaitOne(3000)
        $tcp.Close()
        if ($success) {
            Write-Status "Internet connected" -Type Success
            $Script:IsOffline = $false
            return $true
        }
    } catch { }

    try {
        $tcp2 = New-Object System.Net.Sockets.TcpClient
        $connectResult2 = $tcp2.BeginConnect('1.1.1.1', 53, $null, $null)
        $success2 = $connectResult2.AsyncWaitHandle.WaitOne(3000)
        $tcp2.Close()
        if ($success2) {
            Write-Status "Internet connected" -Type Success
            $Script:IsOffline = $false
            return $true
        }
    } catch { }

    Write-Status "No internet connection detected" -Type Warning
    $Script:IsOffline = $true

    Write-Host ""
    Write-Color "  Options:" $Script:Colors.Heading
    Write-Host "   1. Retry connection"
    Write-Host "   2. Continue offline (limited features)"
    Write-Host "   3. Exit"

    $choice = Read-UserChoice -Prompt "Select option" -Max 3
    switch ($choice) {
        '1' { return Test-Internet }
        '2' {
            Write-Status "Continuing in offline mode" -Type Info
            return $true
        }
        '3' { exit 0 }
        default { return Test-Internet }
    }
}

function Test-WritePermissions {
    Write-Status "Checking write permissions..." -Type Working
    $testFile = Join-Path $Script:ToolkitRoot '.write_test'
    try {
        'test' | Out-File -FilePath $testFile -Force -ErrorAction Stop
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        Write-Status "Write permissions OK" -Type Success
        return $true
    } catch {
        Write-Status "Cannot write to toolkit folder!" -Type Error
        Write-Color "  The toolkit needs permission to create files in:" $Script:Colors.Warning
        Write-Color "  $Script:ToolkitRoot" $Script:Colors.Value
        Write-Color "  Try moving the toolkit to a folder like Documents or Desktop." $Script:Colors.Info
        Write-Log 'ERROR' "Write permission denied at $Script:ToolkitRoot"
        return $false
    }
}

function Initialize-Folders {
    Write-Status "Verifying folder structure..." -Type Working
    $folders = @(
        $Script:ToolsDir
        $Script:FFmpegDir
        $Script:ConfigDir
        $Script:DownloadBaseDir
        $Script:LogDir
        $Script:CacheDir
        $Script:TempDir
    ) + @($Script:DownloadDirs.Values)

    $created = 0
    foreach ($folder in $folders) {
        if (-not (Test-Path $folder)) {
            try {
                New-Item -ItemType Directory -Path $folder -Force | Out-Null
                $created++
            } catch {
                Write-Status "Failed to create folder: $folder" -Type Error
                Write-Log 'ERROR' "Folder creation failed: $folder -- $($_.Exception.Message)"
            }
        }
    }

    if (-not (Test-Path $Script:ArchiveFile)) {
        New-Item -ItemType File -Path $Script:ArchiveFile -Force | Out-Null
    }
    if (-not (Test-Path $Script:HistoryFile)) {
        $historyHeader = "Date,Time,URL,Title,Website,OutputPath,FileSize,Duration,Status"
        $historyHeader | Out-File -FilePath $Script:HistoryFile -Encoding UTF8 -Force
    }

    if ($created -gt 0) {
        Write-Status "Created $created missing folder(s)" -Type Success
    } else {
        Write-Status "All folders present" -Type Success
    }
}

function Test-DiskSpace {
    Write-Status "Checking disk space..." -Type Working
    try {
        $qualifier = (Resolve-Path $Script:ToolkitRoot).Path.Substring(0, 2)
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$qualifier'" -ErrorAction Stop
        $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        $threshold = [double](Get-Setting 'General' 'DiskWarningThresholdGB')
        if ($threshold -le 0) { $threshold = 2 }

        if ($freeGB -lt $threshold) {
            Write-Status "Low disk space! Only $freeGB GB free (threshold: $threshold GB)" -Type Warning
            return $false
        }
        Write-Status "Disk space: $freeGB GB free" -Type Success
        return $true
    } catch {
        Write-Status "Could not check disk space" -Type Warning
        Write-Log 'WARN' "Disk space check failed: $($_.Exception.Message)"
        return $true
    }
}

function Invoke-StartupSequence {
    Show-SectionHeader "Startup Checks"
    Write-Host ""

    Test-WindowsVersion | Out-Null
    Test-Internet | Out-Null

    if (-not (Test-WritePermissions)) {
        Write-Color "`n  Cannot continue without write permissions." $Script:Colors.Error
        Wait-User
        exit 1
    }

    Initialize-Folders

    Write-Status "Loading configuration..." -Type Working
    $config = Read-Config
    if ($null -eq $config -or $config.Count -eq 0) {
        Initialize-Config
        $config = Read-Config
        Write-Status "Default configuration created" -Type Success
    } else {
        $repaired = Repair-Config
        if ($repaired) {
            Write-Status "Configuration repaired" -Type Warning
        } else {
            Write-Status "Configuration loaded" -Type Success
        }
    }

    $savedTheme = Get-Setting 'General' 'Theme'
    if ($savedTheme -and $Script:Themes.ContainsKey($savedTheme)) {
        Set-Theme $savedTheme
    }

    if (-not $Script:IsOffline) {
        $ytdlpOk  = Test-YtDlp
        $ffmpegOk = Test-FFmpeg

        while (-not $ytdlpOk -or -not $ffmpegOk) {
            Write-Host ""
            Write-Color "  One or more critical dependencies failed to install:" $Script:Colors.Error
            if (-not $ytdlpOk)  { Write-Color "    - yt-dlp.exe is missing"  $Script:Colors.Warning }
            if (-not $ffmpegOk) { Write-Color "    - FFmpeg is missing"       $Script:Colors.Warning }
            Write-Host ""
            Write-Host "   1. Retry installation"
            Write-Host "   2. Continue anyway (downloads will fail)"
            Write-Host "   3. Exit"

            $depChoice = Read-UserChoice -Prompt "Select option" -Max 3
            switch ($depChoice) {
                '1' {
                    if (-not $ytdlpOk)  { $ytdlpOk  = Test-YtDlp  }
                    if (-not $ffmpegOk) { $ffmpegOk = Test-FFmpeg }
                }
                '2' {
                    Write-Status "Continuing without all dependencies -- some features will not work" -Type Warning
                    break
                }
                '3' { exit 0 }
                default {
                    if (-not $ytdlpOk)  { $ytdlpOk  = Test-YtDlp  }
                    if (-not $ffmpegOk) { $ffmpegOk = Test-FFmpeg }
                }
            }
            if ($depChoice -eq '2') { break }
        }
    } else {
        if (Test-Path $Script:YtDlpPath) {
            Write-Status "yt-dlp found (offline -- skipping update check)" -Type Info
        } else {
            Write-Status "yt-dlp not found -- install requires internet" -Type Warning
        }
        if ((Test-Path $Script:FFmpegPath) -and (Test-Path $Script:FFprobePath)) {
            Write-Status "FFmpeg found (offline -- skipping update check)" -Type Info
        } else {
            Write-Status "FFmpeg not found -- install requires internet" -Type Warning
        }
    }

    Test-DiskSpace | Out-Null
    Invoke-LogRotation
    Test-UnfinishedDownloads

    Write-Host ""
    Write-Status "All startup checks complete" -Type Success
    Start-Sleep -Milliseconds 800
}

#endregion

# ===============================================================================
#  DEPENDENCY MANAGEMENT
# ===============================================================================
#region Dependencies

function Get-YtDlpVersion {
    if (-not (Test-Path $Script:YtDlpPath)) { return 'Not installed' }
    try {
        $ver = & $Script:YtDlpPath --version 2>&1
        return ($ver | Out-String).Trim()
    } catch {
        return 'Unknown'
    }
}

function Get-FFmpegVersion {
    if (-not (Test-Path $Script:FFmpegPath)) { return 'Not installed' }
    try {
        $out = & $Script:FFmpegPath -version 2>&1 | Select-Object -First 1
        $outStr = ($out | Out-String).Trim()
        if ($outStr -match 'ffmpeg version (\S+)') {
            return $Matches[1]
        }
        return $outStr
    } catch {
        return 'Unknown'
    }
}

function Test-YtDlp {
    Write-Status "Checking yt-dlp..." -Type Working
    if (-not (Test-Path $Script:YtDlpPath)) {
        Write-Status "yt-dlp not found -- installing..." -Type Warning
        Install-YtDlp
        return (Test-Path $Script:YtDlpPath)
    }
    try {
        $ver = & $Script:YtDlpPath --version 2>&1
        $verStr = ($ver | Out-String).Trim()
        if ([string]::IsNullOrEmpty($verStr)) {
            Write-Status "yt-dlp appears corrupted -- reinstalling..." -Type Warning
            Install-YtDlp
            return (Test-Path $Script:YtDlpPath)
        }
        Write-Status "yt-dlp $verStr" -Type Success

        if ((Get-Setting 'General' 'AutoUpdate') -eq 'true') {
            Test-YtDlpUpdate
        }
        return $true
    } catch {
        Write-Status "yt-dlp error -- reinstalling..." -Type Warning
        Install-YtDlp
        return (Test-Path $Script:YtDlpPath)
    }
}

function Invoke-FileDownloadWithProgress {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$Title = 'File'
    )
    $client = $null
    $inStream = $null
    $outStream = $null
    try {
        Add-Type -AssemblyName System.Net.Http
        $handler = New-Object System.Net.Http.HttpClientHandler
        $client = New-Object System.Net.Http.HttpClient($handler)
        $client.Timeout = [TimeSpan]::FromMinutes(10)

        $responseTask = $client.GetAsync($Url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead)
        $responseTask.Wait()
        $response = $responseTask.Result

        if (-not $response.IsSuccessStatusCode) {
            throw "HTTP error $($response.StatusCode)"
        }

        $totalBytesHeader = $response.Content.Headers.ContentLength
        $totalBytesVal = if ($null -ne $totalBytesHeader) { [long]$totalBytesHeader } else { 0L }
        $totalStr = if ($totalBytesVal -gt 0) { Format-FileSize $totalBytesVal } else { 'Unknown size' }

        $streamTask = $response.Content.ReadAsStreamAsync()
        $streamTask.Wait()
        $inStream = $streamTask.Result

        $outStream = [System.IO.File]::Create($OutFile)
        $buffer = New-Object byte[] 65536
        $downloadedBytes = 0L
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $lastReport = [System.Diagnostics.Stopwatch]::StartNew()

        while ($true) {
            $readTask = $inStream.ReadAsync($buffer, 0, $buffer.Length)
            $readTask.Wait()
            $bytesRead = $readTask.Result
            if ($bytesRead -eq 0) { break }

            $outStream.Write($buffer, 0, $bytesRead)
            $downloadedBytes += $bytesRead

            if ($lastReport.ElapsedMilliseconds -gt 150 -or ($totalBytesVal -gt 0 -and $downloadedBytes -eq $totalBytesVal)) {
                $lastReport.Restart()
                $percent = if ($totalBytesVal -gt 0) { [math]::Round(($downloadedBytes / $totalBytesVal) * 100, 1) } else { 0 }
                $elapsedSec = $sw.Elapsed.TotalSeconds
                $speedBps = if ($elapsedSec -gt 0) { $downloadedBytes / $elapsedSec } else { 0 }
                $speedStr = "$(Format-FileSize ([long]$speedBps))/s"
                $downloadedStr = Format-FileSize $downloadedBytes

                $etaStr = if ($totalBytesVal -gt 0 -and $speedBps -gt 0) {
                    $remSec = [int](($totalBytesVal - $downloadedBytes) / $speedBps)
                    Format-Duration $remSec
                } else { '--:--' }

                Show-ProgressBar -Title $Title -Percent $percent -Downloaded $downloadedStr -Total $totalStr -Speed $speedStr -ETA $etaStr
            }
        }

        return $true
    } catch {
        throw $_
    } finally {
        if ($outStream) { try { $outStream.Close() } catch {} }
        if ($inStream) { try { $inStream.Close() } catch {} }
        if ($client) { try { $client.Dispose() } catch {} }
        if ($sw) { $sw.Stop() }
        Show-ProgressBar -Title $Title -Complete
    }
}

function Install-YtDlp {
    Write-Status "Downloading yt-dlp..." -Type Working
    try {
        Invoke-FileDownloadWithProgress -Url $Script:YtDlpDownloadUrl -OutFile $Script:YtDlpPath -Title "yt-dlp.exe"
        if (Test-Path $Script:YtDlpPath) {
            $ver = Get-YtDlpVersion
            Write-Status "yt-dlp $ver installed successfully" -Type Success
        } else {
            Write-Status "yt-dlp download failed" -Type Error
        }
    } catch {
        Write-Status "Failed to download yt-dlp: $($_.Exception.Message)" -Type Error
        Write-Log 'ERROR' "yt-dlp install failed: $($_.Exception.Message)"
    }
}

function Test-YtDlpUpdate {
    try {
        $response = Invoke-RestMethod -Uri $Script:YtDlpApiUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $latestVer = $response.tag_name
        $currentVer = Get-YtDlpVersion
        if ($latestVer -and $currentVer -and $latestVer -ne $currentVer) {
            Write-Status "yt-dlp update available: $currentVer -> $latestVer" -Type Info
            if (Show-Confirmation "Update yt-dlp now?") {
                Update-YtDlp
            }
        }
    } catch {
        Write-Log 'WARN' "yt-dlp update check failed: $($_.Exception.Message)"
    }
}

function Update-YtDlp {
    Write-Status "Updating yt-dlp..." -Type Working
    try {
        $output = & $Script:YtDlpPath -U 2>&1 | Out-String
        if ($output -match 'Updated|Already|up to date') {
            $ver = Get-YtDlpVersion
            Write-Status "yt-dlp updated to $ver" -Type Success
        } else {
            Install-YtDlp
        }
    } catch {
        Write-Status "Self-update failed, downloading fresh copy..." -Type Warning
        Install-YtDlp
    }
}

function Test-FFmpeg {
    Write-Status "Checking FFmpeg..." -Type Working
    $hasFfmpeg  = Test-Path $Script:FFmpegPath
    $hasFfprobe = Test-Path $Script:FFprobePath

    if (-not $hasFfmpeg -or -not $hasFfprobe) {
        $missing = @()
        if (-not $hasFfmpeg)  { $missing += 'ffmpeg.exe' }
        if (-not $hasFfprobe) { $missing += 'ffprobe.exe' }
        Write-Status "Missing: $($missing -join ', ') -- installing..." -Type Warning
        Install-FFmpeg
        return ((Test-Path $Script:FFmpegPath) -and (Test-Path $Script:FFprobePath))
    }

    $ver = Get-FFmpegVersion
    Write-Status "FFmpeg $ver" -Type Success
    return $true
}

function Install-FFmpeg {
    Write-Status "Downloading FFmpeg Essentials..." -Type Working
    $zipPath = Join-Path $Script:TempDir 'ffmpeg.zip'
    try {
        Invoke-FileDownloadWithProgress -Url $Script:FFmpegDownloadUrl -OutFile $zipPath -Title "FFmpeg Essentials"

        Write-Status "Extracting FFmpeg..." -Type Working
        $extractDir = Join-Path $Script:TempDir 'ffmpeg_extract'
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
        Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

        $binDir = Get-ChildItem -Path $extractDir -Recurse -Directory -Filter 'bin' | Select-Object -First 1
        if ($binDir) {
            $ffmpegSrc  = Join-Path $binDir.FullName 'ffmpeg.exe'
            $ffprobeSrc = Join-Path $binDir.FullName 'ffprobe.exe'

            if (-not (Test-Path $Script:FFmpegDir)) {
                New-Item -ItemType Directory -Path $Script:FFmpegDir -Force | Out-Null
            }

            if (Test-Path $ffmpegSrc) {
                Copy-Item $ffmpegSrc -Destination $Script:FFmpegPath -Force
            }
            if (Test-Path $ffprobeSrc) {
                Copy-Item $ffprobeSrc -Destination $Script:FFprobePath -Force
            }
        }

        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue

        if ((Test-Path $Script:FFmpegPath) -and (Test-Path $Script:FFprobePath)) {
            $ver = Get-FFmpegVersion
            Write-Status "FFmpeg $ver installed successfully" -Type Success
        } else {
            Write-Status "FFmpeg extraction failed -- some files were not found" -Type Error
        }
    } catch {
        Write-Status "Failed to install FFmpeg: $($_.Exception.Message)" -Type Error
        Write-Log 'ERROR' "FFmpeg install failed: $($_.Exception.Message)"
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    }
}

#endregion

# ===============================================================================
#  URL ANALYSIS
# ===============================================================================
#region URLAnalysis

function Test-UrlValid {
    param([string]$Url)
    if ([string]::IsNullOrWhiteSpace($Url)) { return $false }
    try {
        $uri = [System.Uri]::new($Url)
        return ($uri.Scheme -eq 'http' -or $uri.Scheme -eq 'https')
    } catch {
        return $false
    }
}

function Get-MediaInfo {
    param([string]$Url)
    if (-not (Test-Path $Script:YtDlpPath)) { return $null }

    $argsList = @('--dump-json', '--no-download', '--no-warnings', '--no-playlist')
    $cookieBrowser = Get-Setting 'Network' 'CookieBrowser'
    if ($cookieBrowser -and $cookieBrowser -ne 'none') {
        $argsList += @('--cookies-from-browser', $cookieBrowser)
    }
    $proxy = Get-Setting 'Network' 'Proxy'
    if ($proxy -and $proxy -ne '') {
        $argsList += @('--proxy', $proxy)
    }
    $argsList += $Url

    try {
        Write-Status "Fetching media information..." -Type Working
        $jsonOutput = & $Script:YtDlpPath @argsList 2>&1
        $jsonStr = ($jsonOutput | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }) | Out-String
        if ([string]::IsNullOrWhiteSpace($jsonStr)) {
            $errorStr = ($jsonOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }) | Out-String
            return @{ Error = $errorStr.Trim() }
        }
        $info = $jsonStr | ConvertFrom-Json

        $duration = ''
        if ($info.duration) {
            $ts = [TimeSpan]::FromSeconds([int]$info.duration)
            $duration = if ($ts.Hours -gt 0) { $ts.ToString('hh\:mm\:ss') } else { $ts.ToString('mm\:ss') }
        }

        $views = ''
        if ($info.view_count) {
            $views = '{0:N0}' -f [long]$info.view_count
        }

        $resolution = ''
        if ($info.width -and $info.height) {
            $resolution = "$($info.width)x$($info.height)"
        } elseif ($info.resolution) {
            $resolution = $info.resolution
        }

        $estimatedSize = ''
        if ($info.filesize_approx) {
            $estimatedSize = Format-FileSize $info.filesize_approx
        } elseif ($info.filesize) {
            $estimatedSize = Format-FileSize $info.filesize
        }

        $website = ''
        if ($info.webpage_url_domain) {
            $website = $info.webpage_url_domain
        } elseif ($info.extractor) {
            $website = $info.extractor
        }

        return @{
            Title        = if ($info.title) { $info.title } else { 'Unknown' }
            Uploader     = if ($info.uploader) { $info.uploader } else { 'Unknown' }
            Duration     = $duration
            DurationSecs = if ($info.duration) { [int]$info.duration } else { 0 }
            Views        = $views
            Resolution   = $resolution
            VideoCodec   = if ($info.vcodec -and $info.vcodec -ne 'none') { $info.vcodec } else { 'N/A' }
            AudioCodec   = if ($info.acodec -and $info.acodec -ne 'none') { $info.acodec } else { 'N/A' }
            EstimatedSize = $estimatedSize
            Website      = $website
            IsLive       = [bool]$info.is_live
            IsUpcoming   = [bool]$info.live_status -and $info.live_status -eq 'is_upcoming'
            WasLive      = [bool]$info.was_live
            PlaylistCount = if ($info.playlist_count) { $info.playlist_count } else { 0 }
            Thumbnail    = $info.thumbnail
            Url          = $Url
            RawInfo      = $info
            Error        = $null
        }
    } catch {
        Write-Log 'ERROR' "Media info extraction failed: $($_.Exception.Message)"
        return @{ Error = $_.Exception.Message }
    }
}

function Get-UrlType {
    param([string]$Url)
    $lower = $Url.ToLower()
    if ($lower -match '/playlist\?list=' -or $lower -match '[?&]list=') {
        if ($lower -match '[?&]v=' -or $lower -match '/watch\?') {
            return 'PlaylistVideo'
        }
        return 'Playlist'
    }
    if ($lower -match '/shorts/') { return 'Short' }
    if ($lower -match '/live/' -or $lower -match 'live\.') { return 'Livestream' }
    return 'Video'
}

function Get-PlaylistInfo {
    param([string]$Url)
    if (-not (Test-Path $Script:YtDlpPath)) { return $null }

    $argsList = @('--flat-playlist', '--dump-json', '--no-download', '--no-warnings')
    $cookieBrowser = Get-Setting 'Network' 'CookieBrowser'
    if ($cookieBrowser -and $cookieBrowser -ne 'none') {
        $argsList += @('--cookies-from-browser', $cookieBrowser)
    }
    $argsList += $Url

    try {
        Write-Status "Fetching playlist information..." -Type Working
        $output = & $Script:YtDlpPath @argsList 2>&1
        $jsonLines = ($output | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }) | Out-String
        $lines = $jsonLines.Split("`n") | Where-Object { $_.Trim() -ne '' }

        if ($lines.Count -eq 0) { return $null }

        $firstEntry = $lines[0] | ConvertFrom-Json -ErrorAction SilentlyContinue
        $playlistTitle = if ($firstEntry.playlist_title) { $firstEntry.playlist_title } else { 'Unknown Playlist' }

        return @{
            Title      = $playlistTitle
            VideoCount = $lines.Count
            Url        = $Url
        }
    } catch {
        Write-Log 'ERROR' "Playlist info failed: $($_.Exception.Message)"
        return $null
    }
}

#endregion

# ===============================================================================
#  PRE-FLIGHT CHECKS
# ===============================================================================
#region PreFlight

function Invoke-PreFlightChecks {
    param(
        [string]$Url,
        [string]$OutputDir,
        [switch]$SkipMediaInfo
    )

    if ($Script:IsOffline) {
        Show-Error -CustomMessage "You are offline. Downloads require an internet connection."
        return $null
    }

    if (-not (Test-UrlValid $Url)) {
        Show-Error -CustomMessage "The URL you entered is not valid. Please check and try again."
        return $null
    }

    if (-not (Test-Path $Script:YtDlpPath)) {
        Show-Error -CustomMessage "yt-dlp is not installed. Please run Maintenance > Reinstall yt-dlp."
        return $null
    }

    if (-not (Test-Path $Script:FFmpegPath)) {
        Show-Error -CustomMessage "FFmpeg is not installed. Please run Maintenance > Reinstall FFmpeg."
        return $null
    }

    if (-not (Test-Path $OutputDir)) {
        try {
            New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        } catch {
            Show-Error -CustomMessage "Cannot create download folder: $OutputDir"
            return $null
        }
    }

    $diskOk = Test-DiskSpace
    if (-not $diskOk) {
        if (-not (Show-Confirmation "Low disk space. Continue anyway?")) {
            return $null
        }
    }

    if (-not $SkipMediaInfo) {
        $info = Get-MediaInfo $Url
        if ($info.Error) {
            Show-Error -RawError $info.Error
            return $null
        }
        return $info
    }

    return @{ Url = $Url; Title = 'Download' }
}

function Test-OutputFile {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        Write-Color "`n  File already exists:" $Script:Colors.Warning
        Write-Color "  $FilePath" $Script:Colors.Value
        Write-Host ""
        Write-Host "   1. Overwrite"
        Write-Host "   2. Auto-rename"
        Write-Host "   3. Skip"
        Write-Host "   0. Cancel"

        $choice = Read-UserChoice -Prompt "Choose action" -Max 3 -AllowZero
        switch ($choice) {
            '1' { return 'overwrite' }
            '2' { return 'rename' }
            '3' { return 'skip' }
            '0' { return 'cancel' }
            default { return 'cancel' }
        }
    }
    return 'proceed'
}

#endregion

# ===============================================================================
#  PROGRESS & FORMATTING
# ===============================================================================
#region Progress

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -lt 0) { return 'Unknown' }
    if ($Bytes -lt 1KB) { return "$Bytes B" }
    if ($Bytes -lt 1MB) { return "$([math]::Round($Bytes / 1KB, 1)) KB" }
    if ($Bytes -lt 1GB) { return "$([math]::Round($Bytes / 1MB, 1)) MB" }
    return "$([math]::Round($Bytes / 1GB, 2)) GB"
}

function Format-Duration {
    param([int]$Seconds)
    if ($Seconds -le 0) { return '00:00' }
    $ts = [TimeSpan]::FromSeconds($Seconds)
    if ($ts.Hours -gt 0) { return $ts.ToString('hh\:mm\:ss') }
    return $ts.ToString('mm\:ss')
}

function Format-Speed {
    param([string]$SpeedStr)
    return $SpeedStr
}

#endregion

# ===============================================================================
#  CORE DOWNLOADER
# ===============================================================================
#region CoreDownloader

function Get-OutputTemplate {
    param([string]$OutputDir)
    $template = Get-Setting 'Downloads' 'FilenameTemplate'
    if ([string]::IsNullOrEmpty($template)) {
        $template = '%(title)s.%(ext)s'
    }
    return Join-Path $OutputDir $template
}

function Get-CommonArgs {
    param(
        [string]$OutputDir,
        [switch]$NoArchive
    )
    $argsList = [System.Collections.ArrayList]@()

    $outputTemplate = Get-OutputTemplate $OutputDir
    [void]$argsList.Add('-o')
    [void]$argsList.Add($outputTemplate)

    [void]$argsList.Add('--ffmpeg-location')
    [void]$argsList.Add($Script:FFmpegDir)

    [void]$argsList.Add('--newline')
    [void]$argsList.Add('--no-colors')
    [void]$argsList.Add('--progress')
    [void]$argsList.Add('--windows-filenames')

    if (-not $NoArchive -and (Get-Setting 'Downloads' 'ArchiveMode') -eq 'true') {
        [void]$argsList.Add('--download-archive')
        [void]$argsList.Add($Script:ArchiveFile)
    }

    if ((Get-Setting 'Downloads' 'EmbedMetadata') -eq 'true') {
        [void]$argsList.Add('--embed-metadata')
    }

    if ((Get-Setting 'Downloads' 'EmbedThumbnails') -eq 'true') {
        [void]$argsList.Add('--embed-thumbnail')
    }

    $cookieBrowser = Get-Setting 'Network' 'CookieBrowser'
    if ($cookieBrowser -and $cookieBrowser -ne 'none') {
        [void]$argsList.Add('--cookies-from-browser')
        [void]$argsList.Add($cookieBrowser)
    }

    $proxy = Get-Setting 'Network' 'Proxy'
    if ($proxy -and $proxy -ne '') {
        [void]$argsList.Add('--proxy')
        [void]$argsList.Add($proxy)
    }

    return ,$argsList
}

function Invoke-YtDlp {
    param(
        [string[]]$Arguments,
        [string]$Title = 'Download',
        [string]$Url
    )

    Write-Log 'INFO' "Starting download: $Title"
    Write-Log 'INFO' "yt-dlp args: $($Arguments -join ' ')"
    Write-Log 'INFO' "URL: $Url"

    $allArgs = [System.Collections.ArrayList]@($Arguments)
    [void]$allArgs.Add($Url)

    $argString = ($allArgs | ForEach-Object {
        if ($_ -match '\s') { "`"$_`"" } else { $_ }
    }) -join ' '

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Script:YtDlpPath
    $psi.Arguments = $argString
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    $psi.WorkingDirectory = $Script:ToolkitRoot

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    try {
        $proc.Start() | Out-Null
    } catch {
        Write-Log 'ERROR' "Failed to start yt-dlp: $($_.Exception.Message)"
        return @{ Success = $false; ExitCode = -1; Error = $_.Exception.Message; Output = '' }
    }

    $stdoutTask = $proc.StandardOutput.ReadToEndAsync()

    $errorOutput = [System.Text.StringBuilder]::new()
    $progressInitialized = $false
    $lastTitle = $Title

    while (-not $proc.StandardError.EndOfStream) {
        $line = $proc.StandardError.ReadLine()
        if ($null -eq $line) { continue }

        Write-Log 'DEBUG' $line
        [void]$errorOutput.AppendLine($line)

        if ($line -match '\[download\]\s+([\d.]+)%\s+of\s+~?([\d.]+\S+)\s+at\s+([\d.]+\S+)\s+ETA\s+(\S+)') {
            $percent    = [double]$Matches[1]
            $totalSize  = $Matches[2]
            $speed      = $Matches[3]
            $eta        = $Matches[4]

            if (-not $progressInitialized) {
                Write-Host ""; Write-Host ""; Write-Host ""; Write-Host ""
                $progressInitialized = $true
            }

            Show-ProgressBar -Title $lastTitle -Percent $percent -Total $totalSize -Speed $speed -ETA $eta
        }
        elseif ($line -match '\[download\]\s+100%\s+of') {
            if ($progressInitialized) {
                Show-ProgressBar -Title $lastTitle -Percent 100 -Total '' -Speed '' -ETA '00:00'
            }
        }
        elseif ($line -match '\[download\]\s+Destination:\s+(.+)') {
            $lastTitle = [System.IO.Path]::GetFileNameWithoutExtension($Matches[1])
            Write-Log 'INFO' "Destination: $($Matches[1])"
        }
        elseif ($line -match '\[Merger\]') {
            Write-Color "`r  Merging audio and video...".PadRight(70) $Script:Colors.Info
        }
        elseif ($line -match '\[ExtractAudio\]') {
            Write-Color "`r  Extracting audio...".PadRight(70) $Script:Colors.Info
        }
        elseif ($line -match 'ERROR:') {
            Write-Log 'ERROR' $line
        }
    }

    $proc.WaitForExit()
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $errorOutput.ToString()

    $success = $proc.ExitCode -eq 0
    if ($success) {
        Write-Log 'INFO' "Download completed successfully: $Title"
    } else {
        Write-Log 'ERROR' "Download failed (exit code $($proc.ExitCode)): $Title"
    }

    return @{
        Success  = $success
        ExitCode = $proc.ExitCode
        Output   = $stdout
        Error    = $stderr
    }
}

function Invoke-Download {
    param(
        [string]$Url,
        [string]$Type,
        [string[]]$ExtraArgs,
        [string]$OutputDir,
        [string]$Description,
        [switch]$SkipMediaInfo,
        [switch]$SkipConfirm
    )

    $info = Invoke-PreFlightChecks -Url $Url -OutputDir $OutputDir -SkipMediaInfo:$SkipMediaInfo
    if ($null -eq $info) { return $false }

    $title = if ($info.Title) { $info.Title } else { 'Download' }

    if (-not $SkipMediaInfo -and $info.Title) {
        Show-MediaInfoCard $info
    }

    if (-not $SkipConfirm) {
        if (-not (Show-Confirmation "Download this $Type?")) {
            Write-Status "Download cancelled." -Type Info
            return $false
        }
    }

    Write-Host ""

    $commonArgs = Get-CommonArgs -OutputDir $OutputDir
    $commonArgs.AddRange($ExtraArgs)

    $result = Invoke-YtDlp -Arguments $commonArgs.ToArray() -Title $title -Url $Url

    if ($result.Success) {
        Write-Host ""
        Write-Status "Download complete: $title" -Type Success

        Add-HistoryEntry -Url $Url -Title $title -Website $info.Website -OutputDir $OutputDir `
            -Duration $info.Duration -Status 'Success'

        if ((Get-Setting 'General' 'AutoOpenFolder') -eq 'true') {
            Start-Process 'explorer.exe' -ArgumentList $OutputDir
        }
        return $true
    } else {
        Write-Host ""
        Show-Error -RawError $result.Error
        Add-HistoryEntry -Url $Url -Title $title -Website $info.Website -OutputDir $OutputDir `
            -Duration $info.Duration -Status 'Failed'

        if (Show-Confirmation "Retry download?") {
            return Invoke-Download -Url $Url -Type $Type -ExtraArgs $ExtraArgs -OutputDir $OutputDir `
                -Description $Description -SkipMediaInfo -SkipConfirm
        }
        return $false
    }
}

#endregion

# ===============================================================================
#  VIDEO DOWNLOADS
# ===============================================================================
#region VideoDownloads

function Get-VideoFormatArgs {
    param(
        [ValidateSet('best','h264','h265','av1','vp9','720p','1080p','1440p','4k')]
        [string]$FormatType
    )
    switch ($FormatType) {
        'best'  { return @('-f', 'bv*+ba/b', '--merge-output-format', 'mkv') }
        'h264'  { return @('-f', 'bv*[vcodec~=''^avc'']+ba/b', '--merge-output-format', 'mp4') }
        'h265'  { return @('-f', 'bv*[vcodec~=''^hev'']+ba/b', '--merge-output-format', 'mp4') }
        'av1'   { return @('-f', 'bv*[vcodec~=''^av01'']+ba/b', '--merge-output-format', 'mkv') }
        'vp9'   { return @('-f', 'bv*[vcodec~=''^vp0?9'']+ba/b', '--merge-output-format', 'mkv') }
        '720p'  { return @('-f', 'bv*[height<=720]+ba/b[height<=720]', '--merge-output-format', 'mp4') }
        '1080p' { return @('-f', 'bv*[height<=1080]+ba/b[height<=1080]', '--merge-output-format', 'mp4') }
        '1440p' { return @('-f', 'bv*[height<=1440]+ba/b[height<=1440]', '--merge-output-format', 'mp4') }
        '4k'    { return @('-f', 'bv*[height<=2160]+ba/b[height<=2160]', '--merge-output-format', 'mp4') }
    }
}

function Start-VideoDownload {
    param(
        [ValidateSet('best','h264','h265','av1','vp9','720p','1080p','1440p','4k')]
        [string]$FormatType = 'best'
    )
    Clear-Screen
    $descriptions = @{
        'best'  = 'Best Quality Video'
        'h264'  = 'H.264 Video (Premiere-friendly)'
        'h265'  = 'H.265 / HEVC Video'
        'av1'   = 'AV1 Video'
        'vp9'   = 'VP9 Video'
        '720p'  = '720p Video'
        '1080p' = '1080p Video'
        '1440p' = '1440p Video'
        '4k'    = '4K Video'
    }
    Show-SectionHeader $descriptions[$FormatType]

    $url = Read-UserInput -Prompt "Enter video URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    $urlType = Get-UrlType $url
    if ($urlType -eq 'Playlist' -or $urlType -eq 'PlaylistVideo') {
        Write-Color "  This looks like a playlist URL." $Script:Colors.Info
        if (-not (Show-Confirmation "Download as single video (ignore playlist)?")) {
            Start-PlaylistDownload -Url $url -FormatType $FormatType
            return
        }
    }

    $formatArgs = Get-VideoFormatArgs -FormatType $FormatType
    $extraArgs = @('--no-playlist') + $formatArgs

    Invoke-Download -Url $url -Type 'video' -ExtraArgs $extraArgs `
        -OutputDir $Script:DownloadDirs.Videos -Description $descriptions[$FormatType]

    Wait-User
}

#endregion

# ===============================================================================
#  AUDIO DOWNLOADS
# ===============================================================================
#region AudioDownloads

function Start-AudioDownload {
    param(
        [ValidateSet('mp3','flac','wav','m4a','aac','opus','vorbis')]
        [string]$Format = 'mp3'
    )
    Clear-Screen
    Show-SectionHeader "$($Format.ToUpper()) Audio Download"

    $url = Read-UserInput -Prompt "Enter video/audio URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    $quality = Get-Setting 'Audio' 'PreferredQuality'
    if ([string]::IsNullOrEmpty($quality)) { $quality = '320' }

    $extraArgs = @(
        '--no-playlist'
        '-x'
        '--audio-format', $Format
        '--audio-quality', "${quality}K"
    )

    Invoke-Download -Url $url -Type 'audio' -ExtraArgs $extraArgs `
        -OutputDir $Script:DownloadDirs.Music -Description "$Format audio"

    Wait-User
}

#endregion

# ===============================================================================
#  PLAYLIST DOWNLOADS
# ===============================================================================
#region PlaylistDownloads

function Start-PlaylistDownload {
    param(
        [string]$Url = '',
        [string]$FormatType = ''
    )
    Clear-Screen
    Show-SectionHeader "Playlist Download"

    if ([string]::IsNullOrEmpty($Url)) {
        $Url = Read-UserInput -Prompt "Enter playlist URL" -Required -IsUrl
        if ($null -eq $Url) { Wait-User; return }
    }

    $plInfo = Get-PlaylistInfo -Url $Url
    if ($null -eq $plInfo) {
        Show-Error -CustomMessage "Could not retrieve playlist information."
        Wait-User
        return
    }

    Write-Host ""
    Write-Color "  Playlist: $($plInfo.Title)" $Script:Colors.Heading
    Write-Color "  Videos:   $($plInfo.VideoCount)" $Script:Colors.Value
    Write-Host ""

    Write-Host "   1. Download entire playlist"
    Write-Host "   2. Download specific range (e.g., 1-10)"
    Write-Host "   3. Download single video by index"
    Write-Host "   0. Cancel"

    $choice = Read-UserChoice -Prompt "Select option" -Max 3 -AllowZero
    if ($choice -eq '0' -or $null -eq $choice) { return }

    if ([string]::IsNullOrEmpty($FormatType)) {
        Write-Host ""
        Write-Host "   1. Best quality"
        Write-Host "   2. 1080p"
        Write-Host "   3. 720p"
        Write-Host "   4. Audio only (MP3)"

        $fmtChoice = Read-UserChoice -Prompt "Select format" -Max 4
        $FormatType = switch ($fmtChoice) {
            '1' { 'best' }
            '2' { '1080p' }
            '3' { '720p' }
            '4' { 'audio' }
            default { 'best' }
        }
    }

    if ($FormatType -eq 'audio') {
        $extraArgs = @('-x', '--audio-format', 'mp3', '--audio-quality', '320K', '--yes-playlist')
    } else {
        $formatArgs = Get-VideoFormatArgs -FormatType $FormatType
        $extraArgs = @('--yes-playlist') + $formatArgs
    }

    $playlistTemplate = Join-Path $Script:DownloadDirs.Playlists '%(playlist_title)s/%(playlist_index)03d - %(title)s.%(ext)s'
    $extraArgs += @('-o', $playlistTemplate)

    switch ($choice) {
        '2' {
            $range = Read-UserInput -Prompt "Enter range (e.g., 1-10 or 1,3,5)" -Required
            if ($null -eq $range) { Wait-User; return }
            $extraArgs += @('--playlist-items', $range)
        }
        '3' {
            $index = Read-UserInput -Prompt "Enter video number" -Required
            if ($null -eq $index) { Wait-User; return }
            $extraArgs += @('--playlist-items', $index)
        }
    }

    $commonArgs = Get-CommonArgs -OutputDir $Script:DownloadDirs.Playlists
    $filteredCommon = [System.Collections.ArrayList]@()
    $skipNext = $false
    foreach ($arg in $commonArgs) {
        if ($skipNext) { $skipNext = $false; continue }
        if ($arg -eq '-o') { $skipNext = $true; continue }
        [void]$filteredCommon.Add($arg)
    }

    $allArgs = $filteredCommon.ToArray() + $extraArgs

    Write-Host ""
    Write-Status "Starting playlist download..." -Type Working

    $result = Invoke-YtDlp -Arguments $allArgs -Title $plInfo.Title -Url $Url

    if ($result.Success) {
        Write-Host ""
        Write-Status "Playlist download complete: $($plInfo.Title)" -Type Success
        Add-HistoryEntry -Url $Url -Title "Playlist: $($plInfo.Title)" -Website '' `
            -OutputDir $Script:DownloadDirs.Playlists -Duration '' -Status 'Success'
    } else {
        Write-Host ""
        Show-Error -RawError $result.Error
        Add-HistoryEntry -Url $Url -Title "Playlist: $($plInfo.Title)" -Website '' `
            -OutputDir $Script:DownloadDirs.Playlists -Duration '' -Status 'Failed'
    }

    Wait-User
}

#endregion

# ===============================================================================
#  LIVESTREAM DOWNLOADS
# ===============================================================================
#region LivestreamDownloads

function Start-LivestreamDownload {
    Clear-Screen
    Show-SectionHeader "Livestream Download"

    $url = Read-UserInput -Prompt "Enter livestream URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    $info = Get-MediaInfo $url
    if ($info.Error) {
        Show-Error -RawError $info.Error
        Wait-User
        return
    }

    if ($info.IsLive) {
        Write-Color "  This is a LIVE stream." $Script:Colors.Success
        Write-Color "  The download will record until you press Ctrl+C or the stream ends." $Script:Colors.Info
    } elseif ($info.IsUpcoming) {
        Write-Color "  This stream has not started yet." $Script:Colors.Warning
        Write-Color "  You can wait for it to begin or try again later." $Script:Colors.Info
        if (-not (Show-Confirmation "Wait for stream to start?")) {
            Wait-User
            return
        }
    } elseif ($info.WasLive) {
        Write-Color "  This is an archived livestream." $Script:Colors.Info
    }

    Show-MediaInfoCard $info

    if (-not (Show-Confirmation "Download this livestream?")) {
        Wait-User
        return
    }

    $extraArgs = @(
        '--no-playlist'
        '-f', 'bv*+ba/b'
        '--merge-output-format', 'mkv'
    )

    if ($info.IsLive) {
        $extraArgs += @('--live-from-start')
    }

    $commonArgs = Get-CommonArgs -OutputDir $Script:DownloadDirs.Livestreams
    $allArgs = $commonArgs.ToArray() + $extraArgs

    Write-Host ""
    if ($info.IsLive) {
        Write-Status "Recording livestream... Press Ctrl+C to stop." -Type Working
    }

    $result = Invoke-YtDlp -Arguments $allArgs -Title $info.Title -Url $url

    if ($result.Success) {
        Write-Status "Livestream download complete: $($info.Title)" -Type Success
    } else {
        Show-Error -RawError $result.Error
    }

    Add-HistoryEntry -Url $url -Title $info.Title -Website $info.Website `
        -OutputDir $Script:DownloadDirs.Livestreams -Duration $info.Duration `
        -Status $(if ($result.Success) { 'Success' } else { 'Failed' })

    Wait-User
}

#endregion

# ===============================================================================
#  SUBTITLE DOWNLOADS
# ===============================================================================
#region SubtitleDownloads

function Start-SubtitleDownload {
    Clear-Screen
    Show-SectionHeader "Download Subtitles"

    $url = Read-UserInput -Prompt "Enter video URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    Write-Host ""
    Write-Host "   1. English subtitles"
    Write-Host "   2. All available languages"
    Write-Host "   3. Auto-generated subtitles (English)"
    Write-Host "   4. Auto-generated subtitles (all languages)"
    Write-Host "   5. Specific language code (e.g., fr, de, ja)"
    Write-Host "   0. Cancel"

    $choice = Read-UserChoice -Prompt "Select option" -Max 5 -AllowZero
    if ($choice -eq '0' -or $null -eq $choice) { return }

    $extraArgs = @('--no-playlist', '--skip-download', '--write-subs')

    switch ($choice) {
        '1' { $extraArgs += @('--sub-langs', 'en') }
        '2' { $extraArgs += @('--sub-langs', 'all') }
        '3' { $extraArgs += @('--write-auto-subs', '--sub-langs', 'en') }
        '4' { $extraArgs += @('--write-auto-subs', '--sub-langs', 'all') }
        '5' {
            $lang = Read-UserInput -Prompt "Enter language code (e.g., fr, de, ja)" -Required
            if ($null -eq $lang) { Wait-User; return }
            $extraArgs += @('--sub-langs', $lang)
        }
    }

    $extraArgs += @('--convert-subs', 'srt')

    $commonArgs = Get-CommonArgs -OutputDir $Script:DownloadDirs.Subtitles -NoArchive
    $allArgs = $commonArgs.ToArray() + $extraArgs

    Write-Status "Downloading subtitles..." -Type Working
    $result = Invoke-YtDlp -Arguments $allArgs -Title 'Subtitles' -Url $url

    if ($result.Success) {
        Write-Status "Subtitles downloaded successfully" -Type Success
    } else {
        Show-Error -RawError $result.Error
    }

    Wait-User
}

#endregion

# ===============================================================================
#  THUMBNAIL DOWNLOADS
# ===============================================================================
#region ThumbnailDownloads

function Start-ThumbnailDownload {
    Clear-Screen
    Show-SectionHeader "Download Thumbnail"

    $url = Read-UserInput -Prompt "Enter video URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    Write-Host ""
    Write-Host "   1. Download thumbnail only"
    Write-Host "   2. Download video and embed thumbnail"
    Write-Host "   3. Both (download thumbnail file + embed in video)"
    Write-Host "   0. Cancel"

    $choice = Read-UserChoice -Prompt "Select option" -Max 3 -AllowZero
    if ($choice -eq '0' -or $null -eq $choice) { return }

    $outputDir = $Script:DownloadDirs.Videos

    switch ($choice) {
        '1' {
            $extraArgs = @('--no-playlist', '--skip-download', '--write-thumbnail', '--convert-thumbnails', 'png')
            $outputDir = $Script:DownloadDirs.Metadata
        }
        '2' {
            $extraArgs = @('--no-playlist', '-f', 'bv*+ba/b', '--embed-thumbnail')
        }
        '3' {
            $extraArgs = @('--no-playlist', '-f', 'bv*+ba/b', '--write-thumbnail', '--embed-thumbnail', '--convert-thumbnails', 'png')
        }
    }

    $commonArgs = Get-CommonArgs -OutputDir $outputDir -NoArchive
    $allArgs = $commonArgs.ToArray() + $extraArgs

    Write-Status "Processing thumbnail request..." -Type Working
    $result = Invoke-YtDlp -Arguments $allArgs -Title 'Thumbnail' -Url $url

    if ($result.Success) {
        Write-Status "Thumbnail operation completed successfully" -Type Success
    } else {
        Show-Error -RawError $result.Error
    }

    Wait-User
}

#endregion

# ===============================================================================
#  METADATA DOWNLOADS
# ===============================================================================
#region MetadataDownloads

function Start-MetadataDownload {
    Clear-Screen
    Show-SectionHeader "Download Metadata"

    $url = Read-UserInput -Prompt "Enter video URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    Write-Host ""
    Write-Host "   1. Info JSON (full metadata)"
    Write-Host "   2. Description"
    Write-Host "   3. Comments"
    Write-Host "   4. Chapters"
    Write-Host "   5. All metadata"
    Write-Host "   0. Cancel"

    $choice = Read-UserChoice -Prompt "Select option" -Max 5 -AllowZero
    if ($choice -eq '0' -or $null -eq $choice) { return }

    $extraArgs = @('--no-playlist', '--skip-download')

    switch ($choice) {
        '1' { $extraArgs += @('--write-info-json') }
        '2' { $extraArgs += @('--write-description') }
        '3' { $extraArgs += @('--write-comments') }
        '4' { $extraArgs += @('--write-info-json') }
        '5' { $extraArgs += @('--write-info-json', '--write-description', '--write-comments', '--write-thumbnail', '--write-subs', '--sub-langs', 'all') }
    }

    $commonArgs = Get-CommonArgs -OutputDir $Script:DownloadDirs.Metadata -NoArchive
    $allArgs = $commonArgs.ToArray() + $extraArgs

    Write-Status "Downloading metadata..." -Type Working
    $result = Invoke-YtDlp -Arguments $allArgs -Title 'Metadata' -Url $url

    if ($result.Success) {
        Write-Status "Metadata downloaded successfully" -Type Success
        if ($choice -eq '4') {
            Write-Color "  Chapters can be found in the .info.json file." $Script:Colors.Info
        }
    } else {
        Show-Error -RawError $result.Error
    }

    Wait-User
}

#endregion

# ===============================================================================
#  SPONSORBLOCK DOWNLOADS
# ===============================================================================
#region SponsorBlock

function Start-SponsorBlockDownload {
    Clear-Screen
    Show-SectionHeader "SponsorBlock Download"

    $url = Read-UserInput -Prompt "Enter video URL" -Required -IsUrl
    if ($null -eq $url) { Wait-User; return }

    Write-Host ""
    Write-Color "  Select categories to remove:" $Script:Colors.Heading
    Write-Host ""
    Write-Host "   1. Sponsors only"
    Write-Host "   2. Intros + Outros"
    Write-Host "   3. Self promotion"
    Write-Host "   4. Interaction reminders"
    Write-Host "   5. Preview / Recap sections"
    Write-Host "   6. All categories"
    Write-Host "   7. Custom selection"
    Write-Host "   0. Cancel"

    $choice = Read-UserChoice -Prompt "Select option" -Max 7 -AllowZero
    if ($choice -eq '0' -or $null -eq $choice) { return }

    $categories = switch ($choice) {
        '1' { 'sponsor' }
        '2' { 'intro,outro' }
        '3' { 'selfpromo' }
        '4' { 'interaction' }
        '5' { 'preview' }
        '6' { 'all' }
        '7' {
            Write-Host ""
            Write-Color "  Available categories:" $Script:Colors.Heading
            $catKeys = @($Script:SponsorBlockCategories.Keys)
            for ($i = 0; $i -lt $catKeys.Count; $i++) {
                Write-Host "   $($i + 1). $($Script:SponsorBlockCategories[$catKeys[$i]])"
            }
            Write-Host ""
            $selection = Read-UserInput -Prompt "Enter numbers separated by commas (e.g., 1,2,5)" -Required
            if ($null -eq $selection) { Wait-User; return }
            $selectedCats = @()
            foreach ($num in ($selection -split ',')) {
                $idx = [int]$num.Trim() - 1
                if ($idx -ge 0 -and $idx -lt $catKeys.Count) {
                    $selectedCats += $catKeys[$idx]
                }
            }
            $selectedCats -join ','
        }
    }

    $extraArgs = @(
        '--no-playlist'
        '-f', 'bv*+ba/b'
        '--merge-output-format', 'mp4'
        '--sponsorblock-remove', $categories
    )

    Invoke-Download -Url $url -Type 'video (SponsorBlock)' -ExtraArgs $extraArgs `
        -OutputDir $Script:DownloadDirs.Videos -Description 'SponsorBlock download'

    Wait-User
}

#endregion

# ===============================================================================
#  BATCH DOWNLOADS
# ===============================================================================
#region BatchDownloads

function Start-BatchDownload {
    Clear-Screen
    Show-SectionHeader "Batch Download"

    Write-Color "  Enter URLs one per line." $Script:Colors.Info
    Write-Color "  Enter a blank line when done." $Script:Colors.Muted
    Write-Host ""

    $urls = [System.Collections.ArrayList]@()
    $lineNum = 1
    while ($true) {
        Write-Color "  [$lineNum] " $Script:Colors.Muted -NoNewline
        $line = Read-Host
        if ([string]::IsNullOrWhiteSpace($line)) { break }
        if (Test-UrlValid $line.Trim()) {
            [void]$urls.Add($line.Trim())
            $lineNum++
        } else {
            Write-Color "  Invalid URL, skipped." $Script:Colors.Warning
        }
    }

    if ($urls.Count -eq 0) {
        Write-Status "No valid URLs entered." -Type Warning
        Wait-User
        return
    }

    Write-Host ""
    Write-Color "  $($urls.Count) URL(s) queued for download." $Script:Colors.Heading

    Write-Host ""
    Write-Host "   1. Best video quality"
    Write-Host "   2. 1080p video"
    Write-Host "   3. 720p video"
    Write-Host "   4. MP3 audio"
    Write-Host "   5. FLAC audio"
    Write-Host "   0. Cancel"

    $fmtChoice = Read-UserChoice -Prompt "Select format for all" -Max 5 -AllowZero
    if ($fmtChoice -eq '0' -or $null -eq $fmtChoice) { return }

    $extraArgs = switch ($fmtChoice) {
        '1' { @('-f', 'bv*+ba/b', '--merge-output-format', 'mkv') }
        '2' { @('-f', 'bv*[height<=1080]+ba/b[height<=1080]', '--merge-output-format', 'mp4') }
        '3' { @('-f', 'bv*[height<=720]+ba/b[height<=720]', '--merge-output-format', 'mp4') }
        '4' { @('-x', '--audio-format', 'mp3', '--audio-quality', '320K') }
        '5' { @('-x', '--audio-format', 'flac') }
    }

    $outputDir = if ($fmtChoice -eq '4' -or $fmtChoice -eq '5') { $Script:DownloadDirs.Music } else { $Script:DownloadDirs.Videos }
    $successCount = 0
    $failCount = 0

    if (-not (Show-Confirmation "Start downloading $($urls.Count) files?")) { return }

    for ($i = 0; $i -lt $urls.Count; $i++) {
        $url = $urls[$i]
        Write-Host ""
        Write-Color "  [$($i + 1)/$($urls.Count)] $url" $Script:Colors.Heading

        $allExtraArgs = @('--no-playlist') + $extraArgs
        $result = Invoke-Download -Url $url -Type 'batch item' -ExtraArgs $allExtraArgs `
            -OutputDir $outputDir -Description "Batch $($i+1)" -SkipConfirm

        if ($result) { $successCount++ } else { $failCount++ }
    }

    Write-Host ""
    Write-Color "  Batch download complete!" $Script:Colors.Heading
    Write-Status "$successCount succeeded, $failCount failed out of $($urls.Count) total" -Type $(if ($failCount -eq 0) { 'Success' } else { 'Warning' })

    Wait-User
}

#endregion

# ===============================================================================
#  FILE CONVERSION
# ===============================================================================
#region Conversion

function Start-FileConversion {
    Clear-Screen
    Show-SectionHeader "Convert Existing File"

    $inputPath = Read-UserInput -Prompt "Enter path to the file" -Required
    if ($null -eq $inputPath) { Wait-User; return }

    if (-not [System.IO.Path]::IsPathRooted($inputPath)) {
        $inputPath = Join-Path $Script:ToolkitRoot $inputPath
    }

    if (-not (Test-Path $inputPath)) {
        Show-Error -CustomMessage "File not found: $inputPath"
        Wait-User
        return
    }

    if (-not (Test-Path $Script:FFmpegPath)) {
        Show-Error -CustomMessage "FFmpeg is required for conversion. Install it from the Maintenance menu."
        Wait-User
        return
    }

    $ext = [System.IO.Path]::GetExtension($inputPath).ToLower()
    Write-Color "  Source file: $(Split-Path $inputPath -Leaf)" $Script:Colors.Value
    Write-Color "  Format:      $ext" $Script:Colors.Muted

    Write-Host ""
    Write-Color "  Convert to:" $Script:Colors.Heading
    Write-Host "   1. MP4 (video)"
    Write-Host "   2. MKV (video)"
    Write-Host "   3. AVI (video)"
    Write-Host "   4. MP3 (audio)"
    Write-Host "   5. FLAC (audio)"
    Write-Host "   6. WAV (audio)"
    Write-Host "   7. M4A (audio)"
    Write-Host "   8. AAC (audio)"
    Write-Host "   0. Cancel"

    $choice = Read-UserChoice -Prompt "Select format" -Max 8 -AllowZero
    if ($choice -eq '0' -or $null -eq $choice) { return }

    $outputExt = switch ($choice) {
        '1' { '.mp4' }
        '2' { '.mkv' }
        '3' { '.avi' }
        '4' { '.mp3' }
        '5' { '.flac' }
        '6' { '.wav' }
        '7' { '.m4a' }
        '8' { '.aac' }
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
    $outputDir = [System.IO.Path]::GetDirectoryName($inputPath)
    $outputPath = Join-Path $outputDir "$baseName$outputExt"

    if (Test-Path $outputPath) {
        $action = Test-OutputFile -FilePath $outputPath
        switch ($action) {
            'skip'   { return }
            'cancel' { return }
            'rename' {
                $counter = 1
                while (Test-Path $outputPath) {
                    $outputPath = Join-Path $outputDir "${baseName}_$counter$outputExt"
                    $counter++
                }
            }
        }
    }

    Write-Status "Converting to $outputExt..." -Type Working

    $ffmpegErrFile = Join-Path $Script:TempDir 'ffmpeg_err.txt'
    $ffmpegArgs = @('-i', $inputPath, '-y', $outputPath)
    try {
        $proc = Start-Process -FilePath $Script:FFmpegPath -ArgumentList $ffmpegArgs `
            -NoNewWindow -PassThru -Wait -RedirectStandardError $ffmpegErrFile

        if ($proc.ExitCode -eq 0) {
            Write-Status "Conversion complete: $(Split-Path $outputPath -Leaf)" -Type Success
        } else {
            $errContent = Get-Content $ffmpegErrFile -Raw -ErrorAction SilentlyContinue
            Show-Error -RawError $errContent -CustomMessage "Conversion failed"
        }
    } catch {
        Show-Error -CustomMessage "FFmpeg error: $($_.Exception.Message)"
    }

    Remove-Item $ffmpegErrFile -Force -ErrorAction SilentlyContinue
    Wait-User
}

#endregion

# ===============================================================================
#  HISTORY
# ===============================================================================
#region History

function Add-HistoryEntry {
    param(
        [string]$Url = '',
        [string]$Title = '',
        [string]$Website = '',
        [string]$OutputDir = '',
        [string]$FileSize = '',
        [string]$Duration = '',
        [string]$Status = 'Success'
    )
    $date = Get-Date -Format 'yyyy-MM-dd'
    $time = Get-Date -Format 'HH:mm:ss'
    $safeTitle = $Title -replace ',', ';'
    $entry = "$date,$time,$Url,$safeTitle,$Website,$OutputDir,$FileSize,$Duration,$Status"
    try {
        $entry | Out-File -FilePath $Script:HistoryFile -Encoding UTF8 -Append
        Write-Log 'INFO' "History entry added: $Status -- $Title"
    } catch {
        Write-Log 'WARN' "Failed to write history: $($_.Exception.Message)"
    }
}

function Get-History {
    param([int]$Limit = 50)
    if (-not (Test-Path $Script:HistoryFile)) { return @() }
    $lines = Get-Content $Script:HistoryFile -ErrorAction SilentlyContinue | Select-Object -Skip 1
    if ($null -eq $lines -or $lines.Count -eq 0) { return @() }

    $entries = @()
    foreach ($line in ($lines | Select-Object -Last $Limit)) {
        $parts = $line -split ','
        if ($parts.Count -ge 9) {
            $entries += @{
                Date      = $parts[0]
                Time      = $parts[1]
                Url       = $parts[2]
                Title     = $parts[3]
                Website   = $parts[4]
                OutputDir = $parts[5]
                FileSize  = $parts[6]
                Duration  = $parts[7]
                Status    = $parts[8]
            }
        }
    }
    return $entries
}

function Show-History {
    Clear-Screen
    Show-SectionHeader "Download History"

    $entries = Get-History -Limit 30
    if ($entries.Count -eq 0) {
        Write-Color "  No download history yet." $Script:Colors.Muted
        Wait-User
        return
    }

    Write-Host ""
    $headerFmt = "  {0,-12} {1,-8} {2,-35} {3,-8}" -f 'Date', 'Time', 'Title', 'Status'
    Write-Color $headerFmt $Script:Colors.Heading
    Write-Color "  $('-' * 65)" $Script:Colors.Muted

    [array]::Reverse($entries)
    foreach ($entry in $entries) {
        $title = $entry.Title
        if ($title.Length -gt 33) { $title = $title.Substring(0, 30) + '...' }
        $statusColor = if ($entry.Status -eq 'Success') { $Script:Colors.Success } else { $Script:Colors.Error }

        Write-Host "  " -NoNewline
        Write-Host ("{0,-12}" -f $entry.Date) -ForegroundColor $Script:Colors.Muted -NoNewline
        Write-Host (" {0,-8}" -f $entry.Time) -ForegroundColor $Script:Colors.Muted -NoNewline
        Write-Host (" {0,-35}" -f $title) -ForegroundColor $Script:Colors.Primary -NoNewline
        Write-Host (" {0}" -f $entry.Status) -ForegroundColor $statusColor
    }

    Write-Host ""
    Write-Host "   1. Clear history"
    Write-Host "   0. Back"

    $choice = Read-UserChoice -Prompt "Select option" -Max 1 -AllowZero
    if ($choice -eq '1') {
        if (Show-Confirmation "Clear all download history?" -DefaultNo) {
            $historyHeader = "Date,Time,URL,Title,Website,OutputPath,FileSize,Duration,Status"
            $historyHeader | Out-File -FilePath $Script:HistoryFile -Encoding UTF8 -Force
            Write-Status "History cleared." -Type Success
            Wait-User
        }
    }
}

#endregion

# ===============================================================================
#  CLEANUP
# ===============================================================================
#region Cleanup

function Remove-TempFiles {
    if (-not (Test-Path $Script:TempDir)) { return }
    $items = Get-ChildItem -Path $Script:TempDir -Recurse -ErrorAction SilentlyContinue
    if ($items.Count -gt 0) {
        $items | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log 'INFO' "Cleaned $($items.Count) temporary file(s)."
    }
}

function Remove-PartialDownloads {
    $count = 0
    foreach ($dir in $Script:DownloadDirs.Values) {
        if (Test-Path $dir) {
            Get-ChildItem -Path $dir -Recurse -Filter '*.part' -ErrorAction SilentlyContinue |
                ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                    $count++
                }
        }
    }
    if ($count -gt 0) {
        Write-Log 'INFO' "Removed $count partial download(s)."
    }
    return $count
}

function Invoke-SessionCleanup {
    Write-Log 'INFO' 'Running session cleanup...'
    Remove-TempFiles
    $sessionDuration = (Get-Date) - $Script:SessionStartTime
    Write-Log 'INFO' "Session ended. Duration: $($sessionDuration.ToString('hh\:mm\:ss'))"
}

#endregion

# ===============================================================================
#  RECOVERY
# ===============================================================================
#region Recovery

function Test-UnfinishedDownloads {
    $partFiles = @()
    foreach ($dir in $Script:DownloadDirs.Values) {
        if (Test-Path $dir) {
            $parts = Get-ChildItem -Path $dir -Recurse -Filter '*.part' -ErrorAction SilentlyContinue
            if ($parts) { $partFiles += $parts }
        }
    }

    $tempFiles = @()
    if (Test-Path $Script:TempDir) {
        $tempFiles = Get-ChildItem -Path $Script:TempDir -File -ErrorAction SilentlyContinue
    }

    if ($partFiles.Count -gt 0 -or $tempFiles.Count -gt 0) {
        Write-Status "Found unfinished downloads ($($partFiles.Count) partial, $($tempFiles.Count) temp files)" -Type Warning
        Write-Host ""
        Write-Host "   1. Clean up partial/temporary files"
        Write-Host "   2. View details"
        Write-Host "   3. Ignore"

        $choice = Read-UserChoice -Prompt "Select option" -Max 3
        switch ($choice) {
            '1' {
                $removed = Remove-PartialDownloads
                Remove-TempFiles
                Write-Status "Cleaned up $removed partial file(s) and temporary files" -Type Success
            }
            '2' {
                foreach ($f in $partFiles) {
                    Write-Color "  PARTIAL: $($f.FullName) ($( Format-FileSize $f.Length ))" $Script:Colors.Muted
                }
                foreach ($f in $tempFiles) {
                    Write-Color "  TEMP:    $($f.FullName)" $Script:Colors.Muted
                }
                Wait-User
            }
        }
    }
}

#endregion

# ===============================================================================
#  SETTINGS
# ===============================================================================
#region Settings

function Show-SettingsMenu {
    do {
        Clear-Screen
        Show-SectionHeader "Settings"
        Write-Host ""

        $dlFolder = Get-Setting 'General' 'DownloadFolder'
        $theme    = Get-Setting 'General' 'Theme'
        $autoUp   = Get-Setting 'General' 'AutoUpdate'
        $autoOpen = Get-Setting 'General' 'AutoOpenFolder'
        $retry    = Get-Setting 'General' 'RetryCount'
        $diskWarn = Get-Setting 'General' 'DiskWarningThresholdGB'
        $vCodec   = Get-Setting 'Video'   'PreferredCodec'
        $vRes     = Get-Setting 'Video'   'PreferredResolution'
        $aFmt     = Get-Setting 'Audio'   'PreferredFormat'
        $aQual    = Get-Setting 'Audio'   'PreferredQuality'
        $embedMd  = Get-Setting 'Downloads' 'EmbedMetadata'
        $embedTh  = Get-Setting 'Downloads' 'EmbedThumbnails'
        $archive  = Get-Setting 'Downloads' 'ArchiveMode'
        $fnTpl    = Get-Setting 'Downloads' 'FilenameTemplate'
        $cookies  = Get-Setting 'Network' 'CookieBrowser'
        $proxy    = Get-Setting 'Network' 'Proxy'
        $sbOn     = Get-Setting 'SponsorBlock' 'Enabled'

        Show-MenuItem '1'  "Download Folder"        "[$dlFolder]"
        Show-MenuItem '2'  "Preferred Video Codec"  "[$vCodec]"
        Show-MenuItem '3'  "Preferred Resolution"   "[$vRes]"
        Show-MenuItem '4'  "Audio Format"           "[$aFmt]"
        Show-MenuItem '5'  "Audio Quality"          "[${aQual}K]"
        Show-MenuItem '6'  "Theme"                  "[$theme]"
        Show-MenuItem '7'  "Retry Count"            "[$retry]"
        Show-MenuItem '8'  "Auto Update"            "[$autoUp]"
        Show-MenuItem '9'  "Auto Open Folder"       "[$autoOpen]"
        Show-MenuItem '10' "Embed Metadata"         "[$embedMd]"
        Show-MenuItem '11' "Embed Thumbnails"       "[$embedTh]"
        Show-MenuItem '12' "Archive Mode"           "[$archive]"
        Show-MenuItem '13' "Filename Template"      "[$fnTpl]"
        Show-MenuItem '14' "Browser Cookies"        "[$cookies]"
        Show-MenuItem '15' "Proxy"                  "[$(if($proxy){$proxy}else{'none'})]"
        Show-MenuItem '16' "SponsorBlock"           "[$(if($sbOn -eq 'true'){'On'}else{'Off'})]"
        Show-MenuItem '17' "Disk Warning (GB)"      "[$diskWarn]"
        Write-Host ""
        Show-MenuItem '0'  "Back to Main Menu"

        $choice = Read-UserChoice -Prompt "Select setting" -Max 17 -AllowZero
        if ($null -eq $choice) { continue }

        switch ($choice) {
            '0' { return }
            '1' {
                $newVal = Read-UserInput -Prompt "Enter download folder path (relative or absolute)"
                if ($newVal) { Set-Setting 'General' 'DownloadFolder' $newVal }
            }
            '2' {
                Write-Host ""; Write-Host "   1. best"; Write-Host "   2. h264"; Write-Host "   3. h265"; Write-Host "   4. av1"; Write-Host "   5. vp9"
                $c = Read-UserChoice -Prompt "Select codec" -Max 5
                $codecs = @{ '1'='best'; '2'='h264'; '3'='h265'; '4'='av1'; '5'='vp9' }
                if ($c -and $codecs.ContainsKey($c)) { Set-Setting 'Video' 'PreferredCodec' $codecs[$c] }
            }
            '3' {
                Write-Host ""; Write-Host "   1. best"; Write-Host "   2. 4k"; Write-Host "   3. 1440p"; Write-Host "   4. 1080p"; Write-Host "   5. 720p"
                $c = Read-UserChoice -Prompt "Select resolution" -Max 5
                $resolutions = @{ '1'='best'; '2'='4k'; '3'='1440p'; '4'='1080p'; '5'='720p' }
                if ($c -and $resolutions.ContainsKey($c)) { Set-Setting 'Video' 'PreferredResolution' $resolutions[$c] }
            }
            '4' {
                Write-Host ""; Write-Host "   1. mp3"; Write-Host "   2. flac"; Write-Host "   3. wav"; Write-Host "   4. m4a"; Write-Host "   5. aac"; Write-Host "   6. opus"; Write-Host "   7. vorbis"
                $c = Read-UserChoice -Prompt "Select format" -Max 7
                $formats = @{ '1'='mp3'; '2'='flac'; '3'='wav'; '4'='m4a'; '5'='aac'; '6'='opus'; '7'='vorbis' }
                if ($c -and $formats.ContainsKey($c)) { Set-Setting 'Audio' 'PreferredFormat' $formats[$c] }
            }
            '5' {
                Write-Host ""; Write-Host "   1. 128K"; Write-Host "   2. 192K"; Write-Host "   3. 256K"; Write-Host "   4. 320K (best)"
                $c = Read-UserChoice -Prompt "Select quality" -Max 4
                $qualities = @{ '1'='128'; '2'='192'; '3'='256'; '4'='320' }
                if ($c -and $qualities.ContainsKey($c)) { Set-Setting 'Audio' 'PreferredQuality' $qualities[$c] }
            }
            '6' {
                Write-Host ""
                $themeNames = @($Script:Themes.Keys)
                for ($i = 0; $i -lt $themeNames.Count; $i++) {
                    $marker = if ($themeNames[$i] -eq $theme) { ' (current)' } else { '' }
                    Write-Host "   $($i + 1). $($themeNames[$i])$marker"
                }
                $c = Read-UserChoice -Prompt "Select theme" -Max $themeNames.Count
                if ($c) {
                    $idx = [int]$c - 1
                    if ($idx -ge 0 -and $idx -lt $themeNames.Count) {
                        Set-Setting 'General' 'Theme' $themeNames[$idx]
                        Set-Theme $themeNames[$idx]
                    }
                }
            }
            '7' {
                $newVal = Read-UserInput -Prompt "Enter retry count (1-10)"
                if ($newVal -match '^\d+$' -and [int]$newVal -ge 1 -and [int]$newVal -le 10) {
                    Set-Setting 'General' 'RetryCount' $newVal
                } else { Write-Color "  Invalid value." $Script:Colors.Warning; Wait-User }
            }
            '8'  { Set-Setting 'General' 'AutoUpdate' $(if ($autoUp -eq 'true') {'false'} else {'true'}) }
            '9'  { Set-Setting 'General' 'AutoOpenFolder' $(if ($autoOpen -eq 'true') {'false'} else {'true'}) }
            '10' { Set-Setting 'Downloads' 'EmbedMetadata' $(if ($embedMd -eq 'true') {'false'} else {'true'}) }
            '11' { Set-Setting 'Downloads' 'EmbedThumbnails' $(if ($embedTh -eq 'true') {'false'} else {'true'}) }
            '12' { Set-Setting 'Downloads' 'ArchiveMode' $(if ($archive -eq 'true') {'false'} else {'true'}) }
            '13' {
                Write-Host ""
                Write-Color "  Filename templates use yt-dlp variables:" $Script:Colors.Info
                Write-Host "   1. %(title)s.%(ext)s                    (Title only)"
                Write-Host "   2. %(title)s - %(uploader)s.%(ext)s     (Title + Uploader)"
                Write-Host "   3. %(upload_date)s - %(title)s.%(ext)s  (Date + Title)"
                Write-Host "   4. Custom template"
                $c = Read-UserChoice -Prompt "Select template" -Max 4
                switch ($c) {
                    '1' { Set-Setting 'Downloads' 'FilenameTemplate' '%(title)s.%(ext)s' }
                    '2' { Set-Setting 'Downloads' 'FilenameTemplate' '%(title)s - %(uploader)s.%(ext)s' }
                    '3' { Set-Setting 'Downloads' 'FilenameTemplate' '%(upload_date)s - %(title)s.%(ext)s' }
                    '4' {
                        $tpl = Read-UserInput -Prompt "Enter custom template"
                        if ($tpl) { Set-Setting 'Downloads' 'FilenameTemplate' $tpl }
                    }
                }
            }
            '14' {
                Write-Host ""; Write-Host "   1. none"; Write-Host "   2. chrome"; Write-Host "   3. firefox"; Write-Host "   4. edge"; Write-Host "   5. opera"; Write-Host "   6. brave"
                $c = Read-UserChoice -Prompt "Select browser" -Max 6
                $browsers = @{ '1'='none'; '2'='chrome'; '3'='firefox'; '4'='edge'; '5'='opera'; '6'='brave' }
                if ($c -and $browsers.ContainsKey($c)) { Set-Setting 'Network' 'CookieBrowser' $browsers[$c] }
            }
            '15' {
                $newVal = Read-UserInput -Prompt "Enter proxy URL (e.g., socks5://127.0.0.1:1080) or 'none'"
                if ($newVal -eq 'none') { Set-Setting 'Network' 'Proxy' '' }
                elseif ($newVal) { Set-Setting 'Network' 'Proxy' $newVal }
            }
            '16' { Set-Setting 'SponsorBlock' 'Enabled' $(if ($sbOn -eq 'true') {'false'} else {'true'}) }
            '17' {
                $newVal = Read-UserInput -Prompt "Enter warning threshold in GB (e.g., 2)"
                if ($newVal -match '^\d+\.?\d*$' -and [double]$newVal -gt 0) {
                    Set-Setting 'General' 'DiskWarningThresholdGB' $newVal
                } else { Write-Color "  Invalid value." $Script:Colors.Warning; Wait-User }
            }
        }
    } while ($true)
}

#endregion

# ===============================================================================
#  MAINTENANCE
# ===============================================================================
#region Maintenance

function Show-MaintenanceMenu {
    do {
        Clear-Screen
        Show-SectionHeader "Maintenance"
        Write-Host ""

        Show-MenuItem '1'  "Verify installation"
        Show-MenuItem '2'  "Repair toolkit"
        Show-MenuItem '3'  "Repair configuration"
        Show-MenuItem '4'  "Repair download folders"
        Show-MenuItem '5'  "Reinstall yt-dlp"
        Show-MenuItem '6'  "Reinstall FFmpeg"
        Show-MenuItem '7'  "Clear cache"
        Show-MenuItem '8'  "Delete temporary files"
        Show-MenuItem '9'  "Reset configuration"
        Show-MenuItem '10' "Export diagnostics"
        Show-MenuItem '11' "View logs"
        Show-MenuItem '12' "Check for updates"
        Show-MenuItem '13' "Factory reset"
        Write-Host ""
        Show-MenuItem '0'  "Back to Main Menu"

        $choice = Read-UserChoice -Prompt "Select option" -Max 13 -AllowZero
        if ($null -eq $choice) { continue }

        switch ($choice) {
            '0' { return }
            '1' {
                Clear-Screen
                Show-SectionHeader "Installation Verification"
                Write-Host ""

                if (Test-Path $Script:YtDlpPath) {
                    Write-Status "yt-dlp: $(Get-YtDlpVersion)" -Type Success
                } else {
                    Write-Status "yt-dlp: Not found" -Type Error
                }

                if (Test-Path $Script:FFmpegPath) {
                    Write-Status "FFmpeg: $(Get-FFmpegVersion)" -Type Success
                } else {
                    Write-Status "FFmpeg: Not found" -Type Error
                }

                if (Test-Path $Script:FFprobePath) {
                    Write-Status "FFprobe: Found" -Type Success
                } else {
                    Write-Status "FFprobe: Not found" -Type Error
                }

                if (Test-Path $Script:ConfigFile) {
                    Write-Status "Configuration: Found" -Type Success
                } else {
                    Write-Status "Configuration: Not found" -Type Warning
                }

                $missingDirs = 0
                foreach ($dir in $Script:DownloadDirs.Values) {
                    if (-not (Test-Path $dir)) { $missingDirs++ }
                }
                if ($missingDirs -eq 0) {
                    Write-Status "Download folders: All present ($($Script:DownloadDirs.Count) dirs)" -Type Success
                } else {
                    Write-Status "Download folders: $missingDirs missing" -Type Warning
                }

                if (Test-Path $Script:ArchiveFile) {
                    $count = (Get-Content $Script:ArchiveFile -ErrorAction SilentlyContinue).Count
                    Write-Status "Archive: $count entries" -Type Success
                } else {
                    Write-Status "Archive: Not found" -Type Warning
                }

                Test-DiskSpace | Out-Null
                Wait-User
            }
            '2' {
                Clear-Screen
                Show-SectionHeader "Repair Toolkit"
                Write-Host ""
                Initialize-Folders
                Repair-Config | Out-Null
                if (-not (Test-Path $Script:YtDlpPath) -and -not $Script:IsOffline) { Install-YtDlp }
                if ((-not (Test-Path $Script:FFmpegPath) -or -not (Test-Path $Script:FFprobePath)) -and -not $Script:IsOffline) { Install-FFmpeg }
                Write-Status "Repair complete" -Type Success
                Wait-User
            }
            '3' {
                if (Show-Confirmation "Repair configuration (restores missing defaults)?") {
                    $repaired = Repair-Config
                    if ($repaired) {
                        Write-Status "Configuration repaired" -Type Success
                    } else {
                        Write-Status "Configuration is already valid" -Type Success
                    }
                }
                Wait-User
            }
            '4' {
                Initialize-Folders
                Write-Status "All download folders verified" -Type Success
                Wait-User
            }
            '5' {
                if ($Script:IsOffline) {
                    Write-Status "Internet required to download yt-dlp" -Type Error
                } else {
                    if (Test-Path $Script:YtDlpPath) {
                        Remove-Item $Script:YtDlpPath -Force -ErrorAction SilentlyContinue
                    }
                    Install-YtDlp
                }
                Wait-User
            }
            '6' {
                if ($Script:IsOffline) {
                    Write-Status "Internet required to download FFmpeg" -Type Error
                } else {
                    if (Test-Path $Script:FFmpegDir) {
                        Remove-Item $Script:FFmpegDir -Recurse -Force -ErrorAction SilentlyContinue
                        New-Item -ItemType Directory -Path $Script:FFmpegDir -Force | Out-Null
                    }
                    Install-FFmpeg
                }
                Wait-User
            }
            '7' {
                if (Test-Path $Script:CacheDir) {
                    $cacheItems = Get-ChildItem -Path $Script:CacheDir -Recurse -ErrorAction SilentlyContinue
                    $cacheCount = if ($cacheItems) { $cacheItems.Count } else { 0 }
                    if ($cacheCount -gt 0) {
                        $cacheItems | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        Write-Status "Cleared $cacheCount cached item(s)" -Type Success
                    } else {
                        Write-Status "Cache is already empty" -Type Info
                    }
                }
                Wait-User
            }
            '8' {
                Remove-TempFiles
                Remove-PartialDownloads
                Write-Status "Temporary files cleaned" -Type Success
                Wait-User
            }
            '9' {
                if (Show-Confirmation "Reset all settings to defaults? This cannot be undone." -DefaultNo) {
                    Initialize-Config
                    Read-Config | Out-Null
                    Set-Theme (Get-Setting 'General' 'Theme')
                    Write-Status "Configuration reset to defaults" -Type Success
                }
                Wait-User
            }
            '10' {
                Export-Diagnostics
                Wait-User
            }
            '11' {
                Clear-Screen
                Show-SectionHeader "Session Logs"
                Write-Host ""
                $logs = Get-ChildItem -Path $Script:LogDir -Filter '*.log' -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending | Select-Object -First 10
                if ($logs.Count -eq 0) {
                    Write-Color "  No log files found." $Script:Colors.Muted
                } else {
                    for ($i = 0; $i -lt $logs.Count; $i++) {
                        $size = Format-FileSize $logs[$i].Length
                        Write-Host "   $($i + 1). " -ForegroundColor $Script:Colors.MenuNum -NoNewline
                        Write-Host "$($logs[$i].Name)" -ForegroundColor $Script:Colors.Primary -NoNewline
                        Write-Host "  ($size)" -ForegroundColor $Script:Colors.Muted
                    }
                    Write-Host ""
                    $logChoice = Read-UserInput -Prompt "Enter number to view, or press Enter to go back" -AllowEmpty
                    if ($logChoice -match '^\d+$') {
                        $idx = [int]$logChoice - 1
                        if ($idx -ge 0 -and $idx -lt $logs.Count) {
                            Write-Host ""
                            Get-Content $logs[$idx].FullName -Tail 50 | ForEach-Object {
                                Write-Color "  $_" $Script:Colors.Muted
                            }
                        }
                    }
                }
                Wait-User
            }
            '12' {
                if ($Script:IsOffline) {
                    Write-Status "Internet required to check for updates" -Type Error
                } else {
                    Write-Status "Checking yt-dlp updates..." -Type Working
                    Test-YtDlpUpdate
                    Write-Status "Toolkit self-update: No update server configured (coming soon)" -Type Info
                }
                Wait-User
            }
            '13' {
                Write-Color "`n  WARNING: Factory reset will:" $Script:Colors.Error
                Write-Color "    - Delete all settings" $Script:Colors.Warning
                Write-Color "    - Delete all logs" $Script:Colors.Warning
                Write-Color "    - Delete all cache and temp files" $Script:Colors.Warning
                Write-Color "    - Clear download history" $Script:Colors.Warning
                Write-Color "    - Clear the download archive" $Script:Colors.Warning
                Write-Color "    - It will NOT delete your downloaded files" $Script:Colors.Info

                if (Show-Confirmation "Are you absolutely sure?" -DefaultNo) {
                    if (Show-Confirmation "This CANNOT be undone. Final confirmation?" -DefaultNo) {
                        Initialize-Config

                        Get-ChildItem -Path $Script:LogDir -Filter '*.log' -ErrorAction SilentlyContinue |
                            Remove-Item -Force -ErrorAction SilentlyContinue

                        Remove-TempFiles
                        if (Test-Path $Script:CacheDir) {
                            Get-ChildItem $Script:CacheDir -Recurse -ErrorAction SilentlyContinue |
                                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        }

                        $historyHeader = "Date,Time,URL,Title,Website,OutputPath,FileSize,Duration,Status"
                        $historyHeader | Out-File -FilePath $Script:HistoryFile -Encoding UTF8 -Force
                        '' | Out-File -FilePath $Script:ArchiveFile -Encoding UTF8 -Force

                        Initialize-Log
                        Read-Config | Out-Null
                        Set-Theme 'Classic'

                        Write-Status "Factory reset complete" -Type Success
                    }
                }
                Wait-User
            }
        }
    } while ($true)
}

#endregion

# ===============================================================================
#  ABOUT SCREEN
# ===============================================================================
#region About

function Show-About {
    Clear-Screen
    $width = 60
    $border = '+' + ('=' * ($width - 2)) + '+'

    Write-Host ""
    Write-Color "  $border" $Script:Colors.Border

    $aboutLines = @(
        ''
        "$Script:AppName"
        "Version $Script:Version"
        ''
        "Author:    $Script:Author"
        "License:   $Script:License"
        "GitHub:    $Script:GitHubUrl"
        ''
        "yt-dlp:    $(Get-YtDlpVersion)"
        "FFmpeg:    $(Get-FFmpegVersion)"
        "PowerShell: $($PSVersionTable.PSVersion)"
        "Windows:   $([Environment]::OSVersion.Version.ToString())"
        ''
        'A free, open-source media download toolkit.'
        'Powered by yt-dlp and FFmpeg.'
        ''
    )

    foreach ($line in $aboutLines) {
        $pad = $width - 4 - $line.Length
        if ($pad -lt 0) { $pad = 0 }
        $left = [math]::Floor($pad / 2)
        $right = [math]::Ceiling($pad / 2)
        Write-Color "  |$(' ' * $left)$line$(' ' * $right)|" $Script:Colors.Border
    }

    Write-Color "  $border" $Script:Colors.Border

    Wait-User
}

#endregion

# ===============================================================================
#  MAIN MENU & ENTRY POINT
# ===============================================================================
#region Main

function Show-MainMenu {
    Show-SectionHeader "Main Menu"
    Write-Host ""

    Write-Color "  VIDEO" $Script:Colors.Heading
    Show-MenuItem '1'  "Best Quality Video"
    Show-MenuItem '2'  "H.264 Video (Premiere-friendly)"
    Show-MenuItem '3'  "H.265 / HEVC Video"
    Show-MenuItem '4'  "AV1 Video"
    Show-MenuItem '5'  "720p Video"
    Show-MenuItem '6'  "1080p Video"
    Show-MenuItem '7'  "1440p Video"
    Show-MenuItem '8'  "4K Video"
    Write-Host ""

    Write-Color "  AUDIO" $Script:Colors.Heading
    Show-MenuItem '9'  "MP3"
    Show-MenuItem '10' "FLAC"
    Show-MenuItem '11' "WAV"
    Show-MenuItem '12' "M4A"
    Show-MenuItem '13' "OPUS"
    Write-Host ""

    Write-Color "  ADVANCED" $Script:Colors.Heading
    Show-MenuItem '14' "Playlist Download"
    Show-MenuItem '15' "Livestream Download"
    Show-MenuItem '16' "Download Thumbnail"
    Show-MenuItem '17' "Download Subtitles"
    Show-MenuItem '18' "Download Metadata"
    Show-MenuItem '19' "SponsorBlock Download"
    Show-MenuItem '20' "Batch Downloads"
    Write-Host ""

    Write-Color "  TOOLS" $Script:Colors.Heading
    Show-MenuItem '21' "Convert Existing Files"
    Show-MenuItem '22' "Settings"
    Show-MenuItem '23' "Maintenance"
    Show-MenuItem '24' "History"
    Show-MenuItem '25' "Open Download Folder"
    Show-MenuItem '26' "About"
    Show-MenuItem '27' "Exit"
}

function Invoke-MainMenuAction {
    param([string]$Choice)

    switch ($Choice) {
        '1'  { Start-VideoDownload -FormatType 'best' }
        '2'  { Start-VideoDownload -FormatType 'h264' }
        '3'  { Start-VideoDownload -FormatType 'h265' }
        '4'  { Start-VideoDownload -FormatType 'av1' }
        '5'  { Start-VideoDownload -FormatType '720p' }
        '6'  { Start-VideoDownload -FormatType '1080p' }
        '7'  { Start-VideoDownload -FormatType '1440p' }
        '8'  { Start-VideoDownload -FormatType '4k' }
        '9'  { Start-AudioDownload -Format 'mp3' }
        '10' { Start-AudioDownload -Format 'flac' }
        '11' { Start-AudioDownload -Format 'wav' }
        '12' { Start-AudioDownload -Format 'm4a' }
        '13' { Start-AudioDownload -Format 'opus' }
        '14' { Start-PlaylistDownload }
        '15' { Start-LivestreamDownload }
        '16' { Start-ThumbnailDownload }
        '17' { Start-SubtitleDownload }
        '18' { Start-MetadataDownload }
        '19' { Start-SponsorBlockDownload }
        '20' { Start-BatchDownload }
        '21' { Start-FileConversion }
        '22' { Show-SettingsMenu }
        '23' { Show-MaintenanceMenu }
        '24' { Show-History }
        '25' {
            $downloadFolder = Get-Setting 'General' 'DownloadFolder'
            if (-not [System.IO.Path]::IsPathRooted($downloadFolder)) {
                $downloadFolder = Join-Path $Script:ToolkitRoot $downloadFolder
            }
            if (Test-Path $downloadFolder) {
                Start-Process 'explorer.exe' -ArgumentList $downloadFolder
            } else {
                Write-Status "Download folder not found: $downloadFolder" -Type Error
                Wait-User
            }
        }
        '26' { Show-About }
        '27' { return 'exit' }
        default {
            Write-Color "  Invalid option. Please try again." $Script:Colors.Warning
            Start-Sleep -Milliseconds 800
        }
    }
    return 'continue'
}

# ===============================================================================
#  ENTRY POINT
# ===============================================================================

try {
    Initialize-Log
    Write-Log 'INFO' "=== $Script:AppName v$Script:Version starting ==="

    Clear-Screen
    Invoke-StartupSequence

    $running = $true
    while ($running) {
        Clear-Screen
        Show-MainMenu

        $choice = Read-UserChoice -Prompt "Select option" -Max 27
        if ($null -eq $choice) { continue }

        $result = Invoke-MainMenuAction -Choice $choice
        if ($result -eq 'exit') {
            $running = $false
        }
    }

    Write-Host ""
    Write-Color "  Thank you for using $Script:AppName!" $Script:Colors.Accent
    Write-Color "  Goodbye." $Script:Colors.Muted
    Write-Host ""

} catch {
    Write-Log 'ERROR' "Unhandled exception: $($_.Exception.Message)"
    Write-Log 'ERROR' "Stack trace: $($_.ScriptStackTrace)"
    Write-Host ""
    Write-Host "  An unexpected error occurred:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Check the log file for details:" -ForegroundColor Gray
    Write-Host "  $Script:LogFile" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} finally {
    Invoke-SessionCleanup
    Write-Log 'INFO' "=== Session ended ==="
}

#endregion
