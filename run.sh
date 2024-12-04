clear
make clean
make -j4
# valgrind --leak-check=full --show-leak-kinds=all ./dcmat < ./tests/tests.txt 
valgrind --leak-check=full --show-leak-kinds=all  --track-origins=yes ./dcmat < ./tests/tests.txt > ./tests/result.txt

# ./dcmat < ./tests/tests.txt
# ./dcmat 