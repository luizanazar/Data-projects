

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM `vocal-orbit-397718.1234.covid_deaths`
WHERE continent is not null
ORDER BY 1,2;


--Looking at the total cases VS Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `vocal-orbit-397718.1234.covid_deaths`
WHERE location LIKE '%States%'
ORDER BY 1,2;

--Looking at the Total Cases VS Population
-- Shows what percentage of population got covid
SELECT Location, date,population,  total_cases,  (total_cases/population)*100 as InfectedPercentage
FROM `vocal-orbit-397718.1234.covid_deaths`
-- WHERE location LIKE '%States%'
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate compared to population
SELECT Location, population,  MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `vocal-orbit-397718.1234.covid_deaths`
-- WHERE location LIKE '%States%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;

--Showing the countries with the Highest Death Count per Population


SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM `vocal-orbit-397718.1234.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int64)) AS TotalDeathCount
FROM `vocal-orbit-397718.1234.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT
  SUM(new_cases) as total_cases,
  SUM(CAST(new_deaths AS INT64)) as total_deaths,
  CASE
    WHEN SUM(new_cases) > 0 THEN (SUM(CAST(new_deaths AS INT64)) / SUM(new_cases)) * 100
    ELSE 0  -- Handle division by zero by setting DeathPercentage to 0 when there are no new cases
  END AS DeathPercentage
FROM `vocal-orbit-397718.1234.covid_deaths`
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;



--Looking at Total Population VS Vaccinations

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM
    `vocal-orbit-397718.1234.covid_deaths` AS dea
  JOIN
    `vocal-orbit-397718.1234.covid_vaccinations` AS vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2,3;


-- USE CTE
WITH PopvsVac AS
(
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM
    `vocal-orbit-397718.1234.covid_deaths` AS dea
  JOIN
    `vocal-orbit-397718.1234.covid_vaccinations` AS vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT
  *,
  (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM
  PopvsVac;

-- Creating View to store data for later visualizations
CREATE OR REPLACE VIEW `vocal-orbit-397718.1234.GlobalDeathPercentage` AS
SELECT
  SUM(new_cases) as total_cases,
  SUM(CAST(new_deaths AS INT64)) as total_deaths,
  CASE
    WHEN SUM(new_cases) > 0 THEN (SUM(CAST(new_deaths AS INT64)) / SUM(new_cases)) * 100
    ELSE 0  -- Handle division by zero by setting DeathPercentage to 0 when there are no new cases
  END AS DeathPercentage
FROM `vocal-orbit-397718.1234.covid_deaths`
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;
