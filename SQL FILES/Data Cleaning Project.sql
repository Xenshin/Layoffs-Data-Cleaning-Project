-- DATA CLEANING

SELECT *
FROM layoffs;

-- NEED TO CREATE THE STAGING DATABASE

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;


-- REMOVE DUPLICATES
-- BUT FOR THAT WE NEED TO CREATE ROW NUMBERS

SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;


--  Lets Create CTE's to filter out the records which has row number > 1

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- as Delete statement doesn't work on CTE's
-- So we need to create the staging_2 data for the same, which will contain the row_num column as default.

CREATE TABLE `layoffs_staging_2` (
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

SELECT *
FROM layoffs_staging_2;

-- LETS INTSERT THE DATA INTO LAYOFFS_STAGING_2 TABLE
INSERT INTO layoffs_staging_2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging_2;

-- NOW LET'S DELETE THE DUPLICATES

DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging_2
WHERE row_num > 1;

-- STANDARDIZING THE DATA

-- -------------------------------- TRIMMING THE COMPANY COLUMN
UPDATE layoffs_staging_2
SET company = TRIM(company);

SELECT company
FROM layoffs_staging_2;

-- -------------------------------- INDUSTRY COLUMN
SELECT DISTINCT industry
FROM layoffs_staging_2;

-- --------------------------------- LET'S SORT THE COLUMN FIRST
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY(1);

-- --------------------------------- UPDATE THE INDUSTRY COLUMN (CRYPTO)
UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY(1);

-- --------------------------------- LOCATION COLUMN IS ALL GOOD
SELECT DISTINCT location
FROM layoffs_staging_2
ORDER BY(1);

-- --------------------------------- COUNTRY COLUMN CHECKING
SELECT DISTINCT country
FROM layoffs_staging_2
ORDER BY(1);

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging_2
ORDER BY(1);

-- updating the column
UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%.';

-- ----------------------------------- DATE COLUMN
SELECT `date`
FROM layoffs_staging_2;

-- ---------------------------------Now let's format the date
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging_2;

-- FINAL UPDATE OF DATE COLUMN
UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- MODIFY THE DATA TYPE OF THE DATE COLUMN
ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

-- ------------------------------------------------FILL THE MISSING OR NULL VALUES
-- AS WE KNOW WE CANNOT JUST RANDOMLY REPLACE BLANK VALUES, SO LET'S FIRST CONVERT THESE INTO NULL VALUES

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

-- ------------------------------------------AS THERE WILL BE MANY SITUATIONS WHERE THE SAME COMPANY WOULD HAVE MADE LAYOFFS AND IN ONE RECORD THE NAME IS MISSING AND IS PRESENT IN THE OTHER RECORD
-- -------------------------- Because for one company the layoff could have been done multiple times, then too its not going to change few of the associated labels like the industry of the company.
SELECT t1.industry, t2.industry
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- ------------ NOW LETS UPDATE THE MISSING VALUE OF THE RECORDS WITH THE AVAILABLE DATA IN THE DATASET
UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- ------------------------------------------------LETS CHECK IT OUT
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY(1);


-- ------------------------- FOR OTHER NULL VALUES, WE HAVE NO SUPPORTING DATA LIKE CHECK THE COLUMNS ON THE NO. OF LAYOFFS AND PERCENTAGE OF LAYOFFS
SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- ---------------------------------------- IF WE COULD HAVE KNOWN THE TOTAL NO. OF EMPLOYEES BEFORE LAYOFFS, AND THEN EITHER WITH PERCENTAGE LAYOFFS OR TOTAL LAID OFFS WE COULD HAVE TAKEN OUT THE OTHER MISSING VALUES
-- BUT THAT'S NOT POSSIBLE IN THIS CASE, SO WE HAVE NO CHOICE BUT TO DELETE THE DATA

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 361 ROWS HAVE BEEN DELETED THAT'S A LOT OF DATA :(

-- -------------------- LET'S LOOK AT THE FINAL DATASET
SELECT *
FROM layoffs_staging_2;

-- ------------------------ ohhhhh we still have that column `row_num`, we don't need it anymore so let's get rid of that
ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- SO THIS DATA IS PROPERLY CLEANED AND READY FOR OUR NEXT PROJECT EXPLORATORY DATA ANALYSIS












