select * from employees where department_id = 90;

SELECT last_name
FROM employees
WHERE last_name LIKE '_o%' ;

SELECT last_name, manager_id FROM employees WHERE manager_id IS NULL ;
SELECT last_name, manager_id FROM employees WHERE manager_id IS NOT NULL ;

SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary >= 10000
AND job_id LIKE '%MAN%' ;

select last_name, department_id, salary
from employees
order by 2 desc, salary desc;

--top n query
select * from employees order by employee_id;

--offset n rows, fetch n norws only
--OFFSET 자리에는 원하는 row limits 갯수를 뽑기 이전에 스킵하고 싶은 row 갯수가 있을 시에 써주면 된다.
--OFFSET에 음수가 오는 경우 Oracle은 0으로 인식 / NULL 이 오거나 리턴되는 row 갯수보다 높은 수를 쓸 경우 아무 행도 리턴되지 않는다.

select employee_id, first_name from employees order by employee_id offset 5 rows fetch next 5 rows only;
SELECT employee_id, first_name FROM employees ORDER BY employee_id FETCH FIRST 5 ROWS ONLY;

select employee_id, last_name, salary, department_id
from employees
where employee_id = &employee_num; --employ num에 대한 값을 입력하도록 뜸

--실행할때마다 컬럼명을 바꿔서 호출할 수 있는 쿼리
select employee_id, last_name, salary, department_id, &a 
from employees
where employee_id = &employee_num;

select last_name, department_id, salary*12
from employees
where job_id = '&job_title'; --값을 넣고싶을 때 따옴표 안에도 & 쓸 수 있음

SELECT employee_id, last_name, job_id,&column_name 
FROM employees WHERE &condition ORDER BY &order_column ;
--따라서 &뒤에는 내가 창에 띄우고 싶은 대로 지정한 이름값을 쓰면 됨..

--이중 앰퍼샌드 치환 변수 사용
--이경우, 첫번째 앰퍼샌드의 사용자 변수값을 저장해서 두번째 앰퍼샌드에서 알아서 사용
--즉, 두번째 앰퍼샌드에서 사용자 변수값을 물어보지 않음
select employee_id, last_name, job_id, &&column_name
from employees
order by &column_name;

--<define 명령어>
define employee_num = 200

select employee_id, last_name
from employees
where employee_id = &employee_num;

undefine column_name;
undefine employee_num

--<verify 명령 사용>
--어느 사용자 변수에 어떤 값을 갖고 출력되었는지 알려줌
--set verify on: 변경내용 자세하게, set verify off: 히스토리없이 간단하게
set verify on
select employee_id, last_name, salary
from employees
where employee_id = &employee_num;

--대소문자 변환
--대소문자 구분하는건 홑따옴표 안에 있는 것만!!!!! 나머진 안함
--upper, lower

--<substr>
select substr('HelloWorld', 1, 5) from dual;
select substr('HelloWorld', -1) from dual;
--시작 인덱스부터 뒷값까지.
--뒷값 없으면 끝까지 보여줘.
--인덱스는 1부터 시작
select employee_id, CONCAT(first_name, last_name) NAME,
LENGTH (last_name), INSTR(last_name, 'a') "Contains 'a'?"
FROM employees
WHERE SUBSTR(last_name, -1, 1) = 'n';

