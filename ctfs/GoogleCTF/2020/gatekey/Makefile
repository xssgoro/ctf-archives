### common ###

.PHONY: run clean all

all: runner/initramfs.cpio.gz

clean:
	rm -f gatekey/*.a gatekey/*.o gatekey/*.tmp gatekey/*.d
	rm -f database/{database,main.o}
	rm -f runner/{initramfs.cpio.gz,runner}




###  runner ###

runner/initramfs.cpio.gz: runner/runner database/database
	rm -rf runner/initramfs_build
	mkdir runner/initramfs_build
	mkdir -m 0755 runner/initramfs_build/bin
	mkdir -m 0755 runner/initramfs_build/tmp
	mkdir -m 0755 runner/initramfs_build/proc
	cp runner/runner runner/initramfs_build/bin/init
	cp database/database runner/initramfs_build/bin/database
	chmod 0755 runner/initramfs_build/bin/init
	cp runner/flagdb runner/initramfs_build/flagdb
	cd runner/initramfs_build && find . | cpio -R 0:0 -o -H newc --quiet | gzip > ../initramfs.cpio.gz
	#rm -rf runner/initramfs_build

runner/runner: runner/runner.c
	gcc -Wall -ggdb -static -O2 -o runner/runner runner/runner.c

run: runner/initramfs.cpio.gz
	runner/launch_qemu.sh




### database ###
database/main.o: database/main.c
	gcc -c -Wall -O2 -ggdb -o database/main.o database/main.c

database/database: database/main.o gatekey_lib
	gcc -static '-Wl,--unique=*gatekey*' -o database/database database/main.o gatekey/gatekey.a




### gatekey ###

.PHONY: gatekey_lib
gatekey_lib: gatekey/gatekey.a(gatekey/gatekey.o) gatekey/gatekey.a(gatekey/gatekey_setup.o) gatekey/gatekey.a(gatekey/gatekey_api.o)
gatekey/gatekey.o: gatekey/gatekey.lds gatekey/key_gate.o gatekey/gatekeyed.o gatekey/md5.o
	ld -i --script=gatekey/gatekey.lds -o gatekey/gatekey.o.tmp gatekey/key_gate.o gatekey/gatekeyed.o gatekey/md5.o
	# Detect references to undefined symbols: We really don't want anything
	# in gatekey code to reference non-gatekey code.
	ld -e 0 -o /dev/null gatekey/gatekey.o.tmp
	mv gatekey/gatekey.o.tmp gatekey/gatekey.o

ASFLAGS := -Wa,--noexecstack
CFLAGS := -mpku -ggdb

gatekey/gatekeyed.o: CFLAGS += -ffreestanding -fno-asynchronous-unwind-tables -O2
gatekey/md5.o: CFLAGS += -ffreestanding -fno-asynchronous-unwind-tables -O2

include $(wildcard gatekey/*.d)
