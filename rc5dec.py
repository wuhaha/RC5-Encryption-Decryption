import bitop
a = [0x4c61f25d,0xd89a156d,0x129732ec,0xaa9e6616,0xbdb8650e]
b = [0xa04b63c0,0x149f900d,0x80a6235c,0xc309a94d,0x3797ea45]
S = [0X9BBBD8C8,	0X1A37F7FB,	0X46F8E8C5,	0X460C6085,	0X70F83B8A,	0X284B8303,	0X513E1454,	0XF621ED22,	0X3125065D,	0X11A83A5D,	0XD427686B,	0X713AD82D,	0X4B792F99,	0X2799A4DD,	0XA7901C49,	0XDEDE871A,	0X36C03196,	0XA7EFC249,	0X61A78BB8,	0X3B0A1D2B,	0X4DBFCA76,	0X4DBFCA76,	0X30D76B0A,	0X43192304,	0XF6CC1431,	0X65046380]
file = open('C:\\Users\\me\\rc5dec.txt','w')

for i in range(5):
	aitem = bitop.bitop(a[i],32)
	bitem = bitop.bitop(b[i],32)
	file.write('b = ' +str(hex(bitem.number))+ '  a = '+str(hex(aitem.number))+'\n')
	for j in range(12,0,-1):
		file.write('dout = '+'{0:8x}'.format(aitem.bitcut()) + '{0:8x}'.format(bitem.bitcut())+'\n')
		ar = int(aitem.number & 31)	
		bitem.number = bitop.bitop(bitem.number - S[2*j + 1],32).rrot(ar) ^ aitem.number
		br = int(bitem.number & 31)
		aitem.number = bitop.bitop(aitem.number - S[2*j],32).rrot(br) ^ bitem.number
	aitem.number -= S[0]
	bitem.number -= S[1]
	file.write('dout = '+'{0:8x}'.format(aitem.bitcut()) + '{0:8x}'.format(bitem.bitcut())+'\n')
		
file.close()
