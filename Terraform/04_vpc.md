# VPC란?

VPC란 Virtual Private Cloud의 약자로 AWS에서 제공해주는 가상 네트워크 망이다. 사용자는 VPC를 통해 독자적인 네트워크를 구성할 수 있다. VPC를 이루는 구성요소는 다음과 같다.

1. 서브넷

    VPC는 여러 개의 서브넷으로 구분된다. 서브넷은 VPC의 특정 IP 주소 범위를 의미하는데, 연결되어 있는 라우팅 테이블에 따라 퍼블릭 서브넷과 프라이빗 서브넷이 존재한다.([참고](https://github.com/Ohjiwoo-lab/TIL/blob/main/AWS/subnet.md)) 서브넷은 특정 가용영역에 포함되어 있으며, 여러 개의 가용영역에 걸쳐 생성하는 것은 불가능하다.

2. 라우팅 테이블

    네트워크 트래픽을 어느 곳으로 전달할지 결정하기 위해 사용된다. 라우팅 테이블에는 라우팅 규칙이 포함된다.

3. 인터넷 게이트웨이

    VPC 내의 리소스들이 인터넷과 통신하기 위해 VPC에 연결되는 게이트웨이이다. 퍼블릭 서브넷에 위치한 리소스들은 인터넷 게이트웨이를 통해 외부와 통신한다.

4. NAT 게이트웨이

    NAT은 네트워크 주소 변환이라는 의미이다. 네트워크 주소 변환을 통해 외부와 단절되어 있는 프라이빗 서브넷의 리소스들이 외부와 통신할 수 있다. NAT 게이트웨이는 퍼블릭 서브넷에 연결된다.

5. Security Group

    보통 EC2 인스턴스에서 사용되는 것으로, 인스턴스에 대한 인바운드, 아웃바운드 규칙을 정의하고 있다. VPC 내의 인스턴스에 허용할 트래픽과 허용하지 않을 트래픽을 구분할 수 있다.

6. VPC 엔드포인트

    VPC 외부의 서비스가 VPC 내부의 인스턴스로 접속하기 위해서는 인터넷 게이트웨이, NAT 게이트웨이가 반드시 필요했다. 하지만 VPC 엔드포인트를 이용하게 되면 VPC 내의 인스턴스가 퍼블릭 IP를 가지고 있지 않더라도 외부 서비스는 VPC에 비공개로 연결할 수 있다. 이때 모든 트래픽은 아마존의 내부망을 통하기 때문에 외부에 노출될 위험이 없다는 장점이 있다.

<br/>

# Terraform으로 직접 만들어보기

## VPC와 서브넷 생성

> 이전 글에서 구축했던 EC2를 이용하지 않고 로컬 컴퓨터를 이용해서 화면에 차이가 있을 수 있습니다. provider 파일을 생성한 뒤, `init`을 진행한 상태입니다.

다음은 VPC를 생성하는 코드이다.

```terraform
resource "aws_vpc" "main" {
	cidr_block = "10.0.0.0/16"

	tags = {
		Name = "terraform-101"
	}
}
```

테라폼으로 VPC를 생성할 때에 많은 인자 값이 있지만 `cidr_block`은 필수로 설정해줘야 한다. cidr_block을 `10.0.0.0/16`으로 지정하고, VPC의 이름을 `terraform-101`로 설정하였다. 여기서 주의할 점은 `main`이 VPC의 이름이라고 착각하면 안된다는 것이다. main은 해당 리소스의 이름일 뿐이고, VPC의 이름을 설정하기 위해서는 따로 tags를 지정해주어야 한다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/42cf657f-d617-4b54-9740-d874fece2c8a)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3a695041-8935-4e1c-8a61-c963709dd25c)

`terraform-101`이라는 이름의 VPC가 정상적으로 생성되었다.

이제 프라이빗 서브넷과 퍼블릭 서브넷을 하나씩 생성해볼 것이다.

```terrafrom
resource "aws_subnet" "public_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.0.0/24"
	
	availability_zone = "ap-northeast-2a"
	
	tags = {
		Name = "terraform-101-public-subnet"
	}
}

resource "aws_subnet" "private_subnet" {
	vpc_id = aws_vpc.main.id
        cidr_block = "10.0.10.0/24"
	
	tags = {
		Name = "terraform-101-private-subnet"
	}
}
```

이는 위의 VPC 코드를 작성했던 리소스 파일에 연결해서 작성해도 무방하다. 리소스 별로 구분하고 싶으면 새로운 .tf 파일을 생성하면 된다.

서브넷은 VPC에 속해있기 때문에 속해있는 VPC ID와 cidr_block은 반드시 설정해주어야 한다. 이때 cidr_block은 당연히 VPC의 cidr_block에 속해있어야 한다. 테라폼에서는 참조가 가능하기 때문에 실제 VPC의 ID를 명시하는 것보다 `aws_vpc.main.id`로 참조하는 것이 더 좋은 방법이다. 특정 숫자에 종속되는 것이 아니라 main이라는 리소스를 가져오는 것이기 때문에 변경에 유연하게 대응할 수 있을 것이다.

2개의 서브넷을 생성할 때에는 서브넷 간에 cidr_block이 겹치지 않도록 해야 한다. VPC에서와 마찬가지로 tags를 이용하여 서브넷의 이름을 지정해주었다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1df8070b-a09a-4adf-ab48-7a938e1b3e1a)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1b4e6200-f12a-448c-84f3-834e9c44070b)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c0b9ae30-201b-4ca3-ac08-05face14e704)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/64f7d54f-263f-4525-a8e3-d082bad0af14)

2개의 서브넷이 생성되었다. 하지만 아직 라우팅 테이블은 생성하지 않았기 때문에 2개의 서브넷 모두 디폴트 라우팅 테이블에 연결되어 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/f7c07006-3180-457d-9975-6992df9fdcd5)

디폴트 라우팅 테이블은 위와 같이 아무런 규칙이 설정되어 있지 않다. 생성한 서브넷이 각각 프라이빗과 퍼블릭 서브넷으로 동작하기 위해서는 새로운 라우팅 테이블을 생성한 뒤 연결해줄 필요가 있을 것이다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-3-2: VPC의 정의와 테라폼으로 VPC, 서브넷 생성하기