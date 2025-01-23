# Makefile to compile assembly files using GCC

AS = as
CC = gcc
ASFLAGS = -g
CFLAGS = -g
OUTPUT = binLED

SRC = binLED.s \
      gpioPinClr.s \
      gpioPinFSelect.s \
      gpioPinSet.s \


OBJ = $(SRC:.s=.o)

.PHONY: all clean

all: $(OUTPUT)

$(OUTPUT): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJ) $(OUTPUT)
