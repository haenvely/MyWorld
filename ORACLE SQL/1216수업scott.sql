--ddl & dcl
--데이터를 조회하는 dml에서 벗어나 테이블을 생성하거나 수정하는 등의 언어
--create table 객체;
--alter table 객체;--계정 수정(unlock)시에도 사용 가능
--drop table 객체; --테이블 삭제
--rename, truncate, comment --이름 변경, 테이블 속 모든 데이터를 삭제, 
--최소한의 작업(업무)단위. transaction. 일이 일어나다가 실패하면 전체를 rollback시켜야 문제가 생기지 않음.
--문제 없이 전부 성공했을 때만 commit.

create table book(bookno number(5), title varchar2(50));
--<자주사용되는 데이터타입
--number(5)-- 숫자개수
--varchar2(50)--char은 고정길이 항상 50을 항상 만들어놓음, 
--varchar은 50을 부여해도 실제로 메모리는 50 이하 데이터를 50이하를 저장하여 메모리 사용률 적음.
--date

--database는 저장이 비싸기 때문에, 파일의 이름과 저장 위치정도만 db에 저장하고, 나머지는 모두 하드디스크에 저장
--보안이 중요한 데이터는 db에 저장하는게 더 나음

create table book(
bookno number(5),
title varchar2(50),
author varchar2(10),
pubdate date
);


create table empSALES
AS
(select * from emp
where job = 'SALES');

--[컬럼 추가 / 수정]
--add(컬럼명, 유형): 컬럼 추가시 가장 마지막에 순서로 추가됨
alter table book ADD(pubs varchar2(50));

--modify(컬럼명, 유형): 컬럼의 유형을 바꿔줌
alter table book modify(title varchar2(100));
--컬럼 삭제
desc book;
alter table book DROP author;
--컬럼 미사용으로 분류하고, 미사용 컬럼 삭제하기
alter table book set unused(author);
desc book; --이미 author 안나옴
alter table book drop unused columns;
desc book;

--column 순서 바꾸기...!! 12c부터 추가된 오라클 기능
--컬럼을 invisible로 바꿨다가 visible로 바꾸면, 맨 아래에 추가가 됨
alter table book modify title INVISIBLE;
desc book;
alter table book modify title visible;
desc book;
--<주의> rollback의 대상이 아님! 되돌릴수없음
--comment
comment on table book is 'this is comment';
desc book;
rename book to article;

--<Constraint> 제약조건
-- 예상치 못한 데이터의 손실이나 일관성을 어기는 데이터를 막음
-- not null: null이 아니어야함
-- unique: 유일한 값만 담을 수 있음
-- primary key: 기본키
-- foriegn key: 외래키
-- check: 그 컬럼 안에는 정의해논 값 외에는 못들어옴

--defualt 값을 지정하면 뭐가 안들어왔을 때도 defualt에 해당하는 값을 갖고잇음

--<제약조건 실습 구문>
create table book(
bookno number primary key);
-- (default 10)

-- primary key의 이름을 찾는법?
--<constraint에 이름을 부여>
--**제약조건 이름: 제약조건을 활성화하거나 비활성화할 수 있기 위해서 사용가능

drop table book;
create table book
(bookno number(5) constraint c_emp_u not null
title varchar2(50););

--[not null을 넣지 않앗기에, insert시 null값을 넣거나, bookno를 스킵해도 insert 가능]
create table book(
bookno number,
title varchar2(50));

insert into book values(null, 'testbook');
insert into book(title) values ('javabook');
select * from book;
insert into book values(1, 'testbook');

--[not null은 아니지만 unique를 넣을때?]
create table book(
bookno number unique,
title varchar2(50));

insert into book values(null, 'testbook'); --넣어짐
insert into book(title) values ('javabook'); --이미 null이 할당되어 안넣어짐
select * from book;
insert into book values(1, 'testbook');
insert into book values(1, 'test');

--[not null + unique]
create table book(
bookno number unique not null,
title varchar2(50));

