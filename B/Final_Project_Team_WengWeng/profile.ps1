
# ==========================================
# TEAM WENGWENG - PROGRAMMING LANGUAGES
# Docker + PowerShell Configuration
# ==========================================

# Automatically locate the repository
$global:ProgrammingLanguagesRoot = $PSScriptRoot

# Language configurations
$global:WengLanguages = @(
    @{
        Name      = "Kotlin"
        Service   = "kotlin"
        Folder    = "Kotlin"
        Extension = "kt"
        Color     = "Magenta"
    },
    @{
        Name      = "SIMULA 67"
        Service   = "simula"
        Folder    = "Simula-67"
        Extension = "sim"
        Color     = "Yellow"
    }
)

# Track automatically generated commands
if ($null -eq $global:WengGeneratedCommands) {
    $global:WengGeneratedCommands = @()
}

# ==========================================
# CORE DOCKER RUNNER
# ==========================================

function Invoke-LanguageProgram {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("kotlin", "simula")]
        [string]$Language,

        [string]$Name
    )

    # Check if Docker is installed
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Docker is not installed." -ForegroundColor Red
        return
    }

    # Check if Docker is running
    docker info --format '{{.OSType}}' 2>$null | Out-Null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Please start Docker Desktop first." -ForegroundColor Red
        return
    }

    Push-Location $global:ProgrammingLanguagesRoot

    try {
        # Interactive program selection
        if ([string]::IsNullOrWhiteSpace($Name)) {
            docker compose run --rm $Language --list

            if ($LASTEXITCODE -ne 0) {
                return
            }

            $Name = Read-Host "Enter program name"
        }

        if ([string]::IsNullOrWhiteSpace($Name)) {
            return
        }

        # Validate program name
        if ($Name -notmatch '^[a-zA-Z0-9_-]+$') {
            Write-Host "Invalid program name." -ForegroundColor Red
            return
        }

        # Compile and execute the program
        docker compose run --rm $Language $Name

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Program execution failed." -ForegroundColor Red
        }
    }
    finally {
        Pop-Location
    }
}

# ==========================================
# GENERAL LANGUAGE COMMANDS
# ==========================================

function kweng {
    param([string]$Name)

    Invoke-LanguageProgram -Language kotlin -Name $Name
}

function sweng {
    param([string]$Name)

    Invoke-LanguageProgram -Language simula -Name $Name
}

# ==========================================
# SOURCE FILE SCANNER
# ==========================================

