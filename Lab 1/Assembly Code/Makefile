# Makefile to compile assembly files using GCC

AS = as
CC = gcc
ASFLAGS = -g
CFLAGS = -g
OUTPUT = countLMU

SRC = countLMU_Rhoa_Mindell.s \
      util/gpioPinClr.s \
      util/gpioPinFSelect.s \
      util/gpioPinSet.s \
      util/binLED.s

OBJ = $(SRC:.s=.o)

.PHONY: all clean

all: $(OUTPUT)

$(OUTPUT): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJ) $(OUTPUT)
