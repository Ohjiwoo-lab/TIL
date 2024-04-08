# 네트워크 아키텍처

데이터센터에 네트워크 장비(스위치, 라우터 등)을 어떻게 배치하느냐에 따라 아키텍처가 달라진다.

## 3계층 아키텍처

이는 전통적인 네트워크 아키텍처이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/912fd19d-3f4e-4309-b0ab-b93f8eb8dbf5)   
출처: [Hierarchical LAN design Model (with. 네트워크 디자인)](https://white-polarbear.tistory.com/100)

네트워크 장비들이 계층을 이루고 있고, 각각의 계층에서 수행하는 역할이 다르다. 이러한 계층형 구조는 초기에 구축하기에 용이하지만 구조를 변경하기에 쉽지 않다는 특징을 가진다. 그래서 네트워크 성능을 개선하기 위해 서버의 개수를 늘리는 Scale-out 방식보다는 서버 자체의 성능을 업그레이드하는 Scale-up 방식을 사용한다. 과거에는 클라이언트와 서버 간의 트래픽(North-South Traffic)이 주를 이룰 때 효과적인 구조였다.

각 계층이 수행하는 일은 다음과 같다.

- `Access Layer`: 서버와 직접적으로 연결되는 부분으로, 비인가 장비의 접근을 차단하는 역할을 맡고 있다.

- `Distribution Layer`: L2 스위치와 L3 스위치로 구성되어 있다. Access Layer와는 L2 스위치로 연결되어 있으며, Spanning-Tree에서 루트 스위치 역할을 수행한다. (이는 STP에 대해 정리하면서 추가로 다뤄보겠다.) Core Layer와는 L3 스위치로 연결되어 있고, IP Routing을 위한 기본적인 정보를 제공한다.

- `Core Layer`: 흔히 백본이라고 불리는 부분이며, 모든 IP에 대한 정보를 가지고 라우팅을 수행한다.

만약 서버끼리 통신을 해야 한다면, Access Layer -> Distribution Layer -> Core Layer를 모두 거쳐야 하기 때문에 지연시간이 증가할 것이다. 그래서 서버와 클라이언트의 통신에서 좋은 효과를 볼 수 있는 것이다.

## Spine-Leaf 아키텍처

3계층 아키텍처는 클라이언트와 서버 간의 트래픽이 많을 경우 효과적이라고 하였다. 그런데 점점 MSA(Micro Service Architecture)로 구조가 변화하면서 클라이언트와 서버 간이 아닌, 서버와 서버 간의 트래픽(East-West Traffic)이 주를 이루게 되었다. 이에 따라 기존의 전통적인 아키텍처로는 이러한 트래픽에 제대로 대응할 수 없었다. 또한 네트워크 장비를 추가하기에도 적합하지 않았다. 이에 장비의 추가가 용이하며 서버 간의 효율적인 통신임 가능하도록 한 Spine-Leaf 아키텍처가 등장하게 되었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/8682614d-6b34-485d-8a3c-1850af7f3d51)   
출처: [Spine and Leaf Architecture (feat. Data Center Network Architecture)](https://white-polarbear.tistory.com/101)

해당 아키텍처에서는 Spine과 Leaf로 2계층으로 구성되어 있다. 모든 서버들은 Leaf 스위치에 연결되고, Spine 스위치는 백본 역할을 수행한다. Leaf 스위치끼리는 연결하지 않으면서 모든 Spine 스위치와 연결되어 있으므로 Spine 스위치의 장애에도 유연하게 대응할 수 있다. 여기서 중요한 점은 3계층 아키텍처에서와 달리 서버끼리 통신할 때 단 2홉만을 거치면 된다는 것이다.(Leaf -> Spine -> Leaf) 그래서 서버끼리의 낮은 지연시간으로 통신할 수 있다는 장점이 있다. 

또한 간단하게 Leaf 스위치를 추가함으로써 Scale-out이 가능하다. 단, 무한정 Leaf 스위치를 늘릴 수는 없다. 모든 Leaf 스위치가 Spine과 연결되어야 하므로, Spine 스위치의 포트 개수에 영향을 받기 때문이다. 만약 Leaf 스위치를 추가하였는데 더 연결할 Spine 스위치가 없다면, 새로운 Spine 스위치도 도입해야 할 것이다.

2가지 아키텍처 중 무엇이 더 좋다라고 이야기할 수는 없을 것이다. 각 서비스의 상황에 맞게 아키텍처를 적절히 구성하는 것이 가장 중요하다.

# Reference

[Hierarchical LAN design Model (with. 네트워크 디자인)](https://white-polarbear.tistory.com/100)   
[Spine and Leaf Architecture (feat. Data Center Network Architecture)](https://white-polarbear.tistory.com/101)

# History

📌 2024-4-8: 3계층 아키텍처와 Spine-Leaf 아키텍처 정리   