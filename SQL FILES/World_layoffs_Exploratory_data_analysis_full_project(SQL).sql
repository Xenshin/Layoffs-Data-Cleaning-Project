-- EXPLORATORY DATA ANALYSIS
SELECT *
FROM layoffs_staging_2;

-- -------------
SELECT MAX(total_laid_off)
FROM layoffs_staging_2;

-- maximum percentage of people being laid off
SELECT MAX(percentage_laid_off)
FROM layoffs_staging_2;

-- let's check which all companies completely shut down with 'percentage_laid_off' equal to 1.
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1;

-- let's order the companies which have completely shut down to see which 'laid of maximum people and shut itself down'
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- let's see the total of employees laid off by each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

-- Let's see when is this data from, is it even relevant?
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2;

-- Now let's see which industry was most hit during this period
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

-- looking at the country which laid of most employee could be useful to get few insights
SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

-- let's look at the layoff trend by the each individual year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- -----------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------

-- Rolling Sum of the employees being laid off
-- -------------
-- LET'S SEE HOW MANY PEOPLE LOST THEIR JOB EACH MONTH OF THE YEARS
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

-- LET'S SEE THE ROLLING SUM
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, total_off, SUM(total_off) OVER(ORDER BY `month`) AS Running_total
FROM Rolling_Total;


-- ---- let's group the companies with the year to understand the trend of layoff in the companies

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

-- let's rank the data for each company, like for each individual company lets rank in which year they laid of the most people
WITH company_year (company, `year`, laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY laid_off DESC) AS Ranking
FROM company_year
WHERE `year` IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE Ranking <= 5;









