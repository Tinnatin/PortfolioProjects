Select * from dbo.CovidDeaths$
where continent is not null
order by 3,4

--Select * from dbo.CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
from dbo.CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid in your country
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from dbo.CovidDeaths$
where continent is not null
--where location like '%states%'
order by 1,2

--Looking at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as CasePercentage
from dbo.CovidDeaths$
where continent is not null
Group by location, population
order by CasePercentage desc

--Let's break things down by continent

--Looking at continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
Select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccinations


Select *
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100 as RollingVaccPercentage
from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 as RollingVaccPercentage
from PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime, 
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as RollingVaccPercentage
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated