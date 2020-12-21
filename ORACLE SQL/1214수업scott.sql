select * from tab;
CREATE TABLE EMP(
	EMPNO NUMBER(4) NOT NULL, 
        ENAME VARCHAR2(10), 
        JOB VARCHAR2(9), 
        MGR NUMBER(4), 
        HIREDATE DATE, 
        SAL NUMBER(7, 2), 
        COMM NUMBER(7, 2), 
        DEPTNO NUMBER(2));
CREATE TABLE DEPT 
       (DEPTNO NUMBER(2), 
        DNAME VARCHAR2(14), 
        LOC VARCHAR2(13) );
CREATE TABLE SALGRADE 
        (GRADE NUMBER,
          LOSAL NUMBER, 
         HISAL NUMBER);
INSERT INTO EMP VALUES 
        (7369, 'SMITH',  'CLERK',     7902, 
        TO_DATE('17-12-1980', 'DD-MM-YYYY'),  800, NULL, 20);
INSERT INTO EMP VALUES 
        (7499, 'ALLEN',  'SALESMAN',  7698, 
        TO_DATE('20-02-1981', 'DD-MM-YYYY'), 1600,  300, 30);
INSERT INTO EMP VALUES 
        (7521, 'WARD',   'SALESMAN',  7698, 
        TO_DATE('22-02-1981', 'DD-MM-YYYY'), 1250,  500, 30);
INSERT INTO EMP VALUES 
        (7566, 'JONES',  'MANAGER',   7839, 
        TO_DATE('02-04-1981', 'DD-MM-YYYY'),  2975, NULL, 20);
INSERT INTO EMP VALUES 
        (7654, 'MARTIN', 'SALESMAN',  7698, 
        TO_DATE('28-09-1981', 'DD-MM-YYYY'), 1250, 1400, 30);
INSERT INTO EMP VALUES 
        (7698, 'BLAKE',  'MANAGER',   7839, 
        TO_DATE('01-05-1981', 'DD-MM-YYYY'),  2850, NULL, 30);
INSERT INTO EMP VALUES 
        (7782, 'CLARK',  'MANAGER',   7839, 
        TO_DATE('09-06-1981', 'DD-MM-YYYY'),  2450, NULL, 10);
INSERT INTO EMP VALUES 
        (7788, 'SCOTT',  'ANALYST',   7566, 
        TO_DATE('09-12-1982', 'DD-MM-YYYY'), 3000, NULL, 20);
INSERT INTO EMP VALUES 
        (7839, 'KING',   'PRESIDENT', NULL, 
        TO_DATE('17-11-1981', 'DD-MM-YYYY'), 5000, NULL, 10);
INSERT INTO EMP VALUES 
        (7844, 'TURNER', 'SALESMAN',  7698, 
        TO_DATE('08-09-1981', 'DD-MM-YYYY'),  1500, NULL, 30);
INSERT INTO EMP VALUES 
        (7876, 'ADAMS',  'CLERK',     7788, 
        TO_DATE('12-01-1983', 'DD-MM-YYYY'), 1100, NULL, 20);
INSERT INTO EMP VALUES
         (7900, 'JAMES',  'CLERK',     7698, 
        TO_DATE('03-12-1981', 'DD-MM-YYYY'),   950, NULL, 30);
INSERT INTO EMP VALUES 
        (7902, 'FORD',   'ANALYST',   7566, 
        TO_DATE('03-12-1981', 'DD-MM-YYYY'),  3000, NULL, 20);
INSERT INTO EMP VALUES 
        (7934, 'MILLER', 'CLERK',     7782, 
        TO_DATE('23-01-1982', 'DD-MM-YYYY'), 1300, NULL, 10);

INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPT VALUES (40, 'OPERATIONS', 'BOSTON');
INSERT INTO SALGRADE VALUES (1,  700, 1200);
INSERT INTO SALGRADE VALUES (2, 1201, 1400);
INSERT INTO SALGRADE VALUES (3, 1401, 2000);
INSERT INTO SALGRADE VALUES (4, 2001, 3000);
INSERT INTO SALGRADE VALUES (5, 3001, 9999); 

select * from tab;
select * from emp;
select * from dept;
select * from salgrade;

select * from emp;
select ename 이름 from emp; --as 없어도 띄어쓰기로 as 대체 가능
select ename as "이름" from emp; -- oracle sql에선 allias(as) 사용할 때만 "" 사용
select ename, job from emp;

select ename, (sal+200)*12 from emp;
select ename, -sal*10 from emp;
select ename, sal from emp;
select * from emp;

