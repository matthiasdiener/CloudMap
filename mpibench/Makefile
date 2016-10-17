CC=mpicc

all: mpi_bench

mpi_bench: mpbench.o timer.o
	$(CC) mpbench.o timer.o -o $@

clean:
	rm -f *.o mpi_bench
