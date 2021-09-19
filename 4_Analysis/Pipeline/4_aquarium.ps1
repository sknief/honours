#for test files, location needs to be updated later on

# go in and make aquarium
cd C:\Users\sknie\github\honours\4_Analysis\ODE
mkdir aquarium

cd C:\Users\sknie\github\honours\4_Analysis\ADD
mkdir aquarium

#files come from the tanks:
## ODE
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ODE\BOptMed\tank\Pog*.csv -Destination C:\Users\sknie\github\honours\4_Analysis\ODE\aquarium
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ODE\BOptLow\tank\Pog*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ODE\aquarium
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ODE\BOptHigh\tank\Pog*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ODE\aquarium
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ODE\Neutral\tank\Pog*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ODE\aquarium

## ADD
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ADD\BOptMed\tank\Pog*.csv -Destination C:\Users\sknie\github\honours\4_Analysis\ADD\aquarium
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ADD\BOptLow\tank\Pog*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ADD\aquarium
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ADD\BOptHigh\tank\Pog*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ADD\aquarium
Move-Item -Path C:\Users\sknie\github\honours\4_Analysis\ADD\Neutral\tank\Pog*.csv  -Destination C:\Users\sknie\github\honours\4_Analysis\ADD\aquarium
