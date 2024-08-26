-- Data Cleaning

select * from layoffs;

-- Step 1. Create a Copy of the Raw Data before working
-- Step 2. Remove Duplicates
-- Step 3. Standardize the Data
-- Step 4. Null Values or Blank values
-- Step 5. Remove Any Columns or Rows





-- Step 1  Lets create a copy of raw data for best practice

CREATE TABLE layoffs_stagging
LIKE layoffs;

INSERT INTO layoffs_stagging
SELECT * FROM layoffs;

SELECT * FROM layoffs_stagging;






-- Step 2  Lets Find Duplicates and Remove them




with cte as
(
	select *,row_number() over(partition by company,location,industry,total_laid_off,
	percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_stagging
)
select * from cte
where row_num > 1;


-- Creating a another table with one extra column of row_num  because
-- we cannot update the CTE

CREATE TABLE `layoffs_stagging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_stagging_2
	select *,row_number() over(partition by company,location,
    industry,total_laid_off,percentage_laid_off,
    `date`,stage,country,funds_raised_millions) as row_num
	from layoffs_stagging;

select * from layoffs_stagging_2;

SET SQL_SAFE_UPDATES = 0;

delete from layoffs_stagging_2
where row_num > 1;






-- Step 3  Lets Standardize our data now




update layoffs_stagging_2
set company = trim(company);

update layoffs_stagging_2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country from layoffs_stagging_2 order by 1;

update layoffs_stagging_2
set country = 'United States'
where country like 'United States%';


select `date`,
str_to_date(`date`,'%m/%d/%Y') from layoffs_stagging_2;

update layoffs_stagging_2
set `date` = str_to_date(`date`,'%m/%d/%Y');

select * from layoffs_stagging_2;

-- lets change the data type as well

alter table layoffs_stagging_2
modify column `date` DATE; 







-- Step 4 Lets Work with NULL and Blank Values






select * from layoffs_stagging_2 where industry is null or industry = '';

update layoffs_stagging_2
set industry = NULL where industry = '';

update layoffs_stagging_2 as t1
	 join layoffs_stagging_2 as t2
	 on t1.company = t2.company
	 set t1.industry = t2.industry
     where t1.industry is null and t2.industry is not null;
 
select * from layoffs_stagging_2 where industry is null;

select * from layoffs_stagging_2 where company = "Bally's Interactive";
 
select * from layoffs_stagging_2;

-- as we have limited columns so we can not deal with other null values
-- as we dont have the total employee info that could be helpful
-- for null values in total laid of and percentage laid offs







-- Step 5 Lets Remove the Rows or Columns which are not useful for our project




-- As we are going to do EDA where we need Total laid offs and percentage laid offs
-- as our Primary information so there is no use of that data which is null for that
-- Analysis so lets remove this

select * from layoffs_stagging_2 where total_laid_off is null
and percentage_laid_off is null;

delete from layoffs_stagging_2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs_stagging_2;


-- lets drop the column row_num which we added to remove duplicates

alter table layoffs_stagging_2
drop column row_num;



-- Great! We are done the Data Cleaning and now we are ready to analyze our data.




