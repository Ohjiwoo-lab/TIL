# Link Aggregation Group이란?

Link Aggregation Group(LAG)이란, 장비 간의 대역폭을 늘리기 위해 여러 물리적 포트를 하나의 논리적 포트로 합치는 기술을 말한다.

> 대역폭이란 일정 시간 동안 전송 가능한 데이터의 양을 말한다. 만약 대역폭이 10Mbps라면 초당 10Megabits의 데이터를 보낼 수 있다는 의미이다. 10Megabits는 1.25MB를 의미한다.

네트워크 기기에서 하나의 포트 당 정해진 대역폭이 존재하는데, 요구사항에 따라 더 높은 대역폭이 필요할 수도 있다. 이럴 경우 이전에는 대역폭을 늘리기 위해 더 성능이 좋은 기기로 교체할 수밖에 없었고, 이는 막대한 비용을 부담해야 했다. 이를 해결하기 위해 등장한 개념이 LAG이다. LAG을 이용하면 기기를 교체하지 않아도 포트 여러 개를 하나로 연결하여 간단히 대역폭을 늘릴 수 있다는 장점이 있다. 아래 그림을 살펴보자.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1e244bbe-25ab-438d-adaf-43a1ba64b882)
출처 : [TIL. 339 LACP 개념 및 동작원리 , 설정 , 장.단점](https://velog.io/@belper6/TIL.-339-LACP-%EA%B0%9C%EB%85%90-%EB%B0%8F-%EB%8F%99%EC%9E%91%EC%9B%90%EB%A6%AC-%EC%84%A4%EC%A0%95-%EC%9E%A5.%EB%8B%A8%EC%A0%90)

그림에서는 1번과 2번 포트를 하나의 논리적 포트로 연결하였다. 각 포트의 대역폭이 100Mbps라고 했을 때, 논리적 포트의 대역폭은 100Mbps + 100Mbps = 200Mbps가 된다. 스위치에 존재하는 물리적 포트의 개수만큼 확장할 수 있기 때문에 최대 600Mbps까지 대역폭을 늘릴 수 있다.

LAG을 사용하기 전에는 네트워크 트래픽이 100Mbps를 넘어갈 때 병목 현상이 발생했을 것이다. 하지만 이제 논리적 포트로 200Mbps까지의 트래픽을 감당할 수 있게 된 것이다.

## LACP

LACP는 Link aggregation Contorol Protocol로, LAG을 구현하기 위한 프로토콜이다. IEEE에서 발표한 표준 프로토콜이며, 2계층에서 동작한다. 표준으로 사용되기 때문에 네트워크 기기 공급사에 상관없이 동일하게 사용된다. 다만, Cisco에서는 PAgP(Port Aggregation Protocol)이라는 독자적인 프로토콜을 개발하여 사용 중이다.

다만 무조건 LACP를 설정할 수 있는 것은 아니다. 연결할 모든 포트의 대역폭이 동일해야 하며, 짝수로만 설정할 수 있다. 포트 6개를 묶는 것은 가능하지만 포트 7개를 묶지는 못한다는 것이다. 또한 LACP를 설정하려는 기기 간에 1:1 관계만 가능하다. 만약 여러 기기를 하나의 논리 기기로 만든 뒤 LACP를 설정하고 싶다면, MC-LAG 등을 이용해야 한다.

LACP는 LACPDU(LACP Data Unit)라고 불리는 프레임을 사용하여 논리 인터페이스를 구성한다. LACP 설정 시에 Active 모드와 Passive 모드가 있다. Active 모드는 LACPDU를 먼저 송신한 뒤, 상대방이 응답을 보내면 LACP를 구성하는 방식이고, Passive 모드는 대기 상태로 있다가 LACPDU를 수신하고 나면 응답을 보내서 LACP를 구성하는 방식이다.

> Passive 모드는 먼저 LACPDU를 전송하지 않기 때문에 Passive-Passive 구성은 불가능하다. Active-Active, Active-Passive 구성만 가능하다.

서로 LACPDU를 주고받고 나면 두 기기 간 LACP가 구성되고, 향상된 대역폭으로 데이터를 보낼 수 있게 된다.

## LAG을 이용했을 때의 장점

LAG를 사용했을 때의 장점은 다음과 같다.

### 1. 비용을 줄일 수 있다.

장비를 교체하지 않아도 쉽게 대역폭을 늘릴 수 있기 때문이다. 네트워크 장비는 성능이 올라갈 수록 몹시 비싸지기 때문에 LAG을 이용하면 비용을 많이 절감할 수 있을 것이다.

### 2. Failover를 수행할 수 있다.

Failover는 시스템에 장애가 발생했을 때 예비 시스템으로 자동 전환되어 정상 운영될 수 있도록 하는 것이다. LAG은 어떻게 Failover를 수행할 수 있을까?

![image](https://github.com/Ohjiwoo-lab/aws-architecture-terraform/assets/74577768/f1c6c9f3-4c15-44ce-b58b-f0317321cf40)   
출처: [TIL. 339 LACP 개념 및 동작원리 , 설정 , 장.단점](https://velog.io/@belper6/TIL.-339-LACP-%EA%B0%9C%EB%85%90-%EB%B0%8F-%EB%8F%99%EC%9E%91%EC%9B%90%EB%A6%AC-%EC%84%A4%EC%A0%95-%EC%9E%A5.%EB%8B%A8%EC%A0%90)

LAG을 통해 구성한 논리 인터페이스는 여러 물리 포트로 이루어져 있다. 그렇기 때문에 물리 포트 중 하나에 장애가 발생하더라도 나머지 포트를 이용하여 문제없이 통신을 지속할 수 있다. 그림에서 1번과 2번 포트로 논리 링크를 구성해서 200Mbps 대역폭을 이용하고 있었는데, 그 중 1번 포트에 장애가 발생하더라도 나머지 2번 포트로 100Mbps 만큼의 대역폭을 사용할 수 있는 것이다.

대역폭을 늘리는 것 외에도 failover 기능을 제공하기 때문에 네트워크 이중화 방식으로도 사용된다.

# Reference

[가비아 - 네트워크 대역폭이란 무엇인가요?](https://customer.gabia.com/faq/detail/12302/12380)   
[이중화 기술 - LACP](https://velog.io/@satoshi25/%EC%9D%B4%EC%A4%91%ED%99%94-%EA%B8%B0%EC%88%A0-LACP)

# History

📌 2024-4-11: LACP 개념과 동작방식, 장점 정리   
📌 2024-4-13: LAG 내용 추가   