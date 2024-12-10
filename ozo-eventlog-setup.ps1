#Requires -RunAsAdministrator

<#PSScriptInfo
    .VERSION 0.0.1
    .GUID 0e6ba28d-02be-4527-9412-bc0547b1a2be
    .AUTHOR Andy Lievertz <alievertz@onezeroone.dev>
    .COMPANYNAME One Zero One
    .COPYRIGHT This script is released under the terms of the GNU General Public License ("GPL") version 2.0.
    .TAGS
    .LICENSEURI https://github.com/onezeroone-dev/OZO-EventLog-Setup/blob/main/LICENSE
    .PROJECTURI https://github.com/onezeroone-dev/OZO-EventLog-Setup
    .ICONURI
    .EXTERNALMODULEDEPENDENCIES 
    .REQUIREDSCRIPTS
    .EXTERNALSCRIPTDEPENDENCIES
    .RELEASENOTES
    .PRIVATEDATA
#>

<# 
    .SYNOPSIS
    See description.
    .DESCRIPTION 
    A non-interactive script that creates a "One Zero One" Windows Event Log. Implementing this log supports the optimal use of the New-OZOLogger function (available in the OZOLogger PowerShell Module).
    .PARAMETER Remove
    Removes the "One Zero One" log (if present).
    .LINK
    https://github.com/onezeroone-dev/OZO-EventLog-Setup/blob/main/README.md
#> 
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(HelpMessage="Removes the 'One Zero One' log (if present)")][Switch]$Remove
)

[String] $dllBase64 = "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"
[String] $xmlManifest = @'
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
					<channel name="One Zero One/Admin" chid="One Zero One/Admin" symbol="One_Zero_One_Admin" type="Admin" enabled="false"></channel>
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
				<string id="OneZeroOne.event.1002.message" value="%1%r&#xA;%2"></string>
				<string id="OneZeroOne.event.1001.message" value="%1%r&#xA;%2"></string>
				<string id="OneZeroOne.event.1000.message" value="%1%r&#xA;%2"></string>
			</stringTable>
		</resources>
	</localization>
</instrumentationManifest>
'@

[Array]  $channelNames       = @("Admin","Operational")
[String] $logName            = "One Zero One"
[String] $programDataPath    = (Join-Path -Path $Env:ProgramData -ChildPath "One Zero One\OZO-EventLog")
[String] $dllDestPath        = (Join-Path -Path $programDataPath -ChildPath "ozo-messages.dll")
[String] $manifestDestPath   = (Join-Path -Path $programDataPath -ChildPath "ozo-messages.man")
[String] $wevtUtil           = (Join-Path -Path $Env:windir -ChildPath "System32\wevtutil.exe")

If ($Remove -eq $true) {
    Start-Process -NoNewWindow -Wait -FilePath $wevtUtil -ArgumentList ('um "' + $manifestDestPath + '"')
    Try {
        Get-Process -Name "mmc" -ErrorAction Stop
    } Catch {
        (Get-Process -Name "mmc").CloseMainWindow()
    }
    Remove-Item -Recurse -Force -Path $programDataPath
}
Else {
    # Create the target directory
    New-Item -ItemType Directory -Path $programDataPath -Force
    # Convert from Base64 to DLL
    [System.IO.File]::WriteAllBytes($dllDestPath,[convert]::FromBase64String($dllBase64))
    $xmlManifest | Out-File -FilePath $manifestDestPath
    Start-Process -NoNewWindow -Wait -FilePath $wevtUtil -ArgumentList ('im "' + $manifestDestPath + '"')
    ForEach ($channelName in $channelNames) {
        Start-Process -NoNewWindow -Wait -FilePath $wevtUtil -ArgumentList ('sl "' + $logName + '/' + $channelName +'" /e:true')
    }
    New-WinEvent -ProviderName "One Zero One" -Id 1000 -Payload $MyInvocation.PSCommandPath,"Thank you for implementing OZO EventLog Setup."
}
