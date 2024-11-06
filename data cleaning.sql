-- Removing extra spaces and trailing
	update layoff set company =trim(company),
	location = trim(location),
	stage = trim(stage),
	country = trim(country),
    location = trim( trailing "." FROM  location),
    country = trim(trailing "." from country);

-- typo check
	update layoff 
	set location = CASE
	when location like "Shen%" then  "Shenzhen"
	when location like "Beau%" then  "Beau Villon"
	when location like "fer%" then  "Fredericton"
	when location like "mal%" then  "Malama"
	when location like "flor%" then "florianopolis"
	when location like "DÃ¼sseldorf" then "Düsseldorf"
	else location
	END;

-- converting blank to null values
	update layoff set industry = null 
	where industry = "";

-- created new table to add count column and to delete duplicates
	CREATE TABLE `layoff_duP` (
	  `company` text,
	  `location` text,
	  `industry` text,
	  `total_laid_off` int DEFAULT NULL,
	  `percentage_laid_off` text,
	  `date` text,
	  `stage` text,
	  `country` text,
	  `funds_raised_millions` int DEFAULT NULL,
	  `count_no` int
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- inserted values from layoff
	insert into layoff_dup select * , row_number() over(partition by company,
	location,
	industry,
	total_laid_off,
	percentage_laid_off,
	stage,
	country,
	funds_raised_millions,
	`date`
	) as count from layoff_data.layoff;

-- deleted duplicate values
	delete FROM layoff_data.layoff_dup
	where count_no > 1;
    alter table layoff_dup drop column count_no;
    
-- delete null values of total_laid_off & percenatge_laid_off
	Delete FROM layoff_data.layoff_dup
	where total_laid_off is null and percentage_laid_off is null;

-- dealt with null values
	update layoff_dup as t1
	join layoff_dup as t2 on t1.company = t2.company
	set t1.industry = t2.industry
	where t1.industry is null and t2.industry is not null;
    
-- converting date (text) to (date)
	UPDATE layoff_dup
	SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");
    alter table layoff_dup modify column `date` date;











