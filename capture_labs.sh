#!/bin/bash
# Runs every Linux-side command from Labs 1, 2, 4, 5, 6 and saves the real
# output to ~/lab-outputs/labN.txt. Run on YOUR laptop:  bash capture_labs.sh
# Take screenshots of the terminal as it scrolls (or of the .txt files) for the Figures.
# Commands that must be typed INSIDE xv6 (QEMU) are listed at the end.

OUT=~/lab-outputs; mkdir -p "$OUT"
run() { echo; echo "\$ $*"; bash -c "$*" 2>&1; }

########## LAB 1 ##########
{
mkdir -p ~/os-lab1 && cd ~/os-lab1
echo "===== Before you start ====="
run whoami; run uname -a; run uptime
echo "===== Part 1 Files ====="
run pwd; run "ls -la /"; run "ls -la ~"; run "cd /etc && ls | head"
mkdir -p demo && cd demo
run 'echo "hello operating systems" > note.txt'
run "cp note.txt copy.txt"; run "mv copy.txt renamed.txt"; run "ls -l"; run "rm renamed.txt"
run "ls -l note.txt"; run "chmod 600 note.txt"; run "ls -l note.txt"; run "chmod 644 note.txt"
echo "===== Part 2 Processes ====="
run "ps aux | head"; run "ps aux | wc -l"; run "top -b -n 1 | head -15"
run "ps -p 1 -o pid,comm,args"
sleep 300 & P=$!
run "ps -ef | grep [s]leep"
run "ls /proc/$P/"; run "head -20 /proc/$P/status"
echo "===== Part 3 Memory ====="
run "free -h"; run "head -6 /proc/meminfo"; run "grep VmRSS /proc/$P/status"
kill $P
echo "===== Part 4 Devices ====="
run "df -h"; run lsblk; run "du -sh ~/os-lab1"; run "ls -l /dev | head"; run "mount | head"
run "findmnt /"
} > "$OUT/lab1.txt" 2>&1

########## LAB 2 / 4 / 6 (host side, xv6 source) ##########
{
cd ~/xv6-riscv || { echo "no ~/xv6-riscv"; exit; }
echo "===== Lab 2 Part 3 ====="
run 'sed -n "1,40p" user/ls.c'; run 'sed -n "1,30p" user/cat.c'
run "cat user/user.h"; run 'grep -n "sys_read\|sys_write" kernel/sysfile.c | head'
echo "===== Lab 4 Part 1 ====="
run 'grep -n "pause\|sleep" user/user.h'; run "cat user/sleep.c"
run "grep -n '_sleep\|_args\|_mystat\|_find' Makefile"
echo "===== Lab 4 Part 4 ====="
run "wc -l user/sh.c"; run 'grep -n "#define" user/sh.c'
run 'grep -n "case " user/sh.c'; run 'grep -n "cd" user/sh.c | head'
run "grep -n '\*\|\\\$' user/sh.c | head -20"
echo "===== Lab 6 ====="
run "cat kernel/stat.h"
run 'grep -n "define BSIZE\|define NDIRECT\|define NINDIRECT\|define DIRSIZ" kernel/fs.h'
run 'grep -n -A12 "struct dinode" kernel/fs.h'
run 'grep -n "nlink--\|nlink-" kernel/sysfile.c'
run "make clean >/dev/null; make fs.img 2>&1 | grep nmeta"
} > "$OUT/xv6_host.txt" 2>&1

########## LAB 4 Part 2/3 (bash side) ##########
{
mkdir -p ~/shtest && cd ~/shtest && touch README a.c b.c
run 'echo hello > f ; cat < f'; run 'ls | grep READ'; run '(echo a; echo b) | wc'
run 'echo one ; echo two'; run 'echo bg & wait'; run 'ls *'; run 'echo $HOME'
run 'echo "a b"'; run 'mkdir -p d ; cd d ; ls ..'
if [ -f ~/xv6-riscv/user/args_linux.c ] || [ -f ~/args_linux.c ]; then
  SRC=$(ls ~/xv6-riscv/user/args_linux.c ~/args_linux.c 2>/dev/null | head -1)
  gcc -o args "$SRC"
  run './args one   two   three'; run './args *.c "x y"'; run './args $HOME'; run "./args 'single quoted'"
fi
} > "$OUT/lab4_bash.txt" 2>&1

