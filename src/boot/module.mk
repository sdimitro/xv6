local_dir  := boot
source     := bootmain.c bootasm.S
local_src  := $(addprefix $(local_dir)/,$(source))
local_objs := $(subst .c,.o,$(filter %.c,$(local_src))) \
              $(subst .S,.o,$(filter %.S,$(local_src))) \
	      $(local_dir)/bootblock.o

objects  += $(local_objs)
sources  += $(local_src)
binaries += $(local_dir)/bootblock

$(local_dir)/bootblock: $(local_dir)/bootblock.o
	$(OBJDUMP) -S $< > $(local_dir)/bootblock.asm
	$(OBJCOPY) -S -O binary -j .text $< $@
	./$(local_dir)/sign.pl $@

# TODO: Find out if there is a way to not keep using $(local_dir)

# TODO: Putting bootasm.o after bootmain.o in the linker
# receipe below, links an incorrect binary. Find out why
# and document the reason!

$(local_dir)/bootblock.o: $(local_dir)/bootasm.o $(local_dir)/bootmain.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@ $(local_dir)/bootasm.o $(local_dir)/bootmain.o

# TODO: Using $< for one dependecy is ok for the two rules
# below but what if I have two dependencies like the rule above?

$(local_dir)/bootmain.o: $(local_dir)/bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c $< -o $@

$(local_dir)/bootasm.o: $(local_dir)/bootasm.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@
