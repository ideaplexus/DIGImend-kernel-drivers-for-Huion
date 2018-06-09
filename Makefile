obj-m := hid-kye.o hid-uclogic.o hid-polostar.o hid-viewsonic.o
hid-uclogic-objs := \
	hid-uclogic-core.o \
	hid-uclogic-rdesc.o \
	hid-uclogic-params.o
KVERSION := $(shell uname -r)
KDIR := /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)
UDEV_RULES := /lib/udev/rules.d/90-hid-rebind.rules
DEPMOD_CONF := /etc/depmod.d/digimend.conf
HID_REBIND := /sbin/hid-rebind
PACKAGE_NAME = digimend-kernel-drivers
PACKAGE_VERSION = 8
PACKAGE = $(PACKAGE_NAME)-$(PACKAGE_VERSION)

modules modules_install clean:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) $@

files_install:
	install -D -m 0644 digimend.conf $(DEPMOD_CONF)
	depmod -a
	install hid-rebind $(HID_REBIND)
	install -m 0644 90-hid-rebind.rules $(UDEV_RULES)
	udevadm control --reload

files_uninstall:
	rm -vf $(UDEV_RULES) $(HID_REBIND) $(DEPMOD_CONF)
	udevadm control --reload
	depmod -a

modules_uninstall:
	rm -vf /lib/modules/*/extra/hid-kye.ko \
	       /lib/modules/*/extra/hid-polostar.ko \
	       /lib/modules/*/extra/hid-uclogic.ko \
	       /lib/modules/*/extra/hid-viewsonic.ko

install: modules_install files_install

uninstall: modules_uninstall files_uninstall

dist:
	git archive --format=tar.gz --prefix=$(PACKAGE)/ HEAD > $(PACKAGE).tar.gz
