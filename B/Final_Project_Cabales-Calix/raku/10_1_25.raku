# The ^ and $ anchors require the whole string to match. <[0..9]>+ accepts one or more ASCII digits.
# Smartmatching with ~~ yields a match or failure, which ?? !! uses to choose the message.
say ('67' ~~ /^ <[0..9]>+ $/) ?? 'valid' !! 'invalid';
