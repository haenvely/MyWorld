select * from tab;
select * from employees;

conn hr
--# DB 상의 data가 대소문자를 구별하므로 저장된 정확한 형태를 알지 못하는 경우 Function을 이용하여 data를 변형시킨 후 비교하기도 한다.
select department_id, department_name from departments where department_name = 'SALES';
SELECT department_id, department_name FROM departments?where UPPER(department_name) = 'SALES'; --에러발생

--#CHAR, ASCII
SELECT CHR(79)||CHR(114)||CHR(97)||CHR(99)||CHR(108)||CHR(101) FROM dual; -- Oracle
SELECT ASCII('O'),ASCII('r'),ASCII('a') FROM dual;-- 79, 114, 97
--# 문자열 치환
SELECT REPLACE('Oracle DB System','DB','Database') FROM dual; --db가 database로
--# 문자열 일부 추출
select substr('Oracle DB System', 2, 4) from dual; --racl
--# 각 글자 단위로 변환 A->1, B->2, ...
select translate('Oracle DBMS', 'ABCD', '1234') from dual; --Oracle 42MS
--# 처음 나오는 위치?
select instr('Oracle DBMS', 'a') from dual; --3
--#길이
select length('Oracle DBMS') from dual; --11

--#substr 문자열 일부 추출
SELECT department_name, SUBSTR(department_name, 1,3) FROM departments;
SELECT department_name, SUBSTR(department_name, 1) FROM departments;
SELECT department_name, SUBSTR(department_name, -5, 3) FROM departments;

