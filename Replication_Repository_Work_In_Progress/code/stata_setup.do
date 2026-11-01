version 18.0
* Optional legacy-output packages. Main replication scripts use built-in commands.
capture which didregress
if _rc {
    display as error "Stata 18+ is required for didregress and dtable."
    exit 199
}
capture which dtable
if _rc {
    display as error "dtable is unavailable. Install/update Stata 18+."
    exit 199
}
capture which esttab
if _rc ssc install estout, replace
capture which outreg2
if _rc ssc install outreg2, replace
display "Stata version: " c(stata_version)
which esttab
which outreg2
