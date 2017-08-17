          x      => '0
fib:'0 - 1       => '1
    if '1 > 0 then jump A
    1            => '2
    return '2
    leave
A:  '0 - 2       => '2
    push fib '1
    call fib     => '3
    push fib '2
    call fib     => '4
    '3 + '4      => '5
    return '5
    leave
