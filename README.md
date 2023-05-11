# ImprovedECC

This repository includes implementations and experiments for improved algorithms for Edge Colored Clustering (ECC) in Hypergraphs and Graphs, to accompany the paper

"Optimal LP Rounding and Linear-Time Approximation Algorithms for Clustering Edge-Colored Hypergraphs", Nate Veldt, ICML 2023

A preprint of the paper is available at [https://arxiv.org/abs/2208.06506](https://arxiv.org/abs/2208.06506)


### Benchmark dataset experiments

In order to run experiments on the benchmark datasets of Amburg, Veldt, and Benson (WWW 2020), unzip JLD_Files.zip in the directory 

	/include/CategoricalEdgeClustering-master/data

### New Trivago Hypergraph

The new edge-colored Trivago Hypergraph is stored in the .mat file

	trivago-dataset/Trivago_Clickout_EdgeLabels.mat
	
Instructions and code showing how this hypergraph was constructed from the [ACM RecSys Challenge 2019](https://recsys.acm.org/recsys19/challenge/) dataset is also provided in the trivago-dataset folder. 