insert into book values(null, 'testbook'); --안넣어짐
insert into book(title) values ('javabook'); --안넣어짐
insert into book values(1, 'testbook');
insert into book values(1, 'test'); --안넣어짐

drop table book;
--[Primary Key + 제약조건 이름]
create table book(
bookno number constraint book_pk primary key,
title varchar2(50));
--제약조건 이름 book_pk
--primary key를 사용하였기 때문에, not null + unique가 된다.
insert into book values(null, 'testbook'); --안넣어짐
insert into book(title) values ('javabook'); --안넣어짐
insert into book values(1, 'testbook');
insert into book values(1, 'test'); --안넣어짐

--<Primary Key를 여러개로 복합해서 사용가능하다. create 맨 마지막줄에
--constraint를 맨 마지막줄에 몰아서 써도 무방하다.
create table ssnbook(
ssn1 number(6),
ssn2 number(6),
constraint ssn_book_pk primary key(ssn1, ssn2));

--<check 제약조건>
--다양한 조건을 자유롭게 걸 수 있음. check (컬럼명 조건);
create table thesis( rate number check (rate IN (1,2,3,4,5)));
create table thesis2 ( title number check (title <20));
--rate 컬럼에 6을 넣으면 오류 발생
select * from thesis;
--<Foreign Key>
--constraint에 foriegn key(컬럼명) reference 외부테이블명(참조컬럼명)
--on delete set null: 외부테이블을 삭제할 때 오류가 발생할까봐 주는 옵션
--외부테이블의 참조컬럼을 삭제하면 foriegn key는 null이 된다
--on delete cascade: 10번의 사원들도 다 지워버릴거야...즉, foriegn key가 날라가는 순간 현재 데이터의 해당 row도 날라감

--<제약 조건 추가>
alter table emp add constraint emp_mgr_fk
foreign key(mgr) references emp(empno); -- + on delete cascade/set null

--제약조건을 삭제할 땐 이름 쓰면 됨
alter table book drop constraint c_emp_u;
alter table dept drop primary key cascade; --primary key가 외부에 fk로 사용시 cascade로 삭제해야함

--primary key나 unique의 제약조건을 가지면 인덱스를 가지게 됨
--데이터가 새로 입력되거나 삭제되거나 할 때 인덱스가 많이 바뀌면....????

--<데이터 사전 Data Dictionary>
--스키마객체나 제약조건, 제약조건 컬럼 등을 확인 가능
alter table emp disable constraint c_emp_pk cascade;

desc user_objects;
--테이블 확인
select object_name
from user_objects
where object_type = 'TABLE';

--제약조건 확인(테이블명 대문자로)
select constraint_name, constraint_type, search_condition
from user_constraints
where table_name = 'EMP';

--제약조건 컬럼 확인
select constraint_name, column_name
from user_cons_columns
where table_name = 'EMP';

select * from dictionary;
select * from user_constraints; - -모든정보
select * from user_cons_columns; --테이블명, 제약조건명, 해당 컬럼명

--이미 생성된 테이블에서, 수정해서 제약조건을 넣으려고 하면
--이전의 데이터와 제약조건이 충돌하면 에러 생길 수 있음

--연습

desc book;
select * from user_cons_columns;
select * from user_constraints;
select * from book;

-- 제약 조건 추가 예시 (alter table 테이블명 add constraint 제약명 조건);
ALTER TABLE book
ADD CONSTRAINT title_len CHECK ( length(title) < 20); 

--emp number primary key
select empno from emp;
select * from user_constraints;
--제약조건 추가: 그냥 컬럼을 프라이머리키로 설정하기
alter table thesis add constraint rate_pk
primary key(rate);

--emp manager 번호를 foriegn key로 지정
alter table emp add constraint emp_mgr_fk
foreign key (mgr) references emp(empno);


rollback; --transaction 처음으로 되돌리기
--create - create 사이가 트랜잭션 구간이라 할 수 있겠음.

--dept number 번호를 foriegn key로 지정

--<DCL>
--여러개의 권한을 묶어놓은것 : role
select * from user_users;
desc ALL_USERS;

