# GuardDuty란?

머신러닝 알고리즘을 기반으로 하여 지능형 위협을 감지하는 AWS의 보안 서비스이다. GuardDuty는 여러가지 Input Data를 기반으로 분석을 하는데, Input Data가 될 수 있는 것은 다음과 같다.

- CloudTrail Event Logs
    - CloudTrail Management Events: 계정 내에서 일어나는 모든 API 호출 이력을 저장한다.
    - CloudTrail Data Events: S3 버킷의 객체 수준 활동이나 Lambda 함수 호출과 같이 빈번하게 일어나는 이벤트를 저장한다.

- VPC Flow Logs: VPC를 통과하는 트래픽을 기록한다.
- DNS Logs: DNS 쿼리에 대한 정보를 기록한다.
- 추가적인 데이터
    - EKS Audit Logs
    - RDS & Aurora Login Activity
    - EBS Volumes
    - Lambda Network Activity
    - S3 Data Events

GuardDuty는 정말 다양한 로그를 수집하고 분석해서 이상한 활동을 감지할 수 있다. 

> WAF Logs는 GuardDuty의 Input Data가 될 수 없다.

또한 EventBridge와 통합하여 이상활 활동이 감지될 때마다 알림을 받을 수 있다. EventBridge는 규칙을 정의해두면, 해당 규칙에 해당하는 이벤트가 발생할 때마다 특정 리소스로 이벤트를 전달해주는 역할을 한다. 그래서 아래와 같은 아키텍처를 통해 알림을 자동화할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/7e513234-e357-4987-854a-a89a6ee9bc03)

GuardDuty는 여러 로그들을 머신러닝 알고리즘으로 분석해서 어떠한 지능형 위협(findings)이 발견되면 EventBridge로 이벤트를 보낼 것이다. 그러면 EventBridge는 미리 정의된 규칙에 의해 지능형 위협이 발생했을 때 SNS나 Lambda를 호출하여 관리자에게 알림을 주거나 어떠한 조치를 취하도록 할 수 있다.

⭐ **암호화폐 해킹 공격**

GuardDuty 관련해서 알아둘 점은 `암호화폐 공격`에 대해 좋은 성능을 보인다는 점이다. GuardDuty에는 암호화폐 공격에 방어하기 위한 별도의 검색 유형을 정의해놓고 있기 때문이다. 아래는 AWS에서 정의해놓은 EC2 검색 유형 중 하나를 발췌한 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/be9769b2-f62a-48b6-ab9e-f513c141d0d9)
출처: [AWS Documentation](https://docs.aws.amazon.com/ko_kr/guardduty/latest/ug/guardduty_finding-types-ec2.html)

그래서 암호화폐 서비스에 대해 공격을 대비하고 싶다면, GuardDuty가 좋은 선택지가 될 것이다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-3-18: AWS GuardDuty에 대해 정리