SELECT CONCAT(CONCAT(last_name, '''s job category is '), job_id) "Job" 
FROM employees WHERE SUBSTR(job_id, 4) = 'REP';

--함수 중첩: 가장 안쪽에 있는 함수부터 차례로 실행.
SELECT last_name,
UPPER(CONCAT(SUBSTR (LAST_NAME, 1, 8), '_US'))
FROM employees
WHERE department_id = 60;

select to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS') from dual;
select sysdate from dual;

--세션이 맘에 안들면 바꿀수있음..일단 파라미터들을 둘러보고 변경
select * from v$NLS_PARAMETERS;
alter session set NLS_Date_format = 'RRRR-MM-DD';
alter session set NLS_Date_format = 'YYYY/MM/DD';

--CURRENT TIME
SELECT SESSIONTIMEZONE, CURRENT_DATE FROM DUAL;
SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

--날짜 함수
SELECT MONTHS_BETWEEN('2020-01-02', '2020-05-02') FROM DUAL;
SELECT ADD_MONTHS('2020-01-02', 4) FROM DUAL; --날짜에 달 추가
SELECT NEXT_DAY('2020-01-02', FRIDAY) FROM DUAL; --지정된 날짜의 요일? 이거 뭐지
SELECT ROUND(SYSDATE , 'MONTH') FROM DUAL;  --#반올림
SELECT ROUND(SYSDATE, 'YEAR') FROM DUAL;
SELECT TRUNC(SYSDATE, 'MONTH') FROM DUAL; --가차없는 버림...?
SELECT TRUNC(SYSDATE, 'YEAR') FROM DUAL;

--<null값 대체>
--nvl(컬럼명, 값) 컬럼명이 null이면 값으로 대체됨
--nvl2(컬럼명, 값1, 값2) 컬럼명이 null이 아니면 값1, 컬럼명이 null이면 값2
select last_name, salary, commission_pct, nvl2(commission_pct, 'sal+comm', 'sal') income
from employees where department_id in (50, 80);

--<null if>
--nullif(값1, 값2)
--값1과 값2가 같다면 null을 출력하고, 같지 않다면 값1을 출력할것

--<coalesce 함수>
--coalesce(값1, 값2)....값n
--값1의 결과가 null이면 값2을 수행
--값2도 null이면 값3 수행....무한 꼬리물기 가능
select last_name, coalesce(salary, 1000)
from employees
where department_id = 10;

--<case when then, decode>함수
select last_name, decode(job_id, 'IT_PROG', 100, 'SALES', 200)
FROM EMPLOYEES;


-- <3 WAY JOIN> 3개 이상 다중 테이블 조인하기
SELECT employee_id, city, department_name
FROM employees e
JOIN departments d
ON d.department_id = e.department_id
JOIN locations l
ON d.location_id = l.location_id;
--밑에랑 동일함.
SELECT employee_id, city, department_name
FROM employees e, departments d, locations l
where d.department_id = e.department_id
and d.location_id = l.location_id;

--self join은 alias 사용이 필수 조건임

-- non equal join의 경우...

--union
--다른테이블에서 가져온 값들을 한꺼번에 출력 가능
SELECT job_id
FROM employees
UNION
SELECT job_id
FROM retired_employees;
--union은 결과에서 중복제거 되고, union all은 중복제거 안된채로 나옴

--###################################################################
--####                   SQL실습05                     ####
--###################################################################

--1-1. 급여가 1000이상인 사원들의?부서별?평균?급여를?출력해보세요?단,?부서별?평균?급여가?2000?이상인?부서만?출력하세요.
select department_id, avg(salary)
from employees
where salary >= 1000
group by department_id
having avg(salary) >= 2000;

--1-2. 각?부서별?같은?업무(job)를?하는?사람의?인원수를?구해서?부서번호,?업무(job),?인원수를?부서번호에?대해서?오름차순?정렬해서?출력해?보세요.
select * from employees;

select department_id, job_id, count(job_id)
from employees
group by department_id, job_id
order by department_id;

--1-3. 사원번호,부서번호,부서명을?출력하세요?단,?사원이?근무하지?않는?부서명도?같이?출력해보세요.
select * from departments;
select e.employee_id, d.department_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id;


--1-4. 'DALLAS'?에서?근무하는?사원의?이름,?부서번호를?출력해보세요.
select * from tab;
select * from locations;

select e.last_name, e.department_id
from employees e, locations l
where l.city = 'Dallas';

--1-5.급여를?3000?이상받는?사원이?소속된?부서와?동일한?부서에서?근무하는?사원들의?이름과?급여,?부서번호를?출력해?보세요
select e.last_name, e.department_id
from employees e
where e.department_id = ANY(select department_id from employees where salary >=3000);

--1-6. IN?연산자를?이용하여?부서별로?가장?급여를?많이?받는?사원의?사원번호,?급?여,?부서번호를?출력해보세요.
select last_name, employee_id, salary, department_id
from employees
where (department_id,salary) in (select department_id, max(salary) from employees group by department_id);

--1-7. 30번?부서의?사원중에서?급여를?가장?많이?받는?사원보다?더?많은?급여를?받는?사원의?이름과?급여를?출력해보세요.
select last_name, salary
from employees
where salary > (select max(salary) from employees where department_id = 30);

--1-8.부서번호가?30번인?사원들의?급여중?최저?급여보다?높은?급여를?받는?사원의?이름,?급여를?출력해보세요.
select last_name, salary
from employees
where salary > (select min(salary) from employees where department_id = 30);

--<part 2>
--1. 직책(Job Title)이 Sales Manager인 사원들의 입사년도와 입사년도(hire_date)별 평균 급여를 출력하시오.
-- 출력 시 년도를 기준으로 오름차순 정렬하시오.
select hire_date, avg(salary) from employees group by hire_date order by hire_date;
select * from jobs;

select e.hire_date, avg(e.salary)
from employees e, jobs j
where e.job_id = j.job_id
and j.job_title = 'Sales Manager'
group by e.hire_date
order by e.hire_date;

--2. 각 도시(city)에 있는 모든 부서 직원들의 평균급여를 조회하고자 한다.
-- 평균급여가 가장 낮은 도시부터 도시명(city)과 평균연봉, 해당 도시의 직원수를 출력하시오.
-- 단, 도시에 근 무하는 직원이 10명 이상인 곳은 제외하고 조회하시오.
select * from employees;

select l.location_id, l.city, avg(e.salary)
from employees e, locations l, departments d
where e.department_id = d.department_id
and d.location_id = l.location_id
group by l.location_id, l.city
having count(e.employee_id) < 10
order by avg(e.salary);

--3. ‘Public Accountant’의 직책(job_title)으로 과거에 근무한 적이 있는 모든 사원의 사번과 이름을 출력하시오.
-- (현재 ‘Public Accountant’의 직책(job_title)으로 근무하는 사원은 고려 하지 않는다.)
-- 이름은 first_name, last_name을 아래의 실행결과와 같이 출력한다.
select * from jobs;
select * from employees;
select * from job_history;
--hire_date between start_date and end_date
select e.employee_id, e.first_name, e.last_name, e.hire_date
from employees e, jobs j, job_history h
where e.job_id = j.job_id
and j.job_id = h.job_id
and j.job_title = 'Public Accountant';

--4. 자신의 매니저보다 연봉(salary)를 많이 받는 직원들의 성(last_name)과 연봉(salary)를 출 력하시오.

select e.last_name, e.salary
from employees e
where e.salary > (select salary from employees where employee_id = e.manager_id);


--5. 2007년에 입사(hire_date)한 직원들의 사번(employee_id), 이름(first_name), 성(last_name),
-- 부서명(department_name)을 조회합니다.
-- 이때, 부서에 배치되지 않은 직원의 경우, ‘’로 출력하시오.
select e.employee_id, e.first_name, e.last_name, nvl2(d.department_name, department_name, '''')
from employees e, departments d
where e.department_id = d.department_id(+)
and e.hire_date like '2007%';

--6. 업무명(job_title)이 ‘Sales Representative’인 직원 중에서 연봉(salary)이 9,000이상, 10,000 이하인
-- 직원들의 이름(first_name), 성(last_name)과 연봉(salary)를 출력하시오
select e.first_name, e.last_name, e.salary
from employees e, jobs j
where e.job_id = j.job_id
and j.job_title = 'Sales Representative'
and e.salary between 9000 and 10000;

--7. 부서별로 가장 적은 급여를 받고 있는 직원의 이름, 부서이름, 급여를 출력하시오.
-- 이름은 last_name만 출력하며, 부서이름으로 오름차순 정렬하고,
-- 부서가 같은 경우 이름을 기준 으로 오름차순 정렬하여 출력합니다.
select e.last_name, d.department_name, e.salary
from employees e, departments d
where e.department_id = d.department_id
and (e.department_id, e.salary) in (select department_id, min(salary) from employees group by department_id)
order by d.department_name, e.last_name;


--8. EMPLOYEES 테이블에서 급여를 많이 받는 순서대로 조회했을 때 결과처럼 6번째부터 10 번째까지
-- 5명의 last_name, first_name, salary를 조회하는 sql문장을 작성하시오.
select e.last_name, e.first_name, e.salary
from employees e
offset 6 rows fetch next 5 rows only;

--9. 사원의 부서가 속한 도시(city)가 ‘Seattle’인 사원의 이름, 해당 사원의 매니저 이름, 사원 의 부서이름을 출력하시오.
-- 이때 사원의 매니저가 없을 경우 ‘<없음>’이라고 출력하시오. 이름은 last_name만 출력하며,
-- 사원의 이름을 오름차순으로 정렬하시오.
select e.last_name, nvl2(m.last_name, m.last_name, '<없음>'), d.department_name
from employees e, employees m, departments d, locations l
where e.manager_id = m.employee_id(+)
and e.department_id = d.department_id
and d.location_id = l.location_id
and l.city = 'Seattle'
order by e.last_name;

--10. 각 업무(job) 별로 연봉(salary)의 총합을 구하고자 한다. 연봉 총합이 가장 높은 업무부터
-- 업무명(job_title)과 연봉 총합을 조회하시오.?단 연봉총합이 30,000보다 큰 업무만 출력하시오.
select e.job_id, j.job_title, sum(e.salary)
from employees e, jobs j
where e.job_id = j.job_id
group by e.job_id, j.job_title
having sum(e.salary) > 30000
order by sum(e.salary) desc;