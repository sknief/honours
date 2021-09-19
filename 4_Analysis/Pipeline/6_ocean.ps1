#for test files, location needs to be updated later on

# go in and make aquarium
cd C:\Users\sknie\github\honours\4_Analysis
mkdir ocean

#files come from the tanks:
## ODE
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ODE\aquarium\Richard*.csv -Destination C:\Users\sknie\github\honours\4_Analysis\ocean
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ODE\aquarium\Shelldon*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ocean
## ADD
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ADD\aquarium\Richard*.csv -Destination C:\Users\sknie\github\honours\4_Analysis\ocean
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ADD\aquarium\Shelldon*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ocean
