********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Initialization Do-file
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

**** Please change the following directories according to your local
clear
local suser = upper(c(username))
* gdWF: Working Folders
* PAOutputs: Outputs for Core Analytics (Rabia's shared folder)
* gdData: Raw Datasets (EEAPV IDN Data Files)

if "`suser'" == "WB594719" {
    ** User: Sam
    local ldLocal "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP"
    global gdData "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents"
} 
else {
	display as error "Please specify your username in 01-init.do first."
	error 1
}

**** Working folders subdirectories
global gdDo		"`ldLocal'/Do"
global gdLog	"`ldLocal'/Log"
global gdTemp	"`ldLocal'/Temp"
global gdOutput	"`ldLocal'/Output"

* Install necessary commands
local commands = "confirmdir mmerge unique"
foreach c of local commands {
	qui capture which `c' 
	qui if _rc != 0 {
		noisily di "This command requires '`c''. The package will now be downloaded and installed."
		ssc install `c'
	}
}

* If needed, install the directories, and sub-directories used in the process 
foreach i in "$gdDo" "$gdLog" "$gdTemp" "$gdOutput" {
	confirmdir "`i'" 
	if _rc!=0 {
		mkdir "`i'" 
	}
	else {
		qui display "No action needed"		
	}
}