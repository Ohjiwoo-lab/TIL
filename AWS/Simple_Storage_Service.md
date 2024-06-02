# Simple Storage Service(S3)란?

S3는 AWS에서 제공하는 클라우드 객체 스토리지이다. 인터넷 스토리지이기 때문에 언제 어디서나 파일을 업로드하고 다운받을 수 있다. S3는 높은 가용성과 무한히 증가하는 용량을 가지고 있기 때문에 대용량의 파일을 오랫동안 저장하기에 유용하다. S3는 99.999999999%의 내구성을 제공하도록 설계되었는데, 이는 AWS가 저장된 파일이 유실되지 않도록 보장해줄 수 있다는 것을 의미한다.

S3는 비용에 따라 다양한 스토리지 클래스를 가지고 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3822071f-6c8d-4d0f-8371-9406124078c2)

하나씩 살펴보자.

1. Standard

    가장 기본적인 유형으로, 빈번한 액세스가 일어날 때 빠른 응답을 받을 수 있는 스토리지 유형이다.

2. Intelligent-Tiering

    이는 데이터 액세스 패턴을 머신러닝으로 분석하여 비용이 최적화될 수 있도록 자동으로 스토리지 클래스를 변경해주는 유형이다. 만약 데이터 액세스가 빈번히 일어나면 Standard에 배치했다가, 일정 시간 이후 액세스가 거의 없다면 Glacier로 옮기는 방식이다. 데이터 저장 비용과 별도의 모니터링 비용이 부과된다.

3. Infrequent Access

    이는 자주 액세스하지 않는 데이터를 저장하기에 유용한 유형이다. 이는 다시 2가지로 나뉘어진다.

    - Standard-IA: 자주 액세스하지 않지만 액세스했을 때 밀리초 단위의 응답이 필요한 경우에 사용한다.
    
    - One Zone-IA: 하나의 가용영역에 데이터가 배치되어 비용이 저렴하지만 데이터 유실 위험이 존재하는 유형이다. 2차 백업 파일을 저장하는 데에 유용하다.

    이 유형의 경우 보관 비용은 저렴하지만 데이터에 액세스할 때마다 비용을 지불한다는 특징이 있다.

4. Glacier

    매우 저렴한 비용으로 백업 및 아카이빙을 하기에 적합한 스토리지이다. 거의 액세스되지 않으면서 오랫동안 보관해야 할 때에 사용할 수 있다. 예를 들어 회사의 정책 상 감사 목적으로 일정 기간 자료를 보관해야 한다고 하면, Glacier를 이용하면 안전하면서 저렴하게 자료를 보관할 수 있다. Glacier는 데이터 액세스 지연 시간에 따라 3가지로 구분된다.

    - Glacier Instant Retrieval: 밀리초 단위의 액세스가 가능하다.

    - Glacier Flexible Retrieval: 일반적인 S3 Glacier라고 불리는 유형이며, 데이터 액세스 시 Expedited의 경우 1~5분, Standard의 경우 3~5시간, Bulk의 경우 5~12시간이 소요된다.

    - Glacier Deep Archive: 데이터 액세스에 Standard의 경우 12시간, Bulk의 경우 48시간이 소요된다. 이는 아주 오랫동안 데이터를 저장하기만 할 용도로 사용하기에 적합하다.


S3를 비용 효율적으로 사용하기 위해서는 수명주기 정책을 활용하면 된다. 수명 주기 정책은 일정 시간이 경과하면 자동으로 클래스 간에 데이터를 전환해주는 기능이다. 일정 기간 이후 자주 사용되지 않는 데이터를 Standard에서 Glacier로 옮기는 `전환 작업`과 일정 기간 이후 데이터를 삭제하는 `만료 작업`을 정의할 수 있다. Intelligent-Tiering과 다른 점은 수명주기 정책은 사용자가 직접 모든 것을 설정해주어야 한다는 것이다. Intelligent-Tiering은 머신러닝 알고리즘이 사용자의 행동 패턴을 알아서 분석하여 적절한 클래스를 찾아준다는 장점이 있다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-6-2: S3의 스토리지 클래스 정리   