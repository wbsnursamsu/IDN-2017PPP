********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Initialization Do-file
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

*** Install necessary commands
local commands = "confirmdir mmerge unique _gwtmean"
foreach c of local commands {
	qui capture which `c' 
	qui if _rc != 0 {
		noisily di "This command requires '`c''. The package will now be downloaded and installed."
		ssc install `c'
	}
}

**** Please change the following directories according to your local
clear
local suser = upper(c(username))
* gdData: Raw Datasets (EEAPV IDN Data Files)

if "`suser'" == "WB594719" {
    ** User: Sam (1. for laptop; 2 - for server)
    confirmdir "C:/Users/wb594719/OneDrive - WBG/Documents/GitHub/IDN-2017PPP"
    if _rc==0 {
        local ldLocal "C:/Users/wb594719/OneDrive - WBG/Documents/GitHub/IDN-2017PPP"
        global gdData "C:/Users/wb594719/OneDrive - WBG/EEAPV IDN Documents"            
    }
    else {
        local ldLocal "D:/wb594719/IDN-2017PPP"
        global gdData "D:/wb594719/Data"        
    }
    ** Others: fill here
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