
<div align="center">

# SIMULA 67

### Installation & Development Guide

A comprehensive guide to setting up SIMULA 67 on Windows
using Ubuntu WSL and the GNU Cim compiler.

![Language](https://img.shields.io/badge/Language-SIMULA_67-7C3AED?style=for-the-badge)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![WSL](https://img.shields.io/badge/Environment-WSL2-0078D4?style=for-the-badge)
![Compiler](https://img.shields.io/badge/Compiler-GNU_Cim-A42E2B?style=for-the-badge&logo=gnu&logoColor=white)

[Overview](#overview) ·
[Prerequisites](#prerequisites) ·
[Installation](#installation) ·
[Usage](#usage) ·
[Troubleshooting](#troubleshooting)

</div>

---

## Overview

SIMULA 67 is a pioneering programming language that
introduced fundamental concepts of object-oriented
programming, including classes, objects, and inheritance.

This guide provides a complete walkthrough for installing
and configuring GNU Cim, allowing users to write, compile,
and execute SIMULA 67 programs on Windows through the
Windows Subsystem for Linux (WSL).

### Compilation Process

```mermaid
flowchart LR
    A["SIMULA Source (.sim)"] --> B["GNU Cim"]
    B --> C["Generated C Code"]
    C --> D["GCC Compiler"]
    D --> E["Executable"]
    E --> F["Program Output"]
```

GNU Cim translates SIMULA source code into C, which is
then compiled and linked using GCC to produce an executable
Linux program.

---

## Prerequisites

Before proceeding, ensure that you have:

- Windows 10 or Windows 11 with WSL2 support
- Administrator privileges
- Hardware virtualization enabled
- A stable internet connection
- Sufficient storage space
- A text editor such as Nano or Visual Studio Code

---

## Installation

### 01 — Install Windows Subsystem for Linux

Open **Windows PowerShell as Administrator** and run:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart your computer if prompted.

After restarting, launch Ubuntu:

```powershell
wsl -d Ubuntu-24.04
```

During the initial setup, Ubuntu will ask you to create
a Linux username and password.

You may choose any username and password.

> [!NOTE]
> Your password will not appear on the screen while typing.
> This is normal Linux terminal behavior.

Verify your WSL installation from PowerShell:

```powershell
wsl --list --verbose
```

Expected output:

```text
  NAME            STATE      VERSION
* Ubuntu-24.04    Running    2
```

> [!IMPORTANT]
> Unless stated otherwise, all succeeding installation
> commands must be executed inside the Ubuntu terminal,
> not Windows PowerShell.

### 02 — Update Ubuntu

Update the package repository:

```bash
sudo apt update
```

Upgrade installed packages:

```bash
sudo apt upgrade -y
```

Enter your Linux password if prompted.

### 03 — Install Required Dependencies

Install the development tools required to build
the GNU Cim compiler:

```bash
sudo apt install -y \
    git \
    build-essential \
    cmake \
    bison \
    flex
```

| Dependency | Purpose |
| :--- | :--- |
| Git | Download the compiler source code |
| Build Essential | Provides GCC, G++, Make, and development libraries |
| CMake | Configures the compiler build system |
| Bison | Generates the compiler parser |
| Flex | Generates the lexical analyzer |

Verify that the required tools are installed:

```bash
git --version
gcc --version
cmake --version
bison --version
flex --version
```

### 04 — Download the GNU Cim Compiler

Create a directory for storing the compiler source code:

```bash
mkdir -p ~/simula-setup
cd ~/simula-setup
```

The `~` symbol represents your Linux home directory.

For example, if your Linux username is `student`,
your home directory would be:

```text
/home/student
```

Using `~` makes the commands compatible with any username.

Clone the GNU Cim repository:

```bash
git clone https://github.com/sergev/simula-compiler.git
```

Navigate into the downloaded repository:

```bash
cd simula-compiler
```

Verify the current directory:

```bash
pwd
```

> [!TIP]
> You may use a different directory name or location
> for the compiler source code. If you do, adjust the
> corresponding paths in the succeeding commands.

### 05 — Configure and Build the Compiler

Configure the project using CMake:

```bash
cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="$HOME/.local"
```

Explanation:

| Argument | Purpose |
| :--- | :--- |
| `-S .` | Uses the current directory as the source |
| `-B build` | Creates a separate build directory |
| `CMAKE_INSTALL_PREFIX` | Specifies the installation location |
| `$HOME` | Automatically resolves your Linux home directory |

Build the compiler:

```bash
cmake --build build -j"$(nproc)"
```

The `$(nproc)` command automatically determines the
number of available processor cores.

Install the compiled files:

```bash
cmake --install build
```

The expected installation directories are:

```text
~/.local/
├── bin/
├── include/
└── lib/
```

### 06 — Configure the Environment PATH

Add the compiler installation directory to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

Reload the terminal configuration:

```bash
source ~/.bashrc
```

Verify that GNU Cim is accessible:

```bash
command -v gnucim
```

Expected output:

```text
/home/<your-username>/.local/bin/gnucim
```

The actual output depends on your Linux username.

> [!IMPORTANT]
> The compiler executable is named `gnucim`, not `cim`.

### 07 — Configure Runtime Libraries

GNU Cim may expect its header and runtime libraries
to be available in standard system directories.

First, verify that the installed files exist:

```bash
ls "$HOME/.local/include/cim.h"
ls "$HOME/.local/lib/libcim.a"
ls "$HOME/.local/lib/libcim-atr.a"
```

If any of these files are missing, review the build
and installation process before continuing.

Create the required system directories:

```bash
sudo mkdir -p /usr/local/include
sudo mkdir -p /usr/local/lib
```

Create a symbolic link for the compiler header:

```bash
sudo ln -sfn "$HOME/.local/include/cim.h" \
    /usr/local/include/cim.h
```

Create symbolic links for the runtime libraries:

```bash
sudo ln -sfn "$HOME/.local/lib/libcim.a" \
    /usr/local/lib/libcim.a
```

```bash
sudo ln -sfn "$HOME/.local/lib/libcim-atr.a" \
    /usr/local/lib/libcim-atr.a
```

Symbolic links allow the compiler to access files from
the expected system locations without duplicating them.

Verify the configuration:

```bash
ls -l /usr/local/include/cim.h
ls -l /usr/local/lib/libcim*
```

> [!WARNING]
> If these system locations already contain another
> compiler installation, inspect them before replacing
> any existing files or symbolic links.

### 08 — Choose Your Project Directory

Your SIMULA programs can be stored either inside the
Linux filesystem or directly inside a Windows folder.

Choose whichever option suits your workflow.

#### Option A — Linux Filesystem

Create a project directory inside your Linux home folder:

```bash
mkdir -p ~/simula-projects
cd ~/simula-projects
```

This option generally provides better filesystem
performance when compiling programs inside WSL.

To access the directory through Windows File Explorer:

```bash
explorer.exe .
```

#### Option B — Windows Filesystem

WSL automatically makes Windows drives accessible
through the `/mnt` directory under its default
drive-mount configuration.

| Windows Drive | Ubuntu WSL Path |
| :--- | :--- |
| `C:\` | `/mnt/c/` |
| `D:\` | `/mnt/d/` |
| `E:\` | `/mnt/e/` |

For example, suppose you want to store your SIMULA
programs inside the following Windows directory:

```text
D:\Programming\Simula
```

Its equivalent Ubuntu WSL path would be:

```text
/mnt/d/Programming/Simula
```

Create and navigate to that directory:

```bash
mkdir -p /mnt/d/Programming/Simula
cd /mnt/d/Programming/Simula
```

This example assumes that your computer has a D: drive.
Use whichever drive and folder are available on your
own computer.

If your directory contains spaces, enclose the path
in quotation marks:

```bash
cd "/mnt/c/My Projects/Simula"
```

#### Understanding Path Conversion

To convert a Windows path into a WSL path:

1. Replace the drive letter with `/mnt/` followed
   by the lowercase drive letter.
2. Replace backslashes with forward slashes.
3. Preserve the remaining directory names.

You can also automatically convert a Windows path
using the `wslpath` command:

```bash
wslpath 'C:\Users\YourName\Documents'
```

> [!TIP]
> You are not required to follow the example directory
> names. You may store your programs anywhere you prefer,
> provided you have permission to access that directory.

#### Save Your Chosen Project Location

After navigating to your preferred project directory,
run:

```bash
export SIMULA_PROJECT_DIR="$(pwd)"
```

Verify the selected location:

```bash
echo "$SIMULA_PROJECT_DIR"
```

The succeeding commands will use this variable instead
of a fixed project path.

This variable remains available during the current
terminal session.

### 09 — Configure Compiler Attribute Files

GNU Cim requires attribute files (`.atr`) containing
information about its standard library components.

Copy the required attribute files into your selected
project directory:

```bash
cp "$HOME"/simula-setup/simula-compiler/lib/*.atr \
    "$SIMULA_PROJECT_DIR/"
```

Verify that the files were copied:

```bash
ls "$SIMULA_PROJECT_DIR"/*.atr
```

> [!NOTE]
> If you selected a different compiler source directory
> in Step 04, update the source path accordingly.

### 10 — Configure Runtime Object Files

Some GNU Cim configurations may also require compiled
runtime object files in the working directory.

Locate the required object files:

```bash
find "$HOME/simula-setup/simula-compiler/build" \
    -name 'simfile.c.o' -o -name 'simenvir.c.o'
```

For the expected CMake build directory structure,
copy the files using:

```bash
cp "$HOME/simula-setup/simula-compiler/build/lib/CMakeFiles/cim.dir/simfile.c.o" \
    "$SIMULA_PROJECT_DIR/simfile.o"
```

```bash
cp "$HOME/simula-setup/simula-compiler/build/lib/CMakeFiles/cim.dir/simenvir.c.o" \
    "$SIMULA_PROJECT_DIR/simenvir.o"
```

Verify the copied files:

```bash
ls -l "$SIMULA_PROJECT_DIR"/*.o
```

> [!WARNING]
> The exact build directory structure may vary depending
> on the compiler version. If the example paths do not
> exist, use the actual paths returned by `find`.

### 11 — Verify the Installation

Navigate to your selected project directory:

```bash
cd "$SIMULA_PROJECT_DIR"
```

Create a temporary test file:

```bash
nano test.sim
```

Enter the following SIMULA code:

```simula
BEGIN
    OutText("SIMULA 67 is working!");
    OutImage;
END;
```

Save and exit Nano:

| Shortcut | Action |
| :--- | :--- |
| `Ctrl + O` | Save the file |
| `Enter` | Confirm the filename |
| `Ctrl + X` | Exit Nano |

Compile the program:

```bash
gnucim test.sim
```

Execute the compiled program:

```bash
./test
```

Expected output:

```text
SIMULA 67 is working!
```

If the program executes successfully, your development
environment is ready.

---

## Usage

Once the installation is complete, you do not need
to reinstall the compiler every time you write a program.

### 01 — Launch Ubuntu

Open Windows PowerShell or Windows Terminal:

```powershell
wsl -d Ubuntu-24.04
```

### 02 — Navigate to Your Project Directory

Use the `cd` command to navigate to the directory
where your SIMULA files are stored.

For a Linux directory:

```bash
cd ~/simula-projects
```

For a Windows directory:

```bash
cd "/mnt/c/path/to/your/project"
```

Replace the example path with your actual project location.

Check your current directory:

```bash
pwd
```

List the available files:

```bash
ls
```

### 03 — Create or Edit a SIMULA Program

```bash
nano filename.sim
```

Replace `filename` with your preferred program name.

Use the `.sim` extension for your SIMULA source files.

You may also create and edit your source files using
your preferred text editor.

### 04 — Compile the Program

```bash
gnucim filename.sim
```

GNU Cim compiles the source file and generates
an executable program.

Depending on the compiler configuration, additional
intermediate files may also be generated.

### 05 — Execute the Program

```bash
./filename
```

When executing the program, omit the `.sim` extension.

### Compile and Execute Together

```bash
gnucim filename.sim && ./filename
```

The `&&` operator ensures that the executable only
runs if compilation succeeds.

---

## Troubleshooting

<details>
<summary><b>gnucim: command not found</b></summary>

<br>

The compiler directory may not be included in your PATH.

Run:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Verify:

```bash
command -v gnucim
```

For a permanent configuration, revisit Step 06.

</details>

<details>
<summary><b>Can't read atr-file simenvir.atr</b></summary>

<br>

The compiler cannot locate its attribute files.

Navigate to your project directory and copy the
required files:

```bash
cp "$HOME"/simula-setup/simula-compiler/lib/*.atr .
```

Verify:

```bash
ls *.atr
```

</details>

<details>
<summary><b>cim.h: No such file or directory</b></summary>

<br>

The compiler header may be missing or incorrectly linked.

Verify:

```bash
ls -l /usr/local/include/cim.h
```

Revisit Step 07 to configure the header correctly.

</details>

<details>
<summary><b>cannot find -lcim</b></summary>

<br>

The GCC linker cannot locate the GNU Cim runtime library.

Verify:

```bash
ls -l /usr/local/lib/libcim*
```

Revisit Step 07 to configure the runtime libraries.

</details>

<details>
<summary><b>Cannot find simfile.o or simenvir.o</b></summary>

<br>

The required runtime object files may be missing
from your working directory.

Revisit Step 10 and ensure that the object files
are copied into the correct project directory.

</details>

<details>
<summary><b>Syntax errors during compilation</b></summary>

<br>

Check your SIMULA source code for:

- Missing semicolons
- Incorrect variable declarations
- Missing BEGIN or END statements
- Curly quotation marks instead of straight quotation marks
- Incorrect procedure parameters
- Invalid identifiers

Compilation errors normally indicate the affected
source file and line number.

</details>

<details>
<summary><b>Program cannot be executed</b></summary>

<br>

Verify that compilation completed successfully:

```bash
gnucim filename.sim
```

Check whether the executable exists:

```bash
ls -l filename
```

If execution permission is missing, try:

```bash
chmod +x filename
./filename
```

If permissions cannot be changed on your Windows-mounted
directory, try compiling and executing the program
inside your Linux home directory instead.

Remember that GNU Cim generates Linux executables.
Run them inside Ubuntu WSL, not directly through
Windows PowerShell.

</details>

---

## Resources

| Resource | Link |
| :--- | :--- |
| GNU Cim Compiler | [GitHub Repository](https://github.com/sergev/simula-compiler) |
| Windows Subsystem for Linux | [Microsoft Documentation](https://learn.microsoft.com/en-us/windows/wsl/) |
| Ubuntu | [Official Documentation](https://documentation.ubuntu.com/) |
| CMake | [Official Documentation](https://cmake.org/documentation/) |
| Visual Studio Code | [Official Website](https://code.visualstudio.com/) |

---

## Compatibility Note

This installation guide is based on a working GNU Cim
configuration using Ubuntu 24.04 through WSL.

Compiler versions, build directory structures, and
runtime requirements may change over time. Adjust
the installation paths and commands when necessary.

---

<div align="center">

### From 1967 to the Modern Terminal

*An old language. A modern environment. Timeless concepts.*

![Established](https://img.shields.io/badge/Established-1967-7C3AED?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows_%2B_Linux-0078D4?style=flat-square)
![Purpose](https://img.shields.io/badge/Purpose-Education-16A34A?style=flat-square)

**Happy Coding!**

</div>
