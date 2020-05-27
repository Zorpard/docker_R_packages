FROM rocker/rstudio:3.6.3
RUN apt-get -qq update && \
# fix-broken: https://askubuntu.com/questions/1077298/depends-libnss3-23-26-but-23-21-1ubuntu4-is-to-be-installed
DEBIAN_FRONTEND=non-interactive apt-get -qy install -f \
#install python pip
python3-pip \
# ggraph dependency (required for clusterProfiler)
libudunits2-dev \
# XML2 dependency (required for tidyverse)
libxml2-dev \
# httr dependency (required for tidyverse)
libssl-dev \
# curl dependency (required for tidyverse)
libcurl4-openssl-dev \
# Required for rjava
default-jdk \
r-cran-rjava \
# survival
#r-cran-survival \
# Seurat requirements (Single Cell RNASeq package)
  libhdf5-dev \
# these are copied from tidyverse: https://hub.docker.com/r/rocker/tidyverse/dockerfile
  libcairo2-dev \
  libsqlite-dev \
  libmariadbd-dev \
  libmariadbclient-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  && install2.r --error \
    --deps TRUE \
    survival \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
    BiocManager \
# clean
&& apt-get clean
# stop and install multtest because it is a bio conductor only dependency for some R package(s)
RUN R -e 'BiocManager::install("multtest")'
# install RANN.L1 (not on CRAN)
RUN installGithub.r --deps TRUE jefferis/RANN@master-L1
# from here I add my own R packages
RUN install2.r --error \
    --deps TRUE \
    Hmisc \
    Rcpp \
    RcppEigen \
    Seurat \
# from here I add git R packages
  && installGithub.r --deps TRUE \
    immunogenomics/harmony \
    hhoeflin/hdf5r \
    mojaveazure/loomR \
    MacoskoLab/liger
# with RUN some bioconductor packages
#RUN Rscript -e 'source("https://bioconductor.org/biocLite.R"); biocLite("scran")'
#Install python libraries
RUN pip3 install \ 
  # dta (Stata)
  pandas \
  scanorama \
  bbknn
# Configure java for R
RUN R CMD javareconf