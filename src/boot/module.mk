local_dir  := boot
source     := bootmain.c bootasm.S entryother.S initcode.S
local_bins := $(addprefix $(local_dir)/, bootblock entryother initcode)
local_src  := $(addprefix $(local_dir)/,$(source))
local_objs := $(subst .c,.o,$(filter %.c,$(local_src))) \
              $(subst .S,.o,$(filter %.S,$(local_src))) \
	      $(local_dir)/bootblock.o \
	      $(local_dir)/bootblockother.o

# TODO: On the variables above rename source to local_src
# and then just add the prefix function below? Just consider
# that

objects  += $(local_objs)
sources  += $(local_src)
binaries += $(local_bins)
toclean  += $(local_dir)/*.asm $(local_dir)/*.out

# TODO: What does objcopy do?

$(local_dir)/bootblock: $(local_dir)/bootblock.o
	$(OBJDUMP) -S $< > $(local_dir)/bootblock.asm
	$(OBJCOPY) -S -O binary -j .text $< $@
	./$(local_dir)/sign.pl $@

$(local_dir)/entryother: $(local_dir)/bootblockother.o
	$(OBJCOPY) -S -O binary -j .text $< $@
	$(OBJDUMP) -S $< > $(local_dir)/entryother.asm

$(local_dir)/initcode: $(local_dir)/initcode.out $(local_dir)/initcode.o
	$(OBJCOPY) -S -O binary -j .text $(local_dir)/initcode.out $@
	$(OBJDUMP) -S $(local_dir)/initcode.o > $(local_dir)/initcode.asm

# TODO: Find out if there is a way to not keep using $(local_dir)

# TODO: Putting bootasm.o after bootmain.o in the linker
# receipe below, links an incorrect binary. Find out why
# and document the reason!

$(local_dir)/bootblock.o: $(local_dir)/bootasm.o $(local_dir)/bootmain.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@ $(local_dir)/bootasm.o $(local_dir)/bootmain.o

# TODO: Using $< for one dependecy is ok for the two rules
# below but what if I have two dependencies like the rule above?

$(local_dir)/bootblockother.o: $(local_dir)/entryother.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7000 -o $@ $<

$(local_dir)/initcode.out: $(local_dir)/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $@ $<

# TODO: Not sure if I need the -I. below

$(local_dir)/bootmain.o: $(local_dir)/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c $< -o $@

# TODO: Maybe merge .S rules?

$(local_dir)/bootasm.o: $(local_dir)/bootasm.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@

$(local_dir)/entryother.o: $(local_dir)/entryother.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@

$(local_dir)/initcode.o: $(local_dir)/initcode.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@
