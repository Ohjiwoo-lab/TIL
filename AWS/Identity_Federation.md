# 페더레이션이란?

페더레이션은 AWS 외부의 사용자에게 임시로 AWS 리소스에 대한 접근 권한을 부여하는 것을 말한다. 권한 부여를 위해 별도의 IAM User를 생성할 필요가 없다. 

다음은 페더레이션을 진행하는 과정이다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d0b07f50-1177-4e18-8836-989856ab25e4)

먼저 사용자 인증을 위해 `Identity Provider`가 존재한다. 온프레미스 상에 존재할 수도 있고, 웹에서 지원해주는 경우도 있다. Identity Provider는 AWS와 신뢰 관계를 형성하고 있다. 이는 AWS에서 해당 Identity Provider가 AWS 리소스를 이용할 권한을 할당해준다는 것을 인식하고 있는 상태라는 것을 의미한다. 사용자는 Identity Provider에 로그인을 하면, Identity Provider는 사용자가 등록되어 있는지 확인한 뒤 임시 자격 증명을 제공한다. 그러면 사용자는 임시 자격 증명을 이용하여 AWS 리소스에 접근할 수 있는 것이다.

AWS에서는 총 4가지의 페더레이션을 지원한다. 각각에 대해 알아보자.

1. SAML 2.0 Federation

    이는 다소 오래된 방식이다. SAML은 Security Assertioin Markup Language로, ADFS 등 많은 Identity Provider에서 제공하고 있는 표준 방식이다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/e6a769a6-1451-4ca6-9cf0-3496c8138db9)

    사용자가 Identity Provider에 인증 요청을 보내면, Identity Provider는 확인한 뒤 SAML Assertion을 응답한다. 그러면 사용자는 이 SAML 토큰을 토대로 하여 STS(Security Token Service)에 `AssumeRoleWithSAML API` 요청을 한다. 그러면 STS는 토큰을 확인한 뒤 임시 자격 증명을 사용자에게 부여하고, 사용자는 이 임시 자격 증명을 통해 AWS 리소스에 접근할 수 있게 된다.

2. Custom Identity Broker

    이는 Identity Provider가 SAML 2.0을 지원하지 않는 경우에만 사용되는 방식이다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/9c6efd75-8167-4110-a569-74bf13461373)

    사용자는 동일하게 Custom Identity Broker에 요청을 보낸다. 그러면 Custom Identity Broker는 사용자 인증을 한 뒤, 바로 STS에 요청을 한다. `AssumeRole API` 또는 `GetFederation Token API`를 이용하여 STS에 요청을 한 뒤, 임시 자격 증명을 부여받는다. 그 후 사용자에게 자격 증명 토큰이나 URL을 응답하게 되고, 사용자는 이를 이용해 AWS 리소스에 접근하거나 AWS 콘솔로 Redirect 할 수 있다.
    
    이전에는 사용자가 STS에 직접 요청을 했다면 이 방식은 Identity Provider가 직접 해준다는 차이점이 있다.

3. Web Identity Federation

    이는 온프레미스에 Identity Provider가 존재하는 것이 아니라 웹을 통해 제공되는 방식이다. Cognito를 이용하는 방식과 이용하지 않는 방식이 있다.

    다음은 Cognito를 이용하지 않는 방식이다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/ade40ad5-5f8e-42dd-9ff8-aa21e7942663)

    SAML을 이용하는 방식과 유사하지만 Identity Provider가 Google, Facebook, Amazon 등 웹 서비스라는 점에서 차이가 있다.

    다음은 Cognito를 이용하는 방식이다.

    ![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/06a7a15c-931c-415a-9a7f-fc5e7d87addf)

    Web Identity Provider는 이전처럼 Web Identity Token이 아니라 ID Token만을 사용자에게 부여한다. 그러면 사용자는 Cognito를 통해 ID Token을 Cognito Token으로 교환하고, STS를 통해 Cognito Token을 임시 자격 증명과 교환한다. 이제 사용자는 임시 자격 증명을 통해 AWS 리소스에 접근할 수 있다.

    이처럼 Cognito는 Token을 교환해주기 때문에 `Token Vending Machine`이라고 불리기도 한다. AWS에서는 Cognito를 이용하는 방식을 더 추천하고 있다. 보안상 더 안전하기 때문이다.

AWS 외부의 사용자에게 AWS 리소스에 접근할 권한을 부여하기 위한 3가지 방법을 살펴보았다. 현재 진행 중인 프로젝트에서도 외부 사용자에게 내 AWS 리소스에 접근하는 기능이 필요한데 이 페더레이션을 더 공부하면 해답을 찾을 수 있을 것 같다.

# Reference

[Udemy 강의](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-3-8: Identity Federation 3가지 방법 정리   