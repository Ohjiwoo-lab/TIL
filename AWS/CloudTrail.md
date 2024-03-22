# CloudTrail이란?

CloudTrail은 AWS 계정에서 수행되는 모든 API 호출 이력을 기록하는 서비스이다. 누가 무엇을 언제 했는지 알아낼 수 있기 때문에 문제의 원인을 파악하거나 감사를 진행할 때 사용된다. CloudTrail은 디폴트로 활성화되어 있다.

CloudTrail이 기록하는 이벤트는 총 3가지이다.

1. Management Events

    이는 기본적으로 로깅되는 이벤트로, AWS 리소스에 수행되는 작업들을 의미한다. 예를 들어 사용자에게 정책을 부여하기 위해 IAM AttachRolePolicy를 호출한 경우 등이 해당될 수 있다. 인프라에 영향을 미치지 않는 `읽기 이벤트`와 인프라에 영향을 미치는 `쓰기 이벤트`로 구분되는데, 당연히 쓰기 이벤트가 더 중요한 이벤트일 것이다.

2. Data Events

    리소스에 수행되는 작업 중에 너무 빈번하게 이루어져서 모두 기록하기 곤란한 작업은 따로 `Data Events`로 구분하고 있다. 예를 들어 S3 버킷의 객체 수준에서 이루어지는 작업이나 람다 함수의 호출 기록과 같은 것이 해당될 수 있다. 이 경우에는 너무 많은 API 호출 이력이 기록될 것이기 때문에 Management Events와 달리 기본적으로 로깅되지 않는 이벤트이다.

3. CloudTrail Insights Events

    이는 수많은 API 활동을 토대로 이상 활동을 탐지하는 이벤트이다. 만약 IAM 정책을 부여하는 활동이 과도하게 많이 수행되었다면, 이는 보안을 의심해보아야 할 문제일 것이다. CloudTrail Insights Events에서 이러한 의심 활동을 탐지하여 로깅한다. Insight Events는 Management Events 중에서도 인프라에 영향을 미치는 쓰기 이벤트를 분석 대상으로 삼는다.

    Insights Events가 생성되면 다음과 같이 처리될 수 있다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/51cfef77-c076-4687-abf6-62b55f1675a2)

    - CloudTrail Console에서 확인한다.
    
    - S3 버킷에 저장한다. (로그 기록은 기본적으로 90일 동안만 보관되기 때문에 S3에 저장해두면 좋다.)

    - 탐지한 이상 현상에 대처하기 위해 EventBridge Event를 생성한다. (자동화)

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-3-22: CloudTrail 3가지 이벤트 정리   