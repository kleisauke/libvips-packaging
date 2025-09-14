# Toolchain configuration

Changes on top of the default toolchain configuration used to generate the
`.config` files in this directory. The changes are formatted as follows:

```
$category > $option = $value -- $comment
```

## `armv7-linux-gnueabihf.config`

- Path and misc options > Prefix directory = /x-tools/${CT_TARGET}
- Path and misc options > Progress bar = DISABLE
- Target options > Target Architecture = arm
- Target options > Default instruction set mode = thumb
- Target options > Suffix to the arch-part = v7
- Target options > Architecture level = armv7-a
- Target options > Use specific FPU = neon-vfpv4
- Target options > Floating point = hardware (FPU)
- Operating System > Target OS = linux
- Operating System > Version of Linux = 4.14.329 -- Amazon Linux 2 kernel
- C-library > Version of glibc = 2.26
- C compiler > Version of GCC = 14.2.0
- C compiler > C++ = ENABLE
