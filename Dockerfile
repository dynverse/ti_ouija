FROM dynverse/dynwrap_latest:v0.1.0

ARG GITHUB_PAT

RUN R -e 'devtools::install_github("kieranrcampbell/ouija")'
RUN R -e 'devtools::install_cran("rstan")'
RUN R -e 'devtools::install_cran("coda")'

COPY definition.yml run.R example.sh /code/

ENTRYPOINT ["/code/run.R"]
