# VPC Peering

VPC Peering이란 2개의 VPC를 AWS의 내부 네트워크 망을 이용하여 프라이빗하게 연결할 수 있는 기능이다. VPC는 Virtual Private Cloud이기 때문에 VPC 외부에서의 접근을 근본적으로 차단한다. 그래서 서로 다른 VPC에 속해있는 리소스들끼리는 통신할 수 없었다. 하지만 VPC Peering을 이용하면 서로 다른 VPC가 마치 하나의 VPC인 것처럼 동작하기 때문에 리소스들끼리 통신이 가능해진다.

> 물론 실제로 통신이 되려면 서브넷에 Routing Table을 업데이트해줘야 한다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/47689152-f2b3-4359-9fbd-a9005e4399db)

VPC-A와 VPC-B 사이에 VPC Peering을 설정하면, VPC-A에 있는 모든 리소스들은 VPC-B의 모든 리소스와 자유롭게 통신할 수 있다. VPC-A와 VPC-B가 동일한 네트워크 환경이 되었다고 이해하면 된다. 그래서 Peering을 설정하려는 VPC는 CIDR가 겹치면 안 된다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/0b5bfe68-01d2-489e-9564-de1ab6fdd794)

만약 VPC-A의 CIDR와 VPC-B의 CIDR이 172.16.0.0/16으로 동일하다면, 해당 서브넷에 생성된 리소스의 IP가 동일한 경우가 생길 수 있다. 그림에서처럼 EC2 인스턴스의 IP가 동일하게 172.16.0.5일 수 있다는 것이다. 동일한 네트워크 속에서는 같은 사설 IP를 가질 수 없다. 해당 IP로 트래픽이 전송되면 어느 리소스로 트래픽을 전달할 지 알 수 없기 때문이다. 그런데 VPC Peering을 설정하면 논리적으로 동일한 네트워크가 되기 때문에 이러한 경우는 큰 문제가 될 수 있다. 그래서 VPC Peering을 설정하려면 IPv4 CIDR가 겹치지 않아야 한다.

VPC Peering은 2개의 VPC 간에 연결할 수 있다. 그러면 3개를 연결하려면 어떻게 해야할까? Peering은 Transitive가 불가능하다. A와 B가 연결되고, B와 C가 연결되었다고 해서 A와 C도 연결되는 것이 아니라는 것이다. 그래서 3개를 동시에 연결하고 싶다면 3개의 Peering 연결을 설정해야 한다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2ae367b6-e66b-47cf-b248-3efd1f3a1162)

## Longest Prefix Match

그렇다면 아래와 같은 아키텍처는 가능할까?

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/a109d212-372f-4e54-bfe0-41ce8042e477)

가능하다. Peering은 Transitive가 불가능하기 때문에 VPC-A와 VPC-B는 서로 통신할 수 없다. 그래서 CIDR이 동일하더라도 문제되지 않는다. 그러면 VPC-C에서 172.16.0.5로 트래픽을 보냈을 때 VPC-A와 VPC-B 중 어느 인스턴스로 전달될까? 이는 VPC-C의 라우팅 테이블을 어떻게 설정하느냐에 따라 달라진다.

라우팅 테이블에서 172.16.0.0/16에 해당하는 트래픽은 VPC-B로 보내되, 172.16.0.5/32에 해당하는 트래픽은 VPC-A로 보내라고 명시해보자. 그러면 172.16.0.5로 향하는 트래픽은 VPC-A로 전달되고, 그 외의 나머지 172.16.0.7, 172.16.0.8 등은 VPC-B로 전달된다. 이렇게 되는 이유는 `Longest Prefix Match`를 사용하기 때문이다. 가장 구체적인 라우팅 경로가 우선순위가 높다. 172.16.0.5/32는 경우의 수가 1개이고, 172.16.0.0/16은 경우의 수가 65,531개이기 때문에 172.16.0.5/32가 우선시 된다. 그래서 172.16.0.5는 172.16.0.0/16에 속함에도 VPC-B가 아닌 VPC-A로 보내질 수 있는 것이다.

## Edge to Edge Routing

VPC Peering은 Edge to Edge Routing을 지원하지 않는다. VPC 간에 Transitive가 성립하지 않던 것과 비슷한 개념이다. 그림을 통해 살펴보자.

1. VPN/Direct Connect

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/4f8a7bf3-2fbd-4334-aff6-09b3bd7fd41d)

    VPC-B와 온프레미스 데이터센터 간에 Site-to-Site VPN 연결이나 Direct Connect를 통해 연결되어 있고, VPC-B와 VPC-C 간에 Peering 연결이 되어있다고 해서 온프레미스에서 VPC-A로의 라우팅은 불가능하다.

2. IGW/NAT

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/4a0ca514-e572-4c64-8101-3a1bf85d54a5)

    VPC-A와 VPC-B가 Peering 연결이 되어 있다고 하더라도, VPC-A의 프라이빗 서브넷에 있는 EC2 인스턴스가 VPC-B의 NAT Gateway를 통해 인터넷에 접속할 수 없다. 인터넷에 접속하고 싶다면 VPC-A에 별도로 NAT Gateway와 Internet Gateway를 설치해줘야 한다.

    VPC Peering을 통해 다른 VPC 내에 있는 NAT Gateway와 Internet Gateway를 이용하여 인터넷에 접근하려는 시도는 좋은 접근인 것처럼 보일 수 있지만, Peering이 Edge to Edge Routing을 지원하지 않는다는 점을 명심해야 한다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-14: VPC Peering과 Edge-to-Edge Routing   