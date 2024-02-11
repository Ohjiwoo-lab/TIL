# 테라폼 사용을 위한 환경설정

## AWS EC2 및 SSH

테라폼 실습을 위해 AWS EC2 인스턴스를 생성하고 SSH로 접속할 것입니다. SSH란 Secure Sheel Protocol로, 클라이언트와 서버 간 네트워크 통신에 사용되는 프로토콜입니다. 보통 클라이언트가 서버로 파일을 업로드하거나, 원격 접속해서 터미널 쉘을 실행하는 경우에 사용됩니다.

### SSH 접속

EC2에 SSH로 접속할 때에 고려해야할 점은 다음과 같습니다.

1. 퍼블릭 IP와 적절한 포트를 사용했는 지 확인합니다.
    - 포트는 서버 측에서 Listen Port를 지정하는 방법과, 클라이언트 측에서 접속할 때 명시하는 방법으로 변경할 수 있습니다. 변경하지 않으면 기본 22번으로 지정됩니다.

    - 실무에서는 보안 상의 이유로 Well-Known 포트를 지양할 것을 권고합니다. Well-Known 포트란, SSH 접속의 기본 포트는 22번인 것처럼 널리 알려져 있는 포트를 말합니다.

2. EC2 인스턴스의 시큐리티 그룹에서 접속하려고 하는 포트와 IP가 허용되어있는 지를 확인합니다.
    - EC2 인스턴스는 기본 방화벽 서비스로 시큐리티 그룹을 제공해줍니다. 그래서 명시적으로 허용되지 않은 모든 트래픽을 차단하기 때문에, 본인의 IP가 허용되어있는 지 확인해야 합니다.

3. EC2 인스턴스가 퍼블릭 서브넷에 위치하고 있는 지를 확인합니다.
    - EC2 인스턴스가 생성되면 기본 VPC가 자동으로 지정됩니다. VPC 내에는 여러 서브넷이 존재하는데, 인터넷 게이트웨이가 설정되어 있는 퍼블릭 서브넷에서만 외부 접속을 허용하고 있습니다.

    - 현재 EC2 인스턴스는 AWS 인프라에서 실행되고, 접속은 본인의 컴퓨터에서 시도하고 있는 것이기 때문에 같은 네트워크 상이 아닙니다. 그래서 공용 인터넷으로 접속하여야 하고, 그러기 위해선 인터넷 게이트웨이가 필요합니다.

    - 퍼블릭 서브넷인지를 알 수 있는 방법은 서브넷의 라우팅 테이블에서 `0.0.0.0/0 igw`가 허용되어있는 지를 확인하면 됩니다.


생성한 EC2에 접속하였습니다. SSH 접속은 EC2 인스턴스를 만들 때 다운받았던 Key를 이용합니다. `ssh -i [다운받은 프라이빗 키] [사용자 이름]@[공용 IP]`로 접속할 수 있습니다.

> 이때 Amazon Linux를 AMI로 선택한 경우 기본 사용자가 `ec2-user`이므로 이를 사용하면 됩니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/b10ec513-4219-429c-a985-4c0bcdf2cbf1)

접속한 뒤 가용한 Port를 확인해보았습니다. `0.0.0.0:22` 포트가 LISTEN 상태입니다. LISTEN 상태라는 것은 서버가 해당 포트로의 접속을 기다리고 있다는 의미입니다. SSH로 접속할 때 사용할 22번 포트가 LISTEN 상태였기 때문에 접속할 수 있었던 것입니다.

또한 SSH 자체가 프로그램으로 동작합니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/8a19f025-6700-4a1f-bab4-d10a6a0d2cf1)

현재 실행 중인 프로세스를 확인해보면 `/usr/sbin/sshd` 데몬을 확인할 수 있습니다.

## 키 페어

이번엔 SSH 접속에 사용된 Key를 살펴보겠습니다. AWS EC2 는 RSA 공개키 암호화 방식을 사용합니다. 

RSA 공개키 암호화는 2개의 키 페어가 존재합니다. 모두에게 공개되어 있는 공개키와 개인이 소유하고 있는 개인키입니다. EC2 인스턴스를 생성할 때 키 페어를 생성하고 다운받았을 것입니다. 다운받아진 키가 개인키이며, 공개키는 생성한 인스턴스에 위치하고 있습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e4b175f1-76e4-4fef-9ed8-cc17627b3f44)

