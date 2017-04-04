from math import pow
b = []
a = 46122132

for i in range(0,32):
	b.append(int(a >> i & 1))
file = open('C:\\Users\\me\\rot.txt','w')

b.reverse()
def rotate(l,n):
    return l[n:] + l[:n]
c = rotate(b,3)
for i in range(0,32):
	file.write(str(b[i]))
d = 0
c.reverse()
for i in range(32):
	d += int(c[i]*pow(2,i))
file.write('\n'+str(bin(a))+'\n'+str(bin(d))+' '+ str(a&31))
file.close()
