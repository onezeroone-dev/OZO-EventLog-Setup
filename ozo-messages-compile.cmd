@ECHO OFF
mc ozo-messages.man
rc -r -fo ozo-messages.res ozo-messages.rc
link -machine:x64 -dll -noentry -out:ozo-messages.dll ozo-messages.res
