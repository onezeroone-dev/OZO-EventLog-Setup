# OZO EventLog Setup Manifest Generation and Publication
## Required Tools
|Tool|Source|
|----|------|
|`ecmangen.exe`|Windows 10 SDK 10.0.15063.468 (available on the [SDK archive page](https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/), as detailed in [How to compile manifest file with MC.exe?](https://stackoverflow.com/questions/27000235/how-to-compile-manifest-file-with-mc-exe)).
|`link.exe`|Visual Studio command-line [build tools](https://visualstudio.microsoft.com/downloads/)|
|`mc.exe`|Windows SDK|
|`rc.exe`|Windows SDK|

## Procedure
1. Use `exmangen.exe` to create the _manifest_ file (See related links, below).
1. Open the Visual Studio x64 Native Tools Command Prompt and use the following steps to compile the manifest and create the DLL:

   ```
   mc example.man
   rc -r -fo example.res example.rc
   link -machine:x64 -dll -noentry -out:example.dll example.res
   ```

1. Use the following PowerShell to convert the DLL into a base-64 encoded string:

   ```powershell
   [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Path\to\example.dll"))
   ```

1. Copy the base-64 string into the setup script.
1. Copy the contents of `example.man` into the setup script.
1. Sign and publish the script to PowerShell Gallery.

## Related Links
* [Writing to the event log in .NET - the right way](http://blog.dlgordon.com/2012/06/writing-to-event-log-in-net-right-way.html)
* [Creating an ETW Provider Step by Step](https://kallanreed.com/2016/05/28/creating-an-etw-provider-step-by-step/)
* [Writing to Event Log — the right way](https://cymbeline.ch/index.html%3Fp=239.html)
* [Message Text Files](https://learn.microsoft.com/en-us/windows/win32/eventlog/message-text-files)