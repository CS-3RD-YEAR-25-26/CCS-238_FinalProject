# unit module gives this compilation unit the module name Pricing.
# is export exposes total to callers that load Pricing with use.
# The final expression supplies the routine's result to the calling program.
unit module Pricing;
sub total($p,$q) is export { $p * $q }
