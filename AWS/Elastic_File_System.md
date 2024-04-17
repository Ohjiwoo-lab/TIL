# EFS란?

EFS는 관리형 NFS(Network File System)이다.

**📚 NFS란?**

    NFS는 사용자가 원격 컴퓨터에 존재하는 파일 또는 디렉토리에 액세스하여 마치 로컬에 있는 것처럼 처리할 수 있도록 허용하는 분산 파일 시스템이다.

EFS는 하나의 VPC에 연결되고, 여러 가용영역에 걸쳐 하나의 ENI를 할당받아 EC2 인스턴스에 마운트된다. EC2 인스턴스 뿐만 아니라 온프레미스 상에 존재하는 서버에도 마운트될 수 있는데, 이때 온프레미스와 AWS 사이에 Direct Connect 또는 Site to Site VPN 연결이 있어야 한다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-17: EFS 개념