########## LAB 5 ##########
{
mkdir -p ~/os-lab5 && cd ~/os-lab5 && rm -rf ./*
run whoami
echo "===== Part 1 ====="
run "ls /"; run "ls -ld /etc /etc/passwd /bin /dev/null /tmp"; run "ls -l /dev | head"
run "file /usr/bin/ls /etc/passwd /bin"; run "du -sh /var/log 2>/dev/null ; du -sh /usr 2>/dev/null"
run "ls -l /dev | grep '^b' | head -3"
echo "===== Part 2 ====="
run "echo hello > notes.txt"; run "stat notes.txt"; run "ls -li notes.txt"
run "ln notes.txt hard.txt"; run "ls -li notes.txt hard.txt"; run "rm notes.txt"
run "cat hard.txt ; ls -li hard.txt"
run "ln -s hard.txt soft.txt"; run "ls -li hard.txt soft.txt"; run "cat soft.txt"
run "rm hard.txt"; run "cat soft.txt ; ls -l soft.txt"
run "mkdir d ; ls -ld d"; run "mkdir d/x d/y ; ls -ld d"
run "echo x > one.txt ; ls -l one.txt ; du -h one.txt"
run "truncate -s 1G big.img ; ls -lh big.img ; du -h big.img"; run "rm big.img"
echo "===== Part 3 ====="
run "echo secret > s.txt"; run "chmod 600 s.txt ; ls -l s.txt"
run "chmod 000 s.txt ; cat s.txt"; run "chmod u+r s.txt ; cat s.txt"
run "umask ; touch new.txt ; mkdir newdir ; ls -ld new.txt newdir"
run "mkdir box ; echo hi > box/f"
run "chmod u=r,go= box ; ls box ; cat box/f"
run "chmod u=x,go= box ; ls box ; cat box/f"
run "chmod 755 box"
run "ls -l /usr/bin/passwd ; ls -ld /tmp"; run "cat /etc/shadow"; run "ls -l /etc/shadow"
echo "===== Part 4 ====="
run lsblk; run "df -h"; run 'mount | grep " / "'
run "grep -c processor /proc/cpuinfo"; run "head -3 /proc/meminfo"
run "head -5 /proc/self/status"; run "ls -l /proc/self/fd"
} > "$OUT/lab5.txt" 2>&1

cat <<'EOF'
Done. Outputs are in ~/lab-outputs/ (lab1.txt, xv6_host.txt, lab4_bash.txt, lab5.txt).

Now run these INSIDE xv6 (cd ~/xv6-riscv; make clean; make qemu) and screenshot:
  Lab 2:  ls | cat README | echo hello xv6 | ls | grep c | wc README | sleep 10 | sleep
  Lab 4:  sleep 20 | sleep | echo hello > f ; cat < f | ls | grep READ
          (echo a; echo b) | wc | echo one ; echo two | echo bg & | ls * | echo $HOME
          echo "a b" | mkdir d ; cd d ; ls .. | /ls  (from inside d)
          args one   two   three | args *.c "x y" | args $HOME | args 'single quoted'
  Lab 6:  ls | mkdir a | ls a | mystat README . console | ln README r2 | mystat README r2
          rm README | mystat r2 | cat r2 | wc | mkdir averyveryverylongname | ls
          mkdir a/b | echo x > a/b/r2 | echo y > a/r2 | ln cat r2 | find . r2 | find a b
Exit QEMU: Ctrl-A then X.
EOF
