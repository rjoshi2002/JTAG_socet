# Written by: Jason Choi

def parse_bsd_file(file_path):
    opcode_dict = {}
    pin_map = {}
    idcode_register = {}
    boundary_scan_registers = 1

    with open(file_path, 'r') as file:
        lines = file.readlines()
        parsing_opcode = False
        parsing_pin_map = False
        parsing_idcode_register = False

        for line in lines:
            if parsing_opcode:
                if line.strip().startswith('"'):
                    opcode = line.strip().split('(')[0].strip('" ')
                    value = line.strip().split('(')[1].split(')')[0]
                    opcode_dict[opcode] = value
                elif line.strip().endswith(";"):
                    parsing_opcode = False

            elif parsing_pin_map:
                if line.strip().endswith(";"):
                    parsing_pin_map = False
                elif line.strip():
                    key, value = line.strip().split(':')
                    pin_map[key.strip('" ')] = value.split(',')[0].strip()

            elif parsing_idcode_register:
                if line.strip().endswith("1149.1"):
                    idcode_register[part.strip()] = "1"
                    parsing_idcode_register = False
                elif line.strip().startswith('"'):
                    idcode_parts = line.strip().split('"')
                    for part in idcode_parts:
                        if part.strip() and not part.strip().startswith("&"):
                            idcode_register[part.strip()] = part.strip()

            elif line.strip().startswith("attribute INSTRUCTION_OPCODE of jtag_adder: entity is"):
                parsing_opcode = True

            elif line.strip().startswith("constant SIP32: PIN_MAP_STRING :="):
                parsing_pin_map = True

            elif line.strip().startswith("attribute IDCODE_REGISTER of jtag_adder : entity is"):
                parsing_idcode_register = True

            elif line.strip().endswith("X),				\" &"):
                boundary_scan_registers += 1

    return opcode_dict, pin_map, idcode_register, boundary_scan_registers

def write_to_txt(opcode_dict, pin_map, idcode_register, boundary_scan_registers, output_file):
    with open(output_file, 'w') as file:
        file.write("INSTRUCTION OPCODE\n")
        for opcode, value in opcode_dict.items():
            file.write(f"{opcode}: {value}\n")
        file.write("\nPIN MAP\n")
        for key, value in pin_map.items():
            file.write(f"{key}: {value}\n")
        file.write("\nIDCODE REGISTER\n")
        file.write("IDCODE: ")
        for key, value in idcode_register.items():
            file.write(f"{value}")
        file.write(f"\n\nNUMBER OF BOUNDARY SCAN REGISTER\n")
        file.write(f"BSR: {boundary_scan_registers}\n")

def main():
    bsd_file = "jtag_adder.bsd"
    output_file = "output.txt"
    opcode_dict, pin_map, idcode_register, boundary_scan_registers = parse_bsd_file(bsd_file)
    write_to_txt(opcode_dict, pin_map, idcode_register, boundary_scan_registers, output_file)

if __name__ == "__main__":
    main()
