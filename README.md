# CloudMap

CloudMap is a mechanism to map tasks to cloud instances based on the task affinities and network performance of the instances.

## Requirements

- external tool to detect MPI communication (e.g., eztrace, http://eztrace.gforge.inria.fr), or another mechanism to describe affinities between tasks
- installed scotch tool (https://www.labri.fr/perso/pelegrin/scotch/)

## Usage

    $ ./CloudMap.sh <binary> <nodecount> <metric>

## Publication

CloudMap is described and evaluated in the following paper:

- Emmanuell D. Carreño, Matthias Diener, Eduardo H. M. Cruz, Philippe O. A. Navaux. “Automatic Communication Optimization of Parallel Applications in Public Clouds.” International Symposium on Cluster, Cloud and Grid Computing (CCGrid), 2016.
