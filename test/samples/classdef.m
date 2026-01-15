% A single line comment.

x = 1;
y = 2;
[X, Y] = func(1.0, 2.3e-9, 3j);

%{
    Multiline comments here,

  and here.

    ... and again here.
%}

s = 'abc ... xyz';

function result = func(x, y)
    % ...
end

% External shell commands.
!ping julialang.org

classdef ClassName
    properties
        x
        y
        z
    end
    methods
        function [s, t] = method_1(x_1, y_2)
            if x_1 < y_2
                s = {1, 2, 4};
                t = n * A + B + 1;
            else
                for i = 1:x_1
                    A(i) = i^2 + 1;
                end
            end
        end
    end
end
