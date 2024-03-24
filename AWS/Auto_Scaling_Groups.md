# Auto Scaling Groups란?

Auto Scaling Group을 이용하면 자동으로 EC2 인스턴스의 개수를 늘리거나 줄일 수 있다. 애플리케이션의 성능 향상을 위해 Scale-out을 할 때에 적합한 서비스이다. 정해놓은 규칙에 따라 트래픽이 많아지면 인스턴스를 자동으로 증가시키고, 트래픽이 줄어들면 인스턴스를 자동으로 감소시킨다. 이때 최대 개수와 최소 개수를 지정할 수 있다.

그러면 언제 스케일링이 일어날 지에 대한 기준을 정할 필요가 있는데 2가지 방법이 존재한다.

1. Dynamic Scaling Policies

    동적 스케일링 정책으로, 다시 3가지로 나누어진다.

    - Target Tracking Scaling

        매우 간단한 방법으로, 지표 1개만 가지고 스케일링 여부를 결정한다. 만약 평균 CPU 사용률을 지표로 선택하고 해당 지표가 40%를 유지하도록 설정한다면, 평균 CPU 사용률이 40% 아래로 떨어졌을 때는 EC2 인스턴스를 감소시키고 40%보다 높아졌을 때는 증가시키는 스케일링을 진행할 것이다.

    - Simple / Step Scaling

        Target Tracking Scaling은 너무 단순해서 복잡한 정책을 정의할 수가 없었다. 이 방법을 이용하면 보다 정교하게 정책을 정의할 수 있다. 예를 들어 평균 CPU 사용률이 70%보다 높아지면 EC2 인스턴스 2개를 추가하고, 평균 CPU 사용률이 30%보다 낮아지면 EC2 인스턴스 1개를 제거하는 식으로 설정할 수 있다.

        단, 이 경우에는 따로 CloudWatch alarm을 지정할 필요가 있어서 설정이 복잡할 수 있다.
    
    - Scheduled Actions

        이는 미리 스케일링을 해야 하는 시점을 정확히 알고 있을 때 사용하면 좋다. 스케일링 작업을 사전에 예약해두는 것이기 때문이다. 만약 금요일마다 이벤트가 있어서 트래픽 양이 급증한다는 것을 알고 있다면, 매주 금요일 오전 10시부터 오후 5시까지 EC2 인스턴스의 최소 개수를 10개로 증가시키는 작업을 예약할 수 있을 것이다.

2. Predictive Scaling

    상황에 따라 동적으로 스케일링을 진행하는 것이 아니라 예측을 통해 미리 스케일링 정책을 설정해두는 것을 의미한다. AWS가 기존의 트래픽을 분석하여 앞으로의 트래픽을 예측한다. 그리고 예측한 것을 토대로 스케일링 정책을 설정해서 수행으로 옮긴다.

    매주 또는 매일 반복되는 트래픽 패턴이 있는 경우에는 매우 좋은 성능을 보일 수 있을 것이다.

<br/>

# ASG 만들어보기

ASG는 EC2 인스턴스 콘솔에서 생성할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/5851f50d-253c-4ca3-9056-4bea60bb3d3e)

현재 시작 템플릿이 없으므로 새롭게 생성해줄 것이다.

## 시작 템플릿 생성

- 이름 지정

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/91839771-d2e1-409d-bcc1-bcd36b9e0d4e)

- 생성할 인스턴스 AMI 지정

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1ec10e11-3df9-4163-b5b5-605c7a5fc60f)

- 생성할 인스턴스 타입과 Key Pair 지정

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/56f08597-32c4-450c-8e16-27ca402def39)

- VPC와 스토리지 선택

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/05065803-b565-4dba-85e2-1005d2125be3)

- User Data 설정

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3300ee3d-9939-4ebf-806e-b9345c20422b)

    User Data는 `고급 세부 정보` 부분에서 설정할 수 있다. 인스턴스가 생성될 때 아파치 웹서버를 함께 설치하도록 하였다.

