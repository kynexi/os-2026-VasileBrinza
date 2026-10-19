# Q1. How many requests failed?
grep -c FAIL access.log

# Q2. How many different pages were requested, and which?
cut -d' ' -f5 access.log | sort -u

# Q3. How many requests did each page get?
cut -d' ' -f5 access.log | sort | uniq -c

# Q4. Which users have the most failed requests, and how many?
grep FAIL access.log | cut -d' ' -f3 | sort | uniq -c | sort -rn | awk 'NR==1{m=$1} $1==m{print $2, $1}'

# Q5. How many requests did user3 make, and how many failed?
printf "Total: "; grep -c ' user3 ' access.log; printf "Failed: "; grep FAIL access.log | grep -c ' user3 '

# Q6. Last 3 failed requests: time and user only
grep FAIL access.log | tail -3 | cut -d' ' -f2,3

# Q7. Which login shells appear in /etc/passwd, and how many accounts use each?
cut -d: -f7 /etc/passwd | sort | uniq -c | sort -rn

# Q8. Why do ls /etc | wc -l and ls -l /etc | wc -l differ by one?
# ls -l prints an extra "total" line; ls piped to wc -l counts that line too.
