SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

/*SELECT * 
FROM CovidVaccinations
ORDER BY 3, 4
*/

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
ORDER BY 1, 2

-- daily total cases vs total deaths
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	CAST(total_deaths/total_cases *100 AS decimal(18,2)) as death_rate
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


-- Final total cases vs total deaths
SELECT
	location,
	max(total_cases) AS total_cases,
	max(total_deaths) AS total_deaths,
	CAST(max(total_deaths)/max(total_cases)*100 AS decimal(18,2)) as death_rate
FROM CovidDeaths
GROUP BY location
ORDER BY 1

-- Total cases vs population
-- show what percentage of population got covid
SELECT
	location,
	date,
	total_cases,
	population,
	CAST(total_cases/ population * 100 AS DECIMAL(18,2)) AS infection_rate
FROM CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1, 2


-- looking at countries with highest infection rate to population
SELECT
	location,
	MAX(total_cases) AS highest_infection_count,
	population,
	CAST(MAX(total_cases/ population * 100) AS DECIMAL(18,2)) AS infection_rate
FROM CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY 4 DESC

-- Highest death count by countries
SELECT
	location,
	MAX(cast(total_deaths as int)) AS total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


-- Highest death count by continent
SELECT
	continent,
	MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global numbers
SELECT
	--date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- looking at total population and vaccination
SELECT 
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.date) AS total_vaccinations
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.date = V.date and D.location=V.location
WHERE D.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopVSVac AS(
	SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.date) AS rolling_people_vaccinated
	FROM CovidDeaths D
	JOIN CovidVaccinations V 
		ON D.date = V.date and D.location=V.location
	WHERE D.continent IS NOT NULL
	)

SELECT 
	*,
	CAST(rolling_people_vaccinated / population * 100 AS DECIMAL(18,2)) AS vaccination_rate
FROM PopVSVac
ORDER BY 2,3


-- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	DATE datetime,
	Population numeric,
	New_vaccinations numeric,
	Rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.date) AS rolling_people_vaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.date = V.date and D.location=V.location
WHERE D.continent IS NOT NULL

SELECT 
	*,
	CAST(rolling_people_vaccinated / population * 100 AS DECIMAL(18,2)) AS vaccination_rate
FROM #PercentPopulationVaccinated
ORDER BY 2,3


-- Create VIEW to store data for later for visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.date) AS rolling_people_vaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V 
	ON D.date = V.date and D.location=V.location
WHERE D.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated

