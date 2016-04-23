dir_2      := kernel
source     := bio.c     \
	      console.c \
	      exec.c    \
	      file.c    \
	      fs.c      \
	      ide.c     \
	      ioapic.c  \
	      kalloc.c  \
	      kbd.c     \
	      lapic.c   \
	      log.c     \
	      main.c    \
	      mp.c      \
	      picirq.c  \
	      pipe.c    \
	      proc.c    \
	      spinlock.c\
	      string.c  \
	      swtch.S   \
	      syscall.c \
	      sysfile.c \
	      sysproc.c \
	      timer.c   \
	      vectors.S \
	      trapasm.S \
	      trap.c    \
	      uart.c    \
	      vm.c

# TODO: Isn't there anything implicit to compile .S
# files with the ASFLAFS and the .c with CFLAGS

csrc       := $(addprefix $(dir_2)/,$(filter %.c, $(source)))
cobjs      := $(subst .c,.o,$(csrc))
asmsrc     := $(addprefix $(dir_2)/,$(filter %.S, $(source)))
asmobjs    := $(subst .S,.o,$(asmsrc))
kobjs      := $(cobjs) $(asmobjs)

local_bins := $(addprefix $(dir_2)/, kernel)
local_src  := $(addprefix $(dir_2)/,$(source))
local_objs := $(kobjs)

# TODO: On the variables above rename source to local_src
# and then just add the prefix function below? Just consider
# that

objects  += $(local_objs)
sources  += $(csrc) $(asmsrc)
binaries += $(local_bins)
toclean  += $(dir_2)/*.asm $(dir_2)/*.sym $(dir_2)/vectors.S

$(dir_2)/kernel: $(kobjs) $(dir_0)/entry.o $(dir_0)/entryother $(dir_1)/initcode $(dir_2)/kernel.ld
	$(LD) $(LDFLAGS) -T $(dir_2)/kernel.ld -o $(dir_2)/kernel $(dir_0)/entry.o $(kobjs) -b binary $(dir_1)/initcode $(dir_0)/entryother
	$(OBJDUMP) -S $(dir_2)/kernel > $(dir_2)/kernel.asm
	$(OBJDUMP) -t $(dir_2)/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(dir_2)/kernel.sym

# TODO: Fix the need to include boot for mmu.h

$(asmobjs): %.o: %.S
	$(CC) -c -I $(dir_0) $(ASFLAGS) $< -o $@

$(cobjs): %.o: %.c

$(dir_2)/vectors.S: $(dir_2)/vectors.pl
	perl $< > $@
