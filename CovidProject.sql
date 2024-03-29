-- Select data we are going to be working on
select location,continent, date, total_cases, new_cases, total_deaths, population
from SQLPROJECT..CovidDeaths$
order by 1,2

-- Looking at Total cases vs Total deaths
select location ,continent ,date, total_cases, total_deaths, (total_deaths/total_cases)*100 Deathperccentage
from SQLPROJECT..CovidDeaths$
where location like '%Africa%'
order by 1,2

--Looking at total cases vs population
-- Shows what % of population has gotten covid
select location,continent, date, total_cases, population, (total_cases/population)*100 Deathperccentage
from SQLPROJECT..CovidDeaths$
where location like '%Africa%'
order by 1,2

-- Looking at location with highest infection rate compared to population
select location,continent, MAX(total_cases) HighestInfectionCount, population, Max((total_cases/population))*100 PercentPopulationInfected
from SQLPROJECT..CovidDeaths$
where location like '%Africa%'
group by population, location, continent
order by 1,2

--Showing continents with Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) HighestDeathCount
from SQLPROJECT..CovidDeaths$
--where location like '%Africa%'
where total_deaths is not null and continent is not null
group by continent
order by HighestDeathCount desc


--GLOBAL NUMBERS
select SUM(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/SUM(new_cases)*100 Deathpercentage
from SQLPROJECT..CovidDeaths$
where continent is not null
--group by date
order by 1,2


--select CD.continent, cd.location, CD.date, cd.population, cv.new_vaccinations
--, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location, cd.date ) 
----or sum(cast(int, cv.new_vaccinations)) over (partition by cd.location)
--from SQLPROJECT..CovidDeaths$ as CD
--join SQLPROJECT..CovidVaccinations$ as CV
--	on CD.location = CV.location
--	and CD.date = CV.date
--where cd.continent is not null
--order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPROJECT..CovidDeaths$ dea
Join SQLPROJECT..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

--Using temp table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPROJECT..CovidDeaths$ dea
Join SQLPROJECT..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating a view to store data for tableau

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLPROJECT..CovidDeaths$ dea
Join SQLPROJECT..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 