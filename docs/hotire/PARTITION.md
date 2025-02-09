# Partition

- 파티션은 하나의 서버에서 테이블을 분산하는 것을 말한다. 

Horizontal Partitioning, Vertical Partitioning 2개가 존재한다. 

## Horizontal Partitioning (수평 분할)

같은 테이블 스키마를 가진 데이터를 데이터베이스 여러 개에 분산하여 저장하는 방법이다. 

데이터 rows 나누어 Partitioning 하는 방법이다.

때문에 Sharding을 Horizontal Partition`이라고 볼 수도 있다.

호리진털 

## Vertical Partitioning (수직 분할)

하나의 테이블 스키마를 분리하여 여러 테이블로 저장하는 방법이다. 

## Partition vs Sharding

수평분할과 샤딩은 비슷한 의미로 사용되지만, 샤딩은 더 큰 의미로 물리적 위치가 다른 데이터베이스를 의미하기도 한다. 

그에 비헤 수평 분할은 같은 데이터베이스 안에서 분리된 것만을 의미한다.

- https://d2.naver.com/helloworld/14822


## 사용 이유 

데이터가 많아진다고 해서 무조건 파티션을 적용하는 것이 효율적인 것은 아니다. 

하나의 테이블이 너무 커서 인덱스의 크기가 물리적인 메모리보다 훨씬 크거나, 데이터 특성상 주기적인 삭제 작업이 필요한 경우 파티션이 필요한 대표적인 예라고 할 수 있다.

### 1. 인덱스 크기

데이터베이스에서 인덱스는 일반적으로 SELECT를 위한 것으로 보이지만 UPDATE나 DELETE, 그리고 INSERT 쿼리를 위해 필요한 때도 많다.

인덱스가 커지면 UPDATE나 DELETE, 그리고 INSERT 점점 느려진다.

하나의 테이블의 인덱스가 MySQL 메모리보다 크다면 심각할 것이다. 


### 2. 대량 삭제 

테이블에서 불필요해진 데이터를 백업하거나 삭제하는 작업은 일반 테이블에서는 상당히 고부하의 작업에 속한다. 

대게 로그 테이블, 이력 테이블

이를 파티셔닝 처리하면 쉽게 처리 할 수 있다.

## 파티션 푸르닝 

SQL 에서 읽지 않아도 되는 파티션을 읽지 않는 기능 

## 내부 처리

파티션 키를 기준으로 파티셔닝 해서 데이터를 분산한다.

### 파티션 테이블의 검색

어느 파티션에 저장돼 있는지 찾아야 하는데, WHERE 조건에 파티션 키 칼럼이 존재하면 빠르게 찾아갈수 있지만, 만약 없다면 모든 파티션을 검색해야 한다.

- 1.파티션 선택 가능 + 인덱스 효율적 사용 가능 : 가장 최고

- 2.파티션 선택 불가 + 인덱스 효율적 사용 가능 : 테이블의 모든 파티션을 대상으로 검색해야 한다. 테이블에 존재하는 모든 파티션의 개수만큼 인덱스 레인지 스캔을 수행

- 3. 파티션 선택 가능 + 인덱스 효율적 사용 불가 : 대상 테이블 풀스캔이 필요하다.

- 4. 파티션 선택 불가 + 인덱스 효율적 사용 불가 : 

### 파티션 테이블의 레코드 INSERT

INSERT되는 레코드를 위한 파티션이 결정되면 나머지 과정은 파티션되지 않은 일반 테이블과 마찬가지로 처리한다. 

### 파티션 테이블의 UPDATE

UPDATE 쿼리를 실행하려면 변경 대상 레코드가 어느 파티션에 저장돼 있는지 찾아야 한다. 

WHERE 조건에 파티션 키 칼럼이 존재하면 빠르게 찾아갈수 있지만, 만약 없다면 모든 파티션을 검색해야 한다.

### 파티션 인덱스

로컬 인덱스에 해당한다. 즉 모든 인덱스는 파티션 단위로 생성되며 테이블 전체 단위로 글로벌하게 하나의 통합된 인덱스는 지원하지 않는다.

 - 파티션되지 않은 테이블에서 인덱스를 순서대로 읽으면 그 칼럼으로 정렬된 결과를 바로 얻을 수 있지만 파티션된 테이블에서는 그렇지 않다.
 
하지만 Using filesort 로 별도로 표시되지 않는데, 이유는 각 파티션으로부터 조건에 일치하는 레코드를 정렬된 순서대로 읽으면서 우선순위 큐(Priority Queue)에 임시로 저장한다. 

그리고 우선순위 큐에서 다시 필요한 순서(인덱스의 정렬 순서)대로 데이터를 가져가는 것이다. 


## 파티션의 제한 사항, 주의사항

- version에 따라서 파티션 키값 제한이 있을 수 있음, 숫자 값(INTEGER 타입 칼럼 또는 INTEGER 타입을 반환하는 함수 및 표현식)에 의해서만 파티션이 가능함(MySQL 5.5부터는 숫자 타입뿐 아니라 문자열이나 날짜 타입 모두 사용할 수 있도록 개선됨)

- 파티션키는 모든 유니크 인덱스((프라이머리 키 포함))의 일부 또는 모든 칼럼을 포함해야 한다. (유니크 인덱스는 중복 레코드에 대한 체크 작업 때문에 범위가 좁혀지지 않기 때문이다. )

- 모든 파티션은 같은 구조의 인덱스만 가질 수 있다. 즉 파티션 단위로 인덱스를 변경하거나 추가할 수 없다. 





https://velog.io/@jsj3282/39.-%ED%8C%8C%ED%8B%B0%EC%85%98-%EA%B0%9C%EC%9A%94