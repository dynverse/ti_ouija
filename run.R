#!/usr/local/bin/Rscript
task <- dyncli::main()

library(jsonlite)
library(readr)
library(dplyr)
library(purrr)

library(ouija)
library(rstan)

#   ____________________________________________________________________________
#   Load data                                                               ####

expression <- as.matrix(task$expression)
params <- task$params

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####


# ouija assumes that a small number of marker genes is used, otherwise the method is too slow
if (!is.null(task$priors$features_id)) {
  expression <- expression[, task$priors$features_id]
}

# write compiled instance of the stanmodel to HDD
rstan::rstan_options(auto_write = TRUE)

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = as.numeric(Sys.time()))

# run ouija
oui <- ouija::ouija(
  x = expression,
  iter = params$iter,
  response_type = params$response_type,
  inference_type = params$inference_type,
  normalise_expression = params$normalise_expression
)

# TIMING: done with method
checkpoints$method_aftermethod <- as.numeric(Sys.time())

# obtain the pseudotime
pseudotime <- ouija::map_pseudotime(oui) %>%
  setNames(rownames(expression))

# return output
output <- lst(
  cell_ids = names(pseudotime),
  pseudotime = pseudotime,
  timings = checkpoints
)

#   ____________________________________________________________________________
#   Save output                                                             ####
dynwrap::wrap_data(cell_ids = names(pseudotime)) %>%
  dynwrap::add_linear_trajectory(
    pseudotime = tibble(cell_id = names(pseudotime), pseudotime = pseudotime)
  ) %>%
  dynwrap::add_timings(timings = checkpoints) %>%
  dyncli::write_output(task$output)
