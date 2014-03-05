function true=isodd(num)

% true=isodd(num) - Returns 1 for even NUM, 0 for odd

true = mod(num,2) == 1;
