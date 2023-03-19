SELECT *
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null -- erre azért van szükség mert csak országokat akarunk látni de vannak csoportosítások mint pl: Europe
ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..Covid_Vaccinations
--ORDER BY 3,4

-- SELECT THE DATA THAT WE ARE GOING TO BE USING

SELECT location, date,total_cases,new_cases,total_deaths,population
FROM Portfolio_Project..Covid_Deaths
ORDER BY 1,2

-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS
-- SHOW THE LIKELIHOOD OF DEATH IN COUNTRY TROGHOUT TIME (?)
SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_Project..Covid_Deaths
WHERE location = 'Hungary'
ORDER BY 1,2

-- LOOKING AT THE TOTAL CASES VS POPULATION
-- SHOWS THE PERCENTAGE OF POPULATION GOT COVID
SELECT location, date,population,total_cases, (total_cases/population)*100 AS Infected_Percentage
FROM Portfolio_Project..Covid_Deaths
WHERE location = 'Hungary'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 AS PopulationInfected_Percentage
FROM Portfolio_Project..Covid_Deaths
GROUP BY location, population
ORDER BY PopulationInfected_Percentage DESC

-- SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null -- erre azért van szükség mert csak országokat akarunk látni de vannak csoportosítások mint pl: Europe
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT
-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT
-- NOTE TO SELF: CREATE VIEW
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
where continent is not null 
--GROUP BY date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLe
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
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 