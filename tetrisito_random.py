cache = {}
pieces =[]
end = []
n = 0
all_pieces = {0: ['....','....','##..','##..'],
          1: ['....','.#..','.#..','##..'],
          2: ['....','....','#...','###.'],
          3: ['....', '##..','#...','#...'],
          4: ['....','....','###.','..#.'],
          5: ['#...','#...','#...','#...'],
          6: ['....','....','....','####'],
          7: ['....','....','.#..','###.'],
          8: ['....','#...','##..','#...'],
          9: ['....','....','###.','.#..'],
          10: ['....','.#..','##..','.#..']
}

def left_points(k):
    piece = all_pieces[k]
    points = []
    for j in range(0, 4):
        for i in range(0,4):
            if piece[j][i] == '#':
                points.append((i, j))
                break
    return points

def down_points(k):
    piece = all_pieces[k]
    points = []
    for i in range(0, 4):
        for j in range(3,-1,-1):
            if piece[j][i] == '#':
                points.append((i, j))
                break
    return points

def right_points(k):
    piece = all_pieces[k]
    points = []
    for j in range(0, 4):
        for i in range(3,-1,-1):
            if piece[j][i] == '#':
                points.append((i, j))
                break
    return points

def print_list(lisT):
    for i in lisT:
        print(i, end=', ')
    print()
        


def read_piece():
    p = []
    for i in range(0, 4):
        p.append(list(input()))
    return p

def read_input():
    x = []
    for i in range(0,6):
        x.append(list(input()))
    return x

def print_output(out):
    for i in range(0,len(out)):
        print(''.join(out[i]))

def clear_line(inp, i):
    for j in range(i-1,-1,-1):
        inp[j+1] = inp[j]
    inp[0] = ['.' for j in range(0,6)]


def clear_lines(inp):
    new_state = [list(h) for h in inp]
    full = ['#' for j in range(0,6)]
    for i in range(5, -1, -1):
        while new_state[i] == full:
            clear_line(new_state, i)
    return new_state

def compare(state):
    return state[4:] == end


def on_obj(x, y, p_ind, state):
    if y>=9: return False
    d = down_points(p_ind)
    for a, b in d:
        if state[y-(3-b)+1][x+a] == '#':
            return True
    return False

def block_right(x,y, p_ind, state):
    r = right_points(p_ind)
    for a, b in r:
        if state[y-(3-b)][x+a+1] == '#':
            return True
    return False

def block_left(x,y, p_ind, state):
    l = left_points(p_ind)
    for a, b in l:
        if state[y-(3-b)][x+a-1] == '#':
            return True
    return False

    
def peeking(x,y, p_ind, state):
    d = down_points(p_ind)
    piece = all_pieces[p_ind]
    for a,b in d:
        for i in range(b,-1, -1):
            if piece[i][a] == '#' and y-(3-i)<4:
                return True
            if piece[i][a] != '#': break
    return False
            

    
def tet_driver(comb, pieces, ind, state):
    landed = 0
    if ind >= n: return compare(state)
    t = len(down_points(pieces[comb[ind]]))
    
    def shift_down(x,y, p_ind, state_h):
        nonlocal ind
        nonlocal landed
        new_state = [list(h) for h in state_h]
        d = down_points(p_ind)
        piece = all_pieces[p_ind]
        for a,b in d:
            for i in range(b,-1, -1):
                if piece[i][a] == '#':
                    new_state[y-(3-i)+1][x+a] = '#'
                    new_state[y-(3-i)][x+a] = '.'
                else:
                    break
        try:
            cac = cache[str(p_ind)+str(new_state)]
            return False
        except KeyError:
            cache[str(p_ind)+str(new_state)] = 0
        if x + len(down_points(p_ind)) <= 5 and not block_right(x,y+1, p_ind, new_state):
            if move_right(x,y+1, p_ind, new_state): return True
        if x-1>=0 and not block_left(x,y+1, p_ind, new_state):
            if move_left(x,y+1, p_ind, new_state): return True
        if y+2<10 and not on_obj(x,y+1, p_ind, new_state):
            return shift_down(x,y+1, p_ind, new_state)
        elif peeking(x,y+1, p_ind, new_state):
            return False
        else:
            #breakpoint()
            landed = 1
            return tet_driver(comb, pieces, ind + 1, [list(6*'.')for i in range(0,4)]\
                              + clear_lines(new_state[4:]))
        
    def move_right(x,y, p_ind, state_h):
        global landed
        new_state = [list(h) for h in state_h]
        r = right_points(p_ind)
        piece = all_pieces[p_ind]
        for a,b in r:
            for i in range(a,-1,-1):
                if piece[b][i] == '#':
                    new_state[y-(3-b)][x+i+1] = '#'
                    new_state[y-(3-b)][x+i] = '.'
                else:
                    break
        try:
            cac = cache[str(p_ind)+str(new_state)]
            return False
        except KeyError:
            cache[str(p_ind)+str(new_state)] = 0
        if y+1<10 and not on_obj(x+1,y, p_ind, new_state):
            return shift_down(x+1,y, p_ind, new_state)
        elif peeking(x+1,y, p_ind, new_state):
            return False
        else:
            #breakpoint()
            landed = 1
            return tet_driver(comb, pieces, ind + 1, [list(6*'.')for i in range(0,4)]\
                              + clear_lines(new_state[4:]))
    
    def move_left(x,y, p_ind, state_h):
        global landed
        new_state = [list(h) for h in state_h]
        l = left_points(p_ind)
        piece = all_pieces[p_ind]
        for a,b in l:
            for i in range(a,4):
                if piece[b][i] == '#':
                    new_state[y-(3-b)][x+i-1] = '#'
                else:
                    new_state[y-(3-b)][x+i-1] = '.'
                    break
        try:
            cac = cache[str(p_ind)+str(new_state)]
            return False
        except KeyError:
            cache[str(p_ind)+str(new_state)] = 0
        if y+1<10 and not on_obj(x-1,y, p_ind, new_state):
            return shift_down(x-1,y, p_ind, new_state)
        elif peeking(x-1,y, p_ind, new_state):
            return False
        else:
            #breakpoint()
            landed = 1
            return tet_driver(comb, pieces, ind + 1, [list(6*'.')for i in range(0,4)]\
                              + clear_lines(new_state[4:]))
        
    part = [list(h)+['.','.'] for h in all_pieces[pieces[comb[ind]]]]
    #breakpoint()
    for i in range(0, 7-t):
        if shift_down(i, 3, pieces[comb[ind]], part + state[4:]): return True
        part = [h[-1:]+h[0:-1] for h in part]
    if not landed:
        return tet_driver(comb, pieces, ind+1, [list(6*'.')for i in range(0,4)] + state[4:])
    else:
        return False

        
def tetrisito():
    start = read_input()
    start = [list(6*'.')for i in range(0,4)] + start
    global end
    end = read_input()
    global n
    n = int(input())
    for i in range(0,n):
        piece = [''.join(x) for x in read_piece()]
        for j in range(0,11):
            if all_pieces[j] == piece:
                pieces.append(j)
                break   
        def combo_t(res, ps, nums):
            if nums == []:
                return tet_driver(res, ps, 0, start)
            for i in nums:
                r_nums = [j for j in nums if j != i]
                n_res = res + [i]
                if combo_t(n_res, ps, r_nums): return True
            return False
                           
    if combo_t([], pieces, list(range(n))): print('YES')
    else: print('NO')

tetrisito()
