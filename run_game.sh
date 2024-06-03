#!/bin/bash

julia --project -q -i -e "using Pkg; Pkg.precompile(); using GenieFramework; Genie.loadapp(); up($1); "