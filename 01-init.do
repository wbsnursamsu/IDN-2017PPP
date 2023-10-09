********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Initialization Do-file
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

*** Install necessary commands
local commands = "confirmdir mmerge unique _gwtmean egenmore"
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
confirmdir "D:\wb594719"
local serv = r(confirmdir)
* gdData: Raw Datasets (EEAPV IDN Data Files)

if ("`suser'" == "WB594719") & (`serv' !=0) {
    ** User: Sam (1. for laptop; 2 - for server)
        local ldLocal "C:/Users/wb594719/OneDrive - WBG/Documents/GitHub/IDN-2017PPP"
        global gdData "C:/Users/wb594719/OneDrive - WBG/EEAPV IDN Documents"         
        global gdCrsw "C:/Users/wb594719/OneDrive - WBG/Indonesia/Monitoring/Measurement/FY23-2017-IPL-Deflation/Data/crosswalk"
        global gdPric "C:/Users/wb594719/OneDrive - WBG/Indonesia/Monitoring/Measurement/FY23-2017-IPL-Deflation/Data/price-survey"        
        global gdCons "C:/Users/wb594719/OneDrive - WBG/Indonesia/Monitoring/Measurement/FY23-2017-IPL-Deflation/Data/susenas-pipeline-cons" 
        global gdSush "C:/Users/wb594719/OneDrive - WBG/Indonesia/Monitoring/Measurement/FY23-2017-IPL-Deflation/Data/susenas-pipeline-hh"
        global gdExpp "C:/Users/wb594719/OneDrive - WBG/Indonesia/Monitoring/Measurement/FY23-2017-IPL-Deflation/Data/susenas-pipeline-exppl"        
    }
else if ("`suser'" == "WB594719") & (`serv' ==0) {
	local ldLocal "D:/wb594719/IDN-2017PPP"
	global gdData "D:/wb594719/Data"        
	global gdCrsw "D:/DATA/2017-PPP-Deflator/crosswalk"                 
	global gdPric "D:/DATA/2017-PPP-Deflator/price-survey"
	global gdCons "D:/DATA/2017-PPP-Deflator/susenas-pipeline-cons"         
	global gdSush "D:/DATA/2017-PPP-Deflator/susenas-pipeline-hh"
	global gdExpp "D:/DATA/2017-PPP-Deflator/susenas-pipeline-exppl"        
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