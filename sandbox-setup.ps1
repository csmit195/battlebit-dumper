# Windows Sandbox Setup Script
# Run this script inside Windows Sandbox to set up the environment

Write-Host "Setting up ApexDumper in Windows Sandbox..." -ForegroundColor Green

# Check if Rust is already installed
$rustInstalled = Get-Command cargo -ErrorAction SilentlyContinue

if (-not $rustInstalled) {
    Write-Host "Installing Rust..." -ForegroundColor Yellow
    
    # Download rustup installer
    $rustupPath = "$env:USERPROFILE\rustup-init.exe"
    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $rustupPath -UseBasicParsing
    
    # Install Rust silently
    & $rustupPath -y --default-toolchain stable
    
    # Add to PATH for current session
    $env:PATH += ";$env:USERPROFILE\.cargo\bin"
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Rust installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Rust is already installed." -ForegroundColor Green
}

# Verify installation
$cargoVersion = cargo --version
Write-Host "Cargo version: $cargoVersion" -ForegroundColor Cyan

# Check if we're in the project directory
if (Test-Path "Cargo.toml") {
    Write-Host "Found Cargo.toml, building project..." -ForegroundColor Yellow
    cargo build --release
    Write-Host "Build complete! You can now run:" -ForegroundColor Green
    Write-Host '  cargo run --release -- "C:\path\to\GameAssembly.dll" > offsets.ini' -ForegroundColor Cyan
} else {
    Write-Host "Cargo.toml not found in current directory." -ForegroundColor Yellow
    Write-Host "Please navigate to the project directory first." -ForegroundColor Yellow
    Write-Host "Example: cd C:\Users\WDAGUtilityAccount\Desktop\apexdumper" -ForegroundColor Cyan
}

Write-Host "`nSetup complete!" -ForegroundColor Green
