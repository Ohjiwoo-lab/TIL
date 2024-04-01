# Terraform에서 Variable 사용하기

Terraform은 HCL 문법을 가진 언어이기 때문에, 변수를 정의하여 사용할 수 있다. 만약 IAM 그룹을 만들어서 사용자를 지정할 때 아래와 같이 사용자 이름을 하드코딩한다면 어떨까?

```
resource "aws_iam_group" "devops_group" {
    name = "devops"
}

resource "aws_iam_group_membership" "devops" {
    name = aws_iam_group.devops_group.name

    users = [
        "gildong.hong",
        "jiwoo"
    ]

    group = aws_iam_group.devops_group.name
}
```

그러면 사용자 이름이 변경될 때마다 해당 부분을 찾아서 일일히 바꿔줘야 하기 때문에 불편할 수 있다. 그래서 사용자의 이름에 해당하는 부분을 변수로 만들어보고자 한다.

먼저 변수를 선언해야 한다. 아무 tf 파일에 선언해도 되지만, 보통 `variables.tf` 파일을 따로 만든 뒤 그곳에 선언하는 게 일반적이라고 한다. 아래와 같이 선언해준다.

```
# variables.tf
variable "iam_user_list" {
    type = list(string)
}
```

이제 선언한 변수에 값을 대입해줘야 하는데, 이는 `terraform.tfvars` 파일을 이용한다.

```
# terraform.tfvars
iam_user_list = ["gildong.hong", "jiwoo"]
```

이제 이 변수를 이용하여 원래 코드를 변경해보자.

```
resource "aws_iam_group_membership" "devops" {
    name = aws_iam_group.devops_group.name

    users = var.iam_user_list

    group = aws_iam_group.devops_group.name
}
```

`var.변수명`으로 변수를 사용할 수 있다. 이제 사용자가 추가되거나 변경되면, terraform.tfvars 파일만 수정하면 되기 때문에 아주 편리해졌다.


# Variable을 Output 변수로 정의하기

Output이란 Variable을 state 파일에 저장하는 것을 말한다. state 파일에 저장해두면 변수를 정의한 파일이 로컬에 없더라도 state 파일만을 이용하여 remote를 통해 참조할 수 있게 된다.

새로운 변수 3개를 정의한다.

```
# variables.tf
variable "image_id" {
  type = string
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "ami_id_maps" {
  type = map
  default = {}
}
```

변수에 값을 할당해준다.

```
# terraform.tfvars
image_id = "ami-064c81ce3a290fde1"
availability_zone_names = ["us-west-1a","us-west-1b","us-west-1c"]
ami_id_maps = {
    ap-northeast-2 = {
      amazon_linux2 = "ami-010bf43fe22f847ed"
      ubuntu_18_04  = "ami-061b0ee20654981ab"
    }

    us-east-1 = {
      amazon_linux2 = "ami-0d29b48622869dfd9"
      ubuntu_18_04  = "ami-0d324124b7b7eec66"
    }
}
```

이제 Output 변수를 생성해줘야 하는데, 아래와 같이 생성할 수 있다.

```
# outputs.tf
output "tf101_image_id" {
    value = var.image_id
}

output "tf101_availability_zone_names" {
    value = var.availability_zone_names
}

output "tf101_ami_id_maps" {
    value = var.ami_id_maps
}
```

terraform apply를 하면, 다음과 같이 생성된 Output 변수들을 확인할 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/bb0001b6-c53b-4fc3-8eff-01c2385232a1)

다음은 state 파일에 저장된 Output 변수들이다. 이는 remote를 통해 참조할 수 있을 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/65eae294-8d91-4260-87cd-d4af31881d2f)

하나의 Output 변수를 추가로 정의해보자. 이전에 생성했던 availability_zone_names 변수에서 첫 번째 값만 output 변수로 저장했다.

```
# outputs.tf
output "tf101_first_availability_zone_names" {
    value = var.availability_zone_names[0]
}
```

결과를 확인해보면, 첫 번째 값인 `us-west-1a`가 저장되었음을 알 수 있다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d08ca738-152e-48bb-b123-c176f9185565)

이처럼 Output 변수로 지정해두면, apply를 할 때마다 어떤 변수들이 있는지 확인할 수 있기 때문에 실습을 할 때 유용하다. 만약 다른 사람이 정의해둔 변수에 참조해야 한다면, 이런 식으로 outputs로 정의해두는 것이 유용할 것이다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-4-1: Terraform Variable 정의하기