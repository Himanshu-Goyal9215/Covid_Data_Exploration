SELECT * FROM covid_database.covidvaccinations;
use covid_database;
drop table if exists covid_vaccination;
drop table if exists covid_deaths;
create table covid_deaths(
 iso_code varchar(255),
continent text,
location text,
date date,
total_cases bigint,
new_cases bigint,
total_deaths text,
new_deaths text,
population bigint);

create table covid_vaccination(
 iso_code varchar(255),
continent text,
location text,
date date,
new_tests text,
total_tests text,
total_vaccinations text,
new_vaccinations text
);
