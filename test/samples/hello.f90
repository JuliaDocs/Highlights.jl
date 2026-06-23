! Based on code samples from https://en.wikipedia.org/wiki/Fortran
! and https://learnxinyminutes.com/docs/fortran95/.

MODULE strings
    TYPE string80            ! a derived type with a trailing comment
        INTEGER :: length
        CHARACTER(80) :: value
    END TYPE string80
END MODULE strings

PROGRAM test
    USE strings
    IMPLICIT NONE

    CHARACTER :: char1, char2, char3
    TYPE(string80) :: str1, str2, str3
    REAL, DIMENSION(10, 20) :: a, b, c
    REAL, DIMENSION(5) :: v, w
    LOGICAL :: flag(10, 20)
    INTEGER :: i, j

    CALL print_message

    ! Logical literals and relational operators
    flag = .true. .AND. .FALSE.
    flag = a < b .AND. i /= j
    flag = a == b

    PRINT "(F6.3)", 4.32

    ! Array assignments and sections
    a = b
    c = a/b
    w = v + 1.2
    w = 5/v + a(1:5, 5)
    c(1:8, 5:10) = a(2:9, 5:10) + b(1:8, 15:20)
    v(2:5) = v(1:4)

    i = 10
    SELECT CASE (i)
        CASE (0) ! case i == 0
        j = 0
        CASE (1:5)
        j = 1
        CASE (6:)
        j = 2
        CASE DEFAULT
        j = 3
    END SELECT
END PROGRAM test

SUBROUTINE print_message
    PRINT *, 'Hello world!'
END SUBROUTINE print_message
