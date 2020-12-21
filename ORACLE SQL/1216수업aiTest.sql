--ddl & dcl
--데이터를 조회하는 dml에서 벗어나 테이블을 생성하거나 수정하는 등의 언어
--create table 객체;
--alter table 객체;--계정 수정(unlock)시에도 사용 가능
--drop table 객체; --테이블 삭제
--rename, truncate, comment --이름 변경, 테이블 속 모든 데이터를 삭제, 

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
select * from emp
where job = 'SALES';
