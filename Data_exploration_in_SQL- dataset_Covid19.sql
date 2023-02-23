--Combining Two Separated Tables into One (CovidDeaths01$ and CovidDeaths02$) and Selecting Useful Data
--It is necessary to do because the dataset for CovidDeaths cannot be put in one xls data

select iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
from CovidDeaths01$
union
select iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
from CovidDeaths02$

drop table if exists #Temp_CovidDeaths
create table #Temp_CovidDeaths
(iso_code nvarchar(255), continent nvarchar(255), location nvarchar(255), Date datetime, population float, total_cases float
, new_cases float, total_deaths float, new_deaths float)

insert into #Temp_CovidDeaths
select iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
from CovidDeaths01$
union
select iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
from CovidDeaths02$

select*
from #Temp_CovidDeaths
--where iso_code is null
order by location



--Combining Two Separated Tables into One (CovidVaccinations01$ and CovidVaccinations02$) and Selecting Useful Data
--It is necessary to do because the dataset for CovidVaccinations cannot be put in one xls data

select*
from Covidvaccinations01$
--where iso_code is null
--order by location

select *
from Covidvaccinations02$

drop table if exists #Temp_CovidVac
create table #Temp_CovidVac
(iso_code nvarchar(255), continent nvarchar(255), location nvarchar(255), Date datetime, new_tests float, total_tests float
, total_vaccinations float, people_vaccinated float, people_fully_vaccinated float, new_vaccinations float, median_age float
, aged_65_older float, aged_70_older float)

insert into #Temp_CovidVac
select iso_code, continent, location, date, new_tests, total_tests, total_vaccinations, people_vaccinated 
, people_fully_vaccinated , new_vaccinations, median_age, aged_65_older, aged_70_older
from CovidVaccinations01$
union
select iso_code, continent, location, date, new_tests, total_tests, total_vaccinations, people_vaccinated 
, people_fully_vaccinated , new_vaccinations, median_age, aged_65_older, aged_70_older
from CovidVaccinations02$

select*
from #Temp_CovidVac



--Looking at Deaths Percentage (country: Indonesia)

select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from #Temp_CovidDeaths
where location like '%Indonesia%'
order by 1,2



--Looking at Total Cases vs Total Population (Country: Indonesia)
--Presenting Percentage of Infected population

select location, date, population, total_cases,
(total_cases/population)*100 as CasesPercentage
from #Temp_CovidDeaths
where location like '%Indonesia%'
order by 1,2



--Presenting Countries with Highest Infection Rate Compared to Population

select location, population, max(total_cases) 
as HighestInfectedCountry, max((total_cases/population))*100
as InfectedPopulationPercentage
from #Temp_CovidDeaths
group by location,population
order by InfectedPopulationPercentage desc


--Presenting Countries with Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from #Temp_CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



--Breaking Things down by Continent
--Presenting the Continents with Highest Death Count per Population

select continent, max(total_deaths) as TotalDeathCount
from #Temp_CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC



--Presenting Death Percentage in Global Scale

select sum(new_cases) as TotaCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from #Temp_CovidDeaths
where continent is not null
--group by date
order by 1,2



--Presenting Total Population vs Vaccinations Globally

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from #Temp_CovidDeaths dea
join #Temp_CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select*
from #Temp_CovidVac


--Presenting Percentage of Fully Vaccinated People

select dea.location, dea.Date, dea.population,
(vac.people_vaccinated/dea.population)*100 as VaccinationRate
from #Temp_CovidDeaths dea
join #Temp_CovidVac vac
	on dea.iso_code = vac.iso_code
--where dea.continent is not null
--where location like '%Indonesia%'
order by 1,2

select dea.location, dea.date, dea.population, vac.people_vaccinated,
(vac.people_vaccinated/dea.population)*100 as VaccinationRate
from #Temp_CovidDeaths dea
join #Temp_CovidVac vac
	on dea.iso_code = vac.iso_code
where dea.location like '%Indonesia%'
order by 1,2

select dea.location, dea.Date, dea.population,vac.people_fully_vaccinated,
(vac.people_fully_vaccinated/dea.population)*100 as FullyVaccinationRate
from #Temp_CovidDeaths dea
join #Temp_CovidVac vac
	on dea.iso_code = vac.iso_code
--where dea.continent is not null
--where location like '%Indonesia%'
order by 1,2

select dea.location, dea.date, dea.population, vac.people_fully_vaccinated,
(vac.people_fully_vaccinated/dea.population)*100 as FullyVaccinationRate
from #Temp_CovidDeaths dea
join #Temp_CovidVac vac
	on dea.iso_code = vac.iso_code
where dea.location like '%Indonesia%'
order by 1,2



--Deleting Unused Rows

select *
from #Temp_CovidDeaths
--where continent is null
order by location

delete
from #Temp_CovidDeaths
where continent is null

select *
from #Temp_CovidVac
order by location

delete
from #Temp_CovidVac
where continent is null
