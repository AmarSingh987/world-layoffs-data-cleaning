-- Exploratory Data Analysis (EDA)

select * from layoffs_stagging_2;


-- Find Companies with 100% Layoffs
select * from layoffs_stagging_2
where percentage_laid_off = 1
order by total_laid_off desc;


-- Total Layoffs by Company
Select company, sum(total_laid_off) as TotalLaidOff 
from layoffs_stagging_2
group by company
order by TotalLaidOff desc;


-- From when to when this layoffs happened
select min(`date`), max(`date`) from layoffs_stagging_2;


-- Total Layoffs by Industries
Select industry, sum(total_laid_off) as TotalLaidOff 
from layoffs_stagging_2
group by industry
order by TotalLaidOff desc;


-- Total Layoffs by Countries
Select country, sum(total_laid_off) as TotalLaidOff 
from layoffs_stagging_2
group by country
order by TotalLaidOff desc;


-- Total Layoffs by year
Select year(`date`) as Year_, sum(total_laid_off) as TotalLaidOff 
from layoffs_stagging_2
group by Year_
order by TotalLaidOff desc;


-- Total Layoffs by year & month
select year(`date`) as `Year`,substring(`date`,6,2) as `Month`,
sum(total_laid_off) as TotalLaidOff from layoffs_stagging_2
group by `Month`,`Year`
order by `Year` desc,`Month`
;



-- Monthly Running Total of Layoffs by Year
with running_total as
(
	select year(`date`) as `Year`,substring(`date`,6,2) as `Month`,
	sum(total_laid_off) as TotalLaidOff from layoffs_stagging_2
	group by `Month`,`Year`
	order by `Year` desc,`Month`
)
select `Year`,`Month`,TotalLaidOff,sum(TotalLaidOff) over(order by `Year`,`Month`)
as running_TotalLaidOff
from running_total
where `Year` is not null;



-- Total Layoffs by Company and Year
select company, year(`date`), sum(total_laid_off) as TotalLaidOff
from layoffs_stagging_2
group by company, year(`date`)
order by TotalLaidOff desc;



-- i have created sprocedure to find out the top 5 companies who laid off highest in different years from 2020 to 2023
DELIMITER $$

CREATE PROCEDURE top5_companies_by_total_laid_off(IN which_year INT)
begin
with cte as
(
	select company, year(`date`) as Year, sum(total_laid_off) as TotalLaidOff
	from layoffs_stagging_2
	group by company, year(`date`)

),
company_ranking as
(
	select company,Year,TotalLaidOff,dense_rank() over(partition by Year order by TotalLaidOff desc)
	as ranking
	from cte
	where Year is not null 
)
    SELECT * 
    FROM company_ranking
    WHERE Year = which_year AND ranking <= 5;
END $$

delimiter ;

call top5_companies_by_total_laid_off(2023);
















