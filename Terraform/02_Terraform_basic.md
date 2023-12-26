# 테라폼 기초

## 구성요소

1. provider

- 생성할 인프라의 종류를 말합니다. 만약 AWS의 인프라를 구성하려고 하면, provider는 aws가 될 것입니다.

- 해당 코드를 통해서는 AWS의 리소스에 접근하기 위한 credentials 등의 파일을 다운받는 역할을 수행합니다.

- 예시
    ```terraform
    provider "aws" {
        region = "ap-northeast-2"
        version = "~> 3.0"
    }
    ```

2. resource

- 실제로 생성할 인프라의 자원을 명시합니다.

- .tf 확장자를 가집니다.

- 예시
    ```terraform
    resource "aws_vpc" "example" {
        cidr_block = "10.0.0.0/16"
    }
    ```
    - AWS의 VPC를 생성하는 코드입니다.
    - cidr_block 외에도 설정할 수 있는 Argument가 다양하게 존재합니다.
    - `example`은 생성한 VPC의 이름입니다.

3. state

- 실제로 테라폼 명령어를 실행하였을 때 생성되는 결과물입니다.

- .tfstate 확장자를 가지는 파일로 생성됩니다.

- 주의할 점은 state 파일에 저장된 값이 실제 인프라 자원의 상태를 의미하는 것은 아닙니다. state 파일과 실제 인프라 상태를 동일하게 유지하는 것이 중요합니다.

- 예시
    ```terraform
    {
        "version": 4,
        "terraform_version": "0.12.24",
        "serial": 3,
        "lineage": "3c77XXXX-2de4-7736-1447-038974a3c187",
        "output": {},
        "resources":[
            {...},
            {...}
        ]
    }
    ```
    - 지금은 형태만 보고 넘어가고 나중에 다시 자세하게 살펴보겠습니다.

4. output

- 생성한 자원을 변수 형태로 state 파일에 저장하는 것입니다.

- 이는 remote로 참조될 수 있습니다.

- 예시
    ```terraform
    resource "aws_vpc" "example" {
        cidr_block = "10.0.0.0/16"
    }

    output "vpc_id" {
        value = aws_vpc.example.id
    }

    output "cidr_block" {
        value = aws_vpc.example.cidr_block
    }
    ```
    - 이전에 생성한 VPC의 id와 cidr_block을 가져와서 변수에 저장하는 예제입니다.

5. module

- 한 번 만들어진 테라폼 코드를 같은 형태로 반복적으로 만들어낼 때 사용합니다.

- 재사용에 강점이 있습니다.

- 예시
    ```terraform
    module "vpc" {
        source = "../_modules/vpc"

        cidr_block = "10.0.0.0/16"
    }
    ```
    - VPC를 cidr_block만 다르게 하여 다시 생성해야 할 때 사용될 수 있습니다.

6. remote

- 다른 경로의 state 파일에서 output 변수를 불러올 때 사용됩니다. (원격 참조)

- 예시
    ```terraform
    data "terraform_remote_state" "vpc" {
        backend = "s3"

        config = {
            bucket = "terraform-s3-bucket"
            region = "ap-northeast-2"
            key = "terraform/vpc/terraform.tfstate"
        }
    }
    ```
    - s3 버킷에 저장되어 있는 .tfstate 파일을 참조합니다.
    - key 값에 명시한 state 파일에서 변수를 가져오는 예제입니다.
    - `vpc`는 remote의 고유한 이름을 의미합니다.
    
    ```terraform
    output "vpc_id" {
        value = aws_vpc.example.id
    }

    resource "aws_instance" "example" {
        vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    }
    ```
    - 실제로 remote를 사용하려면 다음과 같이 작성할 수 있습니다.
    - .tfstate 파일에 `vpc_id`라는 output 변수가 있다면, 인스턴스를 생성할 때에 remote를 이용하여 불러올 수 있습니다.

7. backend

- state 파일을 저장하는 공간을 의미합니다.

- 대표적으로 AWS S3가 있습니다.


## 기본 명령어

1. init

- 테라폼의 명령어들을 사용하기 위해 최초에 실행되어야 하는 명령어입니다.

- 내부적으로 provider와 state, module 등 각종 설정이 진행됩니다.

2. plan

