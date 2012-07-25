# Initial Makefile to create the second stage loader from sources 
# stored in SRC directory
# J J Larkworthy 20 March 2006
#********************************************************************
# JJL: 21/07/06 Add debugging to compile options.

# this is a stand alone system so needs a custom linking and building script.
# Cross compiled for the ARM system as well.
#

BUILD_TIME := "$(shell date)"

# architecture set up options.
ARCH			?= arm
CROSS_COMPILE		?= arm-none-linux-gnueabi-
PLL_FREQUENCY_PROMPT 	?= 0
PLL_FIXED_INDEX		?= 10

# now for the commands needed.
AS		= $(CROSS_COMPILE)as
LD		= $(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE)gcc
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
AWK		= awk
GENKSYMS	= scripts/genksyms/genksyms
DEPMOD		= /sbin/depmod
KALLSYMS	= scripts/kallsyms
PERL		= perl
CHECK		= sparse
CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__
MODFLAGS	= -DMODULE
LDFLAGS_MODULE  = -r
ASFLAGS         = -mapcs-32 -g 
CFLAGS_KERNEL	= 
AFLAGS_KERNEL	=
INCLUDE         = -Iinclude
LDOPTS          = -M -nostdlib --verbose --gc-sections
CCOPTS          = -DPLL_FIXED_INDEX=$(PLL_FIXED_INDEX) -DPLL_FREQUENCY_PROMPT=$(PLL_FREQUENCY_PROMPT) $(INCLUDE) -O2 -c -x c -ffunction-sections -fdata-sections -fno-unwind-tables -Wall -Werror -ggdb -DBUILD_DATE='$(BUILD_TIME)'
OBJCOPYFLAGS    = -O binary -R .note -R .comment -S

ifdef COPRO_COUNT
ASFLAGS += --defsym COPRO_COUNT=$(COPRO_COUNT)
endif

ifdef USE_UARTB
CCOPTS += -DCONFIG_UARTB
endif

OBJDIR = ./obj
SRCDIR = ./src

OBJECTS = $(OBJDIR)/start.o \
	  $(OBJDIR)/stage1.o \
	  $(OBJDIR)/sata.o \
	  $(OBJDIR)/dma.o \
	  $(OBJDIR)/pll.o \
	  $(OBJDIR)/ns16550.o \
	  $(OBJDIR)/debug.o \
	  $(OBJDIR)/crc32.o \
	  $(OBJDIR)/build.o \
	  $(OBJDIR)/ddr_oxsemi.o 

all : stage1.wrapped $(OBJDIR)/. tools/packager

$(OBJDIR)/%.o : $(SRCDIR)/%.c Makefile
	mkdir -p $(OBJDIR)
	$(CC) $(CCOPTS)  $< -o $@

$(OBJDIR)/%.o : $(SRCDIR)/%.S Makefile
	mkdir -p $(OBJDIR)
	$(AS) $(ASFLAGS) $< -o $@

%.d : %.c
	$(CC) -M $(CCOPTS) $< > $@.$$$$; \
	sed 's,\(.*\)\.o[ :]*,$(OBJDIR)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

stage1.wrapped: stage1.elf 
	$(OBJCOPY) $(OBJCOPYFLAGS) stage1.elf stage1.bin
	../boot-tools/update_header stage1.bin
	mv stage1.bin stage1.wrapped

./tools/packager : ./tools/packager.c tools/Makefile
	$(MAKE)  -C ./tools

stage1.elf: $(OBJECTS) linkfile 
	$(LD) $(LDOPTS) -T linkfile $(OBJECTS) -o $@ > $@.map

.PHONY : .lastmake

$(OBJDIR)/build.o : .lastmake

$(OBJDIR)/. :
	mkdir $(OBJDIR)
	
clean :
	@rm -f $(SRCDIR)/*.d
	@rm -rf $(OBJDIR)
	@rm -f stage1.bin
	@rm -f stage1.wrapped
	@rm -f stage1.elf
	$(MAKE)  -C ./tools clean
	@rm -f stage1.elf.map
