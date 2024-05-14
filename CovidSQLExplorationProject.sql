--Exploring Data from CovidDeaths data_set
SELECT *
FROM PortfolioProject..CovidDeaths

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%egypt%' AND continent IS NOT NULL
ORDER BY location,date

--looking at (total cases vs total deaths) death percentage
--Shows likelihood of dying if you contract covid in Egypt
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'egypt' AND continent IS NOT NULL 
ORDER BY location,date

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid 
SELECT Location, date,population, total_cases,
(total_cases/population)*100 AS AffectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'egypt' AND continent IS NOT NULL 
ORDER BY location,date

-- Countries with Highest Infection Rate compared to Population
SELECT Location,population,MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population)*100) AS AffectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location,population 
ORDER BY AffectedPopulationPercentage DESC

--Countries with Highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS INT)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeathCount  DESC

--Countries with Highest Death Count per Population Percentage
SELECT location,SUM(total_cases)AS TotalCasesCount,SUM(CAST(total_deaths AS INT)) AS TotalDeathsCount ,population,
(SUM(CAST(total_deaths AS INT))/population)*100 AS HighestDeathCountPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestDeathCountPercentage DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeathCount  DESC

-- Global Numbers For New Cases And New Deaths
-- New death percentage (new_death,new_cases)
SELECT date,SUM(new_cases) AS NewCasesCount,SUM(CAST(new_deaths AS INT)) AS NewDeathsCount,
(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Total Population vs Daily Increasing New Total Vaccinations 
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalNewVaccinations
FROM PortfolioProject..CovidVaccinations vac
INNER JOIN PortfolioProject..CovidDeaths dea
ON vac.location=dea.location
AND vac.date=dea.date
WHERE dea.continent IS NOT NULL


-- Using CTE to Calculate Total New Vaccinations for each day VS Population 
WITH DailyTotalNewVaccinations (continent,location,date,population,new_vaccinations,TotalNewVaccinations)
AS (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalNewVaccinations
FROM PortfolioProject..CovidVaccinations vac
INNER JOIN PortfolioProject..CovidDeaths dea
ON vac.location=dea.location
AND vac.date=dea.date
WHERE dea.continent IS NOT NULL
)

SELECT *,(TotalNewVaccinations/population)*100 AS NewVaccinationsVsPopulation
FROM DailyTotalNewVaccinations


-- Using Temp Table to Calculate Total New Vaccinations for each day VS Population 
DROP TABLE IF EXISTS #DailyTotalNewVaccinationS
CREATE TABLE #DailyTotalNewVaccinations 
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalNewVaccinations numeric
)

INSERT INTO #DailyTotalNewVaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalNewVaccinations
FROM PortfolioProject..CovidVaccinations vac
INNER JOIN PortfolioProject..CovidDeaths dea
ON vac.location=dea.location
AND vac.date=dea.date
WHERE dea.continent IS NOT NULL

SELECT *,(TotalNewVaccinations/population)*100 AS NewVaccinationsVsPopulation
FROM #DailyTotalNewVaccinations


--Creating View to store data for later visualizations
CREATE VIEW DailyTotalNewVaccinations AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalNewVaccinations
FROM PortfolioProject..CovidVaccinations vac
INNER JOIN PortfolioProject..CovidDeaths dea
ON vac.location=dea.location
AND vac.date=dea.date
WHERE dea.continent IS NOT NULL

