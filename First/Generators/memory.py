import random
output = ""
mem = [[0]*256 for i in range(256)]
#for mem_write in range(0, 2):
for addr in range(0, 65536):
	address = "{0:016b}".format(addr)
	mem_write = '1';
	#memout = int(memhigh[addrhigh])*256 + int(memlow[addrlow])
	#memory_output = "{0:016b}".format(memout)
	data_random = random.randrange(0 , 65536)
	datalow = data_random%256
	datahigh = data_random/256
	#print str(datalow) + ", " + str(datahigh)
	mem[addr%256][addr/256] = datalow;
	addr_plus = (addr + 1) % 65536;
	mem[addr_plus%256][addr_plus/256] = datahigh;
	data = "{0:016b}".format(data_random)
	output += str(mem_write) + " " + address + " " + data + "\n"
happend = False

for i in range(0, 100000):
	addr = random.randrange(0, 65536);
	address = "{0:016b}".format(addr)
	mem_write = random.randrange(0, 2);
	if mem_write == 1:
		data_random = random.randrange(0 , 65536)
		datalow = data_random%256
		datahigh = data_random/256
		mem[addr%256][addr/256] = datalow;
		addr_plus = (addr + 1) % 65536;
		mem[addr_plus%256][addr_plus/256] = datahigh;
		data = "{0:016b}".format(data_random)
		output += str(mem_write) + " " + address + " " + data + "\n"
	elif mem_write == 0:
		datalow = mem[addr%256][addr/256]
		addr_plus = (addr + 1) % 65536;
		datahigh = mem[addr_plus%256][addr_plus/256];
		if not happend:
			#print datalow
			#print datahigh
			#print addr%256
			#print addr/256
			happend = True
		data_random = datahigh*256 + datalow
		data = "{0:016b}".format(data_random)
		output += str(mem_write) + " " + address + " " + data + "\n"
	else:
		print "Destruction"


f = open('Tracefiles/tracefile_memory.txt', 'w')
f.write(output)
f.close()