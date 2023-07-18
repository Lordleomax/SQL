SELECT*
FROM[dbo].[CovidDeaths]
WHERE continent IS NULL
Order By 3,4

--SELECT*
--FROM[dbo].[CovidVaccinations]
--Order by 3,4

--Select Data we are going to be using


SELECT [location],[date],[total_cases],[new_cases], [total_deaths],[population]
FROM CovidDeaths
WHERE continent IS NULL
ORDER BY location,date

--Formatting Data Types Correctly
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_deaths float

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_cases float

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN new_deaths float

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN [new_cases] float

--Loking at the Total Cases vs Total Deaths in %

SELECT [location],[date],[total_cases],[total_deaths], (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS  NULL
ORDER BY location,date

--Looking at the Total Cases vs The Population
--Shows what percentage of the population got covid

SELECT [location],[date],[population], [total_cases], (total_cases/[population])*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NULL
--WHERE location like '%states'
ORDER BY location,date

--Looking at Countries with the Highest Infection Rate compared to Population

SELECT [location],[population],[continent], MAX([total_cases]) AS HighestInfectionCount, MAX((total_cases/[population]))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NULL
--WHERE location like '%states'
GROUP BY population,location,continent
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population

SELECT [location],[continent], MAX([total_deaths]) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
--WHERE location like '%Nigeria'
GROUP BY location,continent
ORDER BY TotalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death counts

SELECT [continent], MAX([total_deaths]) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%Nigeria'
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT [date],
       SUM([new_cases]) AS TotalCases,
       SUM(CAST([new_deaths] AS INT)) AS TotalDeaths,
       CASE WHEN SUM([new_cases]) = 0 THEN NULL
            ELSE (SUM(CAST([new_deaths] AS INT)) / NULLIF(SUM([new_cases]), 0)) * 100
       END AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [date]
ORDER BY date,TotalCases DESC


--Looking at total Population vs Vaccinations 

SELECT Dea.continent, Dea.location, Dea.date,Dea.population,vac.new_vaccinations, 

CASE WHEN SUM (new_vaccinations) =0 THEN NULL
ELSE
SUM (CAST([new_vaccinations] AS int))
OVER (PARTITION BY[location] )
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations vac
ON 
Dea.location=vac.location
AND 
Dea.date=vac.date
WHERE dea.continent IS NOT NULL 
--AND dea.location  LIKE 'canada%'
ORDER BY
2,3

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
       CASE WHEN SUM(CAST(vac.new_vaccinations AS BIGINT)) = 0 THEN NULL
            ELSE SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY dea.location,dea.date)
       END AS RollingPeopleVaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations vac ON Dea.location = vac.location AND Dea.date = vac.date
WHERE Dea.continent IS NOT NULL 
AND Dea.location LIKE 'albania%'
GROUP BY Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
ORDER BY 2, 3

--USE CTE
WITH PopvsVac (Continent,Location, Date, Population, new_vaccinations, RollingPeopleVaccinations)
AS 
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
       CASE WHEN SUM(CAST(vac.new_vaccinations AS BIGINT)) = 0 THEN NULL
            ELSE SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY dea.location,dea.date)
       END AS RollingPeopleVaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations vac ON Dea.location = vac.location AND Dea.date = vac.date
WHERE Dea.continent IS NOT NULL 
--AND Dea.location LIKE 'albania%'
GROUP BY Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinations/Population)*100 PercentageVaccinated
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
       CASE WHEN SUM(CAST(vac.new_vaccinations AS BIGINT)) = 0 THEN NULL
            ELSE SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY dea.location,dea.date)
       END AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations vac ON Dea.location = vac.location AND Dea.date = vac.date
WHERE Dea.continent IS NOT NULL 
--AND Dea.location LIKE 'albania%'
GROUP BY Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 PercentageVaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
       CASE WHEN SUM(CAST(vac.new_vaccinations AS BIGINT)) = 0 THEN NULL
            ELSE SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY Dea.location ORDER BY dea.location,dea.date)
       END AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations vac ON Dea.location = vac.location AND Dea.date = vac.date
WHERE Dea.continent IS NOT NULL 
--AND Dea.location LIKE 'albania%'
GROUP BY Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
--ORDER BY 2, 3
