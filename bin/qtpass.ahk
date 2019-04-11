; open qtpass
!p::
if WinExist("QtPass")
	WinActivate
else
	run C:\Program Files (x86)\QtPass\qtpass.exe
return