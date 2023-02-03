# 1475 방 번호

a = [0 for i in range(10)]

str = input()

for s in str:
    num = int(s)
    a[num] += 1

a[6] = (a[6] + a[9]) // 2 + (a[6] + a[9]) % 2
a[9] = 0

print(max(a))