- 테라폼으로 작성된 코드가 실제로 어떻게 자원으로 만들어질 지에 대한 예측 결과를 보여주는 명령어입니다.

- 실제로 가장 많이 사용되는 명령어입니다.

3. apply

- 테라폼 코드를 실행하여 실제 인프라를 생성하는 명령어입니다.

4. import

- 이미 만들어져 있는 자원을 코드로 만들어 state 파일로 옮겨주는 명령어입니다.

- 기존에 route53이라는 자원을 만들었다고 가정하면, 이를 불러와 사용할 수 있다는 것입니다.

5. state

- state 파일을 다루는 명령어입니다. mv, push와 같은 하위 명령어가 존재합니다.

6. destroy

- 생성된 자원을 state 파일을 기준으로 하여 모두 삭제하는 명령어입니다.

- 삭제하고 새롭게 만들고 싶은 경우에 사용합니다.


## 명령어 사용 프로세스

> 테라폼 코드 작성 -> init -> plan -> apply

보통 다음과 같은 단계로 진행됩니다. 

실행할 테라폼 코드를 작성하는 것이 수반되어야 합니다. 

그 후에 테라폼 명령어들을 사용하기 위해 `init` 명령으로 환경 설정을 해줍니다. 

그리고 실행 결과를 예측하기 위해 `plan` 명령어를 사용합니다. plan의 결과에서 오류가 없어야 실제로 실행했을 때 오류가 없을 확률이 높습니다. 하지만 plan이 100% 오류가 없음을 보장해주지는 않습니다. 예측 결과일 뿐 항상 올바르게 동작한다고 장담할 수는 없기 때문이죠. 

그 후에 `apply`를 통해 코드를 실행하여 자원을 생성합니다. apply는 실제로 인프라에 영향을 미치기 때문에 실행에 유의해야 하며, apply 하기 전에 plan을 하는 습관을 들여야 합니다.

## 테라폼 작동 원리

테라폼은 크게 3가지로 구성되어 있습니다.

1. 로컬에서 작성한 코드
2. 코드를 통해 만들어진 실제 AWS 인프라
3. 백엔드에 저장되는 state 파일

그래서 이 3가지 구성요소 간의 흐름을 이해하여야 합니다.

코드를 통해 만들어지는 실제 AWS 인프라와 백엔드에 저장된 state 파일이 100% 일치하도록 만드는 것이 중요합니다. 만약 state 파일을 변경한 후 반영했는데 다른 개발자와의 싱크가 맞지 않거나, 생성된 AWS 인프라를 콘솔로 변경하려고 하거나, 백엔드에 저장된 state를 임의로 변경하려고 한다면 일치하지 않는 경우가 생길 수도 있습니다.

이를 일치시키기 위해 지속적으로 plan-apply를 하는 것이 중요합니다. 실제로 명령어를 사용해보면서 작동 원리를 이해해보겠습니다.

### Init

init 명령어를 하기 위해서는 테라폼 코드가 존재해야 합니다. 그래서 provider 코드를 작성해보겠습니다.

```terraform
provider "aws" {
    region = "ap-northeast-2"
}
```
provider는 어떤 인프라를 테라폼으로 다룰 지에 대한 내용을 담고 있습니다. AWS를 사용하고 리전을 서울로 지정하였습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2c87754e-2c45-4a16-9a1f-f0aeddf746be)

이제 init을 진행합니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9e7f5153-c2b0-4320-a9a5-56e8406371a2)

그러면 provider로 지정한 AWS 관련 설정이 이루어집니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9aca1fe2-1fdc-4461-8e34-3c8cf98eae39)

init의 결과물로 `.terraform` 폴더가 생성되었습니다. 테라폼 내부적으로 AWS의 API를 호출하여 인프라를 생성하고 변경하게 됩니다. 그래서 AWS의 API를 호출하기 위한 라이브러리를 설치하는 작업도 init 명령어의 역할입니다.


### Plan

이제 실제 인프라를 생성해보겠습니다.

```terraform
resource "aws_s3_buket" "test" {
    bucket = "terraform101-inflearn-jiwoo"
}
```

리소스 파일을 생성해줍니다. 이는 `terraform101-inflearn-jiwoo`라는 이름의 S3 버킷을 생성하는 `test` 리소스 코드입니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/30359880-b3cb-4764-9ec8-a2e627e96a43)

