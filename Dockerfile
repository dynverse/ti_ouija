FROM dynverse/dynwrap:r

RUN R -e 'devtools::install_github("kieranrcampbell/ouija")'
RUN R -e 'devtools::install_cran("rstan")'
RUN R -e 'devtools::install_cran("coda")'

LABEL version 0.1.2

ADD . /code

ENTRYPOINT Rscript /code/run.R
