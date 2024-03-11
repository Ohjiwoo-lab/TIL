# Directory Service란?

AWS에서 제공하는 Directory Service는 Microsoft Active Directory(AD)를 AWS에서 사용할 수 있게 해주는 서비스이다.

Microsoft AD란 Windows 서버에서 사용자 계정을 생성하고 관리하는 서비스라고 생각하면 된다. Domain Controller로 로그인을 하면 연결되어 있는 모든 컴퓨터에 접근할 수 있다는 장점이 있다.

AWS에서는 총 3가지 방법으로 AD를 지원한다.

1. AWS Managed Microsoft AD

    AWS VPC 상에 AD를 생성할 수 있고, 필요시 온프레미스 상의 AD와 연결할 수 있는 서비스이다. 온프레미스 AD와 AWS Managed AD에서 모두 사용자를 생성 및 관리할 수 있으며, 신뢰관계로 연결되어 있기 때문에 언제든 서로 참조할 수 있다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/852f17f4-8f0d-4ed3-a5f9-38cf17fac885)

    신뢰관계는 AWS에서 온프레미스로의 One-way trust, 온프레미스에서 AWS로의 One-way trust, 양방향으로의 Two-way trust가 있다. 
    
    > 여기서 주의할 점은 연결된다는 것이 동기화된다는 것은 아니라는 것이다. 사용자 정보가 실시간으로 동기화되는 것이 아니라, AWS 상에 존재하지 않는 사용자가 온프레미스 상에 존재할 수 있다는 것이고 이를 원하는 대로 참조할 수 있다는 것을 의미한다.

    AWS Managed AD는 다양한 AWS 서비스와 통합할 수 있다. SAML과 호환되는 애플리케이션, AWS Single-Sign On, RDS for SQL Server, EC2 Windows 인스턴스 등 다양한 것과 통합 가능하고 MFA 기능을 지원한다. 단, EC2 Linux 인스턴스는 불가능하다. AWS에서 AD를 사용해야 하고 다양한 서비스와 연결해야 할 필요가 있다면 좋은 선택지일 것이다.

2. AD Connector

    온프레미스 AD로 프록시 역할을 수행하는 Directory Gateway이다. 온프레미스 AD에서만 사용자 정의 및 관리를 수행하고, AD Connector는 사용자 인증 요청을 전달해주는 역할만 수행한다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9140603c-f6e4-431f-a4f3-2a725a2e74de)

    AD Connector는 RDS for SQL Server와 함께 동작하지 못한다. 이 역시 MFA 기능은 지원한다.

    > 아직 어느 때에 사용하는 지는 잘 모르겠다.

3. Simple AD

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9a9556c8-f095-415f-9920-8631d477dda0)

    이는 AWS 상에 독립적으로 존재하는 AD이다. 온프레미스 AD와 연결할 수 없으며 아주 간단한 기능만을 제공한다. 비용이 저렴하다는 장점이 있다. EC2 인스턴스와 연결할 수 있고 사용자 및 그룹을 관리할 수 있도록 기능을 지원한다.

    하지만 MFA, RDS for SQL Server, AWS SSO를 지원하지 않고, 관리 가능한 사용자의 개수도 적다. 그래서 적은 비용으로 가장 기본적인 AD 호환 기능, LDAP 호환 기능을 사용하고 싶은 경우에 적절한 선택지이다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-3-11: Directory Services 3가지 정리   