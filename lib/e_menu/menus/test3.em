[OPTIONS]

in=1.0
om=1
c=10
w=50
pos=26.4

[MENU]

ITEM = Comedy 'Miaou' in 3 parts! Duration ~ 1½ minutes
S: ?-0.01/20:a=/TN=3:ah=3/-0:ah=1/-10:ah=2/-3:ah=2/-3:a=/? echo 'Miaou' part %TN \ndate

[HIDDEN]

ITEM = Intermission
S: echo Intermission %TN \ndate
ITEM = Bell
S: echo Bell N '%TI-3' \ndate
ITEM = Curtain
S: echo Curtain \ndate

########## just to test c= together with fg=, bg=...
fg=#122B05
bg=#afefaf
fE=#002300
bE=#94d494
fS=white
bS=#2a6a2a
fI=yellow
bI=#437043
cc=#002300
hh=green
ht=brown
fM=#122B05
bM=#afefaf
