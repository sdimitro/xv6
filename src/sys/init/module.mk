dir_1      := sys/init
source     := initcode.S
# local_bins := $(addprefix $(dir_1)/, initcode)
local_src  := $(addprefix $(dir_1)/,$(source))
local_objs := $(subst .c,.o,$(filter %.c,$(local_src))) \
              $(subst .S,.o,$(filter %.S,$(local_src)))

# TODO: If you don't have .c files then take out the filters..

# TODO: On the variables above rename source to local_src
# and then just add the prefix function below? Just consider
# that

objects  += $(local_objs)
sources  += $(local_src)
binaries += initcode
toclean  += $(dir_1)/*.asm $(dir_1)/*.out $(dir_1)/*.o $(dir_1)/*.d

initcode: $(dir_1)/initcode.out $(dir_1)/initcode.o
	$(OBJCOPY) -S -O binary -j .text $(dir_1)/initcode.out $@
	$(OBJDUMP) -S $(dir_1)/initcode.o > $(dir_1)/initcode.asm

# TODO: Find out if there is a way to not keep using $(dir_1)

$(dir_1)/initcode.out: $(dir_1)/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $@ $<

# TODO: Not sure if I need the -I. below

$(dir_1)/initcode.o: $(dir_1)/initcode.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $< -o $@