--dba 권한을 가진 계정에서 권한 기능 할 수 있음. 실습의 경우 권한을 가진 계정이 없기 때문에. 시스템에서 할 수밖에 없었음
select * from ALL_USERS;
--select * from DBA_USERS; --SYSTEM에서

--권한 부여: grant 권한 회수: revoke
grant to user1;
revoke from user1;

--role을 생성할 수도 있음
--role을 생성하려면, role에 권한을 grant한 후 role 관리
--create role~~
--관련 딕셔너리: user_role_pr, role_p;

--<DML>
--insert into 테이블명 (컬럼리스트. 생략가능) values(값리스트);
--update 테이블명 set 변경내용 where조건; 조건이 없으면 모든 열에 변경됨..
--delete from 테이블명 where 조건;
create table test(no number, name varchar(10));
insert into test values(3, 'kim');
update test set name = 'kang' where no = 3;
select * from test;
delete from test; --where 안쓰면 데이터 몽땅 지워짐;;
rollback;
select * from test;
delete from test where no = 3;

insert into test values(5, 'oh');
insert into test values(10, 'jeon');
insert into test values(15, 'cha');

update test set name = 'kang', no = 1 where no = 3;
select * from test;

--subquery를 이용한 dml: 다른 테이블에서 값을 복사해오기.
create table deptusa(no number, name varchar(20));
select deptno, dname from dept where loc = 'kangnam';

insert into deptusa (select deptno, dname from dept where loc = 'kangnam');
select * from deptusa;
--subquery를 이용한 dml: 다른 테이블을 이용하여 값을 삭제하기.
delete from deptusa where name = (select dname from dept where loc = 'kangnam');
rollback;

--데이터 입력, 수정시 자주 사용되는 psedu컬럼
--user, sysdate, rowid
insert into emp(empno, hiredate) values(200, sysdate);
select * from emp;

select * from book;
--컬럼 추가하기:ALTER TABLE 테이블명 ADD(컬럼명 데이타타입(사이즈))
alter table book add(pubdate date);
insert into book values(200, 'Gems', DEFAULT);


insert into book values(200, 'Gems', default);
commit;
select * from book;
delete from book where bookno = 200;
rollback;
--rollback을 눌렀을 때, insert - delete -rollback시 insert로 가므로..추가하고 delete가 다 시행됨.
--insert 끝나고 commit을 해줘야 delete만 rollback함.

--transaction의 개념은 이 세션외에서 접속할 때 어떻게 보이느냐를 결정함.
--내가 이 세션에서 데이터를 삭제하거나 추가했더라도, 새 transaction을 실행하거나 commit을 완료하기 전까진 다른 세션에서 접속해도 업데이트 되지않음

--내가 이 세션에서 아직 transaction중인데, 다른 세션에서 transaction을 실행하면 실행이 안되고 대기상태로 들어감
--sqlplus에 lock이 걸렸다가 sql developer에서 끝나면 실행이 됨

--<Sequence>:테이블과 독립적인 존재. 테이블과 관계없이 독립해서 있는 존재로 값을 갖다줌
create sequence test_seq; --+옵션 가능
create sequence incre2_seq increment by 2 start with 40; --40부터 시작해서 2씩 증가하는 시퀀스
select test_seq.nextval from dual; : --1부터 시작. 수행할때마다 숫자가 막 올라감
--응용:
insert into test values(test_seq.nextval, default); --
select * from test;
commit;

update test set no = 0 where name = 'kang';
commit;

--sequence 삭제
drop sequence test_seq;


--<View>: 특정 테이블간 조인이 너무 빈번히 일어나거나, 특정 조건만 많이 사용하거나 할 때 사용하면 좋음
create view emp_10 as select * from emp where deptno = 10;
select * from emp_10 where sal>3000;



--##sql 실습 3##
--사용자에게 속한 테이블
select table_name from user_tables;
select * from tab;

--사용자에게 속한 객체 타입
select distinct object_type from user_objects;

--사용자의 스키마 객체
select * from user_catalog; --테이블명이랑 테이블 타입 출력됨(뷰, 시퀀스도 같이 나옴. 인덱스 안나옴)

