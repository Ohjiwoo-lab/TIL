# Backend 활용하기

Terraform에서 state 파일은 apply의 결과로 생성되는 인프라의 상태를 저장하고 있다. 하지만 테라폼 코드를 통해 생성한 당시의 인프라 상태를 의미하는 것이지, 현재 인프라의 상태를 의미하는 것이 아니다. 현재에는 상태가 달라졌을 수도 있다. 그래서 state 파일과 실제 인프라 상태를 유지시키는 작업이 중요하다.

Backend는 이러한 state 파일을 어디에 저장하고 가져올 지에 대한 설정이다. 기본값으로는 로컬에 저장되는데, s3, consul 등 원격 저장소를 이용할 수도 있다.

## Backend는 왜 사용할까?

그냥 로컬에 저장해도 되는데 왜 Backend를 따로 설정해야 하는 것일까? 

첫 번째 이유는 우리는 협업을 하기 때문이다. 혼자서 모든 코드를 작성하고 관리한다면 Backend는 필요없을 지도 모른다. 하지만 우리가 현업에서 만드는 인프라를 규모가 거대하기 때문에 혼자서 만들기는 쉽지 않을 것이다.

협업을 하다보면 의도치 않게 내가 작성한 코드를 다른 사람이 수정할 수도 있다. 동일한 코드를 동시에 수정하다보면 코드가 꼬일 수 있고 결과적으로 실제 인프라에 악영향을 줄 수 있다. 그래서 Backend에 `Locking`을 하여 코드에 대한 접근을 막아 의도치 않은 장애를 예방할 수 있다.

두 번째 이유는 `Backup`이다. 로컬에 저장되면 로컬 컴퓨터의 장애로 인해 손실될 수 있다. 원격 저장소에 저장해두면 더 안전하고 백업이 쉬워진다는 장점이 있다. 특히 S3의 경우 굉장히 높은 SLA를 제공해서 안전하며, versioning을 통해 실수로 파일을 삭제하는 것을 막아줄 수 있기 때문에 Backend로서 좋은 선택지가 된다.

## Backend 만들어보기

Backend는 S3를 사용할 것이다. 앞서 Backend를 사용하는 이유 중에 Locking을 통해 코드에 대한 접근을 막을 수 있다고 하였다. Locking을 구현하기 위해서 DynamoDB를 따로 생성해주어야 한다. state 파일은 s3 버킷에, state 파일에 대한 Lock 정보는 DynamoDB에 저장된다고 이해하면 된다. 그러면 Terraform은 두 가지를 모두 고려해서 접근 여부를 판단할 것이다.

이제 S3 버킷과 DynamoDB를 생성해보자.

- `tf101-jiwoo-apne2-tfstate`라는 이름의 s3 버킷을 생성한다.

    ```
    # S3 bucket for backend
    resource "aws_s3_bucket" "tfstate" {
        bucket = "tf101-jiwoo-apne2-tfstate"
    }
    ```

- versioning을 활성화하기 위해 추가 리소스를 추가로 만들어준다.
    ```
    resource "aws_s3_bucket_versioning" "versioning" {
        bucket = aws_s3_bucket.tfstate.id
        
        versioning_configuration {
            status = "Enabled"
        }
    }
    ```

- `terraform-lock`이라는 이름의 DynamoDB 테이블을 만들어준다.
    ```
    # DynamoDB for terraform state lock
    resource "aws_dynamodb_table" "terraform_state_lock" {
        name           = "terraform-lock"
        hash_key       = "LockID"
        billing_mode   = "PAY_PER_REQUEST"

        attribute {
            name = "LockID"
            type = "S"
        }
    }
    ```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/7fb78a11-5474-4cc6-a88e-f59bc96c476b)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/7c10b94a-d933-448b-8e62-10f51238d6c1)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/8cbf839f-fa9a-4ef5-8f78-cfa1e011e954)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/3b311e14-8831-45f1-8721-343d9bf6aeaf)


