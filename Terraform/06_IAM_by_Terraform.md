# IAM User와 Group 생성

## User 생성

IAM User를 생성해볼 것이다.

```terraform
resource "aws_iam_user" "gildong_hong" {
    name = "gildong.hong"
}
```

User를 생성할 때에는 사용자 이름이 필수 요소이다. `gildong.hong`이라는 이름의 사용자를 생성하였다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2f4fd9a1-1f30-4575-b656-592eff92ec88)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/b4e0dc93-202d-4cf0-9add-dde43a7cd4b7)

하지만 이렇게 User를 생성했더라도 위의 사진을 보면 콘솔 액세스는 비활성화되어 있는 것을 확인할 수 있다. 이는 User에 대한 비밀번호를 설정하지 않았기 때문이다. 비밀번호 설정을 테라폼을 통해서 해도 되지만 그렇게 할 경우 테라폼 코드에 비밀번호가 그대로 노출되기 때문에 좋은 방법이 아니다. 그래서 테라폼으로 User를 만든 뒤 AWS 콘솔이나 AWS CLI를 통해 설정해주는 것이 좋다.

> 여기서 콘솔 액세스가 비활성화 되었다는 것은 생성한 User로 로그인할 수 없다는 것이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/75a4587a-eb5b-45b7-9b78-524fec36ee24)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/5ea7479d-9f7f-47f5-b823-4e2bbd233fc8)

콘솔 액세스가 활성화 되었으므로 이제 gildong.hong 유저로 로그인이 가능하다. 

MFA도 설정하면 보안 요소를 추가할 수 있기는 하지만 지금은 하지 않겠다. MFA는 비밀번호 외에 사용자의 핸드폰과 같은 추가 물리적 기기를 이용하여 인증을 하는 방식이다. 인증 방식이 여러 개이기 때문에 Multi-Factor Authentication이다.

## Group 생성

