# vroom
A simple script to build the smallest Vlang executable possible.
Please note that this may break executables or make cryptic errors.
Also, this is a short PoC about executable optimization for V and it was
not designed for production use.

# Requirements

This script requires the following:
* Vlang compiler
* Clang
* Strip utility

# Usage

```
$ vroom [path/to/file.v or path/to/dir] -o [output_executable]
```

# Example

```
$ vroom ./example.v -o example.elf
```

# Size benchmarks

Using V 0.3.1 840370f as a baseline on x86_64.

| Tool/Compiler   | Command                                                   | Binary size |
|-----------------|-----------------------------------------------------------|-------------|
| Vroom (clang/gc)| vroom example -o example.elf                              |  44 kB      |
| V     tcc       | v example -prod -gc none -o ex.elf                        |  92 kB      |
| clang 12.0.1    | v example -prod -gc none -o s.c && clang -Oz s.c -o ex.elf| 157 kB      |
| gcc   11.2.1    | v example -prod -gc none -o s.c && gcc -Os s.c -o ex.elf  | 177 kB      |
