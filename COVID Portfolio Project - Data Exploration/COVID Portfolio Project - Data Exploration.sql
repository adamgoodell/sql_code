SELECT *
FROM [DevTest].[dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 3,4

-- SELECT *
--   FROM [DevTest].[dbo].[CovidVaccinations]
--   ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM DevTest..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you tracked covid in your country
SELECT location, date, total_cases, total_deaths, CONVERT(float,CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 as DeathPercentage
FROM DevTest..CovidDeaths
WHERE location LIKE '%states%'
AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got got covid
SELECT location, date, population, total_cases, CONVERT(float,CONVERT(float,total_cases)/CONVERT(float,population))*100 as PercentPopulationInfected
FROM DevTest..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with the Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float,CONVERT(float,total_cases)/CONVERT(float,population)))*100 as PercentPopulationInfected
FROM DevTest..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 

-- Showing Countries with the Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM DevTest..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- CONTINENT NUMBERS
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM DevTest..CovidDeaths
WHERE continent is null
AND location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC  

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM DevTest..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float)) / SUM(new_cases)*100 as DeathPercentage
FROM DevTest..CovidDeaths
WHERE continent is not null
AND location not like '%income%'
GROUP BY date
ORDER BY 1,2 

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DevTest..CovidDeaths dea
JOIN DevTest..CovidVaccinations vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DevTest..CovidDeaths dea
JOIN DevTest..CovidVaccinations vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
Select *, (CAST(RollingPeopleVaccinated as float) / population) * 100
From PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)
Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DevTest..CovidDeaths dea
JOIN DevTest..CovidVaccinations vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

Select *, (CAST(RollingPeopleVaccinated as float) / population) * 100
From #PercentPopulationVaccinated

-- Creating View to Store Data for later visualizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DevTest..CovidDeaths dea
JOIN DevTest..CovidVaccinations vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

Select *
From PercentPopulationVaccinated