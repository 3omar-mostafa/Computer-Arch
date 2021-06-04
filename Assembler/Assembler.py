import re

#read file and store in dectionary
dictionary = {}
with open("Dectionary.txt") as f:
    for line in f:
        (key, val) = line.split()
        dictionary[str(key)] = val

#read code
instructions = []
with open("code.txt") as f:
    for line in f:
        line = line.upper()
        #ignore comments and empty lines
        line = line.replace('\t', '')
        line = line.strip()
        if(len(line) == 0 or line[0] == ';' or line[0] == '#' or line == "\n"):
            continue
        #ignore comments in same line of instruction
        pattern = ";"
        if(re.search(pattern, line)):
            line = line.split(';')[0]
        pattern = "#"
        if(re.search(pattern, line)):
            line = line.split('#')[0]
        #ignore \n if exists
        pattern = "\n"
        if(re.search(pattern, line)):
            line = line.split("\n")[0]
        #split labels and instruction on diffrent lines
        pattern = ':'
        if(re.search(pattern,line)):
            temp = line.split(':')[1]
            pattern = '.*[A-Z].*'
            if(re.search(pattern, temp)):
                instructions.append(line.split(':')[0]+':')
                line = line.split(':')[1]
                line=line.lstrip()
        #save the instructions   
        instructions.append(line)


IRCodes = [] 
addressCounter = 0
interruptAddress = 0
startAddress = 0
isAddress = False


for i,instruction in enumerate(instructions):
    IR = "0000000000000000"
    twoOperands = False
    oneOperand = False
    Branch = False

    #handling org
    pattern = '^.ORG*'
    if(re.search(pattern,instruction)):
        addressCounter = int(instruction.split(' ')[1],16)
        i = i+1
        if(addressCounter == 0):
            startAddress = int(instructions[i],16)
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + '{0:016b}'.format(startAddress) + "\n")
            isAddress = True
            continue
        elif (addressCounter == 2):
            interruptAddress = int(instructions[i],16)
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + '{0:016b}'.format(interruptAddress) + "\n")
            isAddress = True
            continue
        else:
            continue
            
    #skipping numbers after .org line
    if(isAddress == True):
        isAddress = False
        continue

    #handling instructions
    inst = instructions[i].split(' ')[0]
    #Instruction OPcode
    code = dictionary[inst]
    if(code[4:6] == "10"):
        twoOperands = True
        IR = code + IR[9:]
    elif(code[4] == "0"):
        oneOperand = True
        IR = code + IR[9:]
    elif(code[4:6] == "11"):
        Branch= True
        IR = code + IR[9:]
    
    #cut the string after instruction
    Operands = instruction[len(inst)+1:]
    Operands = Operands.strip()

    #######################one operand & no operand########################
    if(oneOperand == True):
        if(inst == "NOP" or inst == "SETC" or inst == "CLRC"):
            IR = IR[0:9] + "0000000"
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + IR + "\n")
            addressCounter = addressCounter + 1
            continue
        else:
            IR = IR[0:9] + "000" + dictionary[Operands] + "0" 
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + IR + "\n")
            addressCounter = addressCounter + 1
            continue
        
    #######################two operand#############################   
    if(twoOperands == True):
        src = Operands.split(',')[0]
        dst = Operands.split(',')[1]
        #check if SHL & SHR & IADD & LDD & LDM & STD
        if(inst == "SHL" or inst == "SHR" or inst == "IADD" or inst == "LDM"):
            IR = IR[0:9] + "000" + dictionary[src] + "0"
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + IR + "\n")
            addressCounter = addressCounter + 1
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + bin(int(dst, 16))[2:].zfill(16) + "\n")
            addressCounter = addressCounter + 1
            continue
        elif(inst == "LDD" or inst == "STD"): #LDD R3,202(R5)
            Imm = dst.split('(')[0] #202
            dst = dst.split('(')[1]
            IR = IR[0:9] + dictionary[dst[0:2]] + dictionary[src] + '0'
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + IR + "\n")
            addressCounter = addressCounter + 1
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + bin(int(Imm, 16))[2:].zfill(16) + "\n")
            addressCounter = addressCounter + 1
            continue
        else:
            IR = IR[0:9] + dictionary[src] + dictionary[dst]+ '0'
            IRCodes.append(hex(addressCounter).upper()[2:] + ": " + IR +"\n")
            addressCounter = addressCounter + 1
            continue

        
    #######################Branch#############################  
    if(Branch == True):
        if(inst == "RTI" or inst == "RET"):
            IR = IR[0:9] + "0000000"
        else:
            IR = IR[0:9] + "000" + dictionary[Operands] +"0" 
        IRCodes.append(hex(addressCounter).upper()[2:] + ": " + IR +"\n")
        addressCounter = addressCounter + 1


#writing IR codes in output file
outputFile = open("IRCodesFile.txt","w")
outputFile.writelines(IRCodes)
outputFile.close()