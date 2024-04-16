# Monotonic Stack

Monotonic Stack은 단조 스택으로, 항상 오름차순 또는 내림차순으로 값이 유지되는 스택입니다.

만약 오름차순으로 스택을 유지한다고 하면, 스택의 가장 최상단에 있는 값과 비교하여 현재 값이 클 때에만 삽입합니다. 만약 스택에 있는 값이 더 크다면, 현재 값보다 작은 수가 나올 때까지 스택을 pop 합니다.   

Monotonic Stack을 사용하는 가장 대표적인 알고리즘은 `다음에 가장 처음 등장하는 큰 값 또는 작은 값 구하는` 문제입니다.   

어떠한 리스트 [1,2,3,5,2] 가 있다고 하고, 각 값을 기준으로 처음 자신보다 작은 값이 나올 때가 언제인지를 구해야한다고 가정해봅시다. 그럼 다음과 같은 순서로 구할 수 있을 것입니다.
- 스택에 1 삽입 → 현재 스택 상태: [1]

- 2가 1보다 크므로 스택에 2 삽입 → 현재 스택 상태: [1,2]
- 3이 2보다 크므로 스택에 3 삽입 → 현재 스택 상태: [1,2,3]
- 5가 3보다 크므로 스택에 5 삽입 → 현재 스택 상태: [1,2,3,5]
- 2는 5보다 작기 때문에 스택에서 값을 꺼냄 (5 다음에 나오는 작은 값은 2) → 현재 스택 상태: [1,2,3]
- 2는 3보다도 작기 때문에 스택에서 값을 꺼냄 (3 다음에 나오는 작은 값도 2) → 현재 스택 상태: [1,2]
- 2는 2보다 크지 않기 때문에 2를 스택에 삽입 → 현재 스택 상태: [1,2,2]

→ 결과적으로 스택에 남아있는 1,2,2는 자신보다 작은 값이 등장하지 않는다.

> 모든 과정을 거칠 때까지 스택에는 값이 오름차순으로 유지됩니다. 같은 값이 등장하기 때문에 완전한 오름차순이라고 보긴 힘들지만 값이 감소하는 경우는 없습니다.
> 이런 것이 바로 Monotonic Stack입니다.

> 자신보다 작은 값을 구해야할 경우에 스택은 오름차순으로 유지되고, 큰 값을 구해야할 경우에 내림차순으로 유지됩니다.

이런 식으로 리스트에 있는 모든 값에 대해 자신보다 작은 값이 처음 나오는 시점을 구할 수가 있습니다. 그럼 문제를 하나 풀어보겠습니다!   

<hr/>

