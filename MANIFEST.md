# OZO EventLog Setup Manifest Generation and Publication
## Required Tools
|Tool|Source|
|----|------|
|`ecmangen.exe`|Windows 10 SDK 10.0.15063.468 (available on the [Windows SDK archive page](https://developer.microsoft.com/en-us/windows/downloads/sdk-archive), as detailed in [How to compile manifest file with MC.exe?](https://stackoverflow.com/questions/27000235/how-to-compile-manifest-file-with-mc-exe)).
|`link.exe`|Visual Studio [command-line build tools](https://visualstudio.microsoft.com/downloads/)|
|`mc.exe`|[Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk)|
|`rc.exe`|[Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk)|

## Procedure
1. Use `ecmangen.exe` to create the _manifest_ file (See related links, below).
1. Open the _Visual Studio x64 Native Tools Command Prompt_, compile the manifest and create the DLL for x86 and x64:

   ```
   mc example.man
   rc -r -fo example.res example.rc
   link -machine:x86 -dll -noentry -out:example-x86.dll example.res
   link -machine:x64 -dll -noentry -out:example-x64.dll example.res
   ```

1. Use the following PowerShell to convert the DLLs into base-64 encoded strings:

   ```powershell
   [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Path\to\example-x86.dll"))
   [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Path\to\example-x64.dll"))
   ```

1. Paste the base-64 strings into the setup script as the values of the `$dllx86Base64` and `$dllx64Base64` variables, respectively.
1. Paste the contents of `example.man` into the setup script as the value of the `$manifestXML` variable.
1. Sign and publish the script to PowerShell Gallery.

## Related Links
* [How to compile manifest file with MC.exe?](https://stackoverflow.com/questions/27000235/how-to-compile-manifest-file-with-mc-exe)
* [Writing to the event log in .NET - the right way](http://blog.dlgordon.com/2012/06/writing-to-event-log-in-net-right-way.html)
* [Creating an ETW Provider Step by Step](https://kallanreed.com/2016/05/28/creating-an-etw-provider-step-by-step/)
* [Writing to Event Log — the right way](https://cymbeline.ch/index.html%3Fp=239.html)
* [Message Text Files](https://learn.microsoft.com/en-us/windows/win32/eventlog/message-text-files)
* [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk)
* [Windows SDK archive page](https://developer.microsoft.com/en-us/windows/downloads/sdk-archive)