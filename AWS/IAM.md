# IAM이란?

IAM은 Identity and Access Management의 약자로, 사용자를 생성 및 관리하고 접근할 수 있는 리소스에 대한 인증과 권한을 부여할 수 있는 서비스이다. IAM은 리전에 종속적이지 않다. `Global Resource`라고 부르는데, 리전별로 생성되는 것이 아니라 전체 리전에 걸쳐 한 개만 생성되는 리소스라는 의미이다. 사용자는 AWS 서비스를 통틀어 고유해야하기 때문이다.

IAM은 AWS 내의 보안을 유지하기 위해 필요하다. 그러면 보안은 어떻게 구현할 수 있을까? 다음은 보안을 구현하기 위한 3가지 방법이다.

1. Blocking

    리소스에 대한 접근 또는 사용 자체를 금지하는 것을 말한다.

2. Encrypting

    공개되어 있는 정보를 암호화하여 정보를 실제로 취득했더라도 알지 못하도록 하는 보안 방법이다.

3. Hiding

    정보에 접근하기 위해 특정 경로와 명령어만을 사용하도록 제한하는 방법이다. 아예 정보에 접근할 수 있는 방법 자체를 숨겨버려서 정보가 어느 위치에 있는지 알지 못하게 하는 것이다.

보통 Encrypting과 Hiding은 같이 사용하며, Blocking이 가장 강력한 보안 방법이라고 할 수 있다. IAM의 경우 Blocking을 통해 보안을 설정하는 방법이다.


## IAM의 구성요소

IAM의 구성요소는 다음과 같다.

1. Policy

    리소스에 대한 접근 권한을 정의하는 것이다. Json의 형태로 정의하며, `Effect`, `Action`, `Resource`, `Condition`으로 구성된다.

2. User

    AWS 계정에서 생성한 사용자를 의미한다. 사용자는 Policy를 가지고 있고, 허용된 권한에 해당하는 활동만 수행할 수 있다. 사용자에 부여된 권한은 영구적으로 유지된다.

3. Group

    여러 사용자를 하나의 그룹으로 지정할 수 있다. 그룹마다 Policy를 부여하여 그룹에 속해있는 사용자에게 동일한 권한을 부여하기 용이하다. 그룹에 속한 사용자들은 동일한 권한을 부여받으며, 사용자마다 추가 권한을 부여받을 수 있다.

4. Role

    특정 권한을 가지고 있는 자격증명으로, EC2 인스턴스와 같은 AWS 서비스에 할당하여 권한을 위임할 수 있다. 이는 STS를 이용한 일시적인 권한 부여 방법이다.

## Policy의 구조

Policy에 대해 좀 더 살펴보자. 아래는 Policy의 예시이다.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*",
            "Condition": {
                "StringEquals": {"aws:ResourceTag/VolumeUser": "${aws:username}"}
            }
        }
    ]
}
```

해당 정책은 본인이 소유한 EC2 인스턴스에 대해 볼륨을 부착하고 제거할 수 있도록 허용하는 내용을 담고 있다. 구성요소를 살펴보자.

- Statement: 정책은 여러 개의 Statement로 이루어져 있다. 콤마를 통해 여러 권한을 추가할 수 있다. (리스트 형태)

- Effect: 허용할지 금지할지에 대한 것이다. `Allow` 또는 `Deny` 값을 가질 수 있다.

- Action: 특정 API 작업을 의미한다. 위의 예시에서는 `AttachVolume`, `DetachVolume`에 해당하며, 해당 작업을 Allow 할 지 Deny 할 지를 결정하는 것이다.

- Resource: Action에 해당하는 작업의 영향을 받는 리소스를 의미한다. 리소스의 이름(ARN)을 지정할 수 있다.

- Condition: 권한을 부여하는 조건을 지정할 수 있다. 이는 반드시 들어가야하는 요소는 아니다. 위의 에시에서는 `ResourceTag/VolumeUser` 값이 사용자 이름과 같은 경우에만 해당 권한을 적용하라는 의미이다. 즉 사용자 소유의 볼륨만을 붙이거나 뗄 수 있다는 의미이다.

IAM 정책을 부여하지 않으면 기본적으로 모든 권한이 부인된다. 즉 특정 권한을 명시적으로 부여해야 리소스에 접근할 수 있게 되는 것이다.


# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-3-4: IAM의 구성요소와 Policy의 구조