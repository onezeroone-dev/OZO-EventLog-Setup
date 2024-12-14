#Requires -RunAsAdministrator

<#PSScriptInfo
    .VERSION 1.0.0
    .GUID 0e6ba28d-02be-4527-9412-bc0547b1a2be
    .AUTHOR Andy Lievertz <alievertz@onezeroone.dev>
    .COMPANYNAME One Zero One
    .COPYRIGHT This script is released under the terms of the GNU General Public License ("GPL") version 2.0.
    .TAGS
    .LICENSEURI https://github.com/onezeroone-dev/OZO-Windows-Event-Log-Provider-Setup/blob/main/LICENSE
    .PROJECTURI https://github.com/onezeroone-dev/OZO-Windows-Event-Log-Provider-Setup
    .ICONURI
    .EXTERNALMODULEDEPENDENCIES 
    .REQUIREDSCRIPTS
    .EXTERNALSCRIPTDEPENDENCIES
    .RELEASENOTES https://github.com/onezeroone-dev/OZO-Windows-Event-Log-Provider-Setup/blob/main/CHANGELOG.md
    .PRIVATEDATA
#>

<# 
    .SYNOPSIS
    See description.
    .DESCRIPTION 
    A non-interactive script that creates a "One Zero One" Windows event log provider. Implementing this provider supports the optimal use of the New-OZOLogger function (available in the OZOLogger PowerShell Module).
    .PARAMETER Remove
    Removes the "One Zero One" provider.
    .LINK
    https://github.com/onezeroone-dev/OZO-Windows-Event-Log-Provider-Setup/blob/main/README.md
    .NOTES
    This script requires an x86 or x64 processor.
#> 
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(HelpMessage='Removes the "One Zero One" provider')][Switch]$Remove
)

