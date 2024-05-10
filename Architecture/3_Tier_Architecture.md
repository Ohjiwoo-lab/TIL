# 3 Tier Architecture란?

![image](https://github.com/Ohjiwoo-lab/TIL/assets/74577768/599ea318-6bfa-475f-b390-62190f192f35)   
출처: [Three-Tier Client Server Architecture in Distributed System](https://www.geeksforgeeks.org/three-tier-client-server-architecture-in-distributed-system/)

3 Tier란 `Presentation Tier(Client)` - `Application Tier(Server)` - `Data Tier`로 나누어진 구조를 말한다. Presentation Tier가 흔히 말하는 프론트엔드이고, Application Tier와 Data Tier가 백엔드이다. Presentation Tier에서는 보통 웹서버가 동작하여 애플리케이션 화면을 사용자에게 제공해주고, 그 외의 동적인 사용자의 요청은 모두 Application Tier에서 WAS에 의해 처리된다. Data Tier는 말 그래도 데이터를 저장하는 부분으로, 여러 종류의 데이터베이스가 사용될 수 있다.

## Web Server vs WAS

그러면 Presentation Tier에서 동작하는 웹서버와, Application Tier에서 동작하는 WAS는 어떤 차이점이 있을까?

웹 서버는 html, css, javascript와 같은 정적인 컨텐츠를 처리하는 데에 최적화되어 있는 서버이다. 사용자로부터 정적인 파일에 대한 요청이 들어오면 웹서버는 WAS나 DB에 액세스하지 않고 바로 응답을 보낼 수 있기 때문에 좋은 성능을 제공해줄 수 있다. 대표적인 웹 서버로는 nginx, apache 등이 있다.

하지만 웹사이트에서는 정적인 파일만 있지는 않다. 데이터베이스에 저장되어 있는 값에 따라 내용이 달라지는 동적인 페이지도 있을 수밖에 없다. 이러한 동적인 페이지는 웹 서버로는 처리하지 못한다. 이렇게 동적인 페이지를 처리하기 위해 사용되는 것이 WAS, Web Application Server이다. WAS는 데이터베이스로부터 데이터를 쿼리하여 동적인 페이지를 사용자에게 전달해준다. 대표적으로 Django를 통해 개발된 애플리케이션이 포함될 수 있다.

결국 웹 서버에서 처리하지 못하는 동적 페이지 요청은 웹 서버에 의해 장고 앱과 같은 웹 애플리케이션 서버에 전달된다. 그런데 웹 서버에서 보내는 HTTP 요청을 파이썬으로 이루어진 장고 내부에서는 이해하지 못한다. 서로 다른 규격을 사용하고 있기 때문이다. 그래서 통일된 프로토콜을 정의할 필요가 있는데 이를 `WSGI`라 한다.

WSGI는 웹 서버로부터 전달된 HTTP 요청을 파이썬이 이해할 수 있도록 처리하는 미들웨어 역할을 한다. 파이썬에 종속적이며, 대표적으로 gunicorn, uWSGI 등이 있다.

장고는 내부적으로 WSGI 기능을 포함하고 있는 간단한 HTTP 서버를 제공한다. 바로 'python manage.py runserver'를 통해 구동된 서버를 의미한다. 이는 개발 및 테스트 환경에서 적합하고, 배포 시에는 이용하지 않는 것이 좋다. 간단한 기능만을 제공하고 있고 보안에 취약할 수 있기 때문이다.

그래서 보통 nginx와 같은 웹 서버와 함께 사용한다. nginx + gunicorn + django 조합이 많이 사용되는데, 여기서 gunicorn과 django 앱을 합쳐서 WAS라고 한다.

웹 서버로 nginx, WAS로 gunicornr과 django 애플리케이션, DB로 MySQL을 사용한다면 3 Tier Architecture를 사용한다고 말할 수 있다.

# History

📌 2024-2-29: 웹 서버 vs WAS   
📌 2024-5-10: 3 Tier 아키텍처 구조 정리   