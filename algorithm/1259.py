# 1259 팰린드롬수

while True:
    s = input()
    if s == '0':
        break

    s = list(s)
    if s == list(reversed(s)):
        print('yes')
    else:
        print('no')
