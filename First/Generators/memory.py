import random
output = ""
memhigh = ["{0:08b}".format(0)]*256
memlow = ["{0:08b}".format(0)]*256
for mem_write in range(0, 2):
	for addr in range(0, 65536):
		addrlow = addr%256
		addrhigh = addr/256
		address = "{0:016b}".format(addr)
		memout = int(memhigh[addrhigh])*256 + int(memlow[addrlow])
		memory_output = "{0:016b}".format(memout)
		data_random = random.randrange(0 , 65535 , 1)
		datalow = data_random%256
		datahigh = data_random/256
		data = "{0:016b}".format(data_random)
		if mem_write:
			memhigh[addrhigh] = datahigh
			memlow[addrlow] = datalow
		output += str(mem_write) + " " + address + " " + memory_output + "\n"
		output += memory_output + "\n"
f = open('../Tracefiles/tracefile_memory.txt', 'w')
f.write(output)
f.close()