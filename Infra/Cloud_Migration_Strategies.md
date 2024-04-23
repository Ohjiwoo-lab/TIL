# 클라우드 마이그레이션 전략: 6R

[6 Strategies for Migrating Applications to the Cloud](https://aws.amazon.com/ko/blogs/enterprise-strategy/6-strategies-for-migrating-applications-to-the-cloud/) 블로그에서 소개하는 클라우드로 마이그레이션하는 6가지 전략을 정리해보고자 한다. 6가지 전략이 모두 `R`로 시작해서 6R이라 한다.

1. Rehosting

    `lift and shift`라고도 하는데, 이는 온프레미스 데이터센터의 모든 것을 그대로 클라우드로 마이그레이션하는 것이다. 만약 온프레미스에서 서버가 6개였다면 클라우드에서도 가상머신을 6개 만드는 것이다. 데이터베이스를 MySQL을 사용했다면, 클라우드에서도 가상머신에 MySQL을 설치하는 방식인 것이다.
    
    이는 클라우드의 특징에 맞춰 성능을 극대화하기 위한 최적화를 진행하지 않는다. 비용은 온디맨드 서비스로 인해 정말 필요한 리소스들만 사용할 수 있기 때문에 30%의 절감 효과가 있다고 한다.

    AWS에서 Rehosting을 수행하기 위하 서비스로 `Application Migration Service(MGN)`가 있다. 이는 CloudEndure Migration과 AWS Server Migration Service(SMS)를 결합하여 만들어낸 서비스로, 최소한의 다운타임과 적은 비용으로 클라우드 마이그레이션을 진행해주는 솔루션이다.

2. Replatforming

    기본적인 서비스의 아키텍처는 그대로 유지하되, 클라우드 최적화를 진행하는 전략이다. 데이터베이스를 MySQL을 사용한다면, DB 엔진인 MySQL은 그대로 유지하되 플랫폼을 변경한다. AWS에서 제공하는 관리형 데이터베이스 서비스인 RDS를 활용하여 다중 AZ, 읽기 전용 복제본, 향상된 모니터링 등의 고급 기능을 사용할 수 있다. MySQL을 RDS MySQL로 마이그레이션 할 경우, 동일한 DB 엔진이기 때문에 스키마 변환이 필요없다. 그래서 Database Migration Service(DMS)를 사용하더라도 Schema Conversion Tool(SCT)을 사용할 필요가 없다.

    Replatforming을 수행하기 위한 최적의 방안은 AWS Elastic Beanstalk이다. 이 서비스를 이용하면 아키텍처의 변경없이, 즉 코드의 변경 없이 클라우드로 손쉽게 마이그레이션 할 수 있다.

3. Repurchase

    `drop and shop`이라고도 한다. 이는 클라우드 제품(SaaS)를 구입함으로써 클라우드로 마이그레이션 하는 전략이다. CRM 서비스를 Salesforce로, HR을 Workday로, CMS를 Drupal로 마이그레이션하는 경우가 해당될 수 있다. 이는 아주 빠르게 배포할 수 있다는 장점이 있지만, SaaS 구매를 하는 데에 단기적인 거대한 지출이 발생한다.

4. Refactoring / Re-architecting

    클라우드에서 네이티브하게 제공하는 기능을 이용하여 애플리케이션의 아키텍처를 변경하는 전략이다. 클라우드에서만 제공하는 기능을 추가하기 위해, 규모의 빠른 확장을 위해, 성능을 폭발적으로 향상하기 위해서 선택하는 방식이다. 
    
    AWS의 경우 S3, Lambda, SQS 등이 해당될 수 있다. 기존에 온프레미스 데이터센터의 물리적인 서버를 통해 호스팅하던 애플리케이션을 클라우드로 옮기면서 서버리스 애플리케이션으로 변환하고 싶은 경우, AWS Lambda, S3 등의 서비스를 이용해야 할 것이다. 그러면 Lambda, S3를 이용하도록 애플리케이션의 코드를 전면 수정해야 할 수도 있다. 클라우드를 사용했을 때의 이점이 코드 변경을 감수할 수 있는 경우 해당 전략을 선택할 수 있다.

5. Retire

    이는 Re-architecting 전략으로 애플리케이션의 구조가 변경되면서 불필요한 구성요소가 생겼을 때 이를 폐기하는 전략이다. 인프라의 구성요소가 줄어들기 때문에 보안 상 더 안전할 수 있으며, 10%~20%의 비용 절감 효과가 있다.

    Retire을 통해 필요없는 리소스를 발견한 후 제거하면 남아있는 리소스에 더욱 집중할 수 있어서 더 효과적인 아키텍처 설계가 가능해질 것이다.

6. Retain

    이는 클라우드로의 전환을 포기하고 온프레미스를 유지하는 전략이다. 마이그레이션이 너무 복잡하거나, 비용이 생각했던 것보다 비싸거나 하는 등의 이유로 온프레미스 데이터센터를 유지하는 것이 더 나은 경우도 있다. 그런 경우에는 굳이 비용이 많이 발생하는 클라우드 전환을 선택할 이유가 없을 것이다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)   
[6 Strategies for Migrating Applications to the Cloud](https://aws.amazon.com/ko/blogs/enterprise-strategy/6-strategies-for-migrating-applications-to-the-cloud/)

# History

📌 2024-4-23: Cloud Migration 전략 6가지: 6R