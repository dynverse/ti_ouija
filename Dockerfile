FROM dynverse/dynwrapr:v0.1.0

RUN R -e 'devtools::install_github("kieranrcampbell/ouija")'
RUN R -e 'devtools::install_cran("rstan")'
RUN R -e 'devtools::install_cran("coda")'

COPY definition.yml run.R example.h5 /code/

ENTRYPOINT ["/code/run.R"]