# CLASSES
Class OZOESConfiguration {
    # PROPERTIES
    [Array]   $channelNames    = $null
    [Array]   $installModules  = $null
    [Boolean] $dllChanged      = $true
    [Boolean] $manifestChanged = $true
    [Boolean] $providerExists  = $true
    [Boolean] $Validates       = $true
    [Int16]   $processorArch   = $null
    [String]  $dllBase64       = $null
    [String]  $dllx86Base64    = $null
    [String]  $dllx64Base64    = $null
    [String]  $manifestXML     = $null
    [String]  $providerName    = $null
    [String]  $ozoEventLogDir  = $null
    [String]  $dllPath         = $null
    [String]  $manifestPath    = $null
    [String]  $wEvtUtilPath    = $null
    # METHODS
    # Constructor method
    OZOESConfiguration($dllx86Base64,$dllx64Base64,$manifestXML) {
        # Set properties
        $this.channelNames   = @("Operational")
        $this.installModules = @("OZOLogger")
        $this.processorArch  = (Get-CimInstance -ClassName CIM_Processor).Architecture
        $this.dllx86Base64   = $dllx86Base64
        $this.dllx64Base64   = $dllx64Base64
        $this.manifestXML    = $manifestXML
        $this.providerName   = "One Zero One"
        $this.ozoEventLogDir = (Join-Path -Path $Env:ProgramFiles -ChildPath (Join-Path -Path $this.providerName -ChildPath "OZO-Windows-Event-Log-Provider"))
        $this.dllPath        = (Join-Path -Path $this.ozoEventLogDir -ChildPath "ozo-messages.dll")
        $this.manifestPath   = (Join-Path -Path $this.ozoEventLogDir -ChildPath "ozo-messages.man")
        $this.wEvtUtilPath   = (Join-Path -Path $Env:windir -ChildPath (Join-Path -Path "System32" -ChildPath "wevtutil.exe"))
        # Call ValidateEnvironment to set Validates
        If ($this.ValidateEnvironment() -eq $true) {
            # Environment validated
            Write-OZOProvider -Message "Environment validated." -Level "Information"
            $this.Validates = $true
            # Inspect the DLL and manifest for changes
            $this.dllChanged      = $this.InspectDLL()
            $this.manifestChanged = $this.InspectManifest()
        } Else {
            # Environment did not validate
            Write-OZOProvider -Message "Environment did not validate." -Level "Error"
            $this.Validates = $false
        }
    }
    # Environment validation method
    Hidden [Boolean] ValidateEnvironment() {
        [Boolean] $Return = $true
        # Try to get the provider (detemine if it exists)
        Try {
            Get-WinEvent -ListProvider $this.providerName -ErrorAction Stop
            # Success
            Write-OZOProvider -Message "Provider exists." -Level "Information"
        } Catch {
            # Failure
            Write-OZOProvider -Message "Provider does not exist." -Level "Information"
            $this.providerExists = $false
        }
        # Determine if processor architecture is supported; see https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor to translate processor architectures to the relevant Int16
        If ($this.processorArch -eq 0) {
            # Processor is x86
            $this.dllBase64 = $this.dllx86Base64
        } ElseIf ($this.processorArch -eq 9) {
            # Processor is x64
            $this.dllBase64 = $this.dllx64Base64
        } Else {
            # Processor architecture is not supported
            Write-OZOProvider -Message "Processor is not supported." -Level "Error"
            $Return = $false
        }
        # Return
        return $Return
    }
    # DLL inspection method
    Hidden [Boolean] InspectDLL() {
        [Boolean] $Return = $true
        # Determine if the DLL exists
        If ((Test-Path -Path $this.dllPath) -eq $true) {
            # DLL exists
            Write-OZOProvider -Message "DLL exists." -Level "Information"
            # Determine if there are differences between the DLLs
            If ((Compare-Object -ReferenceObject $this.dllBase64 -DifferenceObject ([System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($this.dllPath)))) -eq $true) {
                # Differences
                Write-OZOProvider -Message "There are differences between the DLLs." -Level "Information"
            } Else {
                # No differences
                Write-OZOProvider -Message "The DLL has not changed." -Level "Information"
                $Return = $false
            }
        } Else {
            # DLL does not exist
            Write-OZOProvider -Message "DLL does not exist." -Level "Information"
        }
        # Return
        return $Return
    }
    # Manifest inspection method
    Hidden [Boolean] InspectManifest() {
        [Boolean] $Return = $true
        # Determine if the manifest exists
        If ((Test-Path -Path $this.manifestPath) -eq $true) {
            # Manifest exists
            Write-OZOProvider -Message "Manifest exists." -Level "Information"
            # Determine if there are differences between the manifests
            If ((Compare-Object -ReferenceObject $this.manifestXML -DifferenceObject (Get-Content -Path $this.manifestPath)) -eq $true) {
                # Differences
                Write-OZOProvider -Message "There are differences between the manifests." -Level "Information"
            } Else {
                # No differences
                Write-OZOProvider -Message "The manifest has not changed." -Level "Information"
                $Return = $false
            }
        } Else {
            # Manifest does not exist
            Write-OZOProvider -Message "Manifest does not exist." -Level "Information"
        }
        # Return
        return $Return
    }
}

