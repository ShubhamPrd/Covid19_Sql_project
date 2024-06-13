SELECT location, date, total_cases,new_cases, total_deaths, population
FROM ProjectGIT1.dbo.CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths in INDIA
-- Shows likelihood of dying if you contract Covid in your Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage	
FROM ProjectGIT1.dbo.CovidDeaths$
WHERE location='INDIA'
ORDER BY 1,2


-- Looking at Total Cases VS Population in INDIA
-- Shows what Percentage of Population gat Covid

SELECT location, date, total_cases, population, (population/total_cases)*100 AS PercentagePopulationInfected
FROM ProjectGIT1.dbo.CovidDeaths$
WHERE location='INDIA'
ORDER BY 1,2


--LOOKING AT Countries with the Highest Infection rate compared to Population
-- Showing Countries With the Highest Infection rate Per Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_deaths/total_cases))*100 AS PercentagePopulationInfected
FROM ProjectGIT1.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


-- LOOKING AT Countries with the Highest Death Rate 

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotaldDeathCount
FROM ProjectGIT1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotaldDeathCount DESC


-- Looking at Continents with the Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotaldDeathCount
FROM ProjectGIT1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotaldDeathCount DESC

-- Global Values

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM ProjectGIT1.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Perpentage VS Vaccinations

SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectGIT1.dbo.CovidDeaths$ AS dea
Join ProjectGIT1.dbo.CovidVaccinations$ AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


-- USING CTE

WITH PopvsVac( continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectGIT1.dbo.CovidDeaths$ AS dea
Join ProjectGIT1.dbo.CovidVaccinations$ AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( Continent varchar(255),
Location nvarchar(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectGIT1.dbo.CovidDeaths$ AS dea
Join ProjectGIT1.dbo.CovidVaccinations$ AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT*,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to Store Data for Later Visualition 

CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectGIT1.dbo.CovidDeaths$ AS dea
Join ProjectGIT1.dbo.CovidVaccinations$ AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated
