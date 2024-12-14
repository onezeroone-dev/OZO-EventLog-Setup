@ECHO OFF
mc ozo-messages.man
rc -r -fo ozo-messages.res ozo-messages.rc
link -machine:x86 -dll -noentry -out:ozo-messages-x86.dll ozo-messages.res
link -machine:x64 -dll -noentry -out:ozo-messages-x64.dll ozo-messages.res
