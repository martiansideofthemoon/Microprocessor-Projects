import random
output = ""
for m in range(0,10*256*256):
            var1 = random.randint(0,65535)
            var2 = random.randint(0,65535)
            sum1 = (var1 + var2) % 65536
            nand = (var1 ^ 0b1111111111111111) | (var2 ^ 0b1111111111111111)
            zero1 = (sum1 == 0)
            zero2 = (nand == 0)
            carry = (var1 + var2)/65536
            output += "{0:016b}".format(var1) + " " + \
                     "{0:016b}".format(var2) + " 0 " + \
                     "{0:016b}".format(sum1) + " " + \
                     "{0:01b}".format(zero1) + " " + \
                     "{0:01b}".format(carry) + "\n"
            output += "{0:016b}".format(var1) + " " + "{0:016b}".format(var2) + " 1 " + "{0:016b}".format(nand) + " " + "{0:01b}".format(zero2) + " 0 " + "\n"

f = open('Generators/TRACEFILE_ALU.txt', 'w')
f.write(output)
f.close()