EC2 인스턴스에 저장되어 있는 공개키를 확인할 수 있습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c7a7457f-dfcb-4836-babf-48c065efda15)

개인키는 이렇게 본인의 컴퓨터에 저장됩니다.

RSA에서 공개키는 암호화에 사용되고, 개인키는 복호화에 사용됩니다. 즉 공개키를 이용해 암호화한 메시지를 개인키로 해독할 수 있다는 것입니다.

SSH 접속을 할 때 개인키를 지정하면, 서버에 저장되어 있는 공개키와 페어가 맞는 지 검사합니다. 키 페어가 맞다면, 즉 개인키로 공개키 메시지를 해독할 수 있다면 접속이 허용되는 방식입니다.

이때 주의할 점은 개인키는 공개되어서는 안된다는 점입니다. 그래서 개인키를 사용할 수 있는 권한을 제한해야 합니다. 위의 사진을 보면 키 파일의 권한은 `-r--------`입니다. 이는 파일의 소유자만 read 할 수 있다는 것입니다. 이런 식으로 파일을 직접 소유하고 있는 사람만이 개인키를 사용할 수 있도록 설정해주어야 하며, 그렇지 않으면 EC2 인스턴스에 해당 키로 접속할 수 없습니다. 권한을 변경하는 명령어는 `chmod 400 [개인키 파일]`입니다.

## ZSH & Oh-My-ZSH 설치

zsh은 쉘의 확장 버전으로 다양한 추가적인 기능을 제공해줍니다. oh-my-zsh은 zsh 설정을 관리해주는 오픈소스 프레임워크입니다. 터미널 환경을 보다 가독성 있고 이쁘게 꾸며주는 역할을 합니다.

한 번 설치해보겠습니다.

### ZSH 설치 및 기본 쉘 변경

먼저 zsh을 설치합니다.

```shell
sudo yum install zsh
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/c80f3590-fe91-4219-9c82-06d9e2989147)

Amazon Linux에서 기본 쉘을 변경하는 명령어인 `chsh`를 사용하기 위해서 필요한 유틸리티를 설치합니다.

```shell
sudo yum install util-linux-user.x86_64
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/029369f2-8e39-4bb5-b742-fcefbade0e9c)

사용자 ec2-user에 대한 비밀번호를 설정한 뒤, chsh 명령어로 기본 쉘을 zsh로 변경합니다.

```shell
sudo passwd ec2-user
chsh
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/5072a275-d117-4e91-a4d4-d7e447772d2d)

### OH-MY-ZSH 설치

oh-my-zsh을 설치하기 위해 git을 먼저 설치해줍니다.

```shell
sudo yum install git
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/6509408f-ad23-409d-8f56-52f0c6d4e8f0)

oh-my-zsh을 설치합니다.

