# Does-the-weather-change-the-energy-efficiency-gap
code of the paper "Does the weather change the energy efficiency gap: Evidence from air conditioner purchases in the United States"
This folder contains the sample data and codes for the paper. Below are the sources of data and their accessibility:
- The GSOD data are accessed using GSODR package in R and can also be retrieved from https://www1.ncdc.noaa.gov/pub/data/gsod/. 
- The Retail Scanner data is provided by Nielsen Company restricted by non-disclosure terms of use but can be purchased from Nielsen. 
- The metrics of climate attitude are available in the supplementary material of the study “Geographic variation in opinions on climate change at state and local scales in the USA”. 
- The annual state-level electricity price is obtained from the U.S. Energy Information Administration website at https://www.eia.gov/electricity/data/state/. 
- The county-level socioeconomic and demographic characteristics are available in the American Community Survey from https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-data.html. 
- The support of the democratic party in county presidential election returns of 2000-2020 comes from at https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ.
In this folder, the full data other than the GSOD and Retail Scanner data are provided in .dta format. A small sample of 1000 records for GSOD and Retail Scanner data are provided due to limitation on storage and data dissemination. 

The major data processing and all the regression analysis are conducted in Stata 16.0. The download of GSOD data and figure production is conducted in R studio (based on R 4.0.2). The softwares are run on Windows 10. No non-stadard hardware are used. Installation guides and typical install time of the software can be referred from 
- R: https://www.r-project.org/
- R studio: https://www.rstudio.com/
- Stata: https://www.stata.com/new-in-stata/

The file "climate and perception of energy efficiency github.dta" generates the regression result tables and the input for the file "climate and air conditioner.r" to create figures in R. In the .do file, codes for processing the data are kept in the comment mode as a presentation of how raw data are cleaned and merged. The processed data for the final analysis are included in this folder and can be directly inputed into Stata using the .do file.
