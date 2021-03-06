
# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |09.12.2005| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# the following code tests the POD of all distribution files - copied from the Test::Pod::Coverage manual

# load module
use Test::More;

# try to load Test::Pod::Coverage
eval "use Test::Pod::Coverage 1.00";

# configure test if possible
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
plan skip_all => "Docs not complete yet and TODO doesn't work as expected";

# run tests
TODO:
 {
  local($TODO)='Docs to be completed.';
  all_pod_coverage_ok();
 }