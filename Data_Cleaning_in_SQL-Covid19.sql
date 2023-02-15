select *
from CovidDeaths
where continent is not null  
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases,
total_deaths, population
from CovidDeaths
order by 1,2

--looking at total cases vs total deaths (notably in Indonesia)

select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Indonesia%'
order by 1,2

--looking at total cases vs total population
--showing percentage of population got covid

select location, date, population, total_cases,
(total_cases/population)*100 as CasesPercentage
from CovidDeaths
where location like '%Indonesia%'
order by 1,2

--looking at countries with highest infection rate compared ot population

select location, population, max(total_cases) 
as HighestInfectionCount, max((total_cases/population))*100
as PercentPopulationInfected
from CovidDeaths
group by location,population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

select location, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

--breaking things down by continent

--showing the continents with highest death count per population

select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is null
group by continent
order by TotalDeathCount DESC


--Global numbers

select date, sum(new_cases) as TotaCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotaCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations
select *
from CovidVaccinations
order by location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Using Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Now_Vaccinations numeric,
RollingPeopleVaccinated numeric,) 

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select*
from PercentPopulationVaccinated