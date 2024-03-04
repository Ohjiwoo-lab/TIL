# Terraform으로 VPC 생성하기

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

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/0edfaf36-c984-4aa5-8680-1c686beaeef1)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d922eb58-142b-4bdf-9334-0eea174dcb3a)

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

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3e6ca13d-ebf2-4805-a052-ffb1ebcbe279)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/5801162b-0f77-4de5-96d4-8144de8bc672)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/50aba0a5-d492-4635-bb81-562c14a09418)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/f06f0567-ab20-4449-8913-45d81f675de0)

2개의 서브넷이 생성되었다. 하지만 아직 라우팅 테이블은 생성하지 않았기 때문에 2개의 서브넷 모두 디폴트 라우팅 테이블에 연결되어 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/f7c07006-3180-457d-9975-6992df9fdcd5)

디폴트 라우팅 테이블은 위와 같이 아무런 규칙이 설정되어 있지 않다. 생성한 서브넷이 각각 프라이빗과 퍼블릭 서브넷으로 동작하기 위해서는 새로운 라우팅 테이블을 생성한 뒤 연결해줄 필요가 있을 것이다.

## 퍼블릭 서브넷 구성

### 인터넷 게이트웨이 생성

먼저 인터넷 게이트웨이를 생성한다.

```terraform
resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.main.id

	tags = {
		Name = "terraform-101-igw"
	}
}
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c484bf6a-818f-46ce-86bf-23d6f3506119)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/df942cac-50e5-495b-9118-4e6ad10ca6c7)

생성하는 방법은 간단하다. 연결하고자 하는 VPC의 ID를 지정해주면 된다. 이제 이 인터넷 게이트웨이를 퍼블릭 서브넷과 연결하면 인터넷 통신이 가능해진다.

### 라우팅 테이블 생성

인터넷 게이트웨이를 퍼블릭 서브넷과 연결하기 위해 라우팅 테이블을 생성할 것이다.

라우팅 테이블은 서브넷에 종속적이다. 즉 서브넷에 라우팅 테이블이 연결되어야지 비로소 완벽한 서브넷이 되는 것이다. 이전에 생성했던 인터넷 게이트웨이로 트래픽이 향하도록 라우팅 규칙을 추가한 라우팅 테이블을 퍼블릭 서브넷에 연결해야 비로소 퍼블릭 서브넷으로서의 역할을 수행할 수 있는 것이다.

```terraform
resource "aws_route_table" "public" {
        vpc_id = aws_vpc.main.id

		route {
                cidr_block = "0.0.0.0/0"
                gateway_id = aws_internet_gateway.igw.id
        }

        tags = {
                Name = "terraform-101-rt-pubic"
        }
}
```

라우팅 테이블의 규칙을 Inner Code 형태로 작성하였다. 외부로 나가는 `0.0.0.0/0` 트래픽에 대해서 인터넷 게이트웨이로 연결하는 규칙을 정의하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/65a2d657-e853-40f0-b3d5-f527a6aec29f)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/56f11e8e-8ed5-4956-8f2d-113929f6cd3f)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/a7053d55-527f-4ce7-903c-0f9501f37673)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/a50e8160-7307-4de9-8681-277e4a9641f6)

퍼블릭 라우팅 테이블이 생성되었다. 하지만 아직 이 라우팅 테이블을 서브넷에 연결해주지 않았다. 라우팅 테이블을 서브넷에 연결하는 작업을 진행해야 하는데, 이를 `association`이라고 한다. 라우팅 테이블은 여러 개의 서브넷에 연결될 수 있다. 여기에서는 퍼블릭 라우팅 테이블과 프라이빗 라우팅 테이블을 구분하였으므로 각각 서브넷에 연결해줄 것이다.

```terraform
resource "aws_route_table_association" "route_table_association_public" {
        subnet_id      = aws_subnet.public_subnet.id
        route_table_id = aws_route_table.public.id
}
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1298cb31-29e2-4d6c-9f40-35b83b09f887)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3ca9fa13-d0e4-4cb6-be60-4c3027b55903)

이제 퍼블릭 서브넷의 설정이 모두 완료되었다.


## 프라이빗 서브넷 구성

### NAT 게이트웨이 생성

이제 NAT 게이트웨이를 생성해볼 것이다. NAT 게이트웨이는 반드시 고정 IP를 가져야한다는 특징을 가지고 있다. 또한 NAT 게이트웨이는 퍼블릭 서브넷에 위치해 있으면서 프라이빗 서브넷과 연결되어야 한다. NAT 게이트웨이 자체는 외부와 통신이 가능해야 하기 때문이다.

```terraform
resource "aws_eip" "nat" {
        domain = "vpc"

        lifecycle {
                create_before_destroy = true
        }
}
```

NAT 게이트웨이에 할당해줄 고정 IP(Elastic IP)를 먼저 생성한다.

```terraform
resource "aws_nat_gateway" "nat_gateway" {
        allocation_id = aws_eip.nat.id

        subnet_id = aws_subnet.public_subnet.id

        tags = {
                Name = "terraform-NAT-GW"
        }
}
```

NAT 게이트웨이를 생성할 때에는 생성했던 고정 IP와 퍼블릭 서브넷의 ID를 설정해주면 된다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c3039fd2-10c4-48dc-91ff-cb869c40b2da)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c775ca9d-f5ab-4ff4-95d8-c3d6c5f7d3fa)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/b98eea4b-d8a0-41b6-a923-a8f8b64a2ff4)