--다음을 실습해보시오
CREATE TABLE  cre_tab1
            (  db_user  VARCHAR2(30) DEFAULT USER,
               issue_date DATE DEFAULT  SYSDATE, 
           type_operation NUMBER(3));
insert into cre_tab1(type_operation) values(100); --default(scott), default(20/12/16), 100
select * from cre_tab1;
select * from CRE_TAB1; --대소문자 상관없음. 같은 테이블 조회함.

CREATE TABLE "Cre_tab2" ( a  NUMBER,  b  CHAR );
--SELECT * FROM cre_tab2; 에러발생: 테이블 명이 따옴표로 명시되어 대소문자 구분이 됨.

--# 다음은 CHAR와 VARCHAR2 type에 대한 실습이다. 각 문장의 수행 결과를 예측하시오.
CREATE TABLE test_char
           ( id  NUMBER,
             a CHAR(2), 
             b VARCHAR2(2));
INSERT INTO test_char VALUES (1, 'x','x');
INSERT INTO test_char VALUES (2, 'x ','x ');
SELECT * FROM test_char  WHERE  a = 'x';
--# 수행 결과는 어떻게 되는가? 2행 다 조회됨
SELECT * FROM test_char  WHERE  a = 'x '; 
--# 수행 결과는 어떻게 되는가? 2행 다 조회됨
SELECT * FROM test_char  WHERE  b = 'x';
--# 수행 결과는 어떻게 되는가? 1행만 조회됨
SELECT * FROM test_char  WHERE  b = 'x ';
--# 수행 결과는 어떻게 되는가? 2행만 조회됨

--# 다음 숫자가 입력이 되는지, 입력이 된다면 결과는 어떻게 나오는지 확인하시오.
create table test_num(a number(3), b number(3,1));
insert into test_num values (100, 10);
insert into test_num values (100, 0.1);
insert into test_num values (100, 0.5);
insert into test_num values (100, 0.51);
insert into test_num values (100, 0.55);
select * from test_num; --입력한 결과들이 반올림돼서 0,5, 0,6으로 보임
insert into test_num values (999, 99);
insert into test_num values (999, 100); --에러 발생
insert into test_num values (99, 99.9);
insert into test_num values (99, 99.91);
insert into test_num values (99, 99.95); --에러 발생
insert into test_num values (1000, 10); --에러 발생
select * from test_num; --99.9에서 짤림
insert into test_num values (0.1, 10);
insert into test_num values (0.6, 10);
select * from test_num; --각각 반올림해서 0, 1로 들어감

insert into test_num values ('A', 10); --에러 발생

--# 다음 두 문장은 어떤 차이가 있나?
CREATE TABLE history1
           AS SELECT * FROM emp;
CREATE TABLE history2
AS SELECT * FROM emp WHERE 1 = 0;

desc history1;
desc history2;

select * from all_users; --#모든 user 뜸
select * from user_users; --scott의 정보가 뜸
select * from dba_users; --에러 뜸. system에서 해야함

select table_name from dictionary where table_name like '%USER%';
SELECT table_name FROM dictionary
          WHERE table_name LIKE '%PRIV%';
SELECT table_name FROM dictionary
          WHERE table_name LIKE '%TABLE%' 
          OR table_name LIKE '%COLUMN%';
SELECT table_name FROM dictionary
          WHERE table_name LIKE '%CONS%';
SELECT table_name FROM dictionary
          WHERE table_name LIKE '%AUDIT%';
SELECT table_name FROM dictionary
          WHERE table_name LIKE '%IND%';
          
--# create table with constraints 실습

--# 테이블 생성: 다음이 의미하는 바는 무엇인가?
--# 테이블의 구조가 어떻게 되는지 확인하자.

drop table book;
CREATE TABLE book(
    id    NUMBER(5) CONSTRAINT book_id_pk PRIMARY KEY,
    name    VARCHAR2(20) CONSTRAINT book_name_not_null NOT NULL, 
    price    NUMBER(12,2) CONSTRAINT book_price_check CHECK (price > 0), 
    isbn    VARCHAR2(14) CONSTRAINT book_isbn_unique UNIQUE,
    pub_date DATE DEFAULT SYSDATE
     );
