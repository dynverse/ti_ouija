#!/usr/local/bin/Rscript
task <- dyncli::main()

library(dplyr, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)
library(dynwrap, warn.conflicts = FALSE)
library(ouija, warn.conflicts = FALSE)
library(rstan, warn.conflicts = FALSE)

#   ____________________________________________________________________________
#   Load data                                                               ####

expression <- as.matrix(task$expression)
parameters <- task$parameters

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
  iter = parameters$iter,
  response_type = parameters$response_type,
  inference_type = parameters$inference_type,
  normalise_expression = parameters$normalise_expression
)

# TIMING: done with method
checkpoints$method_aftermethod <- as.numeric(Sys.time())

# obtain the pseudotime
pseudotime <- ouija::map_pseudotime(oui) %>%
  setNames(rownames(expression))

#   ____________________________________________________________________________
#   Save output                                                             ####
dynwrap::wrap_data(cell_ids = names(pseudotime)) %>%
  dynwrap::add_linear_trajectory(pseudotime = pseudotime) %>%
  dynwrap::add_timings(timings = checkpoints) %>%
  dyncli::write_output(task$output)
