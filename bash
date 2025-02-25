
nasm -f elf64 keygen.asm -o keygen.o
ld keygen.o -o keygen
./keygen
