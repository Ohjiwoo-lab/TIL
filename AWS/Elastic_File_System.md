# EFS란?

EFS는 관리형 NFS(Network File System) 서비스이다.

**📚 NFS란?**

    NFS는 사용자가 원격 컴퓨터에 존재하는 파일 또는 디렉토리에 액세스하여 마치 로컬에 있는 것처럼 처리할 수 있도록 허용하는 분산 파일 시스템이다.

EFS는 하나의 VPC에 연결되고, 여러 가용영역에 걸쳐 하나의 ENI를 할당받아 EC2 인스턴스에 마운트된다. EC2 인스턴스 뿐만 아니라 온프레미스 상에 존재하는 서버에도 마운트될 수 있는데, 이때 온프레미스와 AWS 사이에 Direct Connect 또는 Site to Site VPN 연결이 있어야 한다.

## 스토리지 클래스

EFS에는 스토리지 클래스가 있다. Standard 티어와 Infrequent access(EFS-IA) 티어이다. Standard 티어는 자주 액세스하는 파일을 저장하며, EFS-IA 티어에는 자주 액세스하지 않는 데이터들을 저장한다. EFS-IA는 스토리지 가격이 저렴한데 파일을 검색할 때마다 비용을 지불한다. Standard 티어에서 일정 시간이 지난 뒤 EFS-IA로 옮길 수 있는 수명주기 정책도 존재한다.

가용성 측면에서 여러 가용영역에 스토리지를 분산하는 Regional과, 하나의 가용영역에서 사용되는 EFS One Zone-IA가 있다. 운영 환경에서는 고가용성을 유지하기 위해 Regional을 사용하는 것이 좋고, 단순한 개발 환경이나 백업을 하기 위해서는 EFS One Zone-IA를 사용하는 것이 좋다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-17: EFS 개념
📌 2024-5-4: EFS 스토리지 클래스 정리   