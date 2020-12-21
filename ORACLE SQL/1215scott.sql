--<조인의 필요성>
select ename, dname from emp, dept; --56개 출력(단순곱)
select count(ename) from emp; -- 14개
select count(dname) from dept;  --4개

--join 할 시 조인의 조건을 무조건 넣어줘야함
--다른 조건은 and로 나열 가능
select e.ename, d.dname from emp e, dept d where e.deptno = d.deptno and sal > 2500;

--Theta Join(Non-equal 조인이면서 조건을 주는 조인)
---between 값으로 join하는 예시
select e.ename, e.sal, s.grade from emp e, salgrade s where e.sal between s.losal and s.hisal;

--<Outer Join>
--데이터에서 null인 값이 없어서 추가해보자. 부서 없는 사원을 만들어보자.
--테이블 내에 넣을때 컬럼 순서대로
--컬럼값을 비워놓으면 null로 되지만, 테이블의 컬럼 조건이 not null인 컬럼의 경우 에러가 뜸. 무조건 넣어야함
insert into emp values(7499, 'carami', 'CLERK', null, sysdate, 5000, NULL, null);
insert into dept values(50, 'dev', 'kangnam');

--기본 조인(Inner Join)시 새로운 사원 Carami와 50번 부서는 결과에 나오지 않음
select e.ename, d.dname from emp e, dept d where e.deptno = d.deptno; --14개
--(+) 없는 경우(null)도 보고싶다 할 때 붙임. 왼쪽에 (+) 붙이면 Right 조인. 오른쪽에 (+)붙이면 Left 조인.
--null이 포함될 경우쪽에 +를 붙인다.
select e.ename, d.dname from emp e, dept d where e.deptno(+) = d.deptno; --15개

--<natural join> 컴터가 알아서 조인 하는 명령
--아주 잘 짜인 관계형 테이블이 아닌이상 쓰지 않는다
select * from emp natural join dept;

--<From 절에 join을 넣기>
--조건이 되는 컬럼명을 명시해주는 것이 using
--join on은 where 대신 사용 가능
--from 테이블 들 where equal 조건을 다음과 같이 응용가능
select * from emp join dept using(deptno);
select * from emp join dept on emp.deptno = dept.deptno;

--Join on을 사용해 Outer Join 하기
select * from emp Left outer join dept on emp.deptno = dept.deptno;
select * from emp right outer join dept on emp.deptno = dept.deptno;
select * from emp full outer join dept on emp.deptno = dept.deptno;
--full outer join은 오라클에서만 가능하다. mysql에서는 left 한뒤 right 한뒤 둘을 union 해야함.

--<Self Join>
--자기자신과 조인하기
--alias를 사용할수밖에 없다.
select e.empno 사번, e.ename 사원이름, m.empno 매니저사번, m.ename 매니저이름
from emp e, emp m
where e.mgr = m.empno; --사원테이블의 매니저랑 매니저테이블의 사원아이디가 같아야함

--나한테 매니저가 없는 사원(보스) 뽑아보기
select e.empno 사번, e.ename 사원이름, m.empno 매니저사번, m.ename 매니저이름
from emp e, emp m
where e.mgr = m.empno(+);

--natural join으로 표현해보기
select e.empno 사번, e.ename 사원이름, m.empno 매니저사번, m.ename 매니저이름
from emp e join emp m on (e.mgr = m.empno);

select e.empno 사번, e.ename 사원이름, m.empno 매니저사번, m.ename 매니저이름
from emp e left outer join emp m on (e.mgr = m.empno);

--계층형 트리 구조 데이터 랭킹하기
--오라클은 섀도우 컬럼 level 제공
select level, ename from emp
start with mgr is null
connect by prior empno = mgr
order by level;

--<그룹함수(집계함수)>
select avg(sal) from emp;
select count(*) from emp;
select count(empno) from emp; --15
select count(mgr) from emp; -- 13
--null값이면 count 대상이 안되기 때문에 pk 혹은 *로 세야 전체 수를 셀수 있음

