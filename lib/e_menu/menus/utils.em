[OPTIONS]

o=-1
in=1.0
pos=4.100

[MENU]

# utils menu for e_menu.tcl

ITEM = Diff of %e%x to LEFT  tab
R: %IF "%z6"=="%%z6" %THEN %M "No left tab available."  %ELSE "%DF" "%z6" "%f"
ITEM = Diff of %e%x to RIGHT tab
R: %IF "%z7"=="%%z7" %THEN %M "No right tab available." %ELSE "%DF" "%f" "%z7"

SEP = 3

ITEM = poApps
RE: tclsh /home/apl/PG/github/poApps/poApps.tcl --dirdiff
ITEM = ruler
RE: tclsh /usr/share/tcltk/tklib0.7/widget/ruler.tcl
ITEM = screenshooter
RE: cd ~/UTILS
RE: ./screenshooter
ITEM = caja here
RE: caja "%d"
ITEM = terminal here
RE: cd %d
RE: %TT

ITEM = wget Web page
S: %#W wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/
R: %Q "CHANGE ME" "The directory %z5/WGET\n\nwould be open by \"caja\" file manager.\n\nYou can change it by editing:\n%mn"
R: cd %z5/WGET
R: %IF [::iswindows] %THEN explorer.exe "." %ELSE caja "."

SEP = 3

ITEM = Tcl/Tk
ME: m=tcltk.em "u=%s" w=40
ITEM = Misc
ME: m=misc.em "u=%s" w=40
ITEM = Tests
ME: m=tests.em "u=%s" w=40
ITEM = Test1
ME: m=test1.em "u=%s" w=40

[DATA]

%#W geo=1089x560+0+56;pos=24.62 # Below are the commands to get the Web page by wget.|!|# The downloaded pages are stored in ~/WGET directory (change this if needed).|!|#|!|# Note that .+ are used to edge "some unique string of the page address", e.g.|!|#   wget -r -k -l 2 -p --accept-regex=.+/UNIQUE/.+ https://www.some.com/UNIQUE/some|!|# would download all of https://www.some.com/UNIQUE/some|!|# excluding all external links that don't most likely match /UNIQUE/.|!|#|!|# Note also that -l option means "maximum level to dig".|!|###################################################################################|!|mkdir ~/WGET|!|cd ~/WGET|!||!|# wget the Tcl/Tk man pages:|!|# wget -r -k -l 2 -p --accept-regex=.+/man/tcl8\.6.+ https://www.tcl.tk/man/tcl8.6/|!||!|# wget letter-to-peter|!|# wget -r -k -l 2 -p --accept-regex=.+letter-to-peter.+ http://catesfamily.org.uk/letter-to-peter/|!||!|# wget -r -k -l 2 -p --accept-regex=.+tablelist/.+ https://www.nemethi.de/tablelist/index.html|!|# wget -r -k -l 2 -p --accept-regex=.+mentry/.+ https://www.nemethi.de/mentry/index.html|!||!|# wget -r -k -l 2 -p --accept-regex=.+/manual3.1/.+ http://tcl.apache.org/rivet/manual3.1/|!|wget -r -k -l 2 -p --accept-regex=.+/tcart.+ http://tcart.com/
