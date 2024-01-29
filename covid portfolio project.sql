Select *
from portfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from portfolioProject..CovidVaccinations
--order by 3,4

-- select data we will use

select location, date, total_cases, new_cases,total_deaths,population
from portfolioProject..CovidDeaths
order by 1,2


-- total cases vs total deaths
-- shows likelihood of dieing

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From portfolioProject..CovidDeaths
where location like '%ken%'
order by 1,2

-- total cases vs population
-- percentage of pop that got covid

select location, date,population, total_cases, (total_cases/population)*100 as Deathpercentage
From portfolioProject..CovidDeaths
--where location like '%ken%'
order by 1,2


-- countries with highest infection rate

select location, MAX(total_cases) as highestinfection,MAX (total_cases/population)*100 as percentagepopinfected
From portfolioProject..CovidDeaths
--where location like '%ken%'
group by location,population
order by percentagepopinfected desc


-- continent



-- showing continents with highest deaths per pop

select location, MAX(cast(total_deaths as int )) as totaldeathcount
From portfolioProject..CovidDeaths
--where location like '%ken%'
where continent is  null
group by location
order by totaldeathcount desc


-- GLOBAL NUMBERS
select date, sum(total_cases), sum(cast(new_deaths as int)), 
sum(cast(new_deaths as int))/ sum(new_cases) *100 as deathpercentage --,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From portfolioProject..CovidDeaths
--where location like '%ken%'
where continent is not null
group by date
order by 1,2



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
, dea.date) as rollingpeoplevaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with popvsvac (continent, location, date,population, new_vaccinations, rollingpeoplevaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location
, dea.date) as rollingpeoplevaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (rollingpeoplevaccinated/population)*100
from popvsvac



-- Temp table

create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location
, dea.date) as rollingpeoplevaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated



-- creating view to store data for visualization
 
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location
, dea.date) as rollingpeoplevaccinated
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select* 
from percentpopulationvaccinated