# OZO Windows Event Log Provider Setup

_Note: For guidance on leveraging the One Zero One Windows event log provider in your scripts, please see **[GUIDE.md](GUIDE.md)**._

## Description
A non-interactive script that creates a _One Zero One_ Windows event log provider. Implementing this provider supports the optimal use of the New-OZOLogger function (available in the OZOLogger PowerShell Module).

## Installation
This script is published to [PowerShell Gallery](https://learn.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-5.1). Ensure your system is configured for this repository then execute the following in an _Administrator_ PowerShell:

```powershell
Install-Script ozo-windows-event-log-provider-setup
```

## Usage
Execute this script in an _Administrator_ PowerShell to implement the "One Zero One" Windows event log provider:

```powershell
ozo-windows-event-log-provider-setup
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`Remove`|Removes the _One Zero One_ provider.|

## Notes
This script requires an x86 or x64 processor architecture. For guidance on leveraging the One Zero One Windows event log provider in your scripts, please see **[GUIDE.md](GUIDE.md)**.

## Acknowledgements
Special thanks to my employer, [Sonic Healthcare USA](https://sonichealthcareusa.com), who has supported the growth of my PowerShell skillset and enabled me to contribute portions of my work product to the PowerShell community.