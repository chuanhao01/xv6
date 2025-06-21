# Speed up system calls

Referencing trapframe, we allocate a pointer to be stored in the `proc`
This is so that we can refer to the `va` of the `usyscall` pointer

We then follow the `allocproc` function as to how a `proc` mem is setup
The `trapframe` and `usyscall` ask for a physical page of memory to be allocated for itself.
We then `mappages` to map the `pa` to the `va`, with the correct flags

We must also remember to add in the free functions for this page of memory since we at the kernel are managing this page of memory and its not with the user.

The functions being `proc_freepagetable` and `freeproc` (Following the logic of tracking where `trapframe` is managed)

After that we follow when `allocproc` is called, since this means a `proc` is made for a user process. This is done for the first process and when it forks. (`userinit` and `fork`).

In this case, these functions then setup/write the data to the `proc` struct which is where we will then write to the struct with the struct pointer.
Therefore, in C code, `p->usyscall->pid` is using the `va` which then write the actual data to the physical memory. (This is also valid since we are still in kernel mode)

Sidenote on the question:
This is faster than a syscall, since we do not need to setup the entire syscall chain, shift into kernel mode, run the syscall and return the value.
Instead, since we have the `va` of the `usyscall` page and `usyscall` struct def, we can directly access the memory/data.
