for param1 in [range]
  do
for param2 in [range]
  do
  for param3 in [range]
    do
    for param4 in [range]
      do
      for param5 in [range]
        do
        for param6 in [range]
          do
          for seed in seeds.csv;
            do
              echo "Seed = " $(seed) " param1 = " $(param1) " param2 = " $(param2) "param3 = " $(param3) "param4 = " $(param4) "param5 = " $(param5) "param6 = " $(param6):
              slim -s $(seed) -d param1=$(param1) -d param2=$(param2) -d param3=$(param3) -d param4=$(param4) -d param5=$(param5) -d param6=$(param6) ~/scripts/NAR_ODE_V1.X.slim &
              echo done
            done
          done
        done
      done
    done
  done
done
