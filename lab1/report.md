# Lab 1 — The OS as a Resource Manager

Vasile Brînză, FAF-242

---

## Introduction

The purpose of this laboratory was to understand how an operating system manages the main resources of a computer. During the lab I used a Linux terminal and tried different commands to see what is happening with files, processes, memory, and devices.

The main idea of the laboratory was not just to run commands, but to actually look at the output and understand what the operating system is doing. Some of the output was easy to understand, while some parts were new to me and I had to look at them more carefully.

---

## Part 1 — Files and Directories

In the first part, I worked with files and directories. I started by checking where I was and looking at the Linux filesystem.

Some of the commands I used were:

```bash
pwd
ls -la /
ls -la ~
cd /etc && ls | head
```

The `/` directory is the top of the Linux filesystem. There are many important directories under it, such as `/etc`, `/dev`, `/home`, `/usr`, and others.

After that, I created a directory for the laboratory and worked with a text file:

```bash
mkdir demo
cd demo
echo "hello operating systems" > note.txt
cp note.txt copy.txt
mv copy.txt renamed.txt
ls -l
rm renamed.txt
```

This showed me some basic file operations. I created `note.txt`, made a copy of it, renamed the copy, and then removed it.

### File ownership and permissions

I checked the information about `note.txt` using:

```bash
ls -l note.txt
```

The output was:

```text
-rw-r--r-- 1 kynex kynex 24 Sep 28 16:45 note.txt
```

From this I can see that the owner of the file is `kynex`, and the group is also `kynex`.

I then changed the permissions using:

```bash
chmod 600 note.txt
ls -l note.txt
```

After using `chmod 600`, the permissions were:

```text
-rw-------
```

- The first character, `-`, means that `note.txt` is a normal file.
- The next three characters, `rw-`, are the permissions for the owner. This means that I can read and write the file.
- The next three characters are `---`, which means that members of the group have no permissions.
- The last three characters are also `---`, meaning that other users have no permissions.

So, in simple terms, `chmod 600` makes the file accessible only to its owner for reading and writing.

After this, I changed the permissions back using:

```bash
chmod 644 note.txt
```

With `644`, the owner can read and write the file, while the group and other users can read it.

### Directories under `/`

I also looked at directories directly under the root directory.

- `/etc` contains configuration files used by Linux and different programs and services.
- `/dev` contains special files that represent devices and device interfaces. This was interesting to me because it is one of the places where Linux uses the idea of treating system resources like files.

### Interesting output

```text
-rw-r--r-- 1 kynex kynex 24 Sep 28 16:45 note.txt
```

I found this output useful because one command shows the file permissions, owner, group, size, date, and filename all at once.

---

## Part 2 — Processes

The second part was about processes. A process is basically a program that is currently running. The operating system creates and manages processes and decides how they use the CPU and other resources.

I first looked at the currently running processes:

```bash
ps aux | head
```

Then I checked approximately how many processes were running:

```bash
ps aux | wc -l
```

The result was around 373 lines, so there were roughly 370 processes running on the VM.

This number was a little surprising to me because I was not running hundreds of programs myself. I realized that many processes are running in the background as part of the operating system and other services.

### Starting a process

I started a `sleep` process in the background:

```bash
sleep 300 &
```

The shell gave me a PID for the process. I could then check the background jobs with:

```bash
jobs
```

and search for the process with:

```bash
ps -ef | grep sleep
```

After I finished looking at it, I stopped the process using:

```bash
kill <PID>
```

This helped me understand that every running process has its own PID, which can be used to identify and manage it.

### Looking at `/proc`

I also started another `sleep` process and checked the information that Linux provides about it:

```bash
sleep 300 &
PID=$!
cat /proc/$PID/status | head -20
```

Part of my output was:

```text
Name:	sleep
Umask:	0002
State:	S (sleeping)
Tgid:	8259
Ngid:	0
Pid:	8259
PPid:	5450
```

The PID of this process was `8259`.

The line I found most relevant was:

```text
State:	S (sleeping)
```

This makes sense because I started the `sleep` command. The process is waiting instead of actively doing some calculation.

### PID 1

The first process has PID 1. On my Linux system, it is managed by `systemd`.

PID 1 is started during the boot process and is responsible for starting and managing many system services. Before this laboratory, I knew that Linux had processes running in the background, but I did not know that there was a special first process that starts very early and helps manage the rest of the system.

### Interesting output

```text
Name:	sleep
Umask:	0002
State:	S (sleeping)
Tgid:	8259
Ngid:	0
Pid:	8259
PPid:	5450
```

I found this interesting because the `/proc` filesystem lets me see information about a running process almost like I am looking at a normal file.

---

## Part 3 — Memory

The third part was about memory management. I used the `free` command to see how much RAM and swap memory the system had.

```bash
free -h
```

The output was:

```text
               total        used        free      shared  buff/cache   available
Mem:            27Gi       4.3Gi        20Gi       263Mi       2.6Gi        22Gi
Swap:          2.0Gi          0B       2.0Gi
```

From this output, I can see that the VM has 27 GiB of RAM in total.

At the time I ran the command, about 4.3 GiB was being used and about 20 GiB was free. There was also about 22 GiB available, which is slightly different from the free value because Linux can use some memory currently occupied by caches when applications need it.

### Swap

The VM has 2.0 GiB of swap space configured. At the moment I checked it, 0 B of swap was being used.

Swap is disk space that the operating system can use as additional virtual memory when it needs it. It is slower than normal RAM because it is stored on the disk, so having free RAM is generally preferable.

I also checked some general memory information with:

```bash
cat /proc/meminfo | head -6
```