[문제 링크](https://school.programmers.co.kr/learn/courses/30/lessons/42584)   

## 문제 설명
초 단위로 기록된 주식가격이 담긴 배열 prices가 매개변수로 주어질 때, 가격이 떨어지지 않은 기간은 몇 초인지를 return 하도록 solution 함수를 완성하세요.

### 제한사항
prices의 각 가격은 1 이상 10,000 이하인 자연수입니다.
prices의 길이는 2 이상 100,000 이하입니다.

### 입출력 예
prices	          return
[1, 2, 3, 2, 3]	  [4, 3, 1, 1, 0]

### 입출력 예 설명
1초 시점의 ₩1은 끝까지 가격이 떨어지지 않았습니다.
2초 시점의 ₩2은 끝까지 가격이 떨어지지 않았습니다.
3초 시점의 ₩3은 1초뒤에 가격이 떨어집니다. 따라서 1초간 가격이 떨어지지 않은 것으로 봅니다.
4초 시점의 ₩2은 1초간 가격이 떨어지지 않았습니다.
5초 시점의 ₩3은 0초간 가격이 떨어지지 않았습니다.

## 문제 풀이
> 이 문제는 가격이 떨어지지 않는 기간을 구하는 문제입니다. 이 말을 다르게 표현해보면, 처음으로 가격이 낮아지는 시점을 구하는 문제로 바꿀 수 있습니다. 바로 Monotonic Stack을 활용하면 딱 적합합니다.

이 문제에를 풀기 위해서는 하나 추가되어야 할 것이 있습니다.

각 가격마다 가격이 떨어지지 않은 기간을 구하여야 하기 때문에, 가격의 인덱스를 함께 저장해줄 필요가 있습니다. 
리턴해줄 리스트를 0으로 초기화해둔 뒤, 만약 가격이 떨어지는 시점이 있다면 저장해두었던 인덱스를 이용하여 리턴 리스트에 값을 변경해야하기 때문입니다. 

차근차근 문제를 풀어보며 살펴봅시다.

### 초기 상태  
2가지의 리스트를 준비해야 합니다. 모노토닉 스택으로 사용할 리스트와, 결과로 리턴할 리스트입니다. 결과로 리턴할 리스트는 prices의 길이만큼 0으로 초기화합니다.
- 스택: [ ]
- 결과 리스트: [ 0, 0, 0, 0, 0 ]

### 1초 시점   
스택이 비어있으므로 스택에 ₩1을 삽입합니다. 값을 넣을 때는 시간도 함께 넣어줍니다.
- 스택: [ [1, ₩1] ]
- 결과 리스트: [ 0, 0, 0, 0, 0 ]

### 2초 시점
₩2는 스택의 가장 상단에 있는 ₩1보다 크므로 삽입합니다.
- 스택: [ [1, ₩1], [2, ₩2] ]
- 결과 리스트: [ 0, 0, 0, 0, 0 ]

### 3초 시점
₩3은 스택의 가장 상단에 있는 ₩2보다 크므로 삽입합니다.
- 스택: [ [1, ₩1], [2, ₩2], [3, ₩3] ]
- 결과 리스트: [ 0, 0, 0, 0, 0 ]

### 4초 시점
₩2는 스택의 가장 상단에 있는 ₩3보다 작습니다. 그러므로 스택에서 값을 pop하고 결과 리스트를 수정해봅시다.   

pop을 하면 [3, ₩3]이 나올 것입니다. 현재 시점은 4초, 스택에서 꺼낸 것은 3초이므로 1초간 값이 유지되었다는 것을 알 수 있습니다. 3초 시점의 ₩3은 1초 유지되어 4초 시점의 ₩2로 값이 감소하였습니다.   

그러면 결과 리스트의 3초에 해당하는 인덱스에 1을 넣어줍니다. 이때 주의할 점은 인덱스는 0부터 시작하므로 1을 빼주어야 한다는 것입니다.   

이제 스택의 최상단의 값은 ₩2로, 값이 작아지지 않으므로 삽입할 수 있습니다.   

- 스택: [ [1, ₩1], [2, ₩2], [4, ₩2] ]
- 결과 리스트: [ 0, 0, 1, 0, 0 ]

### 5초 시점
₩3은 스택의 가장 최상단에 있는 ₩2보다 크므로 삽입합니다.
- 스택: [ [1, ₩1], [2, ₩2], [4, ₩2], [5, ₩3] ]
- 결과 리스트: [ 0, 0, 1, 0, 0 ]

### 나머지 값 업데이트
현재 스택에 남아있는 값은 끝까지 값이 떨어지지 않은 것들입니다. 그래서 추가적인 계산을 해주어야 합니다.   

끝까지 값이 떨어지지 않았으므로 스택에 삽입된 시점과 전체 시간인 5초의 차이를 구하면 됩니다. 스택에서 값을 하나씩 빼면서 업데이트해줍니다.   

[ 5, ₩3 ]이 pop 되었습니다. 5초와의 차이점은 0이므로 인덱스 4에 값을 0으로 저장합니다.
- 스택: [ [1, ₩1], [2, ₩2], [4, ₩2] ]
- 결과 리스트: [ 0, 0, 1, 0, 0 ]

[ 4, ₩2 ]이 pop 되었습니다. 5초와의 차이점은 1이므로 인덱스 3에 값을 1으로 저장합니다.
- 스택: [ [1, ₩1], [2, ₩2] ]
- 결과 리스트: [ 0, 0, 1, 1, 0 ]

[ 2, ₩2 ]이 pop 되었습니다. 5초와의 차이점은 3이므로 인덱스 1에 값을 3으로 저장합니다.
- 스택: [ [1, ₩1] ]
- 결과 리스트: [ 0, 3, 1, 1, 0 ]

[ 1, ₩1 ]이 pop 되었습니다. 5초와의 차이점은 4이므로 인덱스 0에 값을 4으로 저장합니다.
- 스택: [ ]
- 결과 리스트: [ 4, 3, 1, 1, 0 ]

**스택이 비었으므로 모든 시점에 대해 계산을 완료하였음을 알 수 있습니다.**

## 코드
위에 설명한 풀이대로 제가 작성한 코드는 다음과 같습니다! [링크](https://github.com/Ohjiwoo-lab/algorithm_study/blob/main/%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%A8%B8%EC%8A%A4/2/42584.%E2%80%85%EC%A3%BC%EC%8B%9D%EA%B0%80%EA%B2%A9/%EC%A3%BC%EC%8B%9D%EA%B0%80%EA%B2%A9.py)
```python
def solution(prices):
    n=len(prices)
    answer = [0]*n
    
    stack=[]
    stack.append([0,prices[0]])
    
    time=1
    while stack and time<n:
        if stack[-1][1]<=prices[time]:
            stack.append([time,prices[time]])
            time+=1
        else:
            while stack:
                if stack[-1][1]>prices[time]:
                    idx,num=stack.pop()
                    answer[idx]=time-idx
                else:
                    break
            
            stack.append([time,prices[time]])
            time+=1
    
    while stack:
        idx,num=stack.pop()
        answer[idx]=time-1-idx
    
    return answer
```

<hr/>

📌 2023-12-14: 모노토닉 스택의 정의와 실제 문제 풀이