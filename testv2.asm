@code
@pub main
main:
  xor r1 r1
  .loop:
    inc r1
  jmp .loop

@data
testbool:   u1 = 1
testbyte:   u8 = 0xFF
testint:    i32 = -42
testuint:   u16
teststr:    u8[] = "Hello, World!\0"
testarray:  u8[256]
testarray2: u8[4] = [0, 1, 2, 3]
testarray3: u8[69] = [14; 69]