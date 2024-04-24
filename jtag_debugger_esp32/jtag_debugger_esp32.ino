// #define dwon(port, pin) (port |= _BV(pin))
// #define dwoff(port, pin) (port &= ~(_BV(pin)))

const int led = LED_BUILTIN;

//These can be scanned in using a BSDL file
int opcode_len = 5;
const int num_opcodes = 5;
const int bsr_len = 14;

int half_period = 25; //half the period in microseconds

int TCK = 12;
int TMS = 27;
int TDI = 14;
int TDO = 15;
// int TRST;

//IMPORTANT
//replace digitalwrite(TCK, 1) with GPIO.out_w1ts = ((uint32_t)1 << TCK);
//replace digitalwrite(TCK, 0) with GPIO.out_w1tc = ((uint32_t)1 << TCK);

//Should also be able to be scanned from BSDL file
//OPCODES:
// BYPASS					= 5'b00000,	// 6.2.1.1.d	BYPASS = '0 and '1 All 1's -> 31
// SAMPLE					= 5'b00001, -> 1
// PRELOAD				= 5'b00010, -> 2
// EXTEST					= 5'b00011, -> 3
// IDCODE					= 5'b00100, -> 4
int opcodes[num_opcodes] = {31, 1, 2, 3, 4};

uint32_t deviceID;

void setup() {
  // Some boards work best if we also make a serial connection
  Serial.begin(115200);

  // set LED to be an output pin
  pinMode(TCK, OUTPUT); //gpio 12
  pinMode(TMS, OUTPUT); //gpio 27
  pinMode(TDI, OUTPUT); //gpio 33
  pinMode(TDO, INPUT); //gpio 15

  digitalWrite(TCK, LOW);
  digitalWrite(TMS, LOW);
  digitalWrite(TDI, LOW);

  pinMode(led, OUTPUT);
}

void loop() {
  // Say hi!
  Serial.println();
  Serial.println();
  Serial.println("Welcome to JTAG debugger console");
  Serial.println("Please enter the command you would like to run by the number listed before it");
  Serial.println();
  Serial.println("Available commands:");
  Serial.println("1. IDCODE (Will output the device ID) opcode: 00100 ");
  Serial.println("2. SAMPLE (Will sample the current state of BSR chain) opcode: 00001 ");
  Serial.println("3. PRELOAD (Will push value into the BSR chain for EXTEST) opcode: 00010 ");
  Serial.println();
  Serial.println();

  while(Serial.available() == 0) //wait for the user input
  {
    GPIO.out_w1ts = ((uint32_t)1 << led);  // turn the LED on (HIGH is the voltage level)
    delay(500);                // wait for a half second
    GPIO.out_w1tc = ((uint32_t)1 << led);    // turn the LED off by making the voltage LOW
    delay(500);                // wait for a half second
  } 

  int chosenCommand = Serial.parseInt();

  uint32_t bsr_value;

  switch(chosenCommand)
  {
    case 1: //IDCODE code
      idcode();
      break;               
    
    case 2:
      sample();
      break;

    case 3:
      Serial.println("Enter the value you want shifted into the BSR chain in decimal...");
      while(Serial.available() == 0) //wait for the user input
      {
        GPIO.out_w1ts = ((uint32_t)1 << led);  // turn the LED on (HIGH is the voltage level)
        delay(500);                // wait for a half second
        GPIO.out_w1tc = ((uint32_t)1 << led);    // turn the LED off by making the voltage LOW
        delay(500);                // wait for a half second
      }
      bsr_value = Serial.parseInt();
      preload(bsr_value);
      Serial.println("Value has been preloaded, EXTEST will begin now");
      extest();
      break;

    default:
      Serial.println("Invalid Command Number");
      break;
      
  }
 
}

void extest()
{
  Serial.println("Initializing EXTEST...");
  //push intruction into JTAG IR
  instruction_capture(opcodes[3]);
  //now EXTEST should be loaded into DR
  //step through DR and shift the output on TDO
  uint32_t BSR_SCAN;
  BSR_SCAN = read_sample();
  Serial.print("BSR EXTEST SCAN: ");
  Serial.println("BSR SAMPLE SCAN: ");
  Serial.print("Carry In: ");
  Serial.println(bitRead(BSR_SCAN, 13));
  Serial.print("Parallel Input A: ");
  Serial.print(bitRead(BSR_SCAN, 12));
  Serial.print(bitRead(BSR_SCAN, 11));
  Serial.print(bitRead(BSR_SCAN, 10));
  Serial.println(bitRead(BSR_SCAN, 9));
  Serial.print("Parallel Input B: ");
  Serial.print(bitRead(BSR_SCAN, 8));
  Serial.print(bitRead(BSR_SCAN, 7));
  Serial.print(bitRead(BSR_SCAN, 6));
  Serial.println(bitRead(BSR_SCAN, 5));
  Serial.print("Carry Out: ");
  Serial.println(bitRead(BSR_SCAN, 4));
  Serial.print("Parallel Output: ");
  Serial.print(bitRead(BSR_SCAN, 3));
  Serial.print(bitRead(BSR_SCAN, 2));
  Serial.print(bitRead(BSR_SCAN, 1));
  Serial.println(bitRead(BSR_SCAN, 0));
  // Serial.print(BSR_SCAN, BIN);
  // Serial.print(BSR_SCAN, BIN);
  Serial.println();
}