function Get-WengPrograms {
    param (
        [hashtable]$Config
    )

    $Root = Join-Path `
        $global:ProgrammingLanguagesRoot `
        $Config.Folder

    if (-not (Test-Path -LiteralPath $Root)) {
        Write-Warning "Folder not found: $($Config.Folder)"
        return
    }

    # Recursively scan all source files
    $Files = Get-ChildItem `
        -LiteralPath $Root `
        -Recurse `
        -File `
        -Filter "*.$($Config.Extension)"

    foreach ($File in $Files) {

        # Determine the relative folder
        $RelativeFolder = $File.DirectoryName.Substring(
            $Root.Length
        ).TrimStart('\', '/')

        if ([string]::IsNullOrWhiteSpace($RelativeFolder)) {
            $RelativeFolder = "(Root Folder)"
        }

        [PSCustomObject]@{
            Name     = $File.BaseName
            File     = $File.Name
            Folder   = $RelativeFolder
            Path     = $File.FullName
            Language = $Config.Service
            Command  = "$($Config.Service)-$($File.BaseName)"
            Valid    = ($File.BaseName -cmatch '^[a-zA-Z0-9_-]+$')
        }
    }
}

# ==========================================
# AUTOMATIC COMMAND GENERATION
# ==========================================

function Register-WengCommands {
    param (
        [hashtable]$Config
    )

    $Programs = @(Get-WengPrograms -Config $Config)

    # Detect duplicate filenames
    $Groups = $Programs | Group-Object -Property Name

    foreach ($Group in $Groups) {

        if ($Group.Count -gt 1) {
            Write-Warning "Duplicate filename: $($Group.Name)"

            foreach ($Program in $Group.Group) {
                Write-Host "  $($Program.Path)" `
                    -ForegroundColor DarkYellow
            }

            continue
        }

        $Program = $Group.Group[0]

        # Skip invalid filenames
        if (-not $Program.Valid) {
            Write-Warning "Invalid filename: $($Program.File)"
            continue
        }

        $CommandName = $Program.Command
        $Language = $Program.Language
        $Name = $Program.Name

        # Generate the function body
        $ScriptBlock = [ScriptBlock]::Create(
            "Invoke-LanguageProgram -Language '$Language' -Name '$Name'"
        )

        # Check for existing commands
        $Existing = Get-Command `
            -Name $CommandName `
            -ErrorAction SilentlyContinue

        if ($Existing) {

            # Allow previously registered Weng commands
            if ($CommandName -in $global:WengGeneratedCommands) {

                if ($Existing.CommandType -ne "Function") {
                    Write-Warning "Command conflict: $CommandName"
                    continue
                }

            }
            # Recover existing generated functions
            elseif (
                $Existing.CommandType -eq "Function" -and
                $Existing.Definition.Trim() -eq $ScriptBlock.ToString().Trim()
            ) {
                # Existing function belongs to this runner
            }
            else {
                Write-Warning "Unrelated command already exists: $CommandName"
                continue
            }
        }

        # Create or update the global function
        Set-Item `
            -Path "Function:global:$CommandName" `
            -Value $ScriptBlock `
            -Force `
            -ErrorAction Stop

        # Return the successfully registered command
        $CommandName
    }
}

# ==========================================
# REFRESH GENERATED COMMANDS
# ==========================================

function weng-refresh {
    param (
        [switch]$Quiet
    )

    # Remember previously registered commands
    $PreviousCommands = @($global:WengGeneratedCommands)

    # Register current source files
    $CurrentCommands = @(
        foreach ($Config in $global:WengLanguages) {
            Register-WengCommands -Config $Config
        }
    )

    # Remove commands belonging to deleted or renamed files
    foreach ($CommandName in $PreviousCommands) {

        if ($CommandName -notin $CurrentCommands) {

            $Existing = Get-Command `
                -Name $CommandName `
                -CommandType Function `
                -ErrorAction SilentlyContinue

            if ($Existing) {
                Remove-Item `
                    -LiteralPath "Function:\$CommandName" `
                    -Force `
                    -ErrorAction Stop
            }
        }
    }

    # Update the command registry
    $global:WengGeneratedCommands = @(
        $CurrentCommands | Sort-Object -Unique
    )

    if (-not $Quiet) {
        Write-Host ""
        Write-Host "Language commands refreshed." `
            -ForegroundColor Green

        Write-Host "Available commands: $($global:WengGeneratedCommands.Count)"
        Write-Host "Type weng-help to view all commands."
        Write-Host ""
    }
}

# ==========================================
# BUILD DOCKER IMAGES
# ==========================================

function weng-build {
    Push-Location $global:ProgrammingLanguagesRoot

    try {
        docker compose build
    }
    finally {
        Pop-Location
    }
}

# ==========================================
# VERIFY DOCKER ENVIRONMENTS
# ==========================================

function weng-check {
    Push-Location $global:ProgrammingLanguagesRoot

    try {
        Write-Host "`n===== DOCKER =====" `
            -ForegroundColor Cyan

        docker --version
        docker compose version

        Write-Host "`n===== SERVICES =====" `
            -ForegroundColor Cyan

        docker compose config --services

        Write-Host "`n===== KOTLIN =====" `
            -ForegroundColor Magenta

        docker compose run --rm kotlin --version

        Write-Host "`n===== SIMULA 67 =====" `
            -ForegroundColor Yellow

        docker compose run --rm simula --version
    }
    finally {
        Pop-Location
    }
}

# ==========================================
# LIST SOURCE FILES
# ==========================================

function weng-list {
    Push-Location $global:ProgrammingLanguagesRoot

    try {
        docker compose run --rm kotlin --list
        docker compose run --rm simula --list
    }
    finally {
        Pop-Location
    }
}

# ==========================================
# DYNAMIC HELP MENU
# ==========================================

function weng-help {

    # Automatically refresh available commands
    weng-refresh -Quiet

    Write-Host ""
    Write-Host "==========================================" `
        -ForegroundColor Cyan

    Write-Host "       TEAM WENGWENG - COMMANDS" `
        -ForegroundColor Cyan

    Write-Host "==========================================" `
        -ForegroundColor Cyan

    foreach ($Config in $global:WengLanguages) {

        Write-Host ""
        Write-Host "[$($Config.Name)]" `
            -ForegroundColor $Config.Color

        $Programs = @(Get-WengPrograms -Config $Config)

        if ($Programs.Count -eq 0) {
            Write-Host "  No source files found." `
                -ForegroundColor DarkGray

            continue
        }

        # Group source files by their folders
        $Folders = $Programs |
            Group-Object -Property Folder |
            Sort-Object Name

        foreach ($Folder in $Folders) {

            Write-Host ""
            Write-Host "  $($Folder.Name)/" `
                -ForegroundColor White

            foreach ($Program in ($Folder.Group | Sort-Object Name)) {

                $CommandName = $Program.Command

                if ($CommandName -in $global:WengGeneratedCommands) {

                    Write-Host "    $($Program.File)" `
                        -ForegroundColor DarkGray

                    Write-Host "      > $CommandName" `
                        -ForegroundColor $Config.Color

                }
                else {

                    Write-Host "    $($Program.File) [Unavailable]" `
                        -ForegroundColor Red

                }
            }
        }
    }

    Write-Host ""
    Write-Host "[GENERAL COMMANDS]" `
        -ForegroundColor Cyan

    Write-Host ""
    Write-Host "  kweng [filename]  - Run Kotlin program"
    Write-Host "  sweng [filename]  - Run SIMULA program"

    Write-Host ""
    Write-Host "[DOCKER UTILITIES]" `
        -ForegroundColor Cyan

    Write-Host ""
    Write-Host "  weng-build    - Build Docker images"
    Write-Host "  weng-check    - Verify environments"
    Write-Host "  weng-list     - List available programs"
    Write-Host "  weng-refresh  - Rescan and generate commands"
    Write-Host "  weng-help     - Display all commands"

    Write-Host ""
    Write-Host "Total generated commands: $($global:WengGeneratedCommands.Count)" `
        -ForegroundColor Green

    Write-Host ""
    Write-Host "==========================================" `
        -ForegroundColor Cyan

    Write-Host ""
}

# ==========================================
# INITIALIZATION
# ==========================================

# Automatically scan all source files
weng-refresh -Quiet

Write-Host ""
Write-Host "Programming language commands loaded." `
    -ForegroundColor Green

Write-Host "Generated commands: $($global:WengGeneratedCommands.Count)"

Write-Host "Type weng-help to view available commands."
Write-Host ""