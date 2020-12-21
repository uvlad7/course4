# g++ -o gfg -fopenmp multiply.cpp -o multiply

printf '' > output.txt

for n in 500 512 750 1000 1024 1250 1500 1750 2000 2048 2250 2500 2750 3000
    do
        echo $n >> output.txt
        for r in 1 2 5 10 15 20 25 30 35 40 45 50 55 60 65 100 200 500
            do
                ./build/Lab1 -n $n -m $n -r $r
            done
    done
