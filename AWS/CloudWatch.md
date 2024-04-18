# CloudWatch란?

CloudWatch는 AWS에서 제공하는 모니터링 도구이다. 다양한 종류의 지표와 로그를 측정하고 관리할 수 있다. 대부분의 AWS 서비스에서는 CloudWatch Metric을 기본적으로 제공한다. EC2 인스턴스의 경우 기본적으로 5분마다 CPU, 네트워크, 디스크 등의 지표를 수집한다. 단 RAM은 지표로 제공되지 않기 때문에 사용자 지정 지표를 따로 생성하여 CloudWatch로 전송해야 한다.

## CloudWatch Alarm

CloudWatch Metric을 모니터링하다가 어떠한 조건을 만족했을 때 경보를 발생시켜 특정 작업을 수행하도록 할 수 있다. 수행할 수 있는 작업은 다음과 같다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6dbd9b4b-c319-481c-b851-cf6f8c90994e)

- EC2 Action

    EC2 인스턴스에 대해 작업을 수행할 수 있다. EC2 인스턴스에 대한 Stop, Terminate, Reboot, Recover 작업을 수행할 수 있고, 중요한 EC2 인스턴스의 경우 모니터링하다가 문제가 발생하여 중지된다면 즉시 Recover 작업을 수행하여 복구할 수 있다. 이렇게 하면 인스턴스의 사설 IP, 공인 IP가 그대로 유지되기 때문에 서비스를 중단없이 유지할 수 있다는 장점이 있다.

- Auto Scaling

    Auto Scaling Group에서 오토스케일링을 할 때에 CloudWatch Alarm이 사용된다. 지표를 모니터링하다가 설정한 임계값을 넘어가면 경보를 발생시켜 EC2 인스턴스를 늘리는 작업을 수행한다.

- SNS

    SNS를 트리거하여 이메일 알림을 주는 기능을 구현할 수 있다. SNS는 SQS나 Lambda 함수와 통합되어 더 다양하 작업을 수행할 수 있다.

- EventBridge

    추가로 EventBridge는 모든 CloudWatch Alarm을 인터셉트하는 방법을 제공한다. EventBridge는 많은 서비스들과 통합할 수 있기 때문에 더 유연한 아키텍처가 가능해진다.


# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-18: CloudWatch Alarm 정리