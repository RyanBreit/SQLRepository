Select *
from CovidDeaths
where continent is not null
order by 3,4

--Select *
--from CovidVaccinations
--order by 3,4

-- Selecting data 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

-- Looking at total deaths vs population

SELECT Location, date, total_cases, total_deaths, (total_deaths/Population)*100 as death_percent
from CovidDeaths
where Location like '%states'
order by 1,2

-- looking at total cases vs population 
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as CasePercent
from CovidDeaths
--where Location like '%states'
order by 1,2

-- Look at countries with highest infection rate compared to population

SELECT Location, Population, max(total_cases) as highestinfectioncount, max((total_cases/Population))*100 as PercentPopulationInfected
from CovidDeaths
--where Location like '%states'
Group by Population, Location
order by 4 desc

-- Countries with highest death count per population 

SELECT Location, max(cast(Total_deaths as bigint)) as totaldeathcount
from CovidDeaths
--where Location like '%states'
where continent is not null
Group by Location
order by totaldeathcount desc

SELECT Location, max(cast(Total_deaths as bigint)) as totaldeathcount
from CovidDeaths
--where Location like '%states'
where continent is not null
Group by Location
order by totaldeathcount desc

-- Global numbers

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as deathpercent--, total_deaths, (total_deaths/Population)*100 as death_percent
from CovidDeaths
--where Location like '%states'
where new_cases <> 0
--group by date
order by 1,2 


-- Looking at total popualtion vs vaccinations 

SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.Date) as rollingvaccination,
--(rollingvaccinated/population)*100
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
where dea.continent is not null
Order by 2,3

-- use CTE 

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, rollingvaccination)
as 
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.Date) as rollingvaccination
--, (rollingvaccinated/population)*100
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
where dea.continent is not null
--Order by 2,3
)
SELECT *, (rollingvaccination/Population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingvaccination numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.Date) as rollingvaccination
--, (rollingvaccinated/population)*100
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
where dea.continent is not null
--Order by 2,3


-- Creating a view to store data later 

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.Location order by dea.location, dea.Date) as rollingvaccination
--, (rollingvaccinated/population)*100
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
where dea.continent is not null
--Order by 2,3

SELECT *
FROM PercentPopulationVaccinated