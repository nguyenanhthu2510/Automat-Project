from Otomat import *
otomat = Otomat()
otomat.addTransition('A', 'B', '0')
otomat.addTransition('A', 'C', '1')
otomat.addTransition('B', 'B', '0')
otomat.addTransition('B', 'D', '1')
otomat.addTransition('C', 'B', '0')
otomat.addTransition('C', 'C', '1')
otomat.addTransition('D', 'B', '0')
otomat.addTransition('D', 'E', '1')
otomat.addTransition('E', 'B', '0')
otomat.addTransition('E', 'C', '1')
otomat.setStart('A')
otomat.addEnd('E')
newAutomat = otomat.minimize()
newAutomat.print_out()