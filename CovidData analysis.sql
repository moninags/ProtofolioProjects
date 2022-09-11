Select *
From protofolioproject..CovidDeaths
where continent is not null
order by 3,4


Select *
From protofolioproject..CovidVaccinations
order by 3,4


Select location, date, total_cases, new_cases, total_deaths,population
From protofolioproject..CovidDeaths
order by 1,2

--toal Cases vs total death
--shows covid cases by country

Select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as Death_percentage
From protofolioproject..CovidDeaths
where location like '%India%'
and total_deaths is not null
order by 1,2

-- total cases vs population

Select location, date, total_cases,population,
(total_cases/population)*100 as populationinfected
From protofolioproject..CovidDeaths
--where location like '%India%'
order by 1,2

--Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases)as HighestInfectionCount,
MAX((total_cases/population))*100 as Percentpopulationinfected
From protofolioproject..CovidDeaths
Group by location, population
order by Percentpopulationinfected desc

--Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotaldeathCount
From protofolioproject..CovidDeaths
where continent is not null
Group by location
order by Totaldeathcount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
From protofolioproject..CovidDeaths
where continent is not null
Group by continent
order by Totaldeathcount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From protofolioproject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From protofolioproject..CovidDeaths dea
join protofolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From  protofolioproject..CovidDeaths dea
join protofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


--temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From protofolioproject..CovidDeaths dea
join protofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From protofolioproject..CovidDeaths dea
join protofolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
select*
from PercentPopulationVaccinatedd