select * from emp
where sal > (select avg(sal) from emp where deptno = 10);

select * from emp;
select * from dept;

select e.ename, e.deptno, d.loc, e.sal
from emp e, dept d
where e.deptno = d.deptno
and d.dname = 'ACCOUNTING';

select e.empno, e.ename, e.deptno, d.deptno
from emp e join dept d
using(deptno);