```shell
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2a729f27-0828-4830-ae38-56175bb7b63b)

[ohmyzsh 테마](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)를 보면 정말 다양한 테마를 제공해주고 있습니다. 이 중 실무에서 많이 사용하는 것은 `ys`이므로 동일하게 변경해주겠습니다.

변경하는 방법은 .zshrc 파일을 수정해주는 것입니다.

```shell
sudo vim ~/.zshrc
```
다음 명령어를 통해 파일을 수정해줍니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/a2c54e6c-51e3-4ab7-8c1b-6fe2a9fba923)

ZSH_THEME를 `ys`로 변경해주면 설치 완료입니다. 이제 접속을 종료한 뒤 다시 접속해보겠습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/ee1b77a4-9a55-462d-92c6-fd1e38952fc0)

이런 식으로 터미널의 UI가 완전히 변경된 것을 확인할 수 있습니다. 더욱 직관적으로 바뀌었고 시간도 표시해줍니다.

oh-my-zsh의 주요 기능은 `Auto completion`입니다. 이는 파일을 검색할 때 자동완성을 해준다는 것입니다. 이는 bash 쉘에도 있는 기능이지만, oh-my-zsh에서는 중간자 검색을 지원해줍니다.

만약 `app-hello`와 `app-hi`라는 파일이 있다면 보통의 경우엔 app부터 친 후 tab을 눌러야 자동완성이 되었습니다. 하지만 oh-my-zsh은 hello 또는 hi를 치고 tab을 눌러도 자동으로 완성해줍니다. 이는 파일이 엄청나게 많이 존재할 때 유용하게 사용될 수 있는 기능입니다.

또한 방향키로 히스토리를 검색할 때 특정 명령어에 대한 히스토리만 보여주도록 할 수 있습니다. 예를 들어 vim에 대한 히스토리만 보고싶다면, vim을 입력한 상태에서 방향키를 누르면 됩니다. 그러면 다른 명령어는 보이지 않고 vim을 사용했던 기록만 확인할 수 있습니다.

이 밖에도 정말 다양한 기능을 제공하고 있으므로 oh-my-zsh을 이용하여 테라폼을 실습해볼 것입니다.


## AWS CLI 및 테라폼 설치

### AWS CLI

EC2 인스턴스를 생성할 때 Amazon Linux를 선택하였다면 AWS CLI는 이미 설치되어있을 것입니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/dfffc042-927d-4850-bdb0-3204ada4b206)

`aws --version` 명령어를 통해 확인할 수 있습니다. 하지만 설치되어 있는 버전은 1입니다. 버전 2가 기능도 더 많이 지원하며 요즘에 많이 사용되기 때문에 CLI 버전 2로 설치해보겠습니다.

```shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2a9aeaf1-bf6a-43e5-8257-8bce601226cd)

다운받은 zip 파일을 풀어줍니다.

```shell
unzip awscliv2.zip
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/79eba0c7-cb0e-4b92-8914-ec341859a386)

CLI 버전 2를 설치합니다.

```shell
sudo ./aws/install
```
![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/67cc18d8-f38f-4130-9deb-635639dadeab)

EC2 인스턴스의 접속을 끊었다가 다시 접속하면, 다음과 같이 버전이 변경되었음을 확인할 수 있습니다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/70233240-0349-4844-9a3d-ed112bef816f)


### 테라폼 설치

최신 버전의 테라폼 설치: https://developer.hashicorp.com/terraform/install

이전 버전의 테라폼 설치: https://releases.hashicorp.com/terraform/

위의 두 사이트 중 하나를 골라 테라폼을 설치하면 되는데, 보통 가장 최신 버전은 발견되지 않은 버그도 있고 안정성이 떨어질 수 있기 때문에 이전 버전을 설치하는 것이 좋습니다.

저는 1.6.5 버전을 설치해주겠습니다.

```shell
wget https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip
unzip terraform_1.6.5_linux_amd64.zip
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/2307c670-885d-4eef-8ba8-7e661af0c354)

설치 후 zip 파일을 압축 해제하면 `terraform`이라고 하는 바이너리 파일이 생성됩니다. 테라폼은 Go 언어로 만들어졌는데, Go의 특징 중 하나가 결과물이 바이너리 파일 하나로 도출된다는 것입니다.

프로그램이 보통 설치되는 위치를 확인합니다.

```shell
echo $PATH
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/29aa64df-dcb4-4939-91f6-953e07338af1)

`/usr/local/bin` 임을 확인하였으므로, 해당 위치로 생성된 바이너리 파일을 옮깁니다.

```shell
sudo mv terraform /usr/local/bin/
terraform --version
```

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/01fac88d-24b1-4776-bb09-5cb8eebd5c76)

테라폼이 정상적으로 설치되었습니다.

이제 테라폼에서 AWS 리소스에 접근하기 위해서는 권한을 설정해주어야 합니다.

```shell
aws configure
```

다음 명령어를 통해 권한 설정을 할 수 있습니다. 계정에 대한 시크릿 키를 발급받아서 입력하면 됩니다. 이때 발급받은 스크릿 키는 절대 외부에 공개해서는 안되니 주의해주세요!

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/712a5165-e5dd-42b3-a097-33c2bec6557f)

설정이 완료되면 다음과 같은 파일들이 생성됩니다.

# Reference

<https://www.inflearn.com/course/%EB%8D%B0%EB%B8%8C%EC%98%B5%EC%8A%A4-%ED%85%8C%EB%9D%BC%ED%8F%BC-aws>

<hr/>

📌 2023-12-25: 테라폼 기본 설정