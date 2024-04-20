> 이 시리즈는 유튜브 [널널한 개발자 TV](https://www.youtube.com/watch?v=k1gyh9BlOT8&list=PLXvgR_grOs1BFH-TuqFsfHqbh-gpMbFoy)의 강의 내용을 요약하거나 이해한 내용을 토대로 재구성하여 작성된 글입니다.

# 네트워크 개요

![프레젠테이션1](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/853a1677-7452-4cd1-8c97-ff5df4dec9b8)

네트워크 구조를 한 눈에 정리한 모습이다.

> 강사님께서 이 그림은 통채로 암기하는 것이 좋다고 하셨습니다.

컴퓨터 시스템은 크게 H/W와 S/W로 나누어지며, S/W는 다시 User 애플리케이션 레벨과 운영체제 Kernel 레벨로 나눠진다.

네트워크를 공부하기 시작할 때 가장 처음 등장하는 것은 `OSI 7 Layer`이다. 하드웨어 부분에 속하는 `물리 계층`과 `데이터 링크 계층`부터, 운영체제 커널 레벨의 `네트워크 계층`, `전송 계층`, 그리고 사용자 애플리케이션 레벨의 `세션 계층`, `표현 계층`, `애플리케이션 계층`으로 구성되어 있다.

OSI 7 Layer 외에도  미국 국방부 DoD에서는 네트워크 계층을 4가지로 구분하고 있다. 하드웨어 레벨의 `Access 계층`, 운영체제 커널 레벨의 `Network 계층`과 `Transport 계층`, 사용자 애플리케이션 레벨의 `Application 계층`으로 구성되어 있다.

OSI 7 Layer와 DoD는 네트워크 계층을 구분하는 추상적인 개념이다.

사람이라는 `개념`이 있다고 해보자. 사람의 특징을 나열해보면 두 발로 걷는다, 지능을 가지고 있다 등이 있을 수 있다. 그러면 오지우라는 사람이 있다고 해보자. 오지우는 사람의 `실체`라고 할 수 있다. 

> 그럼 앞서 언급했던 사람의 특징만을 가지고 오지우라는 실체와 친해질 수 있을까?

사람이라면 모두가 공통적으로 가지고 있는 특징만으로는 절대 친해질 수 없을 것이다. 그래서 우리는 사람의 특징이 아닌, 실체인 오지우의 특징을 이해해야 할 필요가 있다.

네트워크도 마찬가지이다. OSI 7 Layer는 단지 추상적인 개념에 불과하다. 그래서 이에 집착하는 것이 아니라, 이를 실제로 구현한 실체를 배워야할 필요가 있다. 이제 그 실체에 대해 알아볼 것이다.

사용자 애플리케이션 레벨에서는 `프로세스`가 동작할 것이다. 이는 웹 브라우저일 수도 있고, 채팅 프로그램일 수도 있고, 게임일 수도 있다. 이러한 프로세스들은 프로토콜이라 하여 사전에 정의된 규약으로 통신한다. 웹이라고 한다면 보통 HTTP 프로토콜을 사용할 것이다.

> 그럼 프로세스가 다른 컴퓨터에 있는 프로세스와 통신하고자 한다면 어떻게 해야할까?

바로 운영체제 커널에서 제공하는 `TCP/IP 프로토콜`을 이용해야 한다. 해당 프로토콜를 통해 통신하고자 하는 상대 컴퓨터의 IP와 포트로 데이터를 전송한다. 하지만 프로세스는 바로 TCP/IP 기능을 이용할 수는 없다. 프로세스는 User 레벨에서 동작하고 TCP/IP는 운영체제 Kernel에서 동작하기 때문이다. 그래서 프로세스도 TCP/IP 기능을 이용할 수 있도록 운영체제에서 인터페이스를 제공해주는데, 이를 `소켓`이라 하며 파일의 형태로 제공된다.

즉, 소켓이란 사용자 애플리케이션이 운영체제 커널의 TCP/IP 기능을 사용하기 위해 운영체제에서 제공하는 `추상화된 인터페이스`라고 정의할 수 있다.

> 소켓의 정의를 정확하게 이해하는 게 중요합니다.

TCP/IP 소켓을 이용하여 전송한 데이터는 물리적인 하드웨어를 거치게 되는데, 운영체제 커널에서는 `디바이스 드라이버`를 이용하여 하드웨어에 접근한다.

네트워크 기능을 제공하는 하드웨어 장비는 `NIC(Network Interface Card)`이다. NIC를 통해 복잡하게 연결되어 있는 네트워크 망으로 데이터가 전송되고 통신이 이루어진다.

이때 데이터를 주고받기 위해 사용되는 식별자가 계층별로 존재한다. Access 수준에서 사용되는 것이 `MAC 주소`이고, Network 수준에서는 `IP 주소`, Transfer 수준에서는 `Port 번호`가 있다.

# Port 번호, IP 주소, MAC 주소가 식별하는 것

`MAC 주소`는 네트워크 장비인 NIC에 대한 식별자이기 때문에 하드웨어 주소라고도 한다. 쉽게 LAN 카드에 부여되는 주소라고 이해하면 된다. 만약 노트북에 유선 LAN 카드와 무선 LAN 카드가 연결되어 있다면, NIC가 2개 존재하는 것이고, 결과적으로 총 2개의 MAC 주소가 부여되어 있는 것이다.

> MAC 주소는 변경 가능할까요?   
> => Yes. 가능합니다.

네트워크 계층에서 사용되는 `IP 주소`는 호스트에 대한 식별자이다. 호스트란 인터넷에 연결된 컴퓨터를 의미한다. NIC 1개에 여러 개의 IP 주소가 바인딩될 수 있다. 즉 하나의 컴퓨터에 여러 개의 IP 주소를 가질 수 있다는 것이다. 현재 IPv4와 IPv6가 혼용되어 사용되고 있다.

`Port 번호`는 전송 계층에서 사용되는 식별자로, 수행하는 업무에 따라 다르게 해석될 수 있다. 

주로 7계층에 해당하는 HTTP 프로토콜을 사용하는 S/W 개발, 관리 업무를 하는 사람들은 포트 번호를 `프로세스 식별자`라고 해석한다. HTTP는 보통 TCP 80포트 또는 8080포트를 사용하고, 프로세스마다 부여되는 포트가 있기 때문이다. 3,4계층에 해당하는 네트워크 관리 업무를 하는 사람들은 `서비스 식별자`라고 해석한다. S/W 개발자들이 보통 HTTP 포트 열어주세요.라고 요청하기 때문에 어떤 서비스를 위한 번호라고 여기는 것이다. 1,2계층에 해당하는 하드웨어를 직접 설치하는 업무를 하는 사람들은 `인터페이스 식별자`라고 해석한다. 공유기에 랜카드를 꼽을 때 단자의 번호가 있는데, 이 번호를 식별하는 것이라고 여기는 것이다.

이런 식으로 Port 번호는 주어진 업무에 따라 다양하게 해석될 수 있음을 이해하는 것이 중요하다.

# Reference

[네트워크를 배우려는 사람들을 위해](https://www.youtube.com/watch?v=k1gyh9BlOT8&list=PLXvgR_grOs1BFH-TuqFsfHqbh-gpMbFoy)

[MAC주소, IP주소, Port번호가 식별하는 것](https://www.youtube.com/watch?v=JDh_lzHO_CA&list=PLXvgR_grOs1BFH-TuqFsfHqbh-gpMbFoy&index=2)

# History

📌 2024-1-1: OSI 7 Layer와 Port 번호, IP 주소, MAC 주소가 식별하는 것 정리