SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--SHows the Likelihood of dying if you contract Covud in your country

SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases,population,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at countries with Highest Infection Rates compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents which the highest death count per poplupation
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths ,SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
--total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths ,SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
--total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date

  SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2,3

SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--CONVERT (INT, ) is the same thing as CAST (  AS int)
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2,3

 

  --USE CTE
 WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) -- if the number of the columns in the CTE do not match the columns in the formula you will get an error
 AS (
 SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--CONVERT (INT, ) is the same thing as CAST (  AS int)
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
 -- ORDER BY 2,3 ORDER Clause cannot be in here
  )

  --The PercentagePopulationVaccinated column should continue to increase as the numbers on the New_Vaccinations, RollingPeopleVaccinated keep increasing
  SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePopulationVaccinated
  FROM PopvsVac

  --Maximum Percentage of Population Vaccinated per Country
SELECT location, population, MAX(cast(New_Vaccinations AS int)) AS TotalNew_Vaccinated, MAX(cast(RollingPeopleVaccinated AS int)) AS TotalRollingVaccinated, MAX((RollingPeopleVaccinated/population))*100 AS PercentagePopulationVaccinated
FROM PopvsVac
--WHERE location LIKE '%states%'
--WHERE continent IS NULL
GROUP BY location, population
ORDER BY PercentagePopulationVaccinated DESC

--TEMP table

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--CONVERT (INT, ) is the same thing as CAST (  AS int)
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
 -- WHERE dea.continent IS NOT NULL
 -- ORDER BY 2,3 

   SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePopulationVaccinated
  FROM #PercentPopulationVaccinated



  --Creating view to store data for later visualizations
  CREATE VIEW PercentPopulationVaccinated AS
  SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CONVERT (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated--CONVERT (INT, ) is the same thing as CAST (  AS int)
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 


SELECT *
  FROM PercentPopulationVaccinated