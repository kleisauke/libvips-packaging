# Toolchain configuration

Changes on top of the default toolchain configuration used to generate the
`.config` files in this directory. The changes are formatted as follows:

```
$category > $option = $value -- $comment
```

## `aarch64-linux-gnu.config`

- Path and misc options > Prefix directory = /x-tools/${CT\_TARGET}
- Target options > Target Architecture = arm
- Target options > Bitness = 64-bit
- Operating System > Target OS = linux
- Operating System > Version of Linux = 4.4.268 -- Ubuntu Xenial kernel
- C-library > Version of glibc = 2.17 -- aarch64 support was introduced in this version
- C compiler > Version of GCC = 11.1.0
- C compiler > C++ = ENABLE
