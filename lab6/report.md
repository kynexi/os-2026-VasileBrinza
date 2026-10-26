# Lab Report 6: Inside the xv6 File System
**Author:** Vasile Brînză (FAF-242)  
**Course:** Operating Systems · UTM FCIM / FAF  

## Part 1: File System Structure
- Inode types: 1 = T_DIR, 2 = T_FILE, 3 = T_DEVICE.
- Root inode number is 1. `.` and `..` both point to 1 because `/` has no parent directory.
- Directory entry `struct dirent` is 16 bytes. An empty directory has size 32 bytes (`.` and `..`).

## Part 2: Hard Links and mystat
- Implemented `user/mystat.c`.
- `ln` increased link count from 1 to 2; inode number and size remained identical.
- `rm` unlinked the filename entry, reducing link count to 1. Data blocks are deallocated in `iput()` when `nlink == 0` and `ref == 0`.
- xv6 `struct dinode` fields: `type`, `major`, `minor`, `nlink`, `size`, `addrs[NDIRECT+1]`.

## Part 3: Limits
- Filename length limited by `DIRSIZ` (14 bytes); longer names are truncated.
- Max file size: $12 \text{ direct} + 256 \text{ indirect} = 268 \text{ blocks} \times 1024 \text{ bytes} = 274,432 \text{ bytes}$ (~268 KB).
- Disk layout (`nmeta 47 (boot, super, log blocks 31, inode blocks 13, bitmap blocks 1) blocks 1953 total 2000`): 2000 blocks in total – 47 metadata blocks (boot 1, super 1, log 31, inodes 13, bitmap 1) and 1953 data blocks.

## Part 4: Recursive find
- Implemented `user/find.c` to traverse directories recursively while skipping `.` and `..`.