시작 템플릿은 ASG에 생성될 EC2 인스턴스의 템플릿을 지정하는 것이기 때문에 인스턴스를 생성할 때와 매우 유사한 절차로 진행된 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c42d7c4c-540b-4657-885e-650785c50058)

앞서 생성했던 시작 템플릿을 선택한다.

## 인스턴스 시작 옵션 선택

인스턴스 유형은 선택한 시작 템플릿에 따라 t2.micro로 지정되어 있는데, `시작 템플릿 재정의`를 통해 다르게 변경할 수도 있다. 또한 기본 VPC와 서브넷을 선택해준다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6089cc26-ec0b-4f9e-9e3f-4d1313f3b4c8)

## 로드밸런서 연결

ASG는 로드밸런서 없이 사용하는 경우는 거의 없다. ASG에 의해 늘어난 EC2 인스턴스에도 트래픽이 고르게 전달되기 위해서는 로드밸런서가 필수이기 때문이다. 기존에 로드밸런서가 있다면 선택하면 되는데, 생성해둔 것이 없기 때문에 새롭게 만들어주었다. 로드밸런서와 함께 대상 그룹도 함께 생성하였다.

상태 확인의 경우 EC2 인스턴스 상태확인과 로드밸런서 상태확인이 있는데, EC2 상태확인은 언제나 활성화되어 있다. 로드밸런서 수준에서 비정상인 인스턴스로 트래픽을 보내지 않기 위하여 로드밸런서 상태확인도 활성화하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6dab1cc0-6219-4d08-ad06-91ab7faba564)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/fcf08a22-c579-4038-ae09-38276ff80f37)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/69b70070-616c-47e4-b817-0db786e709ee)

## ASG 크기 조정

ASG 내의 EC2 인스턴스의 개수를 지정할 수 있다. 유지되었으면 하는 개수와 최소 개수, 최대 개수를 지정할 수 있다. 아직 스케일링 정책을 설정하기 전이기 때문에 모두 1로 설정해주었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1f18b0a0-a962-435e-9b11-6ffa460b1577)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/0642e83e-e371-4812-8bc4-80338e2a6069)

> 인스턴스 유지관리 정책에 대해서는 따로 알아보도록 하겠다.

## 결과물

아래와 같이 ASG가 생성되었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9a8aecd7-755f-45de-9eed-6d9c8aa69012)

현재 ASG에 속한 EC2 인스턴스가 하나도 존재하기 않기 때문에 희망 개수인 1개의 인스턴스를 생성하는 것을 확인할 수 있다. 아래와 같이 ASG의 작업 내역을 모두 확인할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/81eecb7e-68c9-415f-a2f7-de1db16dfbd2)

ASG에 의해 EC2 인스턴스 1개와 대상 그룹이 생성되었다. 하지만 대상 그룹에 아직 인스턴스가 지정되지 않아서 수동으로 추가해주었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/cb4dab45-e153-4f36-be3d-d7157c180290)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/b9f1d312-591d-4ef0-9c80-2584b91d06d8)

> 만약 상태 확인이 UnHealthy로 되어 있다면, EC2 인스턴스의 보안 그룹이 80포트를 허용하고 있는지를 체크해야 한다.

## 스케일링 실습

만약 희망 용량을 2개로 변경한다면 어떻게 될까? 희망 용량이 늘어남에 따라 최대 용량도 따라서 늘어나야 할 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/4efc08df-0bcb-47ec-951a-b578bc8d4124)

희망 개수는 2개인데 현재 인스턴스는 1개뿐이므로 ASG는 인스턴스 1개를 추가로 생성한다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/ae0c9698-344d-4139-9780-e863a80b1241)

> 대상 그룹에 자동으로 추가되지 않는군. ALB와 대상그룹이 연결되지 않은건가..? 대상그룹을 먼저 생성하고 연결해주어야 하나. 이건 내일 마저 해봅시다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-3-23: ASG Scaling 정책 정리   
📌 2024-3-24: ASG 실제로 만들어보기 - 대상 그룹이 업데이트 안되는 오류 발생