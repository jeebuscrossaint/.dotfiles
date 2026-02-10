# Windows Dotfiles Installer

Write-Host "[INFO] Installing Windows dotfiles..." -ForegroundColor Blue

# Directories
$DOTFILES_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$WINDOWS_DIR = Join-Path $DOTFILES_DIR "windows"

# PowerShell profile
$PROFILE_SOURCE = Join-Path $WINDOWS_DIR "Microsoft.PowerShell_profile.ps1"
$PROFILE_DIR = Join-Path $env:USERPROFILE "Documents\PowerShell"
$PROFILE_TARGET = Join-Path $PROFILE_DIR "Microsoft.PowerShell_profile.ps1"

# Starship config
$STARSHIP_SOURCE = Join-Path $WINDOWS_DIR "starship.toml"
$CONFIG_DIR = Join-Path $env:USERPROFILE ".config"
$STARSHIP_TARGET = Join-Path $CONFIG_DIR "starship.toml"

# Create directories if needed
if (-not (Test-Path $PROFILE_DIR)) {
    New-Item -ItemType Directory -Path $PROFILE_DIR -Force | Out-Null
}
if (-not (Test-Path $CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
}

# Copy PowerShell profile
if (Test-Path $PROFILE_SOURCE) {
    Copy-Item -Path $PROFILE_SOURCE -Destination $PROFILE_TARGET -Force
    Write-Host "[SUCCESS] Installed PowerShell profile" -ForegroundColor Green
}

# Copy Starship config
if (Test-Path $STARSHIP_SOURCE) {
    Copy-Item -Path $STARSHIP_SOURCE -Destination $STARSHIP_TARGET -Force
    Write-Host "[SUCCESS] Installed Starship config" -ForegroundColor Green
}

Write-Host "[SUCCESS] Done!" -ForegroundColor Green
