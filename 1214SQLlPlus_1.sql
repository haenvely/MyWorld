select * from tab;
DESCRIBE dept;
select empno, ename, sal from emp;
--## 다음 문장을 실행해 보시오.? Column이 Null인 경우 어떻게 표현되는가?? 
--Comm 값이 있는 사원은 어떤 사원들인가??? 
--사번 7844인 사원의 커미션은 얼마인가?
select empno, job, comm from emp;
select empno, comm from emp where empno=7844;
--## 다음은 사원들의 연봉을 계산하는 문장이다.? 
--Comm 값이 Null인 경우 연봉은 얼마인가?? 
--연봉 계산한 수식의 column heading은 어떻게 나타나는가? 
select sal, comm, (sal+comm)*12 from emp;
--## 다음은 사번과 커미션을 출력하면서 커미션이 없는 사원의 경우 Null이 아니라 0으로 출력하도록 하는 문장이다.? 실행해 보시오.
select empno, ename, NVL(comm, 0) comm from emp;
--## 다음은 매니저가 없는 , 즉 최고 직급의 사원인 경우 ‘No Manager’라고 출력되도록 하는 문장이다.? 실행하여 Error 메시지를 적어보고 Error가 나는 이유를 설명하시오.
select NVL(mgr, 'No Manager') from emp;
--Error: ORA-01722: invalid number 01722. 00000 -  "invalid number" *Cause:    The specified number was invalid. *Action:   Specify a valid number.
select NVL(TO_CHAR(mgr), 'No Manager') from emp;
--* Error 발생.? 이유는 :?????mgr과 'No Manager'을 비교하기에 같은 데이터 형식이 아니기 때문에 변환 필요
--## column alias를 사용한 문장들이다.? column heading이 어떻게 나타나는지를 기록하고,? Error가 나는 문장에 대해서는 이유를 설명하시오.
select sal*12 annual_salary from emp; --컬럼헤딩: ANNUAL_SALARY
select sal*12 Annual_salary from emp;--컬럼헤딩: ANNUAL_SALARY
select sal*12  "Annual Salary" from emp; --alias 사용시 띄어쓰기 불가. 쌍따옴표 필요

select empno||ename from emp;
select empno||ename||hiredate FROM emp;

select ename||' '||sal from emp;
select ename|| ' is working as a '|| job from emp;