```
resource "aws_iam_group" "devops_group" {
    name = "devops"
}
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/abfd5f9c-8f4c-4d5a-9b6c-daf6d884e7bf)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/acfb69e9-5925-4132-8913-8e1e1f7780d8)

User와 유사하게 생성해주면 된다.

## Group에 User 추가

```
resource "aws_iam_group_membership" "devops" {
    name = aws_iam_group.devops_group.name

    users = [
        aws_iam_user.gildong_hong.name
    ]

    group = aws_iam_group.devops_group.name
}
```

`aws_iam_group_membership`을 통해 그룹에 사용자를 추가할 수 있다. `users`에 추가할 사용자 이름을, `group`에 그룹 이름을 적어주면 된다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/5afb4119-04f8-4f93-bdc4-854dce08959f)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/78fffb90-917e-4477-bd8d-9144deef59a9)

# IAM Role 생성

Role은 다음과 같이 생성할 수 있다.

```
resource "aws_iam_role" "hello" {
    name = "hello-iam-role"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
```
- name: 역할의 이름
- assume_role_policy: 역할에 대한 신뢰 관계

**Role에는 권한과 신뢰 관계가 존재한다.**

신뢰 관계란 AWS에서는 `지정된 조건에서 이 역할을 수임할 수 있는 엔터티`라고 정의하고 있다. 즉 해당 역할을 맡을 수 있는 대상을 지정하는 것이 신뢰 관계라는 것이다. 위의 예시에서는 EC2 서비스가 역할을 수임(Assume)하는 것을 허용한다라고 되어 있다. 따라서 해당 역할은 EC2 인스턴스에만 사용될 수 있는 것이다.

권한은 이름에서 알 수 있듯이 해당 역할을 맡게 되었을 때 가질 수 있는 정책을 의미한다. 아직 역할을 생성만 했을 뿐 권한을 연결하지는 않았으므로 역할을 맡게 되더라도 수행할 수 있는 작업은 없을 것이다.

> 코드를 작성할 때 EOF 사이에 나오는 부분은 들여쓰기를 하면 오류가 발생한다. `Error: "assume_role_policy" contains an invalid JSON policy: leading space characters are not allowed
`와 같은 오류가 발생한다면 들여쓰기를 의심해보자.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e6586080-a8c8-48d0-9850-802a469563c7)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/0ae46f4c-2fb5-4490-93ab-158a4a5e2bc8)

`hello-iam-role`이라는 역할이 생성되었다.

이제 이 역할에 권한을 추가해보자.

```
resource "aws_iam_role_policy" "hello_s3" {
  name   = "hello-s3-download"
  role   = aws_iam_role.hello.id
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "AllowAppArtifactsReadAccess",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}
```

- name: 정책 이름
- role: 정책을 연결할 IAM Role
- policy: 실제로 생성할 정책의 세부사항(json 형태)

현재 EC2 인스턴스에 대한 IAM Role을 생성하려고 하기 때문에 `IAM Instance Profile`도 함께 추가해주어야 한다. IAM Instance Profile이란, EC2 인스턴스를 시작할 때 역할 정보를 전달하는 데에 사용되는 것이다. EC2 인스턴스에 역할을 부여하기 위한 컨테이너라고 이해하며 된다. 콘솔에서 역할을 생성하면 이를 자동으로 생성해주는데, Terraform은 수동으로 생성해주어야 한다.

```
resource "aws_iam_instance_profile" "hello" {
  name = "hello-profile"
  role = aws_iam_role.hello.name
}
```
- name: Instance Profile 이름
- role: Instance Profile을 부착할 역할 이름

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/8e7300a1-703b-4efd-9aaf-503d2349d7e8)
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/52f95549-f2d2-40aa-af7d-762a01d11e06)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/0e69aecf-be63-40ca-9d30-6fbe6a4ddff7)

`hello-s3-download`라는 이름의 권한이 역할에 생성되었다. 역할을 맡게 된 EC2 인스턴스는 S3 버킷으로부터 객체를 받을 수 있게 될 것이다.

**역할은 언제 사용할까?**

로컬 PC가 아닌 서버에서 S3 버킷에 접근해야하는 상황이 생길 경우, credentials가 필요하다. 즉, Access Key와 Secret Key가 필요하다는 것이다. 하지만 이러한 중요한 정보를 외부의 서버에 저장해둘 수 없을 것이다. 그때 사용하는 것이 IAM Role이다. 앞서 생성했던 hello-s3-download 라는 역할을 EC2 인스턴스에 할당한다면, 해당 EC2 인스턴스는 Key가 없더라도 S3에 접근할 수 있는 권한이 생길 것이다.

# Policy 생성

Policy는 AWS 리소스에 대한 접근 권한이며, User와 Group 모두에 할당할 수 있다. AWS에서 관리하는 다양한 Managed Policy가 존재하지만, 사용자가 코드를 통해 직접 생성하는 것이 관리하기에 더 좋을 것이다.

이전에 생성했던 `gildong.hong`이라는 User를 생성만 하고 권한을 할당하지 않았었다. 권한을 생성해서 할당해보자. 권한은 다음과 같이 생성할 수 있다.

```
resource "aws_iam_user_policy" "art_devops_black" {
  name  = "super-admin"
  user  = aws_iam_user.gildong_hong.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
```

> 이전에 역할에 권한을 할당했을 때는 aws_iam_role_policy 이었는데, 지금은 User에 할당하는 것이기 때문에 aws_iam_user_policy 임을 알 수 있다. 동일한 것이라고 생각하면 안된다.

- name: 권한 이름
- user: 권한을 할당할 user 이름
- policy: 실제 권한 내용 (해당 예시에서는 모든 리소스에 접근할 수 있다)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c47cc6e2-2048-4d87-aed3-34c8a7f653d7)

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/808d1c2b-0f43-4231-9b58-34fa6ada077a)

권한이 할당된 것을 확인할 수 있다.

# Reference

[처음 시작하는 Infrastructure as Code: AWS & 테라폼](https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws)

# History

📌 2024-3-29: 테라폼으로 IAM User, Group, Role, Policy 생성하기   