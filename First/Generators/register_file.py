import random
output = ""
regs = ["{0:016b}".format(0)]*8
for pr in range(2, -1, -1):
	for a1 in range(0, 8):
		for a2 in range(0, 8):
			for a3 in range(0, 8):
				reada1 = "{0:03b}".format(a1)
				reada2 = "{0:03b}".format(a2)
				writea3 = "{0:03b}".format(a3)
				pc_write = pr%2
				reg_write = pr/2
				din_random = random.randrange(0 , 65535 , 1)
				din = "{0:016b}".format(din_random)
				pcin_random = random.randrange(0 , 65535 , 1)
				PC_in = "{0:016b}".format(pcin_random)
				dout1 = regs[a1]
				dout2 = regs[a2]
				PC_out = regs[7]
				if reg_write:
					regs[a3] = din
				if pc_write:
					regs[7] = PC_in
				output += str(reg_write) + " " + str(pc_write) + " " + reada1 + " " + reada2 + " " + writea3 + " "  +  din + " " + PC_in + "\n"
				output += dout1 + " " + dout2 + " " + PC_out + "\n"
f = open('Tracefiles/tracefile_register_file.txt', 'w')
f.write(output)
f.close()