--집계함수의 결과는 한 row만 남게 됨.
select * from emp;
select min(sal) from emp;
select max(sal) from emp;
--min()을 가진 사람 이름은? (subquery사용)
select empno, ename, sal from emp where sal = (select min(sal) from emp);

select deptno, avg(sal) from emp; --에러발생!
--ㅇㅇ별 과 같은 내용을 필요할 때는 group by절 사용
--왜냐면 avg()나 min()과 같은 값은 데이터row가 딱 하나
--deptno나 다른 컬럼들은 여러row이기 때문.

--<group by> 사용 : ㅇㅇ별 을 사용하고 싶을 때
select deptno, avg(sal) from emp
group by deptno;

select deptno, dname, avg(sal)
from emp natural join dept
group by deptno, dname
order by dname;

select e.deptno, d.dname, avg(e.sal) from emp e, dept d
where e.deptno=d.deptno
group by e.deptno, d.dname;

select deptno, avg(sal) from emp
where sal < 5000
group by deptno
having avg(sal) > 2000;
--평균 급여가 5000이상인 사람은 빼겟다 where
--부서별 급여가 평균 2000 이상인 그룹만 남기겟다 having

--급여가 5000이상인 직원은 빼고 부서별 평균급여를 나타내는데, 
--부서별 평균급여가 2000이하인 부서는 빼고 출력
--평균급여가 높은 부서부터 정렬
select deptno, avg(sal)
from emp
where sal <5000
group by deptno
having avg(sal) > 2000
order by avg(sal) desc;

select d.dname, e.deptno, avg(e.sal) 
from emp e, dept d 
where e.deptno = d.deptno and e.sal < 5000 
group by e.deptno, d.dname 
having avg(e.sal) >= 2000 
order by avg(e.sal) desc;

--rollup, cube
--roll은 A(대분류) 안에 B(소분류)
--cube는 A분류 B분류 복합으로 나옴

--<SUBQUERY> 서브쿼리. 쿼리문 안에 또다른 쿼리문 사용
---single row 섭쿼리의 경우(단일 값과 비교할 때)
--#스미스 부서의 평균 급여
select avg(sal) from emp
where deptno = (select deptno from emp where ename = 'SMITH');

--#급여가 20번 부서의 평균급여보다 많이 받는 사람들만 출력
select ename from emp
where sal > (select avg(sal) from emp where deptno = 20);

--#scott보다 월급이 많은 사람의 이름
select ename from emp
where sal> (select sal from emp where ename = 'SCOTT');

select ename, sal, deptno from emp
where ename = (select min(ename) from emp);

select ename, sal from emp
where sal < (select avg(sal) from emp);

select ename, deptno
from emp
where deptno = (select deptno from dept where dname = 'SALES');

---multi row subquery
select ename, sal, deptno
from emp
where ename in (select min(ename) from emp group by deptno);
-- in (allen, adams, clark, carami)와 같은 형태
-- in은 equal or의 결합 : 값 = (A or B)
-- in() = =ANY()
-- ALL의 경우 and로 연결됨.

--#각 부서별로 최고급여를 받는 사원을 출력하시오
select deptno, empno, ename, sal
from emp
where (deptno, sal) in (select deptno, max(sal) from emp group by deptno);

select e.deptno, e.empno, e.ename, e.sal
from emp e, (select s.deptno, max(s.sal) msal 
from emp s group by deptno) m
where e.deptno = m.deptno AND e.sal = m.msal;

--<Correlated Query> 서브쿼리의 한 종류. 바깥에 영향을 받는 subquery
--outer query와 inner query가 서로 연관되어있음
--outer query의 테이블에게 alias 무조건 부여해야함
--바깥의 쿼리에 영향을 받는것이 correlated query 형태

