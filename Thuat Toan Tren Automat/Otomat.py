class Otomat:
    class Transition:
        def __init__(self, end, input):
            self.end = end
            self.inp = input
     
    __states__ = list()
    __char__ = list()
    __start__ = ''
    __end__ = list()
    __transitions__ = list()

    def __init__(self):
        self.__states__ = list()
        self.__char__ = list()
        self.__end__ = list()
        self.__transitions__ = list()

    def getStates(self):
        return self.__states__
    def setStates(self, states):
        self.__states__ = states

    def getChar(self):
        return self.__char__
    def setChar(self, char):
        self.__char__ = char

    def getStart(self):
        return self.__start__
    def setStart(self, start):
        if start in self.__states__ : self.__start__ = start

    def getEnd(self):
        return self.__end__
    def setEnd(self, end):
        self.__end__ = end
    def addEnd(self, end):
        if end in self.__states__: self.__end__.append(end)

    def getTransitions(self):
        return self.__transitions__
    def setTransition(self, trans):
        self.__transitions__ = trans
    def addTransition(self, s, f, char):
        if s not in self.__states__:
            self.__states__.append(s)
            self.__transitions__.append(list())
        if f not in self.__states__:
            self.__states__.append(f)
            self.__transitions__.append(list())
        if char not in self.__char__:
            self.__char__.append(char)

        index = self.__states__.index(s)
        lst = self.__transitions__[index]
        for trans in lst:
            if trans.end == f:
                trans.inp = char
                return
        self.__transitions__[index].append(self.Transition(f, char))

    def minimize(self):
        P = list()
        F = list()  # ds chua cac trang thai ket
        SF = list() # ds chua cac trang thai khong ket
        for s in self.__states__:
            if s in self.__end__:
                F.append(s)
            else:
                SF.append(s)
        
        P.append(F)
        P.append(SF)
        
        # tim cac phan hoach cua P
        newP = self.partition(P)
        while newP != P:
            P = newP
            newP = self.partition(P)
        # print("P is here", P)
        print("newP is here", newP)

        # khoi tao otomat toi tieu
        otomat = Otomat()
        n_state = ''
        n_states = list()
        n_start = ''
        n_end = list()
        n_transitions = list()

        for Q in newP:  # voi moi phan hoach cua newP
            print("Q", Q)
            n_state = Q[0] # vi moi phan hoach dai dien cho 1 tap trang thai co ham chuyen giong nhau nen chi lay 1 trang thai
            print(n_state)
            n_states.append(n_state)
            if self.__start__ in Q: # neu trang thai khoi tao bd co trong phan hoach
                n_start = n_state   # lay trang thai co trong phan hoach chua trang thai bd vi chung co ham chuyen nhu nhau

            # tim xem trong phan hoach Q co chua trang thai di ra cua transition cu nao hay ko
            # neu co thi gan lai trang thai di ra do = trang thoi moi
            for c in Q: # voi moi state trong phan hoach Q
                for lst in self.__transitions__: # voi moi ds chua cac obj transitions
                    for trans in lst:   # voi moi obj trong ds
                        if trans.end == c:  # neu trang thai ra la trang thai co trong phan hoach Q 
                            trans.end = n_state # gan trang thai ra bang trang thai moi
            
            # tim xem trong phan hoach Q co chua trang thai ket cua transition cu nao hay ko
            # neu co thi kiem tra neu trang thai moi chua co trong tap ket thuc thi append
            for charQ in Q:
                if charQ in self.__end__ :
                    if n_state not in n_end:
                        n_end.append(n_state)

        for Q in newP:  # voi moi phan hoach cua newP
            index = self.__states__.index(Q[0]) # lay index cua state trong phan hoach
            newTransiton = self.__transitions__[index]  # lay obj trans tai vi tri index
            n_transitions.append(newTransiton)  # append obj do vao mang transition moi

        otomat.setStates(n_states)
        otomat.setStart(n_start)
        otomat.setChar(self.__char__)
        otomat.setEnd(n_end)
        otomat.setTransition(n_transitions)
        return otomat
    
    def partition(self, P):
        # = P = [ A[...], B[...], ...] mang 2 chieu
        newP = P.copy()
        for Q in P:
            for s_i in Q:
                for s_j in Q:
                    if s_i != s_j:
                        for a in self.getChar():
                            trans_p = self.getTransition(s_i, a)
                            trans_q = self.getTransition(s_j, a)
                            if not self.checkEquavalence(trans_p.end, trans_q.end, P):
                                self.separateState(s_i, s_j, newP, P)
        return newP

    def separateState(self, p, q, newP, P):
        if not self.isDifferentPartition(p, q, newP):
            q_lst = list()
            q_lst.append(q)
            for set in newP:
                if p in set and q in set:
                    for state in set:
                        if state != p and state != q:
                            for a in self.__char__:
                                state_desti = self.getTransition(state, a).end
                                q_desti = self.getTransition(q, a).end
                                if state_desti != None and q_desti != None:
                                    # kiem tra 2 ky tu co nam trong 1 phan hoach hoac co trung nhau khong
                                    if self.isDifferentPartition(state_desti, q_desti, P) == 1: # neu nam khac phan hoach
                                        q_lst.remove(state) # xoa
                                        break
                                    else:
                                        if state not in q_lst:
                                            q_lst.append(state)
                    for c in q_lst:
                        set.remove(c)
                    break
            newP.append(q_lst)

    def isDifferentPartition(self, p, q, P):  # kiem tra 2 ky tu co nam khac phan hoach
        for set in P:
            for state in set:
                if p == state and q in set:
                    return 0
        return 1

    def getTransition(self, start, input):
        index = self.__states__.index(start)
        transLst = self.getTransitions()[index]
        for trans in transLst:
            if trans.inp == input:
                return trans
        return None

    def checkEquavalence(self, a, b, P): # kiem tra 2 ky tu co nam trong 1 phan hoach hoac co trung nhau khong
        if a == b:
            return True
        for Q in P:
            if a in Q and b in Q:
                return True
        return False
        
    def print_out(self):
        print("States: ", end=" ")
        for c in self.__states__:
            print(c + " ", end=" ")

        print('\n\n' + "Alphabet: ", end=" ")
        for c in self.__char__:
            print(c + " ", end=" ")

        print('\n\n' + "Start state: " + self.__start__)
        
        print('\n' + "Finish state: ", end=" ")
        for c in self.__end__:
            print(c + " ", end=" ")

        print('\n\n' + "Transitions: ")
        for i in range(0, len(self.__states__)):
            state = self.__states__[i]
            lst = self.__transitions__[i]
            for trans in lst:
                print("(" + state + ", " + trans.inp + ") = " + trans.end)