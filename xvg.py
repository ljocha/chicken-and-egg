def read_xvg(fn):
    x = []
    y = []
    with open(fn) as fh:
        f = fh.readlines()
	    
    for l in f:
        if l[0] != '#' and l[0] != '@':
            x1,y1 = l.split()
            x.append(float(x1))
            y.append(float(y1))

    return x,y
