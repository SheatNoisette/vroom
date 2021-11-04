# vroom
A simple script to build the smallest Vlang executable possible.
Please note that this may break executables or make cryptic errors.

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

Using V 0.2.4 73e25cc as a baseline on x86_64.

| Tool/Compiler       | Command                                            | Binary size |
|---------------------|----------------------------------------------------|-------------|
| V     tcc           | v example -o example.elf                           | 574.4 kB    |
| gcc   11.2.1        | v example -o ex.c && gcc -O3 ex.c -o example.elf   | 260.2 kb    |
| clang 12.0.1        | v example -o ex.c && clang -Oz ex.c -o example.elf | 157.1 kB    |
| Vroom (clang)       | vroom example -o example.elf                       | 44.7 kB     |
