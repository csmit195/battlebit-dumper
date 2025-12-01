# Running ApexDumper Sandboxed on Windows

This document outlines several methods to run the BattleBit offset dumper in a sandboxed environment on Windows.

## Option 1: Windows Sandbox (Recommended)

Windows Sandbox is a lightweight, temporary desktop environment that's isolated from your main Windows installation.

### Prerequisites
- Windows 10 Pro/Enterprise/Education (version 1903+) or Windows 11
- Virtualization enabled in BIOS

### Setup Steps

1. **Enable Windows Sandbox:**
   - Open "Turn Windows features on or off"
   - Check "Windows Sandbox"
   - Restart if prompted

2. **Prepare the project:**
   ```powershell
   # Create a directory with everything needed
   mkdir C:\SandboxWork
   # Copy your project there
   xcopy /E /I . C:\SandboxWork\apexdumper
   ```

3. **Create a setup script** (`sandbox-setup.ps1`):
   ```powershell
   # Install Rust (if not already installed in sandbox)
   Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "$env:USERPROFILE\rustup-init.exe"
   & "$env:USERPROFILE\rustup-init.exe" -y
   
   # Add Rust to PATH for current session
   $env:PATH += ";$env:USERPROFILE\.cargo\bin"
   
   # Navigate to project
   cd C:\SandboxWork\apexdumper
   
   # Build and run
   cargo build --release
   ```

4. **Run in Sandbox:**
   - Launch Windows Sandbox from Start menu
   - Copy your project folder into the sandbox
   - Copy the GameAssembly.dll file
   - Run the setup script or manually execute:
     ```powershell
     cargo run --release -- "C:\path\to\GameAssembly.dll" > offsets.ini
     ```

### Advantages
- ✅ Built into Windows
- ✅ Lightweight and fast
- ✅ Completely isolated
- ✅ Automatically cleaned up when closed

### Disadvantages
- ❌ Requires Windows Pro/Enterprise
- ❌ No persistence (everything resets on close)

---

## Option 2: Docker with Windows Containers

### Prerequisites
- Docker Desktop for Windows
- Windows containers enabled (not Linux containers)

### Setup

1. **Switch to Windows containers** in Docker Desktop

2. **Build the image:**
   ```powershell
   docker build -f Dockerfile.windows -t apexdumper:windows .
   ```

3. **Run the container:**
   ```powershell
   # Mount your BattleBit directory
   docker run --rm `
     -v "C:\path\to\battlebit:/data" `
     apexdumper:windows `
     "C:\data\GameAssembly.dll" > offsets.ini
   ```

### Advantages
- ✅ Good isolation
- ✅ Reproducible environment
- ✅ Can version control the environment

### Disadvantages
- ❌ Requires Docker Desktop
- ❌ Windows containers are larger than Linux containers
- ❌ More complex setup

---

## Option 3: Virtual Machine (Hyper-V)

### Prerequisites
- Windows 10 Pro/Enterprise or Windows 11 Pro
- Hyper-V enabled

### Setup Steps

1. **Enable Hyper-V:**
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   ```

2. **Create a VM:**
   - Use Hyper-V Manager
   - Create a new VM with Windows 10/11
   - Allocate sufficient resources (2GB RAM minimum)

3. **Install Rust in the VM:**
   - Download rustup-init.exe
   - Install Rust toolchain

4. **Copy project into VM:**
   - Use shared folders or copy files directly

5. **Build and run:**
   ```powershell
   cargo run --release -- "C:\path\to\GameAssembly.dll" > offsets.ini
   ```

### Advantages
- ✅ Complete isolation
- ✅ Can snapshot/restore state
- ✅ Most secure option

### Disadvantages
- ❌ Heavy resource usage
- ❌ Slower than other options
- ❌ Requires Windows Pro/Enterprise

---

## Option 4: WSL2 (Linux Environment)

If you're comfortable running this in a Linux environment on Windows:

### Prerequisites
- WSL2 installed
- Rust installed in WSL2

### Setup

1. **Install Rust in WSL2:**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Access Windows files from WSL2:**
   ```bash
   # Windows drives are mounted at /mnt/c, /mnt/d, etc.
   cd /mnt/c/path/to/project
   cargo run --release -- "/mnt/c/path/to/GameAssembly.dll" > offsets.ini
   ```

### Advantages
- ✅ Lightweight
- ✅ Good performance
- ✅ Easy to set up

### Disadvantages
- ❌ Running in Linux, not Windows
- ❌ May have compatibility issues with Windows DLLs

---

## Recommended Approach

For most users, **Windows Sandbox** is the best option because:
- It's built into Windows (Pro/Enterprise)
- Provides good isolation
- Easy to use
- Automatically cleans up

If you don't have Windows Pro, consider:
- **Docker** if you have Docker Desktop
- **VM** if you need persistent state
- **WSL2** if Linux compatibility is acceptable

---

## Security Notes

⚠️ **Important:** This tool analyzes game binaries. While sandboxing provides isolation:
- The tool itself reads and parses DLL files
- Make sure you trust the source of GameAssembly.dll
- Consider running in a VM if you're analyzing untrusted binaries
