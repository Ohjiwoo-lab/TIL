# 알아두면 유용할 것들

## 시간 단축하는 법

terraform plan을 했을 때 생성되어있는 리소스가 수백개라면 이를 일일히 검사하는 데에 시간이 오래 소요될 것이다. 그래서 `-parallelism=n` 옵션을 이용하여 동시에 검사할 리소스 개수를 늘린다면 시간이 단축되는 효과를 누릴 수 있다.

```terraform
terraform plan -parallelism=30
```

기본값은 10인데 30으로 늘리면 동시에 30개를 검사하기 때문에 시간이 단축된다.

이는 apply를 할 때에도 적용할 수 있다. apply도 plan과 마찬가지로 이미 존재하는 리소스를 검사하기 때문이다.

```terraform
terraform apply -parallelism=30
```