# API Gateway란?

API Gateway는 Lambda, HTTP Endpoint, AWS Service의 앞에 위치하여 클라이언트에게 공개적으로 배포된 API를 제공해주는 서비스이다. 그런데 직접 호출할 수도 있는데 API Gateway를 거쳐야 하는 이유가 무엇일까? API Gateway는 다음과 같은 기능을 제공해준다.

- API versioning

- 사용자 인증

- API 호출 트래픽 관리

    - API Key를 이용한 클라이언트 식별
    - Usage Plan을 이용한 API 액세스 관리
    - 특정 사용자에게 허용되는 API 개수 제한

- API 응답 캐싱

- CORS(Cross-origin resource sharing) 보안

그래서 온프레미스 상의 프라이빗한 HTTP API를 공개적으로 배포하거나, 애플리케이션 로드밸런서 앞에서 요청 개수 제한, 캐싱, 사용자 인증을 사용하고자 할 때, Step Function workflow를 시작하려고 하거나, SQS에 메시지를 보내려고 할 때 주로 사용한다.

## API Gateway의 한계점

그런데 API Gateway는 한계가 존재한다. 요청에 대한 29초 타임아웃이 존재하고, 처리할 수 있는 최대 payload size는 10MB이다. 만약 API Gateway에서 Lambda 함수를 호출했는데 함수 처리에 3분이 소요된다면, API Gateway는 타임아웃될 것이다. 또한 10MB 이상의 데이터를 보낼 수 없다. 요청을 처리하는 데에 오래걸리는 경우나, 큰 사이즈의 데이터를 보내야 하는 경우에는 API Gateway는 좋은 선택이 아니다.

만약 아래와 같은 S3 버킷에 사진을 업로드하는 애플리케이션이 있다고 가정해보자.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/61dd8d34-08a2-4ee5-ad33-a112e0a34c45)

S3에 바로 업로드하면 보안상 문제가 될 수 있기 때문에 API Gateway를 앞단에 배치하여 사용자 인증 기능을 추가한 예시이다. 그런데 API Gateway는 10MB 이상의 데이터를 처리하지 못하기 때문에 10MB 이하의 사진만 요청할 수 있을 것이다.

이러한 아키텍처도 가능하긴 하지만, 이보다는 아래와 같은 방식이 더 나은 선택일 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/28d0a280-c3e0-4c6d-a456-b595bdf8bc54)

다음과 같이 동작한다.

1. 클라이언트는 API Gateway로 요청을 보낸다.

2. API Gateway는 Lambda 함수를 호출한다.

3. Lambda 함수는 미리 서명된 URL을 생성한 뒤 API Gateway로 리턴한다.

4. 클라이언트는 API Gateway로부터 받은 미리 서명된 URL을 토대로 S3 버킷에 직접 파일을 업로드한다.

비록 Lambda 함수가 추가로 필요하지만, 사용자는 크기에 상관없이 파일을 업로드할 수 있다는 장점이 있다. 추가로 미리 서명된 URL의 유효기한을 설정하여 일정 시간 동안만 업로드가 가능하도록 추가 보안 요소를 설정할 수 있다.

API Gateway는 REST API와 WebSocket을 처리할 수 있는 훌륭한 서비스이지만, 비용이 비싸고 위에서 언급한 대로 한계점이 있기 때문에 아키텍처를 구성할 때 유의할 필요가 있다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌2024-3-26: API Gateway 개요와 한계점   