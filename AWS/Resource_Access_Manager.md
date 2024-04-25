# Resource Access Manager(RAM)이란?

RAM은 서로 다른 계정 간 리소스를 공유할 수 있는 서비스이다. 계정 간에 리소스를 공유할 때, 복제하거나 VPC 피어링을 설정하지 않아도 가능하다는 점에서 유용하게 사용될 수 있다. 대표적인 예시로 VPC Subnet이 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/88029d83-853e-4020-b070-c0c3109aad54)

그림을 보면 계정 A, 계정 B, 계정 C가 있고, VPC는 계정 A의 소유이다. 이때 계정 A가 본인이 생성한 리소스와 계정 B, 계정 C에서 생성한 리소스들끼리 통신을 하고 싶다고 가정해보자. 이럴 때 사용할 수 있는 솔루션이 RAM이다. RAM을 이용해 계정 A 소유의 서브넷을 공유하면, 계정 B, 계정 C도 해당 서브넷에 리소스를 생성할 수 있게 된다. 그러면 이론상 같은 서브넷에 리소스를 생성한 것이기 때문에 프라이빗 서브넷이라 하더라도 리소스들 간에 통신이 가능할 것이다.

만약 RAM을 이용하지 않는다면, 계정 A의 VPC, 계정 B의 VPC, 계정 C의 VPC끼리 VPC Peering을 설정해야 했을 것이다. 그렇게 되면 VPC 내에서 생성한 모든 리소스들에 접근이 가능해진다. 다른 계정에 공개하고 싶지 않은 리소스도 모두 공개가 되므로 보안 측면에서 좋지 않다. RAM을 이용하면 특정 서브넷 하나만 공유할 수 있기 때문에 더욱 안전하다.

단, 리소스들끼리 통신만 가능할 뿐 다른 작업을 수행할 수 없다. 계정 B는 계정 A에서 생성한 RDS 데이터베이스를 수정하거나 삭제할 수 없다. 별개의 계정이기 때문이다. 단지 데이터를 주고받기만 할 수 있을 뿐이다.

VPC Subnet 말고도 Transit Gateway, Route 53, Aurora DB Cluster, EC2 Instance 등 다양한 리소스를 공유할 수 있다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-25: Resource Access Manager 개념 정리   