# Load Balancer란?

Load Balancer란 부하 분산 장치이다. 여러 서버에 네트워크 트래픽을 고르게 분산해주는 기능을 제공한다. AWS에는 총 3개의 로드밸런서를 제공한다. (원래 Classic Load Balancer도 있었지만, 현재에는 생성이 불가능하다.)

1. Application Load Balancer

    이는 7계층에서 동작하는 로드밸런서로, HTTP를 이용하는 애플리케이션에 부하를 분산해줄 수 있다. 동적 포트 매핑 기능을 이용하면 같은 서버 내의 여러 컨테이너에도 로드밸런싱이 가능하다. HTTP와 WebSocket을 지원하고, HTTP에서 HTTPS로 리디렉션해주는 기능도 있다. 또한 7계층 수준의 로드밸런싱이기 때문에 정교한 라우팅 규칙을 정의할 수 있다. `/user`와 `/search`가 서로 다른 타겟 그룹으로 가도록 설정할 수 있다.

    ALB의 타겟 그룹이 될 수 있는 것을 EC2 인스턴스, ECS 태스크, Lambda 함수, IP Address이다. 이때 타겟 그룹은 로드밸런서에 의해 트래픽을 전달받는 서버 그룹을 의미한다. ECS 태스크는 앞서 언급했던 것처럼 동적 포트 매핑 기능을 이용할 때 가능하고, IP Address는 Private IP만 가능하다.

    > 왜 Private IP만 가능한지 생각해봤는데, 로드밸런서를 통하지 않고 직접 애플리케이션에 접근하는 것을 막기 위한 장치라고 생각한다. Public IP가 있으면 직접 접근할 수 있기 때문이다.

2. Network Load Balancer

    이는 4계층에서 동작하는 로드밸런서로, TCP와 UDP 트래픽을 분산해준다. NLB는 초당 수백만 개의 요청을 처리할 수 있고, 지연시간도 ALB에 비해 낮다는 특징을 가진다. 또한 가용 영역 당 정적인 IP 1개를 제공해주기 때문에, 높은 성능과 하나의 IP 주소를 받고 싶다면 NLB가 좋은 선택일 것이다.

    NLB의 타겟 그룹이 될 수 있는 것은 EC2 인스턴스, IP Address (이 역시 Private IP이다.), Application Load Balancer이다. 특이한 점은 ALB로도 트래픽을 보낼 수 있다는 점인데, HTTP를 이용하는 애플리케이션이지만 정적인 IP를 할당받고 싶다면, NLB + ALB 조합도 좋은 선택이다.

3. Gateway Load Balancer

    이는 3계층에서 동작하는 로드밸런서이다. 이는 앞서 살펴본 ALB, NLB와는 다소 다른 양상을 보인다. 바로 모든 트래픽을 특정한 타겟 그룹으로 우회해준다는 것이다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c8286103-6a1b-4777-b972-b05b88687e38)

    그림을 보면 사용자는 라우팅 테이블에 의해 Gateway Load Balancer로 요청을 보내게 되고, 이는 타겟 그룹에 전달된다. 타겟 그룹으로부터 응답이 돌아오면 로드밸런서는 기존의 목적지였던 애플리케이션으로 요청을 전달하게 된다.

    그럼 언제 사용하는 것일까? 타겟 그룹은 네트워크 가상 어플라이언스의 세트이다. 네트워크 트래픽이 정상적인 것인지, 문제는 없는지 등을 검사한다. 모든 트래픽을 검사하고 싶다면, GLB를 사용하여 모든 트래픽이 어플라이언스를 우회하도록 설정하면 된다.

    GLB의 타겟 그룹은 EC2 인스턴스와 IP Address (Private Ip)만 가능하다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-4-3: 3가지 로드밸런서 특징 정리   