! Based on code samples from https://en.wikipedia.org/wiki/Fortran
! and https://learnxinyminutes.com/docs/fortran95/.

PROGRAM test
    CALL print_message
END PROGRAM test
SUBROUTINE print_message
    PRINT *, 'Hello world!'
END SUBROUTINE print_message

# a preprocessor comment

.true. == .FALSE.

a < b .AND. i /= j
flag = a == b

print "(F6.3)", 4.32

! A comment...

TYPE string80            ! ... and other comment.
    INTEGER       length
    CHARACTER(80) value
END TYPE string80
CHARACTER:: char1, char2, char3
TYPE(string80):: str1,  str2,  str3

REAL, DIMENSION(10, 20) :: a, b, c
REAL, DIMENSION(5)      :: v, w
LOGICAL                    flag(10, 20)

a = b
c = a/b
w = v + 1.2
w = 5/v + a(1:5, 5)
c(1:8, 5:10) = a(2:9, 5:10) + b(1:8, 15:20)
v(2:5) = v(1:4)

i = 10
select case (i)
    case (0) ! case i == 0
    j=0
    case (1:5)
    j=1
    case (6:)
    j=2
    case default
    j=3
end select