This provides information directly from the Linux kernel about the memory available on the system.

### Memory used by `sleep`

I started another `sleep` process and checked its resident memory:

```bash
sleep 300 & PID=$!
grep VmRSS /proc/$PID/status
```

The value I got was approximately:

```text
VmRSS:	    2124 kB
```

So the `sleep` process was using about 2.1 MB of physical RAM.

This did not really surprise me because `sleep` is a very simple program. It mostly just waits, so I expected it to use very little memory.

### Interesting output

```text
Mem:            27Gi       4.3Gi        20Gi       263Mi       2.6Gi        22Gi
Swap:          2.0Gi          0B       2.0Gi
```

This output was useful because I could see the total memory, currently used memory, free memory, and swap all at the same time.

---

## Part 4 — Devices and Storage

The last part was about storage devices and other devices managed by Linux.

First, I checked the mounted filesystems using:

```bash
df -h
```

My output included:

```text
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           2.8G  2.1M  2.8G   1% /run
efivarfs        148K   94K   50K  66% /sys/firmware/efi/efivars
/dev/nvme0n1p5  192G   92G   91G  51% /
tmpfs            14G     0   14G   0% /dev/shm
tmpfs           5.0M   12K  5.0M   1% /run/lock
/dev/nvme0n1p1   96M   70M   27M  73% /boot/efi
tmpfs           2.8G  200K  2.8G   1% /run/user/1000
```

The important part for the laboratory is:

```text
/dev/nvme0n1p5  192G   92G   91G  51% /
```

This shows that the root filesystem `/` is mounted on `/dev/nvme0n1p5`.

### Looking at the disk

I also used:

```bash
lsblk
```

The output was:

```text
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0 953.9G  0 disk 
├─nvme0n1p1 259:1    0   100M  0 part /boot/efi
├─nvme0n1p2 259:2    0    16M  0 part 
├─nvme0n1p3 259:3    0 757.8G  0 part 
├─nvme0n1p4 259:4    0   759M  0 part 
└─nvme0n1p5 259:5    0 195.2G  0 part /
```

The main disk is `nvme0n1`, with a size of about 953.9 GB. It is divided into several partitions.

The partition containing `/` is `nvme0n1p5`.

### Size of my laboratory folder

I used:

```bash
du -sh ~/os-lab1
```

and got:

```text
12K	/home/kynex/os-lab1
```

So my laboratory folder was using about 12 KB of disk space.

I initially typed the wrong directory name (`~/osd-lab1`), so Linux returned a "No such file or directory" error. I then corrected the command and checked the actual `~/os-lab1` directory.

### Devices as files

I checked the `/dev` directory using:

```bash
ls -l /dev | head
```

The output included:

```text
total 0
drwxr-xr-x   2 root root              60 Sep 28 16:18 accel
crw-r--r--   1 root root       10,   235 Sep 28 16:18 autofs
drwxr-xr-x   2 root root             320 Sep 28 16:18 block
crw-rw----   1 root disk       10,   234 Sep 28 16:18 btrfs-control
drwxr-xr-x   3 root root              60 Sep 28 16:18 bus
crw-r--r--   1 root root            5260 Sep 28 16:18 char
crw--w----   1 root tty         5,     1 Sep 28 16:18 console
lrwxrwxrwx   1 root root              11 Sep 28 16:18 core -> /proc/kcore
```

One entry I chose is `/dev/console`. It represents the system console and provides a file-like interface for interacting with the console.

I initially tried `ls -l dev | head`, but this was not the correct path because `dev` without `/` means a directory called `dev` inside the current directory. The correct path is `/dev`, and running `ls -l /dev | head` gave me the device entries I was looking for.

### Mount information

Finally, I checked the mounted filesystems with:

```bash
mount | head
```

Part of the output was:

```text
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,relatime,size=14222752k,nr_inodes=3555688,mode=755,inode64)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,nodev,noexec,relatime,size=2853332k,mode=755,inode64)
efivarfs on /sys/firmware/efi/efivars type efivarfs (rw,nosuid,nodev,noexec,relatime)
```

The line:

```text
/dev/nvme0n1p5 on / type ext4
```

was especially useful because it directly shows that the device `/dev/nvme0n1p5` is mounted as the root filesystem `/`.

### "Everything is a file"

Based on what I saw, the phrase "everything is a file" means that Linux provides file-like interfaces for many different resources, including devices and system information.

For example, `/dev/console` is not a normal text file, but Linux still represents it through a file-like interface. This allows programs to interact with many resources using similar operations such as reading and writing.

### Interesting output

```text
/dev/nvme0n1p5 on / type ext4 (rw,relatime,errors=remount-ro)
```

I found this interesting because it connects the physical storage device with the filesystem I am actually using. It shows that `/dev/nvme0n1p5` is mounted as `/` and uses the `ext4` filesystem.

---

## Conclusion

This laboratory helped me understand the operating system as a resource manager by actually seeing four important resources in Linux: files, processes, memory, and devices/storage.

- **Files:** I used `ls -l` and `chmod` to see file ownership and permissions.
- **Processes:** I used `ps`, `kill`, and `/proc/<pid>/status` to see and manage running programs.
- **Memory:** I used `free -h` and `/proc` to see RAM, swap, and the memory used by a process.
- **Devices and storage:** I used `df -h`, `lsblk`, `/dev`, and `mount` to see disks, partitions, filesystems, and device interfaces.

The main thing I learned is that the operating system is constantly managing resources in the background. Before this lab, I mostly thought about the OS as the thing that lets me open programs and files, but now I can see that it is also responsible for organizing files, running processes, allocating memory, and communicating with hardware.