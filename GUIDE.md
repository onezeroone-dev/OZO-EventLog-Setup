# "One Zero One" Windows Event Log Provider Usage Guide

<img src="ozo-eventlog-provider.png" alt="The Windows Event Viewer showing the One Zero One event provider." width="600">

_The Windows Event Viewer showing the "One Zero One" event provider._

## Overview
The _One Zero One_ Windows event provider can be viewed by opening Windows Event Viewer and navigating to _Applications and Services Logs > One Zero One > Operational_. It provides three event IDs and no categories. For guidance on installing the One Zero One Windows event log provider, please see [README.md](README.md)

## Event IDs
|Event ID|Display Name|Message format|
|--------|------------|--------------|
|`1000`|Information|`%1`<br>`%2`|
|`1001`|Warning|`%1`<br>`%2`|
|`1002`|Error|`%1`<br>`%2`|

## Writing to the Provider
You can write to this provider with any language that supports [Event Tracing for Windows](https://learn.microsoft.com/en-us/archive/msdn-magazine/2007/april/event-tracing-improve-debugging-and-performance-tuning-with-etw).

### PowerShell Example
When using PowerShell, the optimal way to leverage this provider is by using the accompanying [`OZOLogger`](https://github.com/onezeroone-dev/OZOLogger-PowerShell-Module/blob/main/README.md) module (which is installed by the OZO EventLog Setup script).

```powershell
Import-Module OZOLogger
$ozoLoggerObject = New-OZOLogger
$ozoLoggerObject.Write("This is a test message.","Information")
```

You can leverage this provider _without_ the `OZOLogger` module with the `New-WinEvent` cmdlet:

```powershell
New-WinEvent -ProviderName "One Zero One" -Id 1000 -Payload "This is line one.","This is line two."
```