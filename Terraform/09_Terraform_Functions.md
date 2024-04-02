# Terraform에서 Functions 사용하기

Terraform도 일종의 언어이기 때문에 변수와 마찬가지로 함수도 사용할 수 있다. 하지만 Terraform 자체에서 제공해주는 내장 함수 외에 사용자가 직접 함수를 정의하는 것은 불가능하다. (아직은 안되지만 곧 기능이 나올 수도 있다. 아마 나올 것 같다.) 내장 함수는 [Functions](https://developer.hashicorp.com/terraform/language/functions)에서 자세히 살펴볼 수 있다. 주로 Numeric Functions와 Collection Functions가 많이 사용된다.

함수의 예시를 살펴보자.

```
max(12, 54, 3)
```

Numeric 함수에서는 가장 잘 알려진 Max 함수가 있다. 여러 수 중에서 가장 큰 값을 리턴한다.

```
join("-", ["foo", "bar", "baz"])
split(",", "foo,bar,baz")
```

문자열을 다루는 함수 중에는 join과 split이 있다. join을 이용하면 리스트를 문자열로 연결해주고, 반대로 split을 이용하면 문자열을 쪼개서 리스트로 만들어준다.

그러면 실제 코드에서는 어떻게 사용되는지 살펴보자. 강사님이 운영 중인 오픈소스를 이용하여 실습할 것이다. 링크는 [다음](https://github.com/DevopsArtFactory/aws-provisioning/tree/main/terraform/vpc/artd_apnortheast2)과 같다.

해당 코드를 살펴보면 `count`를 찾을 수 있는데, 이는 count 파라미터라 한다. 모든 리소스에 적용할 수 있으며, count에 지정된 숫자만큼 리소스를 만들어준다. 만약 `count = 3`라 하였다면 동일한 리소스가 3개 생성되는데, Terraform에서 자체적으로 리소스 이름 뒤에 [0]를 붙여서 리스트로 만들어준다고 한다.

VPC를 만들 때 서브넷을 생성하는 코드 중 일부를 가져왔다.

우선 가용 영역에 대한 변수를 살펴보자.
```
# variables.tf
variable "availability_zones" {
  type        = list(string)
  description = "A comma-delimited list of availability zones for the VPC."
}

# terraform.tfvars
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
```

변수 `availability_zones`를 선언한 뒤, `ap-northeast-2a`와 `ap-northeast-2c`를 대입하였다. 이제 이 2개의 가용 영역에 대해 서브넷을 생성할 것이다.

```
resource "aws_subnet" "public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/20"
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_subnet" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/20"
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_subnet" "private_db" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private_db[count.index]}.0/20"
  availability_zone = element(var.availability_zones, count.index)
}
```

각각 퍼블릭 서브넷, 프라이빗 서브넷, DB 전용 프라이빗 서브넷이다. 코드를 하나씩 살펴보자.

```
count  = length(var.availability_zones)
```

해당 코드는 변수 `availability_zones`의 길이만큼 리소스를 생성하라는 의미이다. count 파라미터와 length 함수를 사용하였다. 이번에 availability_zones를 2개 정의하였으므로, 각 서브넷이 2개씩 생성될 것임을 짐작할 수 있다.

```
cidr_block = "10.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/20"
```

서브넷의 cidr_block을 정의하는 코드인데, `count.index`를 주의깊게 살펴보자. count 파라미터에 index가 있다는 것을 의미한다. 즉, 리소스를 생성할 때 Terraform 자체적으로 count 파라미터의 index에 따라 `public[0]`, `public[1]`과 같이 리소스 이름을 붙이게 된다. 그래서 이 index를 참조할 수도 있다. 위와 같은 방식으로 사용한다면, 변수 `cidr_numeral_public`에서 첫 번째 값과 두 번째 값이 차례대로 참조될 것이다.

```
availability_zone = element(var.availability_zones, count.index)
```

마지막은 `element`이다. 이는 리스트에서 특정 인덱스의 값을 가져오는 함수이다. 그러면 해당 코드는 변수 `availability_zones`에서 count 파라미터의 인덱스에 해당하는 값을 가져온다는 의미이고, `ap-northeast-2a`와 `ap-northeast-2c`가 차례대로 가져와질 것이다.

한 가지 함수를 더 실습해보자. `flatten`이라는 함수인데, 여러 리스트를 하나의 리스트로 합쳐준다.

```
output "all_subnets" {
  description = "List of All subnet ID in VPC"
  value = flatten([aws_subnet.private.*.id, aws_subnet.public.*.id, aws_subnet.private_db.*.id])
}
```

이전에 생성했던 3가지의 서브넷을 모두 합친 것을 output 변수로 만들어보았다. 이제 프라이빗 서브넷 2개, 퍼블릭 서브넷 2개, DB 프라이빗 서브넷 2개의 ID가 하나의 리스트로 합쳐져서 all_subnets 변수에 담길 것이다.

이제 결과를 확인해보자.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/cc2f0f24-78d3-4533-988e-0e4509fc9efe)

```
all_subnets = [
  "subnet-0facaa1a73e27a693",
  "subnet-07818d84c906d5c27",
  "subnet-0e4e2761f76cc1dd4",
  "subnet-0a60b84511786f2f4",
  "subnet-00cceff194e292264",
  "subnet-0d5297bff08a5c3bf",
]
```

의도했던 대로 서브넷 6개가 하나의 리스트로 합쳐진 것을 확인할 수 있다. 이런 식으로 Terraform에서 제공해주는 함수들을 적절히 사용하면 코드도 간결해지고 참조하기도 쉬워질 것이다. 모든 함수를 다 외울 필요는 없고, 그때그때 공식문서를 통해 찾아서 사용하면 된다.

> 리소스의 순서는 아무렇게나 선언해도 상관없다. Terraform에서 알아서 순서에 맞게 리소스를 생성해주기 때문이다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-4-2: Terraform Functions 사용하기