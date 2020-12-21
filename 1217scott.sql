--index
--장점: 검색, 조인, 정렬..빠르게하려고 / 단점: 유지비용
--where절의 조건이나 join에 자주 사용되는 컬럼
-- 매우 큰 테이블에서 2~4% 레코드만 선택할 때
-- 값의 종류가 다양할 때. 그래야 트리 형식으로 만들어내기 때문 (예. 성별?처럼 다양성이 없는 건 성능에 안좋음)
-- 자주 변경되지 않을 때

create index idx_emp_ename on emp(ename);
drop index idx_emp_ename;

--dictionary에서 찾기
select * from user_indexes;
select * from user_ind_columns;

--synonym : =alias같은 존재
--접근 제한자가 붙음

--Oracle SQL1_ep.pdf
-- SQL: RDBM를 위한 Ansi 표준언어
--중복제거
select distinct job from emp;

--대체 인용 연산자 q
SELECT department_name || q'[ Department's Manager Id: ]' || manager_id AS "Department and Manager" FROM dept;

SELECT  sal*12 "yearly sal" FROM emp;


