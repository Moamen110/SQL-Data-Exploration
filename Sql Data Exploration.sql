select * 
from [portfolio project]..CovidDeaths
order by 3,4

--select * 
--from [portfolio project]..CovidVaccinations
--order by 3,4

--selecting data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..CovidDeaths
order by 1,2



--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathperecentage
from [portfolio project]..CovidDeaths
where location like '%states%'
where continent is not null
order by 1,2


--looking at total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected	
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2



--looking at countries with highest infection rate copared to population 

select location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases/population)*100 as percentpopulationinfected
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by percentpopulationinfected desc



--countries with hihgest death count per population

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc



--break things using continent

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc



--looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


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
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
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
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



select * 
from PercentPopulationVaccinatedd