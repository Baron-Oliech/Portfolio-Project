select*
from [Portfolio Project]..[Covid-Deaths]
where continent is not null
Order by 3,4


--select*
--from [Portfolio Project]..[Covid-Vaccinations]
--Order by 3,4

select location, date, total_cases,total_deaths, population
from [Portfolio Project]..[Covid-Deaths]
Order by 1,2

---Looking at Total Cases vs Total Deaths
select location, date, total_cases,total_deaths,cast(total_deaths AS int)/cast(total_cases AS int)
from [Portfolio Project]..[Covid-Deaths]
Order by 1,2

select*
from [Portfolio Project]..[Covid-Deaths]

exec sp_help '[Portfolio Project]..[Covid-Deaths]'

select location, date, total_cases,population,(total_deaths/population)*100 as CovidPercetage
from [Portfolio Project]..[Covid-Deaths]
where location like '%kenya%'
Order by 1,2

---Lookig countries with highest infection rate compared to population

select location,population ,MAX( total_cases) AS HighestInfectionCount,MAX(total_deaths/population)*100 as PercentPopulationInfected
from [Portfolio Project]..[Covid-Deaths]
--where location like '%kenya%'
where continent is not null
Group by location,population
Order by PercentPopulationInfected desc


--Showing countries with the highest Death count per population

select location, MAX(cast(total_deaths AS int)) as TotalDeathsCount
from [Portfolio Project]..[Covid-Deaths]
--where location like '%kenya%'
where continent is not null
Group by location
Order by TotalDeathsCount desc

---LET'S BREAK THINGS BY  CONTINENT
---Showing the Continents with the highest death count per population

select continent, MAX(cast(total_deaths AS int)) as TotalDeathsCount
from [Portfolio Project]..[Covid-Deaths]
--where location like '%kenya%'
where continent is not null
Group by continent
Order by TotalDeathsCount desc

select location, MAX(cast(total_deaths AS int)) as TotalDeathsCount
from [Portfolio Project]..[Covid-Deaths]
--where location like '%kenya%'
where continent is null
Group by location
Order by TotalDeathsCount desc

---Global numbers

select  date, total_cases,total_deaths,cast(total_deaths AS int) / cast(total_cases AS int )
from [Portfolio Project]..[Covid-Deaths]
where continent is  not null
Group by date
Order by 1,2

select  SUM(new_cases)as TotalCases,SUM(new_deaths)  as TotalDeaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..[Covid-Deaths]
where continent is  not null
--Group by date
Order by 1,2

---Looking at Total Population Vs Vaccination

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations  )) over (partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinate
from [Portfolio Project]..[Covid-Deaths] dea
join [Portfolio Project]..[Covid-Vaccinations] vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	Order by 2,3

---USE CTE
WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations  )) over (partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid-Deaths] dea
join [Portfolio Project]..[Covid-Vaccinations] vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)

select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


---TEMP TABLE
Drop table if exists #PercentagePopulationVacc
Create Table #PercentagePopulationVacc
(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVacc
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations  )) over (partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid-Deaths] dea
join [Portfolio Project]..[Covid-Vaccinations] vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentagePopulationVacc

---Creating views to store data for later use

create view PercentagePopulationVacc as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations  )) over (partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..[Covid-Deaths] dea
join [Portfolio Project]..[Covid-Vaccinations] vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,

Select*
From PercentagePopulationVacc