void preload(uint32_t BSR_INSTR)
{
  Serial.println("Initializing PRELOAD push...");
  //push intruction into JTAG IR
  instruction_capture(opcodes[2]);
  //now PRELOAD should be loaded into DR
  //step through DR and shift the input through TDI
  push_preload(BSR_INSTR);

}

void push_preload(uint32_t instr)
{
  //We begin back in run-test/idle
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Select-DR-Scan");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Capture-DR");
  for(int i = 0; i < bsr_len; i++)
  {
    tck_pulse();
    Serial.println("In Shift-IR");
    digitalWrite(TDI, bitRead(instr, i)); //shift instruction opcode in lsb first
  }
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Exit1-DR");
  tck_pulse();
  Serial.println("In Update-DR");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Run-Test/Idle State");
}

void sample()
{
  Serial.println("Initializing SAMPLE scan...");
  //push intruction into JTAG IR
  instruction_capture(opcodes[1]);
  //now SAMPLE should be loaded into DR
  //step through DR and shift the output on TDO
  uint32_t BSR_SCAN;
  BSR_SCAN = read_sample();
  Serial.println("BSR SAMPLE SCAN: ");
  Serial.print("Carry In: ");
  Serial.println(bitRead(BSR_SCAN, 13));
  Serial.print("Parallel Input A: ");
  Serial.print(bitRead(BSR_SCAN, 12));
  Serial.print(bitRead(BSR_SCAN, 11));
  Serial.print(bitRead(BSR_SCAN, 10));
  Serial.println(bitRead(BSR_SCAN, 9));
  Serial.print("Parallel Input B: ");
  Serial.print(bitRead(BSR_SCAN, 8));
  Serial.print(bitRead(BSR_SCAN, 7));
  Serial.print(bitRead(BSR_SCAN, 6));
  Serial.println(bitRead(BSR_SCAN, 5));
  Serial.print("Carry Out: ");
  Serial.println(bitRead(BSR_SCAN, 4));
  Serial.print("Parallel Output: ");
  Serial.print(bitRead(BSR_SCAN, 3));
  Serial.print(bitRead(BSR_SCAN, 2));
  Serial.print(bitRead(BSR_SCAN, 1));
  Serial.println(bitRead(BSR_SCAN, 0));
  // Serial.print(BSR_SCAN, BIN);
  Serial.println();
}

//1000100010
//0001 + 0001 = 0 0010

//11000100100
//0011 + 0001 = 0 0100

//10011000100101
//1 + 0011 + 0001 = 0 0101

uint32_t read_sample()
{
  //We begin back in run-test/idle
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Select-DR-Scan");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Capture-DR");
  uint32_t bit;
  uint32_t scan_chain;
  for(int i = 0; i < bsr_len; i++)
  {
    tck_pulse(); //TMS remains low and pulse clock so we can read next value on negedge
    Serial.println("In Shift-DR");
    //slight delay may need to be added
    //data should be valid @ negedge
    bit = (GPIO.in >> TDO) & (uint32_t)1;
    scan_chain = scan_chain | (bit << i);
    Serial.print("Bit #");
    Serial.print(i);
    Serial.print(": ");
    Serial.println(bit);
  }
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Exit1-DR");
  tck_pulse();
  Serial.println("In Update-DR");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Run-Test/Idle State");
  return scan_chain;
}

void idcode() 
{
  Serial.println("Initializing IDCODE scan...");
  //push instruction into JTAG IR
  instruction_capture(opcodes[4]);
  //now IDCODE should be loaded into DR
  //must step through the DR and read output on TDO
  read_id();
  //now lets check the full IDCODE
  Serial.print("IDCODE: ");
  Serial.print(deviceID, BIN);
  Serial.println();
}

void read_id()
{
  //We begin back in run-test/idle
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Select-DR-Scan");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Capture-DR");
  uint32_t bit;
  for(int i = 0; i < 32; i++)
  {
    tck_pulse(); //TMS remains low and pulse clock so we can read next value on negedge
    Serial.println("In Shift-DR");
    //slight delay may need to be added
    //data should be valid @ negedge
    bit = (GPIO.in >> TDO) & (uint32_t)1;
    deviceID = deviceID  | (bit << i);
    Serial.print("Bit #");
    Serial.print(i);
    Serial.print(": ");
    Serial.println(bit);
  }
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Exit1-DR");
  tck_pulse();
  Serial.println("In Update-DR");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Run-Test/Idle State");
}

void instruction_capture(int opcode)
{
  //assume we start in test logic reset state
  digitalWrite(TMS, LOW); 
  tck_pulse(); 
  Serial.println("In Run-Test/Idle State");
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Select-DR-Scan");
  tck_pulse();
  Serial.println("In Select-IR-Scan");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Capture-IR");
  for(int i = 0; i < opcode_len; i++)
  {
    tck_pulse();
    Serial.println("In Shift-IR");
    digitalWrite(TDI, bitRead(opcode, i)); //shift instruction opcode in lsb first
  }
  digitalWrite(TMS, HIGH);
  tck_pulse();
  Serial.println("In Exit1-IR");
  tck_pulse();
  Serial.println("In Update-IR");
  digitalWrite(TMS, LOW);
  tck_pulse();
  Serial.println("In Run-Test/Idle State");
}

void tck_pulse() //~20kHz clock pulse 50 ms clock period
{
  // pulse pin 12
  delayMicroseconds(half_period); //on
  GPIO.out_w1ts = ((uint32_t)1 << TCK); //posedge
  delayMicroseconds(half_period); //on
  GPIO.out_w1tc = ((uint32_t)1 << TCK); //negedge
}






