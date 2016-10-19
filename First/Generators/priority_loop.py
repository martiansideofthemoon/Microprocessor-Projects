output = ""
for i in range(0, 256):
	binary = "{0:08b}".format(i)
	output += binary + " " + str(binary.count('1')) + "\n"
	for index in range(0,8):
		j = binary[7-index]
		if j == '1':
			output += "{0:03b}".format(index) + "\n"

f = open('Tracefiles/tracefile_priority.txt', 'w')
f.write(output)
f.close()