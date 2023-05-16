--looking at Total Cases vs Total Deaths
--Percentage of likelihood of deaths in your country

select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'

--looking at total cases vs population
--Shows what percentage of population got covid

select location,date, population,total_cases, (total_cases/population)*100 as PopulationPercentInfected
from CovidDeaths
where location like '%states%'


--looking at countries with highest infection rate

select location, population,max(total_cases) as HighestInfectedCount, max((total_cases/population))*100 as HighestInfectedPercent
from CovidDeaths
where population is not null
group by location,population
order by 4 desc


--looking at countries with highest death count per population

select location, 
max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- looking at continents with highest death count

select continent, 
max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2


-- Total Popualtions vs Total Vaccinations
--using CTE

with PopvsVac(continent,location,date,population,new_vaccinations,TotalVacCount)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as TotalVacCount
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(TotalVacCount/population)*100
from PopvsVac


--Temp Table

drop table if exists #TotalPeopleVaccinated
create table #TotalPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVacCount numeric
)

insert into #TotalPeopleVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as TotalVacCount
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.population is not null

select *,(TotalVacCount/population)*100 as VaccinatedPercent
from #TotalPeopleVaccinated


-- Creating view for using later as visualization

create view TotalPeopleVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as TotalVacCount
from CovidDeaths dea
join CovidVaccines vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.population is not null


select * from TotalPeopleVaccinated
