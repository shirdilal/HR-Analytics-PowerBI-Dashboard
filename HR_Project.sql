alter table  hr_data
add column Salaryband varchar(15);

set sql_safe_updates = 0;
update hr_data
set Salaryband = case
	when Salary > 100000.00 then 'Band A'
    when Salary >= 50000.00 then 'Band B'
    else 'Band C'
    end;
alter table hr_data
drop column Salaryband;
    
select
*
from hr_data;

create or replace view hr_project as
select
Emp_Id,
Full_Name,
Age,
DOB,
gender,
department,
jobtitle,
location,
hire_date,
status,
location_city,
Salary
from hr_data;

alter table hr_data
add column DOB date;
-- Assuming your table is 'hr_data' and your column is 'salary'
UPDATE hr_data
SET 
salary = CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2));


update hr_data
set DOB = str_to_date(birthdate, '%c/%e/%Y');

alter table hr_data
drop column birthdate;

alter table hr_data
add column new_hire_date date;

update hr_data
set new_hire_date = str_to_date(hire_date, '%c/%e/%Y');

alter table hr_data
drop column hire_date;

alter table hr_data
rename column new_hire_date to hire_date;


-- select
-- department,
-- race,
-- count(*)
-- from hr_data
-- group by race, department
-- order by count(*) desc

-- select
-- gender,
-- avg(salary)
-- from hr_data
-- group by gender


-- select
-- count(*) as total_employees
-- from hr_data

select
count(*) as Active_employees
from hr_data
where status = 'Active';

select
count(*) as Terminated_employees
from hr_data
where status = 'Terminated';

-- select
-- round((Terminated_employees * 100 / total_employees),2) as attritionrate_Percentage
-- from
-- (

-- select
-- count(*) as total_employees,
-- sum(case
-- 	when status = 'Terminated' then 1 else 0 end) as Terminated_employees
-- from hr_data
-- ) t;

select
department,
round((Terminated_employees/ total_employees *100), 2) as attritionrate_department
from
(
select
department,
count(*) as total_employees,
sum(case
	when status = 'Active' then 1 else 0 end) as Active_employees,
sum(case
	when status = 'Terminated' then 1 else 0 end) as Terminated_employees
from hr_data
group by department
) t
group by department;

SELECT
    Gender,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM hr_data
GROUP BY Gender;
create or replace view salary_bands as
select
Emp_Id,
salary,
case
 when salary < 40000 then 'less $40k'
 when salary >= 40000 and salary < 60000 then '$40k-$60k'
 when salary >= 60000 and salary < 80000 then '$60k-$80k'
 when salary >= 80000 and salary < 100000 then '$80-$100k'
 else '$100k+' end as salary_band
from hr_data;

select
department,
round(avg(salary),2) as avgerage_salary
from hr_data
where status = "Active" 
group by department
having avgerage_salary > 50000.00
order by avgerage_salary desc
limit 3;

select
*
from 
(

select
Emp_Id,
department,
salary,
dense_rank() over(partition by department order by salary desc) as ranking
from hr_data
where status = "Active"
) t
where ranking <= 3;

SELECT 
    Emp_Id,
    concat(
    TIMESTAMPDIFF(year,hire_date, CURDATE()), '.',
    TIMESTAMPDIFF(month,hire_date, CURDATE()) % 12, 'years'
    ) tenure
FROM hr_data;

select
*
from hr_data;


alter table hr_data
add column Term_date date;

UPDATE hr_data
SET Term_date = CASE 
    WHEN termdate IS NULL OR TRIM(termdate) = '' THEN NULL
    ELSE STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
END;

alter table hr_data
drop column termdate;

create or replace view tenure as
select
Emp_Id,
Term_date
from hr_data;