이를 적용하기 전에 plan을 통해 예측 결과를 확인해보겠습니다. 

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/fb1e8ca3-fa39-4960-a011-82602d495a08)

해당 리소스 코드로 S3 버킷 하나가 생성된다고 예측하였습니다. plan 명령어는 실제 인프라에 아무런 영향을 주지 않습니다.


### Apply

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/caed443c-ef60-4d06-9326-a454476535ef)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1d771fb6-6121-44c7-8f77-b51fa03fe1e4)

apply 명령어를 통해 실제 인프라를 배포하였습니다. 명령어를 실행하기 위해서는 중간에 `yes`를 수동으로 입력해야 합니다. 이는 명령어를 잘못 입력한 경우를 방지하기 위해서 입니다. 실제 인프라에 영향을 줄 수 있는 명령어이기 때문에 항상 주의할 필요가 있습니다.

apply 명령을 수행하고 나면 인프라가 실제로 생성되고, 인프라의 상태 정보를 저장하는 state 파일이 백엔드에 저장됩니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e2d68156-010c-4d8a-b862-dee87631e534)

AWS 콘솔을 통해 생성된 S3 버킷을 확인하였습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/aa03203c-f7c7-4012-89d2-2da6168af5d4)

생성된 state 파일입니다. 백엔드를 따로 지정하지 않았기 때문에 로컬에 저장된 것입니다.

### 테라폼이 인프라를 인식하는 방법

> state 파일이 삭제된다면?

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6f50697f-4aff-4e80-8788-96ee25731a64)

이 상태로 plan을 다시 진행해보겠습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/bf64cc1a-43ce-400e-ab9c-c7a3dc6d3261)

이미 존재하는 `terraform101-inflearn-jiwoo` 버킷을 다시 생성한다고 예측하였습니다. 여기서 알 수 있는 것은 테라폼은 실제 인프라가 존재하는 지 여부를 확인하지 않는다는 것입니다. 백엔드에 state 파일이 저장되어 있는 지를 확인하고 없기 때문에 새롭게 만들어야겠다고 판단한 것입니다.

즉, 테라폼이 인프라를 인식하는 방법은 state 파일인 것입니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d575e286-bfb5-46fb-8755-9a3ae998ee95)

apply를 하면 plan의 예측대로 S3 버킷이 생성되지 않습니다. 이미 동일한 이름의 버킷이 존재하기 때문입니다. 이처럼 plan과 apply의 결과는 항상 일치하지 않을 수 있기 때문에 주의해야합니다.

### Import

결국 테라폼은 인프라의 정보를 state 파일로 관리합니다. state 파일이 있다면 인프라가 존재하는 것으로 판단합니다.

그러면 이미 존재하는 인프라의 상태 정보를 불러오면 테라폼이 해당 인프라를 인식하게 할 수 있습니다.

```terraform
terraform import aws_s3_bucket.test terraform101-inflearn-jiwoo
```

- test: 리소스 이름
- terraform101-inflearn-jiwoo: 불러올 S3 버킷 이름

import를 하기 위해서는 로컬에 리소스 파일이 존재해야 합니다. 리소스 정보를 바탕으로 state 파일을 생성하기 때문입니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/b6e8ff82-b2e4-409e-ab71-39fd8d6086d7)

import 결과 .tfstate 파일이 생성되었습니다. 강의에서는 import 만으로 코드 생성이 이루어지지는 않는다고 하였는데, 버전이 업그레이드되면서 자동으로 state 파일이 생성된 것 같습니다.

그래도 혹시 모르니 `terraform plan` -> `terraform apply`를 통해 백엔드의 state 파일과 실제 인프라 상태를 일치시킵니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e3d25948-c366-41b9-9f9a-2fa127069605)

테라폼을 사용함에 있어서 가장 중요한 것은 state 파일과 실제 인프라 정보를 일치시키는 것입니다. 그래서 state 파일의 정보를 바탕으로 실제 인프라와의 변경사항을 보여주는 `plan` 명령어를 적극적으로 활용해야 합니다.

<hr/>

😃 2023-12-22 TIL   
😃 2023-12-26 TIL - 테라폼 작동 원리 추가