만든 S3 버킷이 실제 Backend로 동작하기 위해 설정을 해주어야 한다.

```
terraform {
    backend "s3" {
      bucket         = "tf101-jiwoo-apne2-tfstate"
      key            = "Dev/terraform/iam/terraform.tfstate"
      region         = "ap-northeast-2"  
      encrypt        = true
      dynamodb_table = "terraform-lock"
    }
}
```

- bucket: 생성한 S3 버킷 이름
- key: S3 버킷에서 state 파일이 위치하게 되는 경로(마음대로 설정해도 되지만, 로컬 경로와 일치하는 것이 좋음)
- region: S3 버킷이 위치한 리전
- encrypt: 암호화 여부
- dynamodb_table: 생성한 DynamoDB 테이블 이름

전에 IAM 실습 때 진행했었던 state 파일을 S3 버킷으로 관리해보자 한다. 그래서 state 파일이 있는 곳에 Backend 설정 파일(backend.tf)를 배치하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/a2d997a6-58cf-499c-a4a1-eca25d1a2b4f)

이 상태로 `terraform init`을 한다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/35f074f1-db20-4457-8615-db12b7883d40)

기존의 state 파일을 새로운 백엔드로 이동할 것인지 묻고 있다. yes를 입력하면 정상적으로 완료된다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/4dab59f4-0232-4bac-8467-d6835125d073)

설정했던 경로 `Dev/terraform/iam/`에 state 파일이 생성된 것을 확인할 수 있다. 이제 로컬에 state 파일이 없더라도 정상적으로 동작할 수 있다. 만약 다른 state 파일도 동일한 S3 버킷에서 관리하고 싶다면, 백엔드 설정 코드에서 `key` 경로를 다르게 설정해야 할 것이다. 동일한 경로로 파일을 올리게 되면 오류가 발생한다.

> 원격 저장소에 있는 state 파일을 로컬에서 보고싶다면 `terraform state pull` 명령어를 이용하면 된다.

## Locking

Locking은 어떻게 진행되는 것일까? 정확히 어떤 식으로 진행되는 지는 모르겠지만, 아래의 DynamoDB 테이블에 생성된 값을 살펴보자.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/30f6cec9-3ff2-420a-abda-891f7a185aa9)

3개의 항목이 생성되었다. 앞서 업로드했던 iam 외에 s3와 vpc 실습했던 것도 S3 버킷에 업로드한 결과이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/74f1927d-4b0e-4fb6-95de-9d550ad55131)

Digest라는 문자열이 하나 존재한다. 아마 이를 통해 Locking을 구현하는 듯하다.

vpc를 생성하는 코드의 state 파일을 S3 버킷에 업로드한 뒤, AWS 콘솔에서 수동으로 state 파일을 삭제했었다. 그리고 다시 Backend 연결을 시도하니까 다음과 같은 오류가 발생했다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/de4d2b74-35e2-4f6a-b85c-3a20222998d4)

이유를 생각해보니, state 파일이 올라갔던 때에 DynamoDB에 Digest 값이 설정됐었던 것이다. Terraform은 Digest 값을 확인한 뒤 해당 코드를 누군가가 수정하고 있음을 인식한 것이다. 그래서 다른 사람이 수정하려고 했을 때 못하도록 막은 것이라 추측했다.

> .terraform 폴더를 삭제한 뒤 다시 시도했었던 거라 Terraform은 나를 다른 사람으로 인식했을 것이다.

그래서 Digest 값을 삭제한 뒤 다시 시도해보니 정상적으로 연결되었다. 즉, 누군가 인프라를 생성해서 Backend에 state 파일이 생성되면, 이에 따라 Digest 값도 생성된다. 그래서 다른 사람이 해당 인프라를 수정하려고 하면 오류가 발생하는 원리인 듯 하다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-3-30: S3 버킷을 테라폼 백엔드로 설정하기   