NAT 게이트웨이가 정상적으로 생성되었다. 퍼블릭 IP 주소를 살펴보면 `52.79.68.61`이 할당되었는데, 방금 전 같이 생성했던 고정 IP이다. 이처럼 NAT 게이트웨이는 하나의 퍼블릭 IP를 가져야한다.

### 라우팅 테이블 생성

```terraform
resource "aws_route_table" "private" {
        vpc_id = aws_vpc.main.id

        tags = {
                Name = "terraform-101-rt-private"
        }
}

resource "aws_route" "privae_nat" {
        route_table_id = aws_route_table.private.id
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
}
```

퍼블릭 라우팅 테이블에서와 달리 이번에는 규칙을 추가하는 부분을 분리하였다. 라우팅 테이블과 라우팅 규칙을 별도의 리소스로 관리하는 것이다. 둘 중 무엇을 선택해도 상관없지만, 위와 같이 분리하는 형태가 코드의 확장성 측면에서 더 나은 선택이라고 할 수 있다. 만약 라우팅 규칙만을 가져와서 사용하고 싶은 경우가 있다면, 라우팅 테이블과 규칙이 분리되어 있는 것이 참조하기 훨씬 쉬워질 것이기 때문이다. 이렇게 확장성을 고려하여 코드를 작성하는 습관을 들이면 좋다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/0ce4c3ea-5de9-4ad6-9269-fff2ea400618)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/b5e20979-ab8e-4d70-adc8-3320be3837a6)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/a1a411e0-cbdb-4ee5-b7a6-e8b578e7a615)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2a900add-f8dd-4bc1-95ec-ebf0aa054e6a)

프라이빗 라우팅 테이블이 생성되었다. 하지만 이 역시 서브넷에는 아직 연결이 안되어 있는 상태이다. 퍼블릭 서브넷을 생성할 때와 마찬가지로 association을 생성해야 한다.

```terraform
resource "aws_route_table_association" "route_table_association_private" {
        subnet_id      = aws_subnet.private_subnet.id
        route_table_id = aws_route_table.private.id
}
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/057d275e-438b-40a2-a98b-bae863e6c910)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/7e2301ef-976a-494a-8e35-15aefd862015)

서브넷과 연결되었다. 이제 프라이빗 서브넷도 본인의 역할을 수행할 수 있다.

## VPC 엔드포인트 생성

추가로 VPC 엔드포인트를 생성해볼 것이다.

```terraform
resource "aws_vpc_endpoint" "s3" {
	vpc_id       = aws_vpc.main.id
	service_name = "com.amazonaws.ap-northeast-2.s3"
}
```

VPC 외부에 있는 S3 버킷에 대한 VPC 엔드포인트를 생성하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/5ab641d3-e4df-4a21-8b58-bcbbbd5124ac)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/7d9ff21f-2556-4d73-b8b3-33650fc87d32)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e97a3c8f-d5ce-444a-95e4-5cf66b50e6e4)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/08843a51-e948-46b2-b440-c1934c18b4dc)

하지만 아직 연결되어있는 라우팅 테이블이 없다. 이전에 생성했었던 퍼블릭 라우팅 테이블과 프라이빗 라우팅 테이블을 연결하면 된다. 라우팅 테이블을 서브넷과 연결할 때와 마찬가지로 `association`을 사용하면 된다.

```terraform
resource "aws_vpc_endpoint_route_table_association" "public_endpoint" {
	route_table_id  = aws_route_table.public.id
	vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private_endpoint" {
	route_table_id  = aws_route_table.private.id
	vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/ede18521-522d-4312-b156-8b2414f42261)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/4a492b16-2900-4dc6-816a-93f40118e9a1)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2c962836-7dac-4d62-8c88-d9fc4ded064e)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c90dc486-d1ba-411e-a889-7ff9e498648d)

이제 퍼블릭 서브넷과 프라이빗 서브넷에 있는 인스턴스는 VPC 외부에 있는 S3 버킷에 비공개 연결이 가능하다. 외부에 노출되지 않고 AWS 내부망을 이용하여 통신할 수 있게 되었다.

> 여기서 주의할 점은 VPC 내부에서 외부로의 통신을 하기 위한 수단이다. 외부에서 VPC 내의 프라이빗 서브넷에 접근할 수 있다는 것이 아니다.

# 전체 리소스 맵

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d091e3e7-3ab5-4875-bd7c-5bbc6dab5ec0)

지금까지 생성한 모든 리소스이다. 퍼블릭 서브넷의 경우 외부로는 인터넷 게이트웨이, AWS 서비스로는 VPC 엔드포인트를 이용하여 통신한다. 프라이빗 서브넷의 경우 외부로는 NAT 게이트웨이, AWS 서비스로는 VPC 엔드포인트를 이용하여 통신한다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-3-2: VPC의 정의와 테라폼으로 VPC, 서브넷 생성하기   
📌 2024-3-3: 인터넷 게이트웨이와 NAT 게이트웨이 생성하기   
📌 2024-3-4: 라우팅 테이블 생성 및 프라이빗, 퍼블릭 서브넷 구성