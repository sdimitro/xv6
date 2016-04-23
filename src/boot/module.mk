dir_0      := boot
source     := bootmain.c bootasm.S entryother.S entry.S
local_bins := $(addprefix $(dir_0)/, bootblock entryother)
local_src  := $(addprefix $(dir_0)/,$(source))
local_objs := $(subst .c,.o,$(filter %.c,$(local_src))) \
              $(subst .S,.o,$(filter %.S,$(local_src))) \
	      $(dir_0)/bootblock.o \
	      $(dir_0)/bootblockother.o

# TODO: On the variables above rename source to local_src
# and then just add the prefix function below? Just consider
# that

objects  += $(local_objs)
sources  += $(local_src)
binaries += $(local_bins)
toclean  += $(dir_0)/*.asm

# TODO: What does objcopy do?

$(dir_0)/bootblock: $(dir_0)/bootblock.o
	$(OBJDUMP) -S $< > $(dir_0)/bootblock.asm
	$(OBJCOPY) -S -O binary -j .text $< $@
	./$(dir_0)/sign.pl $@

$(dir_0)/entryother: $(dir_0)/bootblockother.o
	$(OBJCOPY) -S -O binary -j .text $< $@
	$(OBJDUMP) -S $< > $(dir_0)/entryother.asm

# TODO: Find out if there is a way to not keep using $(dir_0)

# TODO: Putting bootasm.o after bootmain.o in the linker
# receipe below, links an incorrect binary. Find out why
# and document the reason!

$(dir_0)/bootblock.o: $(dir_0)/bootasm.o $(dir_0)/bootmain.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@ $(dir_0)/bootasm.o $(dir_0)/bootmain.o

# TODO: Using $< for one dependecy is ok for the two rules
# below but what if I have two dependencies like the rule above?

$(dir_0)/bootblockother.o: $(dir_0)/entryother.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7000 -o $@ $<

# TODO: Not sure if I need the -I. below

$(dir_0)/bootmain.o: $(dir_0)/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c $< -o $@

# TODO: Maybe merge .S rules?

$(dir_0)/bootasm.o: $(dir_0)/bootasm.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@

$(dir_0)/entryother.o: $(dir_0)/entryother.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@