desc emp;
--null값이 있는 컬럼과 연산하기
select ename, sal, comm from emp;
select ename, (sal+comm)*12 from emp; --null에 대한 연산은 되지 않아서 무조건 null로 나옴
--nvl 함수 사용하기: NVL(컬럼명, 대체값) null 대신 0 return한다
select sal, comm, (sal+NVL(comm, 0))*12 from emp;

--그냥 값만 있는 컬럼 하나 추가해서 뽑기
select ename, 1000, SYSDATE from emp;
--출력양식을 준 채로 컬럼 뽑기
select 'Name is ' || ename || ' and no is ' || empno FROM emp;


--<where> 조건을 만족하는 열만 가져오기
-- in 집합에 포함되는지
-- between a and b 쓸 땐 a가 작은값
-- like 첫글자나 중간에 포함된 것을 찾을 수 있음
-- is null, is not null
-- and, or
-- any, all 집합 중 어느 한 열, 집합 중 모든 열(다른 비교연산자와 함께 사용)
-- exist 결과 row가 하나라도 있는지

-- like연산에서
-- wildcard 이용한 문자열 부분매칭
-- %랑 _ 사용가능
--% 임의의 길이의 문자열(공백 문자 가능)
-- _ 한글자
-- escape 뒤의 문자열로 시작하는 문자는 wildcard가 아닌 것으로 해석

-- 이름 두번째 글자가 M인 사원의 이름
select ename from emp where ename like '_M%';
--83년에 입사한 사원
select * from emp;
select * from emp where hiredate like '83%';

-- 정렬. 기본은 asc임. null은 뒤로감. 
select * from emp order by comm;
select * from emp order by comm desc; --null이 앞에 오고 desc

--order by 여러 기준 가능
select empno, ename, sal, comm from emp order by sal desc, comm desc;
select empno, ename, sal, comm from emp order by 3 desc, 4 desc; --3번째 컬럼, 4번째 컬럼 의미

select lower(ename) from emp; --싱글로우 함수. 함수당 결과값 각각 하나 나오는거
select sum(sal) from emp; --멀티로우 펑션. 전체 결과 중 결과값 하나 나옴

select concat(ename, sal) from emp;
select concat('hhhh', 'gggg') from dual; --임시테이블에서 테스트해보고 싶을 때 dual 사용

-- 대소문자 변환
select lower('DaewerHweyr') from dual;
select upper('DasesweHweyr') from dual;
select initcap(ename) from emp; --첫글자만 대문자화로

--오라클은 index가 1부터 시작
--문자열조작
select substr('database', 2, 4) from dual;
select length('database') from dual;
select instr('database', 'b') from dual; --index출력
select lpad(24000, 10, '*') from dual;
select rpad(salary, 10, '*') from dual;
select trim('#' from '##database###') from dual;
--숫자조작
select ceil(-2.4) from dual;
select floor(-2.4) from dual;
select abs(-2.4) from dual;
select mod(13, 2) from dual; --나머지
select power(2,3) from dual; --m의 n승
select round(4.567, 2) from dual; --m의 n자리까지 반올림
select trunc(4.567, 2) from dual; --m의 n자리 이후엔 버림
select sign(-10) from dual; --부호 출력(-1, 1, 0)

select sysdate from dual;
select value from nls_session_parameters where parameter = 'NLS_DATE_FORMAT';
--하나하나하나가 각각 다른 세션을 갖는다.

--날짜 함수 Date함수
select hiredate, add_months(hiredate, 3) from emp; --컬럼명의 날짜에 3달 더하기
select last_day(sysdate) from dual; --이번달의 마지막 날
select months_between('20/12/14', '19/11/20') from dual;
select round(sysdate, 'month') from dual;
select next_day(hiredate, 3) from emp; --값이나 컬럼명의 n일 뒤
select next_day('20/12/12', 'SUNDAY') from dual;
select round(sysdate, 'year') from dual;
select trunc(sysdate, 'month') from dual;
select trunc(sysdate, 'year') from dual;

select ename, comm, NVL2(comm, comm+30, 30) from emp;
select ename, NVL(TO_CHAR(mgr), 'No Manager') from emp; --mgr이 int이니까 char로 바꿔야 대체 가능

-- <case when then 구문>
--case job컬럼이 when 안에꺼와 같다면 then으로 갈거야
--case end로 끝냄
-- end 뒤에 allias 넣을 수 있음
-- <decode 구문>
-- decode(컬럼명, 조건, 값) allias

select * from emp where deptno = 10 or deptno = 20;
select * from emp where deptno in (10, 20); --위랑 결과 똑같음. 10, 20 집합중에 있다.
select * from emp where deptno = 10 and sal>=3000;