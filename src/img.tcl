###########################################################
# Name:    img.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    07/03/2021
# Brief:   Handles images for alited.tcl (base64).
# License: MIT.
###########################################################

# _________________________ proc/method "red bars" ________________________ #

namespace eval img {

set _AL_IMG(0) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEUAAAAAtv86+l98AAAAAXRS
TlMAQObYZgAAABRJREFUCNdjwAT//zM0MAIRiIEBAHh/BP9K+QllAAAAAElFTkSuQmCC}

set _AL_IMG(1) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAhg4GBEUxAuHgBAIyVA3uaLu15AAAAAElFTkSuQmCC}

set _AL_IMG(2) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAhq4GBEUxAuHgBALW7BH+TzwWIAAAAAElFTkSuQmCC}

set _AL_IMG(3) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAhawUDI5iAcPECAMJjBM+vW7PvAAAAAElFTkSuQmCC}

set _AL_IMG(4) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAha1UDI5iAcPECAOqFBdNjIsJTAAAAAElFTkSuQmCC}

set _AL_IMG(5) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAha9UKRjAB4eIFAPbdBiPyKo3yAAAAAElFTkSuQmCC}

set _AL_IMG(6) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAha9WqRjAB4eIFAB4KBycPp4bQAAAAAElFTkSuQmCC}

set _AL_IMG(7) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEUAAAAAtv/tHCS5r+j6AAAA
AXRSTlMAQObYZgAAABdJREFUCNdjwA9CgYAha9WqlWACwsULACoSB3dYfX36AAAAAElFTkSuQmCC}

# ________________________ Tcl files _________________________ #

set _AL_IMG(Tcl) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAG1BMVEUAAABEebIcVpN6oMOFqMp5
nsLb////SUlJbZK4hOm9AAAABnRSTlMA4bzy7uoa1GpmAAAAPklEQVQI12NgdgGCBgYGBtY0IMgA
MpjTQKABJAIWgomkCQBFIAwSRdLL08vKwCJl6WkgBiuQUVaOokYJDAQAbKolE+c3DpQAAAAASUVO
RK5CYII=}

# ________________________ e_menu _________________________ #

set _AL_IMG(e_menu) {iVBORw0KGgoAAAANSUhEUgAAABYAAAAcCAMAAABS8b9vAAAAD1BMVEUrRF3Y2tab4+U9Oz4jKjDz
nD2xAAAAP0lEQVQoz2NgwgoYmBiwAKKEGaEAXZgFDLAIM2ITxm4IcS5hRANgYSYmRkYUL+IVxmEI
1VyCohav8PByCVYAAFFEAcBPpMHrAAAAAElFTkSuQmCC}

# ________________________ keyboard ("key") _________________________ #

set _AL_IMG(kbd) {iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABAlBMVEUAAAAQEBZ9fZsYGCF/f5oa
GiF/f52AgJ13d5RnZ4l5eZgaGiISEhcNDRCGhqKLi6V7e5pvb45hYYVRUWc5OVMSEhsICAg6OmoZ
GSUBAQUAAADg4Onn5+7k5OzZ2eWFhalubpb6+vx+fqnb2+XCwtLX1+HR0d7NzdvExNXw8PfW1uDT
0963t8W0tMOxscH////r6/Hp6fHm5u7d3ea/v8+rq72oqLicnLCYmK9wcIX29vzt7fbt7fPi4uzg
4OvW1uTJydrGxta9vdXFxdG9vcq4uMq1tce4uMacnMGWlsCRkbShobKAgKyUlKiQkKaMjJ1xcZuG
hpZ9fZJnZ5J6eotOTmdxldK8AAAAG3RSTlMAuPnA+sD5+/v7+cW7nfz7+/v71dOrko8lIxvPqped
AAAAt0lEQVQY0z3O1XbCQBRA0dtpmra424RgYYjg7u6u//8r3GEx7MfzdADChMhElgmRJMntjwLY
svXWotmYaIgVnQCu2rJzuOzGuq5rbO4A+K02jte7xnJIXX1hqLQKp45pWpbFaB6DVK2zWV7NIjPO
g0ehNTrMvFQKGGxl+tHj4a+vxAWjyINRVoQuD16jlBJKTQz/I6q+ZQZtHvRtQpjy4Fvv08ImgeuB
W/Lj/AgBRIL2b+4H2Z2xJ1dcH5DXF1JFAAAAAElFTkSuQmCC}

# ________________________ Tcl & alited _________________________ #

set _AL_IMG(feather) {iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAMAAABiM0N1AAAABlBMVEUAAAC1CgZ1fsiLAAAAAnRS
TlMA/1uRIrUAAADmSURBVFjD3djLEsIgDIXhc97/pd24aFXIhR9xzJK23zApJaHSP4ZNOYYYAPIz
GGXN8TUQpA35QyBI3fEwEKQC2YTjOCAmA5lxbASyGQhybAY64bjhiEmzmOXzOtz9KIbD1f2vkep9
TnNr3OUEyzMNBas866jtqOR4vyPKUYHBnBy06OjXHFGOKEdzp9hLTYtI0Vnu8GInDUEd59w500eP
ihFwOjh64HndRs6fBnln34QGpWV0UB/PpwdpFQoSdLlyu+ntiSjRWSh8Yd+GUn1KAsr1KXlIq1Cy
nM9bjXuFJSBBEPGL7AEx9we9fjFHxQAAAABJRU5ErkJggg==}

set _AL_IMG(ale) {iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAMAAABiM0N1AAAABlBMVEUAAAC1CgZ1fsiLAAAAAnRS
TlMA/1uRIrUAAADySURBVFjD3djJDsMgDEVRv///6W66yACeuIiq3kTKcATEAROzfwyJcgQxAKRv
MMqao2sgSBvSIBCk7mgaCFKBJMJRHBCTgcQ4EgJJDAQ5EgOdcNRwjBlmY9Lnebr7UUxPV+e/xlDv
c5pT4y4nSM80FGR51rG2YyVH+x2jHCswmJODFh37NccoxyjHfKdYS7mLSNFZrvBiJw1BFafvnKmj
Z4sRsDs4uuF5TiPnd4O8s7VB10u3WwYPue1pQKlZ2IOCjr0Pk38QUceykKKOOVC6Y4MVeAoFGZSG
okz0oeybLwx2pv66HwZL6Wjk1yCDIOIX2QdlGgfl1r+rLQAAAABJRU5ErkJggg==}

}
# _________________________________ EOF _________________________________ #
#RUNF1: alited.tcl DEBUG
