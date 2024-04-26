# CICD란?

CICD는 Continuous Integration, Continuous Delivery의 약자로, 지속적 통합과 지속적 배포라는 의미이다. 애플리케이션의 빌드와 테스트, 배포 과정을 자동화하는 것이다. 요즘 개발과 운영을 통합한다는 의미에서 DevOps라는 단어가 등장하며 모든 것을 자동화하기 시작했는데, 그 일환으로 CICD 파이프라인이 등장하였다.

먼저 지속적 통합을 의미하는 `CI`는 개발자가 코드 레파지토리에 코드를 올리면 Build Server가 레파지토리로부터 코드를 가져와서 빌드하고 테스트한다. 개발자는 Build Sever에 의해 테스트 결과를 받고 통과되지 못했다면 코드를 수정할 수 있다. 이렇게 CI를 도입하게 되면 개발자는 빌드와 테스트를 더이상 하지 않아도 되고 코드를 작성하는 데에만 집중할 수 있다. 코드 레파지토리는 Github, CodeCommit, Bitbucket 등이 있을 수 있고, CI를 수행하는 Build Server로 CodeBuild, Jenkins CI 등이 있다. CodeCommit과 CodeBuild가 AWS에서 제공하는 서비스이다.

다음으로 지속적 배포를 의미하는 `CD`를 알아보자. 이는 Build Server에 의해 모든 테스트가 통과한 코드의 경우 Deployment Server를 통해 자동으로 배포된다. 코드를 푸시할 때마다 자동으로 배포가 되기 때문에 하루에도 5번 이상 배포가 이루어질 수 있다. 그러면 애플리케이션의 새로운 버전이 계속 나오게 되며 고객들의 요구사항을 빠르게 반영할 수 있게 될 것이다. Deployment Server로 AWS에서 제공하는 CodeDeploy, 오픈소스인 Jenkins CD, Spinnaker 등이 있다.

## Architecture

CICD 파이프라인을 AWS에서 구현하는 방법은 다음과 같다.

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/d46c7779-b5ee-4404-91f6-ee4fbd294b94)

우선 개발 환경과 운영 환경으로 나뉘어 있다. CodePipeline은 파이프라인을 정의하여 CICD 각 단계를 관리해주는 서비스이다. CodePipeline은 CodeCommit의 브랜치마다 생성되어야 한다. 그래서 개발용 CodePipeline과 운영용 CodePipeline이 나누어져 있다.

개발자는 CodeCommit의 DEV 브랜치로 코드를 푸시할 것이다. 그러면 CodeBuild에서 DEV 브랜치의 코드를 가져와 빌드 & 테스트를 진행할 것이고, 빌드가 성공하면 CodeDeploy에 의해 DEV 환경으로 배포될 것이다. 이때 배포환경은 다양할 수 있다. CloudFormation이 될 수도 있고, Elastic Beanstalk이 될 수도 있다. 회사에서 정하기 나름이다.

이제 어느정도 개발이 완료되고 나면 DEV 브랜치에서 PROD 브랜치로 Pull Request를 하여 코드를 병합한다. 그러면 PROD 브랜치에 코드가 변경될 것이고, PROD 파이프라인에서 정의한 대로 CodeBuild에 의해 빌드&테스트, CodeDeploy에 의해 배포될 것이다. PROD 환경은 DEV 환경과 유사하나 실제로 운영되고 있는 환경일 것이다.

이런 아키텍처를 구축해놓으면 개발자는 단순히 코드를 올리기만 하면, 운영 브랜치에 코드를 합치기만 하면 모든 배포과정이 알아서 이루어지기 때문에 편리해진다. 사람이 직접할 때보다 더 정확할 수도 있고, 체계적으로 모든 과정이 이루어질 것이다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-26: CICD 개념과 AWS에서 CICD 파이프라인 구축하는 방법 정리   