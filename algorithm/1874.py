# 1874 스택 수열

n = int(input())

aws = []
temp = []
pm = []
flag = True

for i in range(n):
    aws.append(int(input()))

j = 1
for arr in aws:
    while True:
        if len(temp) == 0:
            temp.append(j)
            pm.append('+')
            j += 1
        elif arr > temp[-1]:
            temp.append(j)
            pm.append('+')
            j += 1
        elif arr < temp[-1]:
            flag = False
            break
        else:
            temp.pop()
            pm.append('-')
            break

if flag:
    for i in pm:
        print(i)
else:
    print('NO')
