SELECT*
FROM PortfolioProject.. Coviddeaths$
WHERE continent is not null
order by 3,4

--SELECT*
--FROM PortfolioProject..covidvaccinations$
--order by 3,4

--selecting data that were using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.. Coviddeaths$
order by 1,2

--Looking at total cases vs total deaths

-- changed the data type of total deaths and total cases to float.
ALTER TABLE PortfolioProject.. Coviddeaths$
ALTER COLUMN total_cases float

-- shows likelihoood of dying if tyou contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject.. Coviddeaths$
WHERE location like '%Kenya%'
order by 1,2

--Looking at total cases vs population
-- shows what percentage got covidd

Select location, date, total_cases, population, (total_cases / population)*100 as PopulationPercentage
From PortfolioProject.. Coviddeaths$
--WHERE location like '%Kenya%'
order by 1,2


--Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases / population))*100 as PopulationPercentageInfected
From PortfolioProject.. Coviddeaths$
--WHERE location like '%Kenya%'
GROUP BY Location, population
order by PopulationPercentageInfected desc


-- Showing countries with highest death count per population
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.. Coviddeaths$
--WHERE location like '%Kenya%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount desc


--BREAKING THINGS UP BY CONTINENT

--Showing continents with highest death count
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.. Coviddeaths$
--WHERE location like '%Kenya%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.. Coviddeaths$
--WHERE location like '%Kenya%'
Where continent is not null and new_cases <> 0
GROUP BY date
order by 1,2


SELECT*
FROM PortfolioProject.. covidvaccinations$

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. Coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
 Where dea.continent is not null
 order by 2,3

 --USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. Coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
 Where dea.continent is not null
 --order by 2,3
 )
 SELECT* , (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac

 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric,
 )

 Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. Coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
 Where dea.continent is not null

 SELECT* , (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated



 --Creating View to store data for later visualizations

 Create View PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. Coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
   On dea.location = vac.location 
   and dea.date = vac.date
 Where dea.continent is not null