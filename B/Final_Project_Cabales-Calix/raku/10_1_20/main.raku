# use Pricing loads the module at compile time and imports the exported total routine.
# The caller uses total as an ordinary routine. The calculation itself lives in Pricing.rakumod.
use Pricing;
say total(3,4);