select 'Korea Fighting' from emp;
--(* Korea Fighting 이라는 literal이 14 번 출력된다. 이유는 :?emp의 데이터가 14개이기 때문에

select 'Korea Fighting' from dept;
--(* Korea Fighting 이라는 literal이 4 번 출력된다. 이유 :?dept의 데이터가 4개라서)

--## literal이나 literal들의 연산결과를 출력해 볼 때는 sys사용자 소유의 dual이라는 dummy table을 활용한다.
select 'Korea Fighting' from dual;
select 10+20 from dual;
select 'Red' || ' ' || 'Devil' from dual;

--##? dual table을 이용하여 server의 현재 시각이나 현재 접속중인 DB 사용자를 조회해 볼 수 있다. 
select sysdate, user from dual;

--## DISTINCT: 다음 문장들을 실행하고 결과를 비교하시오.## 몇 개의 튜플이 출력되는가??
select job from emp;--14개
select distinct job from emp; --5개
select deptno from emp; --14개
select distinct deptno from emp; --3개

--## 다음은 여러 column에 대한 중복 값을 제거하는 문장이다. 결과를 비교하시오.
select deptno, job from emp; -- 14개
select distinct deptno, job from emp; --9개
select distinct job, deptno from emp; --9개

--## Date 값에 대해 조건을 줄 때는 현재 session의 NLS_DATE_FORMAT에 맞춰 주도록 한다.
--## 현재 Date포멧은?
select value from nls_session_parameters where parameter = 'NLS_DATE_FORMAT';
-- RR/MM/DD
--## 그외에도 각종 SESSION 파라메터를 확인해보자.
select * from nls_session_parameters;
--## 날짜 출력 포멧 변경, RR은 Y2K고려한 2자리 년도
alter session set nls_date_format = 'DD-MON-RR';
SELECT empno, ename FROM emp WHERE hiredate>='01-1월-82'; --이거 에러로 nov a valid month 떠요
alter session set nls_date_format = 'RR/MM/DD';
select empno, ename from emp where hiredate >= '82/01/01';

--## ANY / IN 연산자
--## BOSTON이나 DALLAS 에 위치한 부서를 출력하시오.
select * from dept;
select dname, loc from dept where loc IN('BOSTON', 'DALLAS');
select dname, loc from dept where loc = ANY('BOSTON', 'DALLAS');

--## 30, 40번 부서에 속하지 않는 사원들을 출력하시오.
select ename, deptno from emp where deptno NOT in (30,40);
select ename, deptno from emp where deptno <> all(30,40);

--## DALLAS의 20번 부서, 또는 CHICAGO의 30번 부서를 출력하시오.
select * from dept where (deptno,loc) in ((30, 'DALLAS'),(30,'CHICAGO'));

--# 급여가 2000에서 3000 사이인 사원을 출력하시오.
select ename, job, sal from emp where sal between 2000 and 3000;
--## 이름이 A 로 시작되는 사원을 출력하시오.
select * from emp where ename like 'A%';
--## 사번이 8번으로 끝나는 사원을 출력하시오.
select * from emp where empno like '%8';
--## 82년도에 입사한 사원을 출력하시오.
select * from emp where hiredate like '82%';
--## 부서명에 X_Y 가 포함되어 있는 부서를 출력하시오.
select *  FROM dept WHERE dname LIKE '%X/_Y%' ESCAPE '/';

--## 커미션 지급 대상인 사원을 출력하시오.
select ename, comm from emp where comm is not null;
--##아래 두 문장의 결과를 비교해 보고 차이점을 설명하시오.
select ename, comm from emp where comm is null; --11개
select ename, comm from emp where comm = null; --결과 없음

--## 사번이 7788인 사원의 이름과 급여를 출력하시오.
select ename, sal from emp where empno = 7788;
--## 급여가 3000 이 넘는 직종을 출력하시오.
select job from emp where sal>3000;
--## PRESIDENT 를 제외한 사원들의 이름과 직종을 출력하시오.
select ename, job from emp where job <>'PRESIDENT';
--## BOSTON 지역에 있는 부서의 번호와 이름을 출력하시오. 
select deptno, dname from dept where loc = 'BOSTON';
--## 직종이 CLERK 인 사원 중에서 급여가 1000 이상인 사원을 출력하시오.
SELECT ename, job, sal FROM emp WHERE job = 'CLERK' AND sal >= 1000;
--## commission을 받는 사원을 출력하시오.
SELECT ename FROM emp WHERE comm IS NOT NULL;
SELECT ename FROM emp WHERE NOT comm IS NULL; --not 사용
--## 10번 부서와 20번 부서에 속한 사원을 출력하시오.
select * from emp where deptno = 10 or deptno = 20;
select * from emp where deptno in (10,20);

--## 10번과 20번 부서에 속하지 않는 사원의 이름과 부서번호를 출력하시오.
select * from emp where deptno not in (10,20);
select * from emp where deptno <> 10 and deptno <> 20;

--## 급여가 2000에서 3000 사이인 사원을 출력하시오.
select ename from emp where sal>=2000 and sal <=3000;
select ename from emp where sal between 2000 and 3000;

--## ORDER BY## Null 값은 오름차순의 경우 맨 마지막에, 내림자순의 경우 맨 처음에 display된다.
select ename, comm from emp order by comm desc;

--## 급여가 적은 사원부터 출력하시오.
select ename from emp order by sal;
--## 급여가 많은 사원부터 출력하시오.
select ename from emp order by sal desc;
--## 급여가 많은 사원부터 출력하되 급여가 같은 경우 이름 순서대로 출력하시오.
select ename, sal from emp order by sal desc, ename;
--## 급여가 많은 사원부터 출력하되 급여가 같은 경우 이름 순서대로 출력하시오. (ORDER BY 절에 숫자 사용: 몇번째 컬럼?)
select ename, sal from emp order by 2 desc, 1;

--## SELECT 절에 나타나지 않은 column에 대해서도 정렬이 가능하다.
select ename from emp order by sal desc;

--#ROUND, TRUNC 는 첫 번째 argument를 소수점 아래 두 번째 argument자리까지 표현한다.
SELECT sal, ROUND(sal, -3), TRUNC(sal, -3) FROM emp;

--#TRUNC나 ROUND는 자리수 표현, 자리수 지정 없으면 정수부분
select floor(45.925), ceil(45.925) from dual;
select trunc(45.925), round(45.925) from dual;

--# 각종 수학 함수 다음을 실습해 보시오.
SELECT MOD(10, 3), MOD(10, -3), MOD(-10, 3), MOD(45.925, 10) FROM dual;
SELECT ABS(-15), ABS(15) FROM dual;
SELECT SIGN(-15),SIGN(15) FROM dual;
SELECT SIN(3.141592/2) FROM dual;
SELECT EXP(4) FROM dual;

--# TRIM: 주어진 문자가 아닌 문자가 나올때까지 지운다. 
select ename, LTRIM(ename, 'AB'), RTRIM(ename, 'SR') from emp;