Class OESMain {
    # METHODS
    # Constructor method
    OESMain($Remove) {
        # Determine if we are removing, updating, or adding
        If ($Global:oesConfiguration.providerExists -eq $true -And $Remove -eq $true) {
            # Log exists and operator requested remove; call RemoveProvider
            $this.RemoveProvider()
            Write-OZOProvider -Message "Provider removed." -Level "Information"
        } ElseIf ($Global:oesConfiguration.providerExists -eq $true -And ($Global:oesConfiguration.dllChanged -Or $Global:oesConfiguration.manifestChanged) -eq $true) {
            # Log exists and the DLL or manifest has changed; call RemoveProvider + AddProvider + InstallModules
            $this.RemoveProvider()
            $this.AddProvider()
            $this.InstallModules()
            Write-OZOProvider -Message "Thank you for updating the One Zero One Windows event log provider." -Level "Information"
        } ElseIf ($Global:oesConfiguration.providerExists -eq $false) {
            # Log does not exist; call AddProvider + InstallModules
            $this.AddProvider()
            $this.InstallModules()
            Write-OZOProvider -Message "Thank you for installing the One Zero One Windows event log provider." -Level "Information"
        } ElseIf ($Global:oesConfiguration.providerExists -eq $true -And ($Global:oesConfiguration.dllChanged -And $Global:oesConfiguration.manifestChanged) -eq $false) {
            Write-OZOProvider -Message "Provider exists and the configuration has not changed; skipping." -Level "Information"
        } Else {
            # No conditions matched
            Write-OZOProvider -Message "No conditions matched." -Level "Warning"
        }
    }
    # Remove provider method
    Hidden [Void] RemoveProvider() {
        Write-OZOProvider -Message "Removing provider." -Level "Information"
        # Determine that manifest exists
        If ((Test-Path -Path $Global:oesConfiguration.manifestPath) -eq $false) {
            # Manifest does not exist; write payload manifest to disk and attempt to remove
            Write-OZOProvider -Message "Provider exists but manifest is missing; attempting to remove based on the payload manifest." -Level "Warning"
            # Export the payload manifest to an XML file in the Program Files directory
            $Global:oesConfiguration.manifestXML | Out-File -FilePath $Global:oesConfiguration.manifestPath
        }
        # Uninstall the manifest
        Start-Process -NoNewWindow -Wait -FilePath $Global:oesConfiguration.wEvtUtilPath -ArgumentList ('um "' + $Global:oesConfiguration.manifestPath + '"')
    }
    # Add provider method
    Hidden [Void] AddProvider() {
        Write-OZOProvider -Message "Adding provider." -Level "Information"
        # Create the Program Files directory
        New-Item -ItemType Directory -Path $Global:oesConfiguration.ozoEventLogDir -Force
        # Convert the payload base64 DLL to a binary file in the Program Files directory
        [System.IO.File]::WriteAllBytes($Global:oesConfiguration.dllPath,[Convert]::FromBase64String($Global:oesConfiguration.dllBase64))
        # Export the payload manifest to an XML file in the Program Files directory
        $Global:oesConfiguration.manifestXML | Out-File -FilePath $Global:oesConfiguration.manifestPath
        # Install the manifest
        Start-Process -NoNewWindow -Wait -FilePath $Global:oesConfiguration.wEvtUtilPath -ArgumentList ('im "' + $Global:oesConfiguration.manifestPath + '"')
        # Iterate through the channels
        ForEach ($channelName in $Global:oesConfiguration.channelNames) {
            # Enable the channel
            Start-Process -NoNewWindow -Wait -FilePath $Global:oesConfiguration.wEvtUtilPath -ArgumentList ('sl "' + $Global:oesConfiguration.providerName + '/' + $channelName + '" /e:true')
        }
    }
    # Install modules method
    Hidden [Void] InstallModules() {
        # Iterate through the list of modules to install
        ForEach ($module in $Global:oesConfiguration.InstallModules) {
            If ([Boolean](Get-Module -Name $module) -eq $true) {
                # Module available; try to update the OZOLogger module
                Try {
                    Update-Module -Name $module -ErrorAction Stop
                    # Success
                    Write-OZOProvider -Message ("Updated the " + $module + " module.") -Level "Information"
                } Catch {
                    # Failure; try to install the OZOLogger module
                    Write-OZOProvider -Message ("The " + $module + " module does not appear to be installed; attempting to install.")
                    Try {
                        Install-Module -Name $module -ErrorAction Stop
                        # Success
                        Write-OZOProvider -Message ("Installed the " + $module + " module.") -Level "Information"
                    } Catch {
                        # Failure
                        Write-OZOProvider -Message ("Unable to install the " + $module + " module.") -Level "Warning"
                    }
                }
            } Else {
                # Module unavailable
                Write-OZOProvider -Message ("The " + $module + " module is not available.") -Level "Warning"
            }
        }
    }
}

