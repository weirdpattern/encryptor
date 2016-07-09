# Encryptor
A PowerShell module that wraps the .NET `aspnet_regiis` tool.

## Inspiration
How many times have you encrypted or decrypted a configuration file?
Probably not as many times as you need to learn the exact commands and options needed to perform the operations.

So, instead of looking for the commands online over and over again just open Encryptor and let it do it for you.
A few questions and you are done. Free from the hassle and into what really matters...

## Installation
Download the complete source code and follow these instructions:

1. Double click `Install.cmd`
2. The script will open a new PowerShell prompt, when prompted click OK to allow PowerShell to run with elevated privileges.
3. Follow the instructions on screen.
   - Choose to install the module for all users on the machine or to just the current user.
   - Choose to create a desktop shortcut to run the application (`Encryptor.cmd`).
   - Choose to run the application or exit the installation process.

## Running Encryptor
Running *Encryptor* should be simple once it has been installed. You can even do it in two different ways.
- Double click the desktop shortcut created by the installer (`Encryptor.cmd`).

or

- Open a PowerShell prompt with elevated privileges (Right click, Run as Administrator).
- Use one of the following commands.

```bash
$ Encryptor
$ Run-Encrytor
$ Open-Encrytor
$ Start-Encryptor
$ Invoke-Encrytor
```

## Running Encryptor without installing the module
It is possible to run *Encryptor* without installing the module, to do so follow these instructions.

1. Open a PowerShell prompt with elevated privileges (Right click, Run as Administrator).
2. cd to the *Encryptor* root folder

```bash
$ cd <Location_Encryptor_Root_Folder>
```

3. Import the module

```bash
$ Import .\Encryptor.psd1
```

4. Use one of the following commands.

```bash
$ Encryptor
$ Run-Encrytor
$ Open-Encrytor
$ Start-Encryptor
$ Invoke-Encrytor
```