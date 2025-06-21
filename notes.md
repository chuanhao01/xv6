# How xv6 starts and kernel

1. `kernel/entry.S` is loaded in machine mode
   1. Sets up the stack for C code to run
2. calls `kernel/start.c` `start` func
   1. Runs in machine code
   2. Sets up kernel and riscv studd
3. calls `kernel/main.c` `main` to setup first user mode program
   1. sets up `userinit`, loading `initcode.S` for `exec` syscall
   2. `ecall` to run in kernel then looks up `a7` for syscall no.
   3. runs user program `init.c`

# Syscall table

| System call                           | Description                                                              |
| ------------------------------------- | ------------------------------------------------------------------------ |
| `int fork()`                          | Create a process, return child's PID.                                    |
| `int exit(int status)`                | Terminate the current process; status reported to wait(). No return.     |
| `int wait(int *status)`               | Wait for a child to exit; exit status in `*status`; returns child PID.   |
| `int kill(int pid)`                   | Terminate process PID. Returns 0, or -1 for error.                       |
| `int getpid()`                        | Return the current process's PID.                                        |
| `int sleep(int n)`                    | Pause for n clock ticks.                                                 |
| `int exec(char *file, char *argv[])`  | Load a file and execute it with arguments; only returns if error.        |
| `char *sbrk(int n)`                   | Grow process's memory by n zero bytes. Returns start of new memory.      |
| `int open(char *file, int flags)`     | Open a file; flags indicate read/write; returns an fd (file descriptor). |
| `int write(int fd, char *buf, int n)` | Write n bytes from buf to file descriptor fd; returns n.                 |
| `int read(int fd, char *buf, int n)`  | Read n bytes into buf; returns number read; or 0 if end of file.         |
| `int close(int fd)`                   | Release open file fd.                                                    |
| `int dup(int fd)`                     | Return a new file fd referring to the same file as fd.                   |
| `int pipe(int p[])`                   | Create a pipe, put read/write file descriptors in p\[0\] and p\[1\].     |
| `int chdir(char *dir)`                | Change the current directory.                                            |
| `int mkdir(char *dir)`                | Create a new directory.                                                  |
| `int mknod(char *file, int, int)`     | Create a device file.                                                    |
| `int fstat(int fd, struct stat *st)`  | Place info about an open file into `*st`.                                |
| `int link(char *file1, char *file2)`  | Create another name (file2) for the file file1.                          |
| `int unlink(char *file)`              | Remove a file.                                                           |

1111101000000000000000010100000
1000000010000000

# Page Table Flags
V- Valid
R- Readable
W- Writable
X- Executable
U- User
A- Accessed
D- Dirty (0 in page **directory**


# Note about process and mem

When a process is created
- a `proc *p` is `allocproc` in `proc.c`
- it will ask the kernel to provide a physical page pointer for trapframe with `kalloc`
   - `TRAMPOLINE` has the same `va` and `pa` based on book and in code
   - `TRAPFRAME` `va` is `TRAMPOLINE - PGSIZE` since it is 1 page below
     - But it requests a page from `kalloc`
   -
