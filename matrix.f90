PROGRAM MATS
    IMPLICIT NONE
    REAL, ALLOCATABLE :: x(:,:), y(:,:), res(:,:)
    INTEGER :: n, ans, i, j

    OPEN(12, file="m1/3.txt")
    n=3
    ALLOCATE(x(n, n))
    READ(12,*) x
    CLOSE(12)
    OPEN(12, file="m2/3.txt")
    ALLOCATE(y(n, n))
    READ(12,*) y
    CLOSE(12)
    ALLOCATE(res(n, n))
    res = MATMUL(x, y)
    DO i = 1, n
        WRITE(*,*) (res(i, j), j=1, n)
    END DO
END PROGRAM MATS