# FUNCTIONS
Function Write-OZOProvider {
    param(
        [Parameter(Mandatory=$true)][String]$Message,
        [Parameter(Mandatory=$false)][String]$Level = "Information"
    )
    [Int32]$Id = 0000
    Switch($Level) {
        "Information" { $Id = 1000 }
        "Warning"     { $Id = 1001 }
        "Error"       { $Id = 1002 }
        default       { $Id = 1000 }
    }
    # Try to write to the One Zero One provider
    Try {
        New-WinEvent -ProviderName "One Zero One" -Id $Id -Payload (Split-Path -Path $PSCommandPath -Leaf),$Message -ErrorAction Stop
    } Catch {
        New-WinEvent -ProviderName "Microsoft-Windows-PowerShell" -Id 4100 (Split-Path -Path $PSCommandPath -Leaf),"Script output.",$Message
    }
}

# MAIN
# Variables
[String] $dllx86Base64 = "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"
[String] $dllx64Base64 = "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"
[String] $manifestXML  = @'
<?xml version="1.0"?>
<instrumentationManifest xsi:schemaLocation="http://schemas.microsoft.com/win/2004/08/events eventman.xsd" xmlns="http://schemas.microsoft.com/win/2004/08/events" xmlns:win="http://manifests.microsoft.com/win/2004/08/windows/events" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:trace="http://schemas.microsoft.com/win/2004/08/events/trace">
	<instrumentation>
		<events>
			<provider name="One Zero One" guid="{1A87849A-29DF-464E-8AE9-71D981A0667C}" symbol="One_Zero_One" resourceFileName="%PROGRAMDATA%\One Zero One\OZO-EventLog\ozo-messages.dll" messageFileName="%PROGRAMDATA%\One Zero One\OZO-EventLog\ozo-messages.dll">
				<events>
					<event symbol="Information" value="1000" version="1" channel="One Zero One/Operational" level="win:Informational" template="OZOEventTemplate" message="$(string.OneZeroOne.event.1000.message)"></event>
					<event symbol="Warning" value="1001" version="1" channel="One Zero One/Operational" level="win:Warning" template="OZOEventTemplate" message="$(string.OneZeroOne.event.1001.message)"></event>
					<event symbol="Error" value="1002" version="1" channel="One Zero One/Operational" level="win:Error" template="OZOEventTemplate" message="$(string.OneZeroOne.event.1002.message)"></event>
				</events>
				<levels></levels>
				<channels>
					<channel name="One Zero One/Operational" chid="One Zero One/Operational" symbol="One_Zero_One_Operational" type="Operational" enabled="false"></channel>
				</channels>
				<templates>
					<template tid="OZOEventTemplate">
						<data name="Source" inType="win:UnicodeString" outType="xs:string"></data>
						<data name="Message" inType="win:UnicodeString" outType="xs:string"></data>
					</template>
				</templates>
			</provider>
		</events>
	</instrumentation>
	<localization>
		<resources culture="en-US">
			<stringTable>
				<string id="level.Warning" value="Warning"></string>
				<string id="level.Informational" value="Information"></string>
				<string id="level.Error" value="Error"></string>
				<string id="OneZeroOne.event.1002.message" value="%1%r%2"></string>
				<string id="OneZeroOne.event.1001.message" value="%1%r%2"></string>
				<string id="OneZeroOne.event.1000.message" value="%1%r%2"></string>
			</stringTable>
		</resources>
	</localization>
</instrumentationManifest>
'@
# Create an object of the OESCOnfiguration class
[PSCustomObject]$Global:oesConfiguration = [OZOESConfiguration]::new($dllx86Base64,$dllx64Base64,$manifestXML)
# Determine if the configuration is valid
If ($Global:oesConfiguration.Validates -eq $true) {
    # Configuration validates
    Write-OZOProvider -Message "Configuration validates." -Level "Information"
    # Set oesConfiguration to read-only
    Set-Variable -Name $Global:oesConfiguration -Option ReadOnly
    # Create an object of the OESMain class
    [OESMain]::new($Remove) | Out-Null
} Else {
    # Configuration did not validate
    Write-OZOProvider -Message "Configuration did not validate." -Level "Error"
}