CREATE TABLE job(
    id    NUMBER(3) CONSTRAINT job_id_pk PRIMARY KEY,
    name    VARCHAR(5) NOT NULL
     );
CREATE TABLE author (
    id    NUMBER(5) CONSTRAINT author_id_pk PRIMARY KEY, 
    name    VARCHAR2(20) CONSTRAINT author_name_not_null NOT NULL,
    gender    CHAR(1) DEFAULT 'M',
    age    NUMBER(2),
    job_id    NUMBER(3),
    CONSTRAINT author_gender_check CHECK (gender in ('M', 'F')),
    CONSTRAINT author_job_id_fk FOREIGN KEY (job_id) REFERENCES job(id) 
     );
CREATE TABLE author_book (
    author_id    NUMBER(5),
    book_id        NUMBER(5),
    author_order    NUMBER(2) DEFAULT 1,
    CONSTRAINT authorbook_author_id_fk FOREIGN KEY (author_id) REFERENCES author(id) ON DELETE CASCADE,
    CONSTRAINT authorbook_book_id_fk FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    CONSTRAINT authorbook_pk PRIMARY KEY (book_id, author_id, author_order)
     );
--#생성된 제약조건 확인해보기
--왜안나올까?
SELECT constraint_name, constraint_type,
    search_condition
    FROM user_constraints
    WHERE table_name = 'book'; --안나옴
--딕셔너리에서 검사할때는 테이블 이름을 무조건 대문자로 한다

--# 제약조건의 이름과 종류, 검색 조건만 나온다.
SELECT constraint_name, constraint_type,
    search_condition
    FROM user_constraints
    WHERE table_name = 'BOOK';
--# 어느 컬럼에 걸렸는지만 나온다.
SELECT constraint_name, column_name
    FROM user_cons_columns
    WHERE table_name = 'BOOK'; 
--# 조인을 하면 원하는 것을 얻을 수 있다.
SELECT uc.constraint_name, uc.constraint_type, ucc.column_name, uc.search_condition
    FROM user_constraints uc, user_cons_columns ucc
    WHERE uc.constraint_name = ucc.constraint_name and uc.table_name = 'BOOK';
--# 다른 테이블도 확인해보자
SELECT uc.constraint_name, uc.constraint_type, ucc.column_name, ucc.position, uc.search_condition
    FROM user_constraints uc, user_cons_columns ucc
    WHERE uc.constraint_name = ucc.constraint_name and uc.table_name = '&table_name';
--(* SQL*PLUS에서는 &를 사용하면 값을 입력받도록 할 수 있다.) ; EMP 넣어보기
--job을 넣어보니, 제약조건 name not null이 출력되었음.

--#생성한 테이블의 동작 테스트
INSERT INTO book VALUES (1, 'C++ INTRO', 20000, '15-222-22222', '07/01/02');
INSERT INTO book VALUES (2, 'JAVA PRIMER', 50000, '11-111-1111', DEFAULT);
SELECT * FROM book; --2행 출력

--# 다음은 수행될 수 있나? 안된다면 각각 어떠한 제약조건에 걸리는지 확인해보자.
INSERT INTO book VALUES (1, 'TEST BOOK', 50000, '33-333-3333', DEFAULT); --에러, 유니크 위반
INSERT INTO book VALUES (3, NULL, 50000, '33-333-3333', DEFAULT); --에러, not null 위반
INSERT INTO book VALUES (3, 'TEST BOOK', 50000, '11-111-1111', DEFAULT); --에러, 유니크 위반
INSERT INTO book VALUES (3, 'TEST BOOK', -100, '33-333-3333', DEFAULT); --체크 조건 위반
INSERT INTO book VALUES (3, 'TEST BOOK', 30000, '33-333-3333', NULL);
SQL> INSERT INTO book VALUES (4, 'TEST BOOK', 30000, '33-333-3333', NULL);
SQL> SELECT * FROM book;