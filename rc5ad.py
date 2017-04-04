import bitop
b = [0x12345678,0x87654321,0x11765029,0x92056711,0x00000001]
S = [0X9BBBD8C8,	0X1A37F7FB,	0X46F8E8C5,	0X460C6085,	0X70F83B8A,	0X284B8303,	0X513E1454,	0XF621ED22,	0X3125065D,	0X11A83A5D,	0XD427686B,	0X713AD82D,	0X4B792F99,	0X2799A4DD,	0XA7901C49,	0XDEDE871A,	0X36C03196,	0XA7EFC249,	0X61A78BB8,	0X3B0A1D2B,	0X4DBFCA76,	0XAE162167,	0X30D76B0A,	0X43192304,	0XF6CC1431,	0X65046380]
for i in range(5):
	a = bitop.bitop(0x11765029-i,32)
	for t in range(5):
		bitem = bitop.bitop(0x76543210,32)
		a = bitop.bitop(0xFEDCBA98,32)
		"""bitem = bitop.bitop(b[t],32)"""
		print('b = '+str(bitem.number) + 'a = '+str(a.number))
		"""a = bitop.bitop(0x11765029-i,32)"""
		a.number += S[0]
		bitem.number += S[1]
		for j in range(1,13):
			print('dout = ',end = '')
			a.printbin()
			bitem.printbin()
			print('\n')
			br = int(bitem.number & 31)
			a.number = bitop.bitop((bitem.number^a.number),32).lrot(br) + S[2*j]
			ar = int(a.number & 31)	
			bitem.number = bitop.bitop((bitem.number^a.number),32).lrot(ar) + S[2*j+1]