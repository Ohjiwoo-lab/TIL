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

인스턴스 유형은 선택한 시작 템플릿에 따라 t2.micro로 지정되어 있는데, `시작 템플릿 재정의`를 통해 다르게 변경할 수도 있다. 또한 VPC와 서브넷을 선택해야 하는데, 여기서는 기본 VPC와 가용영역 `ap-northeast-2a`, `ap-northeast-2c`로 선택하였다. t2.micro의 경우 `ap-northeast-2b`와 `ap-northeast-2d`에서는 사용할 수 없기 때문이다.

> 만약 사용할 수 없는 가용영역을 선택한다면 ASG가 제대로 동작하지 않게 된다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/67c679de-5355-4859-9650-d101cb18ca14)

## 로드밸런서 연결

ASG는 로드밸런서 없이 사용하는 경우는 거의 없다. ASG에 의해 늘어난 EC2 인스턴스에도 트래픽이 고르게 전달되기 위해서는 로드밸런서가 필수이기 때문이다. 기존에 로드밸런서가 있다면 선택하면 되는데, 생성해둔 것이 없기 때문에 새롭게 만들어주었다. 로드밸런서와 함께 대상 그룹도 함께 생성하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/58ca1e85-314e-48e0-a9f7-5f83e6a1fb10)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/ce5381aa-a54e-49fb-8751-dc08c2efbe9c)

> 이렇게 하면 로드밸런서와 대상 그룹이 자동으로 생성되고, ASG에 의해 생성된 인스턴스는 자동으로 대상 그룹에 포함되어 로드밸런서로부터 트래픽을 받을 수 있다.

상태 확인의 경우 EC2 인스턴스 상태확인과 로드밸런서 상태확인이 있는데, EC2 상태확인은 언제나 활성화되어 있다. 로드밸런서 수준에서 비정상인 인스턴스로 트래픽을 보내지 않기 위하여 로드밸런서 상태확인도 활성화하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d9c49df7-1128-4b99-ae80-e00d38580df5)

## ASG 크기 조정

ASG 내의 EC2 인스턴스의 개수를 지정할 수 있다. 유지되었으면 하는 개수와 최소 개수, 최대 개수를 지정할 수 있다. 아직 스케일링 정책을 설정하기 전이기 때문에 모두 1로 설정해주었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c5a113aa-8833-41eb-b414-fe333b31df5e)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e60dce0a-243c-4aec-b906-2a0be0c3a94e)

> 인스턴스 유지관리 정책에 대해서는 따로 알아보도록 하겠다.

## 알림&태그 추가

알림과 태그 추가는 넘어간다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/48987cdc-bf66-46ea-8962-1a2415706655)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9c05f9e8-0c56-4c11-902b-bc8f2de84119)

## 결과물

아래와 같이 ASG가 생성되었다. 또한 로드밸런서와 대상 그룹도 함께 생성되었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d3fde5d0-6a90-42f6-b4f1-9f07a223ffb2)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/f1c1f81a-d481-4861-a511-2551b400ed3c)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/91aafbc5-7a88-45c2-b2ac-222935ee0e6c)

대상 그룹에 인스턴스가 1개 존재하는 것을 확인할 수 있다. 이는 ASG에 설정해둔 희망 개수는 1개인데 현재 EC2 인스턴스가 하나도 존재하기 않기 때문에 1개의 인스턴스를 생성한 것이다. 아래에서 생성된 EC2 인스턴스를 확인할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/44d68444-0705-422f-8292-39044b528fdf)

이러한 ASG의 활동은 모두 기록으로 남아서 콘솔을 통해 확인할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e38912a9-efd3-4ee7-8f25-6ea3bd3c1af7)

> 만약 상태 확인이 UnHealthy로 되어 있다면, EC2 인스턴스의 보안 그룹이 80포트를 허용하고 있는지를 체크해야 한다.

## 스케일링 실습

만약 희망 용량을 2개로 변경한다면 어떻게 될까? 희망 용량이 늘어남에 따라 최대 용량도 따라서 늘어나야 할 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/48eba3ac-02e7-41d3-90b2-948270bf91d8)

EC2 인스턴스 1개가 추가로 생성되었고, 자동으로 대상 그룹에 추가되었음을 확인할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/7e4e1ee9-5b5d-45e0-9b32-89c0ae2001e4)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c4bde7fb-fed1-44f3-8860-c3430fcbee26)

ASG 콘솔을 확인해보면, 희망 개수는 1개에서 2개로 늘어남에 따라 인스턴스 1개를 추가한다고 나와있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d1255468-de8a-41a9-8090-c23ccdeb756f)

로드밸런서에 접속해보면, ASG에 속한 2개의 인스턴스로 트래픽이 균등하게 보내지고 있음을 확인할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3cfc6689-796c-4b0f-8669-a8bdd1413e5b)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6b77df9f-f8d9-40ba-ae2a-bdda78e16fbd)

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-3-23: ASG Scaling 정책 정리   
📌 2024-3-24: ASG 실제로 만들어보기 - 대상 그룹이 업데이트 안되는 오류 발생   
📌 2024-3-25: 대상 그룹이 업데이트 안되는 오류 해결 - t2.micro를 사용할 수 없는 가용영역이 설정되어있어서 생겼던 오류임을 확인