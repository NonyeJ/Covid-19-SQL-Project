----Confirm tables have been correctly uploaded--check data uniformity.
SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM [Portfolio Project]..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select primary data to be used
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Examine total cases vs total deaths as per the country
--Shows likelyhood of death in the case of covid contraction in Nigeria

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DatePercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2


--Now, examine total cases vs the population. What population got covid?
SELECT location,date,population,total_cases,(total_cases/population)*100 AS Death_Population_Percentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2

--Which countries have higher infection rate compared to their population?
SELECT location,population, MAX(total_cases) AS Higest_Infection_Count, MAX(total_cases/population)*100 AS Percentage_Population_Infected
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Percentage_Population_Infected desc

--Highest death count per country's population. Continent has been queried to exclude 'Null' so  'Location' & 'contininet can run independently. Visualization is also, efficient this way.
SELECT location,population, MAX(CAST(total_deaths as int)) AS Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Total_Death_Count desc

--Different the above query be contininet. -- This query isn't best practice because it excludes some figures that this data set cartegorizes as continent but it works for visualization. It is mathematically correct.
SELECT continent,MAX(CAST(total_deaths as int)) AS Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count desc

--Now, the below query is best practice. It encopasses all continet total in the data set.
SELECT location, continent, MAX(CAST(total_deaths as int)) AS Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count desc

--Global Numbers
SELECT date,SUM (new_cases) AS New_Cases_Total, SUM (cast (new_deaths as int)) AS New_Deaths_Total, SUM(cast (new_deaths as int))/SUM(new_cases)*100 AS New_Cases_Vs_New_Death_Percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--TOTAL Global Numbers
SELECT SUM (new_cases) AS New_Cases_Total, SUM (cast (new_deaths as int)) AS New_Deaths_Total, SUM(cast (new_deaths as int))/SUM(new_cases)*100 AS New_Cases_Vs_New_Death_Percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-----------------------------------------------------------((Identation of ON & AND is super important))
SELECT *
FROM [Portfolio Project]..CovidDeaths AS CDTH
JOIN [Portfolio Project]..CovidVaccinations AS CVCN
	ON CDTH.location=CVCN.location
	and CDTH.date=CVCN.date


--Calculate total population vs Vaccination
SELECT CDTH.continent,CDTH.location,CDTH.date,CDTH.population,SUM (CONVERT(int,CVCN.new_vaccinations)) OVER (Partition by CDTH.location order by CDTH.location, CDTH.date) AS Vaccinated_People_Per_Time
FROM [Portfolio Project]..CovidDeaths AS CDTH
JOIN [Portfolio Project]..CovidVaccinations AS CVCN
	ON CDTH.location=CVCN.location
	and CDTH.date=CVCN.date
WHERE CDTH.continent is not null
ORDER BY 2,3

--USE Common Table Expression (CTE)
With VACCvsPOPU (location, continent,new_vaccinations, date,Vaccinated_People_Per_Time)
as
(
SELECT CDTH.continent,CDTH.location, CDTH.date,CDTH.population,SUM (CONVERT(int,CVCN.new_vaccinations)) OVER (Partition by CDTH.location order by CDTH.location, CDTH.date) AS Vaccinated_People_Per_Time
FROM [Portfolio Project]..CovidDeaths AS CDTH
JOIN [Portfolio Project]..CovidVaccinations AS CVCN
	ON CDTH.location=CVCN.location
	and CDTH.date=CVCN.date
WHERE CDTH.continent is not null
)
Select *, (Vaccinated_People_Per_Time/location )*100
from VACCvsPOPU


--Temp table method is an alternative to the CTE method.


--creating view to store data for later visual
Create view PopulationPercentVacci
Insert into
SELECT CDTH.continent,CDTH.location, CDTH.date,CDTH.population,SUM (CONVERT(int,CVCN.new_vaccinations)) OVER (Partition by CDTH.location order by CDTH.location, CDTH.date) AS Vaccinated_People_Per_Time
FROM [Portfolio Project]..CovidDeaths AS CDTH
JOIN [Portfolio Project]..CovidVaccinations AS CVCN
	ON CDTH.location=CVCN.location
	and CDTH.date=CVCN.date
WHERE CDTH.continent is not null


--Create view to visualize later
Create View PercentPopulationVaccinated as
SELECT CDTH.continent,CDTH.location,CDTH.date,CDTH.population,SUM (CONVERT(int,CVCN.new_vaccinations)) OVER (Partition by CDTH.location order by CDTH.location, CDTH.date) AS Vaccinated_People_Per_Time
FROM [Portfolio Project]..CovidDeaths AS CDTH
JOIN [Portfolio Project]..CovidVaccinations AS CVCN
	ON CDTH.location=CVCN.location
	and CDTH.date=CVCN.date
WHERE CDTH.continent is not null
