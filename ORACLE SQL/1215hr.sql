select * from tab;
-- countries, departments, employees, emp_details_view, jobs, job_history, locations, regions

--#20번 부서의 이름과 그 부서에 근무하는 사원의 이름
select * from departments;
select d.department_name, e.last_name from departments d, employees e
where d.department_id = e.department_id and d.department_id = 20;

--#1400, 1500번 위치의 도시 이름과 그곳에 있는 부서의 이름 출력
select * from locations;
select l.city, d.department_name from locations l, departments d
where l.location_id = d.location_id;

--<문제1.>HR 에서 사원 중 가장 빨리 입사한 사원 출력
select * from employees;

select e.*
from employees e
where e.hire_date = (select min(hire_date) from employees);


--<문제 2> HR 에서 각 지역(region)별로 나라의 개수를 출력하시오(지역명, 나라 갯수 출력)
select * from regions;
select * from countries;

select r.region_name, count(c.country_id)
from regions r, countries c
where r.region_id = c.region_id
group by r.region_id, r.region_name;

select r.region_id, r.region_name, count(c.country_id)
from regions r, countries c
where r.region_id = c.region_id
group by r.region_id, r.region_name;

--<문제 3> HR에서 사원의 연봉이 가장 많은 사원의 모든 정보를 출력하시오
select * from employees
where salary = (select max(salary) from employees);

--<문제 4> HR에서 사원의 last_name 이름 순서대로 상위 3명의 last_name을 출력하시오.
--top k 방식
select * from employees;

select rownum, last_name
from (select * from employees order by last_name)
where rownum < 4;


--<문제 5> HR에서 각 부서의 매니저 전화번호를 출력하고, 부서 번호 순서대로 정렬(부서번호, 부서이름, 매니저 last 이름, 매니저 전화번호)
select * from departments;
select * from employees;

select d.department_id, d.department_name, e.last_name, e.phone_number
from departments d, employees e
where d.manager_id = e.employee_id
order by d.department_id;




