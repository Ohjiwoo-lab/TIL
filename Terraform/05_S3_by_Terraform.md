# S3란?

S3는 Simple Storage Service의 약자로, 인터넷용 스토리지 서비스이다. S3는 정말 방대한 양의 저장공간을 제공해주기 때문에 `Infinity Storage`라고 불리기도 한다. 무수히 많은 데이터를 저장하더라도 빠르게 검색해서 가져올 수 있고 높은 확장성을 제공해준다. 또한 거의 100%에 가까운 신뢰성을 보장해주는데, 이는 S3에 저장한 데이터는 거의 유실되지 않는다는 것을 의미한다. 이 밖에도 개발자를 위해 정말 다양한 기능을 제공해주는 서비스이다.

S3 버킷의 이름은 모든 리전에 대해 고유한 값이어야 한다. 또한 리전에 종속적이기 때문에 하나의 리전에 속해있어야 한다. 테라폼 코드를 통해 생성할 경우에는 초기에 `provider.tf`를 통해 설정했던 리전이 자동으로 반영된다.

# Terraform으로 S3 생성하기

## S3 버킷 생성

S3에서 가장 기본이 되는 리소스는 `버킷`이다. 사진, 동영상 등 객체가 저장되기 위한 저장소이다. 폴더라고 이해하면 쉽다.

```terraform
resource "aws_s3_bucket" "s3" {
  bucket = "devopsart-terraform-101-jiwoo"
}
```

버킷의 이름은 반드시 포함되어야 한다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/918942d9-8912-4316-9212-d026872066e7)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/cc82d873-38f3-44ef-b150-161ffc6ea553)

`devopsart-terraform-101-jiwoo`라는 이름의 버킷이 생성되었다. S3는 인터넷 스토리지 서비스이기 때문에 언제든 파일을 다운받고 업로드할 수 있다.

## 파일 업로드 및 다운로드하기

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/45906bf8-27b3-4d54-8edd-0dcee8fe712d)

생성한 버킷에 업로드하기 위해 파일을 하나 생성해주었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/beea47c8-c965-493a-9a79-59199dd53bf1)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/20217feb-fd31-4a67-82b2-02607482dbcc)

aws cli를 통해 파일을 업로드하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/58e6a4d1-8295-4f41-86fe-6961627b81e2)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/431536ec-b740-45b1-aaf1-f0d6f8b01d7b)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/bf4bfe39-ddb1-40ee-ad6e-90642396cd9a)

마찬가지로 파일 하나를 더 생성하여 업로드하였다. 존재하지 않는 경로로 업로드하게 되면 해당 폴더를 알아서 생성해준다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/52b80c76-1a33-490c-890f-25d3b2097285)

다운로드 받을 때에는 위치를 반대로 해주면 된다.

> 지금 나는 액세스 키를 이용하여 설정을 해두었기 때문에 S3 버킷에 접근이 가능했다. 하지만 해당 버킷은 퍼블릭 액세스가 불가능하기 때문에 인터넷으로는 접근이 불가능하다.

만약 퍼블릭 접근이 가능하도록 버킷을 설정해두면, S3를 정적 웹사이트 호스팅으로도 사용할 수 있다. S3 버킷에 index.html 같이 정적인 웹페이지를 업로드해두면 객체마다 고유의 URL을 제공해주기 때문에 누구에게나 제공이 가능해지는 것이다. 그래서 간단한 정적 웹페이지를 호스팅하고 싶은 경우에 아파치 웹서버 등을 사용하기도 하지만 요즘에는 S3 서비스도 많이 이용하는 추세이다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-3-4: 테라폼으로 S3 생성하기