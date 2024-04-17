# CloudFront란?

CloudFront는 CDN (Content Delivery Network) 서비스이다. 전 세계에 있는 엣지 로케이션에 컨텐츠를 캐싱함으로써 백엔드의 성능을 개선할 수 있다. 사용자는 백엔드가 아닌 본인의 위치에서 가까운 엣지 로케이션으로 요청을 보내게 되고, 만약 원하는 컨텐츠가 캐싱되어 있을 경우에는 캐시로부터 즉시 응답을 받을 수 있어서 지연시간이 최소화된다. 또한 백엔드로의 요청 수가 줄어들면서 비용도 절감할 수 있다.

**📚 CDN (Content Delivery Network)이란?**

    지리적으로 분산된 서버들을 연결한 네트워크로서, 웹 컨텐츠의 복사본을 사용자 가까운 곳에 두거나 동적 컨텐츠의 전달을 활성화하여 웹 성능 및 속도를 향상할 수 있도록 하는 기능이다.

    출처: https://www.ibm.com/kr-ko/topics/content-delivery-networks

## CloudFront Origin

CloudFront에서 컨텐츠를 제공해주는 백엔드를 `오리진`이라고 한다. CloudFront의 오리진이 될 수 있는 것은 다음과 같다.

- S3 Bucket
    
    가장 대표적인 CloudFront의 오리진이다. 정적인 컨텐츠를 서비스할 때 가장 많이 사용되는 조합이다. S3 버킷은 OAC(Origin Access Control)을 통해 CloudFront를 통해서만 S3 버킷에 접근할 수 있도록 보안을 제공한다. 또한 정적 웹 호스팅을 활성화하여 파일 뿐만 아니라 웹사이트를 컨텐츠로 제공할 수도 있다.

- MediaStore Container & MediaPackage Endpoint

    이는 비디오 제작 및 스토리지, 비디오 스트림을 패키징하여 제공해주는 서비스이다. CloudFront의 오리진으로 사용되어 비디오 전달과 라이브 스트리밍을 할 수 있다.

- Custom Origin (HTTP)

    사용자 지정 HTTP Endpoint를 오리진으로 설정할 수 있다. EC2 인스턴스, ELB, API Gateway 등이 가능하다. 특히 API Gateway는 엣지 최적화 유형의 엔드포인트를 제공하는데, 이미 CloudFront와 결합되어 있다.

CloudFront의 오리진은 퍼블릭 IP를 가져야 한다. CloudFront로부터 요청을 받을 수 있어야 하기 때문이다. 그래서 EC2 인스턴스나 ELB와 같은 경우에는 보안 그룹을 설정하여 CloudFront의 퍼블릭 IP만을 허용하면 좋다.

## Custom HTTP Header

S3 버킷은 OAC를 활성화하면 손쉽게 오리진에 대한 보안을 설정할 수 있었다. 그런데 Custom Origin이나 Application Load Balancer의 경우에는 OAC를 활성화할 수 없다. 그러면 어떻게 오리진을 보호할 수 있을까? 바로 Custom HTTP Header를 이용할 수 있다.

CloudFront는 HTTP Header를 추가할 수 있다. 그래서 CloudFront는 사용자로부터 온 요청에 헤더 이름과 값을 추가하여 오리진으로 보낸다. 오리진에서는 CloudFront가 추가한 헤더가 요청에 있는지 없는지를 확인한 뒤, 없으면 요청을 제거하고 있으면 백엔드로 요청을 전달하는 방식을 사용하면 손쉽게 보안을 설정할 수 있다. 다만 오리진에 HTTP 헤더를 확인하는 로직을 별도로 구현해야 한다. 그래서 Custom Origin과 ALB에서 사용할 수 있는 오리진 보호 방법이다.

# Reference

[Udemy 강의 - AWS Certified Solutions Architect Professional](https://www.udemy.com/course/aws-csa-professional/?couponCode=KRLETSLEARNNOW)

# History

📌 2024-4-17: CloudFront 개념과 오리진, Custom HTTP Header