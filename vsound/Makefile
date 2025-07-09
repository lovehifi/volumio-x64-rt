KERNEL_SRC = /lib/modules/$(shell uname -r)/build

EXTRA_CFLAGS := $(EC) -I$(KERNEL_SRC)/../include 
EXTRA_CFLAGS += -O3
EXTRA_CFLAGS += -Wno-unused-result
EXTRA_CFLAGS += -Wno-declaration-after-statement
#EXTRA_CFLAGS += -DDEBUG_VSOUND
EXTRA_CFLAGS += -DCONFIG_SMPD_OPTION_RPI_DAC_32BIT_786KHZ

OBJS    = vsound.o
obj-m := $(OBJS)

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(shell pwd) modules

clean:
	-rm -f *.[oas] *.ko *.mod.c .*.d .*.tmp .*.cmd *.symvers *.order *.mod
	-rm -rf .tmp_versions
