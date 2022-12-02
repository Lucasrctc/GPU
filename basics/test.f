      PROGRAM   MAIN
      
      IMPLICIT NONE
      
      DOUBLE PRECISION ALPHA, BETA
      INTEGER          M, K, N, I, J
      PARAMETER        (M=2000, K=200, N=1000)
      DOUBLE PRECISION A(M,K), B(K,N), C(M,N)
      CHARACTER*1 TA, TB
      
      PRINT *, "This example computes real matrix C=alpha*A*B+beta*C"
      PRINT *, "using Intel(R) MKL function dgemm, where A, B, and C"
      PRINT *, "are matrices and alpha and beta are double precision "
      PRINT *, "scalars"
      PRINT *, ""
      
      PRINT *, "Initializing data for matrix multiplication C=A*B for "
      PRINT *, ""
      ALPHA = 1.0 
      BETA = 0.0
      
      PRINT *, "Intializing matrix data"
      PRINT *, ""
      DO I = 1, M
        DO J = 1, K
          A(I,J) = (I-1) * K + J
        END DO
      END DO
      
      DO I = 1, K
        DO J = 1, N
          B(I,J) = -((I-1) * N + J)
        END DO
      END DO
      
      DO I = 1, M
        DO J = 1, N
          C(I,J) = 0.0
        END DO
      END DO
      
      PRINT *, "Computing matrix product using Intel(R) MKL DGEMM "
      PRINT *, "subroutine"
      CALL DGEMM_WR('N','N',M,N,K,ALPHA,A,M,B,K,BETA,C,M)
      PRINT *, "Computations completed."
      PRINT *, ""
      
      PRINT *, "Top left corner of matrix A:"
      WRITE(*,*) ((A(I,J), J = 1,MIN(K,6)), I = 1,MIN(M,6))
      PRINT *, ""
      
      PRINT *, "Top left corner of matrix B:"
      WRITE(*,*), ((B(I,J),J = 1,MIN(N,6)), I = 1,MIN(K,6))
      PRINT *, ""
      
      
      PRINT *, "Top left corner of matrix C:"
      WRITE(*,*), ((C(I,J), J = 1,MIN(N,6)), I = 1,MIN(M,6))
      PRINT *, ""
      
      
      PRINT *, "Example completed."
      STOP 
      
      END
