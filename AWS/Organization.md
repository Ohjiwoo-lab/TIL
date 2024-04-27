# Organization이란?

Organization이란 AWS에서 여러 계정을 중앙에서 한 번에 관리할 수 있도록 해주는 서비스이다. 다중 계정에 대한 관리가 필요할 때에는 Organization이 모범사례이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/1c553a0d-7326-4df5-bad9-60d9c6dfda9a)

Organization을 생성하면 Root OU가 기본적으로 같이 생성된다. 그리고 이 Root OU 내에 여러 OU가 존재할 수 있으며, OU 내부에 또 다른 OU가 존재할 수 있다. Organization을 생성하고 관리하는 Management Account가 1개 있고, 그 외에 계정은 모두 Member Account이다. 관리 계정은 멤버를 초대할 수 있고 멤버 계정의 사용자에 권한을 부여할 수 있다.

멤버가 Organization에 초대되면 `OrganizationAccountAccessRole`이 부여된다. 해당 역할을 이용하여 관리 계정이 멤버 계정을 관리할 수 있는 것이다. 콘솔을 통해 멤버 계정을 추가하면 자동으로 부여되지만, IaC 등으로 생성하면 따로 역할을 부여해줘야 한다.

관리 계정은 멤버 계정의 IAM 사용자 또는 그룹에 직접 권한 정책을 부여할 수 있고, IAM 역할을 생성하여 이를 위임할 수도 있다. Organization에는 SCP(Service Control Policies)가 있다. 이는 어떤 특정한 액션에 대해 허용하거나 거부할 수 있는 정책이다. IAM 정책과 굉장히 유사하지만 차이점은 SCP는 실제 권한을 부여할 수 없다는 점이다. IAM의 권한 경계처럼 수행할 수 있는 작업의 가드레일을 제공할 뿐이다. 기본적으로 SCP와 IAM 정책 모두 허용해야 작업을 수행할 수 있지만, SCP에서 허용하더라도 IAM 정책이 없다면 수행할 수 없다. 멤버 계정에 권한을 부여하기 위해 SCP를 적용하는 것은 잘못된 것이다. 권한은 IAM 정책을 직접 부여하거나 IAM 역할을 수임하는 방법으로만 얻을 수 있다.

⭐ **중요**

    SCP는 수행할 수 있는 작업의 최대 권한을 지정할 뿐, 실제 권한을 부여하지는 않는다.

많이 헷갈렸던 부분이니, 명심하도록 하자.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-27: AWS Organization과 SCP 정리   