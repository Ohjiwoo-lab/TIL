# Kinesis Data Stream

Kinesis Data Stream은 IoT 디바이스 또는 Click Streams 등으로부터 대규모로 스트림 데이터를 수집한 후 저장하는 서비스이다. 실시간 서비스이기 때문에 200ms 이하의 짧은 지연시간이 소요된다. 스트림 데이터는 `샤드`에 순서대로 나뉘어 저장된다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/90e61b58-951a-475e-83e0-75a1eb5e412d)

스트림 데이터를 생산자가 수집하여 샤드에 저장한다. 이때 어느 샤드에 저장되는지는 `Partition Key`를 이용하여 결정할 수 있다. 같은 Partition Key를 가진 데이터는 언제나 같은 샤드에 들어감을 보장한다. Partition Key에 대해 Kinesis에서 해시 함수를 적용하여 데이터를 보낼 샤드를 결정하게 된다.

샤드에 데이터가 저장되고 나면 보존기간이 끝날 때까지 절대 삭제할 수 없다. 보존기간은 기본적으로 24시간인데, 최대 365일까지 설정할 수 있다. SQS와 달리 소비되어도 데이터가 삭제되지 않기 때문에 동일한 스트림 데이터에 대해 여러 애플리케이션이 소비할 수 있다. 또한 보관된 데이터를 reprocess, reply 할 수 있다는 장점이 있다.

Kinesis의 용량에 대한 2가지 모드가 존재한다.

1. On-demand: 용량 계획이 필요없고, 처리량에 따라 자동으로 샤드를 스케일링한다.

2. Provisioned: 직접 샤드를 관리해야 한다.

Kinesis Data Stream은 샤드의 개수에 따라 처리량이 달라진다. 처리량이 많아지면 샤드를 추가해야 하고, 처리량이 적어지면 샤드를 줄여야 한다.

## 생산자와 소비자

Kinesis Data Stream의 생산자와 소비자가 될 수 있는 후보는 다음과 같다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6ab9bc8f-9baf-4584-a257-83b837e291fc)

생산자는 스트림 데이터를 수집해서 Kinesis Stream의 샤드로 보내는 애플리케이션이고, 소비자는 Kinesis Stream으로부터 스트림 데이터를 가져가서 처리하는 애플리케이션이다. 하나씩 무엇인지 살펴보자.

### Producer

1. AWS SDK

    가장 간단하고 일반적인 생산자이다. Java, Python, Node.js 등 다양한 프로그래밍 언어를 지원하고 있다.

2. Kinesis Producer Library (KPL)

    이는 Kinesis Data Stream에 대한 높은 쓰기 처리량을 제공해주는 사용자 라이브러리이다. 개발자가 생산자 애플리케이션을 편리하게 개발하기 위한 다양한 기능을 제공한다. 다만 라이브러리를 사용하면 추가 지연시간이 발생할 수 있기 때문에 지연시간을 허용할 수 없는 애플리케이션은 SDK를 사용하는 것이 좋다.

3. Kinesis Agent

    KPL 기반의 에이전트이다. 로그 파일을 모니터링하고 이를 Kinesis Data Stream과 Kinesis Data Firehose로 직접 전송할 수 있다. EC2 인스턴스에서 로그파일을 가져와서 Stream으로 전송하고 싶은 경우 유용한 서비스이다.

생산자는 샤드 당 1MB/s 또는 1000 messages/s를 Stream에 작성할 수 있다. 만약 너무 많은 쓰기 작업이 일어나게 될 경우 `ProvisionedThroughputException` 에러가 발생하는데, 이는 샤드의 개수를 늘림으로써 해결할 수 있다.

### Consumer

1. AWS SDK

    생산자와 마찬가지로 SDK를 이용하여 소비자 애플리케이션을 제작할 수 있다.

2. Lambda

    `이벤트 소스 매핑`을 통해 Lambda 함수를 호출할 수 있다. Kinesis Stream에서 이벤트 소스 매핑을 통해 Lambda를 호출하면, 실시간으로 데이터를 처리할 수 있다. 만약 데이터를 실시간으로 S3 버킷에 저장하고 싶다면, 람다 함수를 이용해야 한다.

    > 이벤트 소스 매핑이란, Lambda 함수를 직접 호출하지 않더라도 이벤트 소스로부터 Lambda를 간접 호출할 수 있도록 하는 기능이다. Lambda는 Kinesis Data Streams, SQS, MQ 등의 이벤트 소스로부터 이벤트가 있는지를 Long Polling을 통해 확인한다. 그리고 이벤트가 있으면 이벤트를 Poll 해와서 처리한다. 이는 이벤트 소스인 Kinesis, SQS, MQ에서 람다를 호출하지 않아도 알아서 이벤트를 가져와 처리할 수 있는 방식이다.

3. Kinesis Client Library (KCL)

    스트림 데이터를 병렬로 읽을 수 있는 라이브러리이다. 병렬 처리를 위해 체크포인트 기능을 제공한다. KCL 애플리케이션은 Kinesis Data Stream으로부터 데이터를 읽은 후, 어디까지 읽었는지에 대한 진행상황을 DynamoDB에 남긴다.(체크포인트) 그러면 다른 KCL 애플리케이션은 이 진행상황을 확인하여 아직 읽히지 않은 데이터를 읽을 수 있다. 그래서 여러 애플리케이션이 동시에 실행되어도 같은 데이터를 여러 번 읽지 않게 할 수 있다. 이는 애플리케이션의 Scale-out 확장이 가능하다는 것이다.

4. Kinesis Data Analytics

    Kinesis에서 데이터 분석을 하기 위한 서비스이다. Kinesis Stream으로부터 데이터를 가져와서 실시간으로 분석한 뒤 Kinesis Firehose나 Kinesis Stream으로 결과를 보낼 수 있다.

5. Kinesis Data Firehose

    이는 데이터를 처리한 뒤 전송하기 위한 Kinesis 서비스이다. 레코드를 위한 버퍼가 존재한다. 설정한 Buffer Size 만큼 데이터가 채워졌을 때, 그리고 Buffer Time 만큼 시간이 지났을 때마다 버퍼를 Flush한다. Flush 할 때에는 1분 정도의 지연시간이 발생하고, 배치 단위로 데이터를 전송하기 대문에 준 실시간 서비스라고 한다. Firehose도 Stream의 소비자가 될 수 있다.

    > 이에 대해서는 따로 정리할 예정이다.

소비자는 2가지 모드가 있다.

`Consumer Classic` 모드는 소비자의 개수에 상관없이 샤드 당 2MB/s의 읽기 처리량과 5 API Calls per second 을 할 수 있다. 이는 소비자의 개수를 늘려도 처리량이 증가하지 않으므로 성능을 개선하기 위해서 샤드를 늘리는 방법밖에 없다.

`Consumer Enhanced Fan-Out` 모드는 샤드 당, 소비자 당 2MB/s의 처리량을 가질 수 있다. 따라서 성능을 개선하기 위해 샤드를 늘리는 것 대신 소비자를 늘리는 방법을 사용할 수 있다.

> push model이라 API Call은 필요하지 않다고 하는데 아직 무슨 소리인지 모르겠다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-16: Kinesis Data Stream, 생산자와 소비자   
📌 2024-4-24: 이벤트 소스 매핑 추가 내용 정리   