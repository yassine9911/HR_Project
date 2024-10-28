-- Create DATABASE  and Import Table
create database Hr_project ;
use hr_project ;

-------------- Cleaning Data --------------
-- Rename the Table  
select * from hr_project.`human resources`;
rename table hr_project.`human resources` to hr;

-- Rename the Column  and Change the Type 
select * from hr;
alter table hr  rename column ï»¿id to   ID  ;
 alter table hr modify column  id varchar(40) Null ;
 describe hr ;
 
 -- Update Date Columns 
 select * from hr ;
 set sql_safe_updates=0;
 update hr set birthdate = case  
                           when birthdate like'%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y/'),'%y-%m-%d')
                           when birthdate like '%_%' then date_format(str_to_date(birthdate,'%m/%d/%Y/'),'%y-%m-%d')
                           else null
                           end ;
 alter table hr  
 modify column birthdate date;
 describe hr  ;
 
 update hr set hire_date= case 
                           when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%y-%m-%d')
						  Else Null 
                          end ;
alter table hr 
modify column hire_date date ;
 describe hr  ;

update hr  set termdate=date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
 where termdate is not null and termdate !='' ;
 select * from hr ;


-- Add column Age 
alter table hr 
add column age int ;

update  hr 
set age = timestampdiff(Year,birthdate,now());

select * from hr ;
describe hr;

-------------- Analysis Data --------------

-- 1/ What is the gender breakdown of employees in the company?! 
select gender  , count(*) as Count 
from hr 
where age>=18 and termdate=''
group by  gender ;

-- 2/ What is the race breakdown of employees in the company ?!
select * from hr;
select race , count(*) as Count 
from hr 
where age>=18 and termdate='' 
group by race 
order by Count desc ;

-- 3/ What is the age and gender distribution od employees in the company?!
select  min(age) , max(age)
from hr 
where age>=18 and termdate='' ; 

select 
case when age>=18 and age<=24 then '18-24' 
     when age>=25 and age<=34 then '25-34' 
	 when age>=35 and age<=44 then '35-44' 
	 when age>=45 and age<=54 then '45-54'
	 when age>=55 and age<=64 then '55-64' 
     else  '65+' 
     end as group_age ,  gender, 
	count(*) as Count
from hr where age>=18 and termdate=''
  group by group_age ,  gender
  order by group_age ;
  
  -- 4/How many employees work at headquaters versuss remote location
  select location , count(*) as Count 
  from hr
  where age>=18 and termdate='' 
  group by location ;
  
  -- 5/What is the average lenght of employement for employees who have terminated?! 
 select round(avg(datediff(termdate,hire_date))/365) as Avg_Length_employees
  from hr
  where age>=18 and termdate!='' and termdate <= now() ;
  
  -- 6/How does the gender distribution vary across departements and job titles?! 
  select department , gender , count(*)  as Count 
  from hr 
   where age>=18 and termdate='' 
   group by department , gender
   order by department ;
   
   -- 7/What  is distribution of job titles across the company?!
   select jobtitle , count(*) as Count 
   from hr 
    where age>=18 and termdate='' 
    group by jobtitle
    order by jobtitle Desc;
    
-- 8/Which departement has the highest turnover rate?!

select department ,  total_Count, terminated_Count , terminated_Count/total_Count as Terminated_Rate 
from (
select department , count(*)  as total_Count  , 
       sum( case when termdate!='' and termdate<=now() then 1 else 0 end) as terminated_Count  
from hr 
group by department ) as subquery 
order by Terminated_Rate Desc ;

-- 9/What is the distribution of employees  across location by city and state?!
select location_city , count(*)  as count
from hr where termdate = '' and age>=18 
group by location_city 
order by count desc ; 

-- 10/How has the company's employee count changed overtime based on hire  and termdate?!
select Years , hires , termination , hires-termination as change_net  , round(((hires-termination) /hires)*100,2) as Net_Change_Percent 
 from (
select year(hire_date) as Years  , count(*) as hires , sum(case when termdate!='' and termdate<= now() then 1 else 0 end )  as termination 
from hr
where age >=18
group by Years ) as Subquery 
order by Years  ;

-- 11/What is the tenure distribution for each departement ?!
select department , round(avg(datediff( termdate,hire_date)/365),0) as avg_tenure 
from hr
where termdate !='' and age>=18  and termdate<=now()
group by department;

 
 
 
