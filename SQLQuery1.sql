SELECT *
	FROM PortfolioProject..CovidDeaths
	ORDER BY 3,5

	--SELECT *
	--FROM PortfolioProject..CovidVaccinations
	--ORDER BY 3,4

	--Select data that were going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject..CovidDeaths
	ORDER BY 1,2

-- Total Cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage 
	FROM PortfolioProject..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2
		

-- Total Cases vs population
-- Who got covid
SELECT location, date, total_cases, population, (total_cases/population)* 100 as PopulationPercentage 
	FROM PortfolioProject..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2

-- Lokking at countries with highest infection rate compared to population
SELECT location, population, 
	   MAX(total_cases) as HighestInfectionCount,
	   MAX((total_cases/population)* 100) as HighestPopulationPercentage 
	FROM PortfolioProject..CovidDeaths
	GROUP BY location, population
	ORDER BY 4 desc 

-- Lokking at countries with highest death rate compared to population

SELECT location, population, 
	   MAX(cast(total_deaths as INT)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY location, population
	ORDER BY TotalDeathCount desc 

-- Breaking it down by continient 

SELECT continent,
	   MAX(cast(total_deaths as INT)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY continent
	ORDER BY TotalDeathCount desc 

--Global Numbers
SELECT  date,
	    SUM(new_cases) as total_cases,
		SUM(cast(new_deaths as INT)) as TotalDeaths,
		SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPrecentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY date
	ORDER BY 1,2

-- looking at total pop vs vac
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
	 as
(
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


)
SELECT *, (RollingPeopleVac/population)*100
FROM PopVSVac
ORDER BY 2,3

-- TEMP TABLE
DROP TABLE IF exists #PrecentPopVac
CREATE TABLE #PrecentPopVac
(
	continent nvarchar(255),
	location NVARCHAR(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVac numeric
)

INSERT INTO #PrecentPopVac
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (RollingPeopleVac/population)*100
FROM #PrecentPopVac
ORDER BY 2,3

-- creating visual
CREATE VIEW PercentPeopleVac AS
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null



select top 10 * from PercentPeopleVac