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

# Print a page table

Adding dbkpgtbl for more debugging

Digging in
It seems that the pagetable_t pointer is the pointer to the start of an allocated physical page of memory. (4096 bytes)
This page contains 512 PTE if u access the memory stored at that address.

```
pagetable_t * -> 0x0000000087f22000
i=0 0x0000000087f22000 0x0000000021fc7801
i=1 0x0000000087f22008 0x0000000021fc7802
...
```

Each increment is 8 btyes since its a uint64 pointer(64 bits/8 bytes per int)
Since the physicall memory allocated is 1 page so 4096 btyes, with 512 pointers which is 512 PTEs


Reading `freewalk`
It seems that we iterate through all the 512 pages per PTE


Thinking from VA to PA
1. pagetable_t gives the base address of the pagetable
2. The VA is split from MAXVA into `PGSIZE(4096)` pages for each PTE
   1. I think
   2. `4096` is also 12 bits
3. Starting from the bottom, `VA=0x0` and move 1 page up at a time, next being `VA=0x1000` (Cause 4069 in hex is 1000)
   1. If not you will be in the previous page? (Not sure how they align again then?)
4. Then the VA is used to calculate the level offsets
   1. Since the L2 address only changes when the far end 9 bits changes
      1. This means that the first `|9 bit L2|9 bit L1|9 bit L0|12 offset`, 9 + 9 + 12 bits don't affect the first PTE
   2. We then use the level offset to select the page using the `pagetable_t` as a base for L2
5. From this we can get the `PA` (which is a pointer to the actual memory) of the `PPN`j
