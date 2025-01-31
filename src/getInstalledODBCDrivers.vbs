Wscript.Echo ""
Wscript.Echo "---------------------------------------"
Set oShell = WScript.CreateObject("WScript.Shell")
proc_arch = oShell.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%")
Wscript.Echo "ODBC driver for proc_arch=" & proc_arch
Wscript.Echo "---------------------------------------"

Const HKEY_LOCAL_MACHINE = &H80000002

strComputer = "."

Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")

strKeyPath = "SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers"
objRegistry.EnumValues HKEY_LOCAL_MACHINE, strKeyPath, arrValueNames, arrValueTypes


For i = 0 to UBound(arrValueNames)
    strValueName = arrValueNames(i)
    objRegistry.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue    
    Wscript.Echo arrValueNames(i) & " - " & strValue
Next
Wscript.Echo "---------------------------------------"
Wscript.Echo ""

