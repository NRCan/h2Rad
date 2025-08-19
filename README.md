# radiolysis
[![License]([https://img.shields.io/badge/License-Apache_2.0-blue.svg](https://img.shields.io/badge/License-CC_BY_NC-blue.svg))](https://creativecommons.org/licenses/by-nc/4.0/deed.en)

## Description

'Radiolys' is a R package that performs the Monte Carlo model of [Warr et al. (2023)](https://www.frontiersin.org/journals/earth-science/articles/10.3389/feart.2023.1150740/full) and extends this work by incorporating these models into economic assessments. The goal is to provide a streamlined approach to take lithogeochemical data and assess it for hydrogen or helium production. This is achieved thorugh a series of modelling and plotting functions uilizing 'dplyr' and 'ggplot'. 

## Requirements

- ggplot
- dplyr

## installation

install.packages("devtools")
install_github("NRCAN_h2Rad")
library(Radiolysis)