SELECT
deptno , empno , ename , sal
FROM
emp e
WHERE e.sal = (SELECT max(
sal )
FROM
emp WHERE deptno = e.deptno;

--<Top K query>
--rownum: 질의의 결과에 가상으로 매겨지는 index?
select rownum, ename, sal
from emp order by ename;
--rownum이 order by의 정렬보다 먼저 정렬되어있음
--order by가 나중에 적용

select rownum, ename, sal
from (select * from emp
where hiredate like '81%'
order by sal desc)
where rownum < 4;
--테이블 살펴보기
select * from emp
where hiredate like '81%'
order by sal desc;

--select * from emp group by sal desc
--OFFSET 2 ROWS fetch next 3 rows only;
--봉급이 가장 많은 사람 중 2번부터 3개 보여줘
--offset 2 fetch next 3
--fetch first 3 rows only --처음부터 3개 보여줘

--동점자를 어떻게 처리할 것인가(중복값 처리?)
--rank 관련 함수
--SELECT sal, ename, RANK() OVER (ORDER BY sal DESC) AS rank, DENSE_RANK() OVER (ORDER BY sal DESC) AS dense_rank, ROW_NUMBER() OVER (ORDER BY sal DESC) AS row_number, rownum AS "rownum“
--FROM emp;


--##스스로 5문항 만들어서 풀이와 함께 업로드
select * from emp;
select * from emp cross join dept;

--[sql 실습 2]
--#다음 문장들의 실행 결과를 비교해보시오
select ename, dname from emp e, dept d where e.deptno(+) = d.deptno;
select ename, dname from dept left outer join emp using (deptno);
--결과 똑같이 16개 출력됨

--#각 부서별 인원을 출력하여 결과 비교
select dname, count(empno) from emp e, dept d
where e.deptno = d.deptno
group by d.deptno, d.dname;

select dname, count(empno) from emp e, dept d
where e.deptno(+) = d.deptno
group by d.deptno, d.dname; --이경우, 사원이 없는 부서도 출력됨

--#트리구조
--top to bottom
select empno, ename, job, mgr, level from emp
start with mgr is null
connect by prior empno = mgr
order by level;
--bottom to top
select empno, ename, job, mgr, level from emp
start with ename = 'SMITH'
connect by prior mgr = empno;

--aggregation

--직종별 최고 급여를 급여가 많은 직종부터 출력하시오
select job, max(sal) from emp
group by job
order by max(sal) desc;

--직종별 최고 급여를 급여가 많은 직종부터 출력하는데, 직원이 2명이상인 경우만
select job, max(sal) from emp
group by job
having count(sal)>=2
order by max(sal) desc;

--<받은 문제 1> scott에서 평균월급이 2000이상 3000이하인 부서는 ?
select * from dept;
select d.dname from dept d, emp e
where e.deptno = d.deptno
and avg(e.sal) between 2000 and 3000;

SELECT deptno, AVG(sal)
FROM emp
having avg(sal) < 3000 and avg(sal) > 2000
GROUP BY deptno;

--<받은 문제 2> -- 1. 급여를 적게 받는 순서대로 상위 5명을 출력하시오. 
--만약 급여가 같은 경우, 이름 순으로 출력하시오.
select rownum, ename
from (select * from emp order by sal, ename)
where rownum < 6;

SELECT rownum, ename, sal 
           FROM (SELECT * FROM emp  ORDER BY sal, ename) 
           WHERE rownum < 6;

--rownum은 order by보다 먼저 들어가기 때문에 마지막 기준 순서로 뽑고 싶다면 
--그전에 서브쿼리 안에 결과 뽑고 바깥에서 rownum

--<받은 문제 3>각 부서별 인원과 부서별 평균월급을 내림차순으로 정렬
select dname, count(empno),avg(e.sal) FROM emp e, dept d where e.deptno  = d.deptno group by d.dname
order by avg(e.sal) desc;

--<받은 문제 4>scott에서 각 부서별로 급여가 1500 이상인 사원들 중 입사년도가 가장 최근인 사원을 출력하시오.
select * from emp;

select ename
from emp
where sal >= 1500 and hiredate = (select max(hiredate) from emp);

SELECT deptno, empno, ename, sal, hiredate
           FROM emp
           WHERE (deptno,hiredate) IN  (SELECT deptno, max(hiredate) 
                                          FROM emp WHERE sal >= 1500 GROUP BY deptno);

select deptno, max(hiredate)
from emp
where sal >= 1500
group by deptno;