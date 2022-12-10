      PROGRAM   MAIN
      use iso_c_binding
      IMPLICIT NONE
      double precision rand
      
      interface
             integer(c_int) function &
             cublasCreate_v2(handle) &
             bind(c, name="cublasCreate_v2")
          use, intrinsic :: iso_c_binding
          type(c_ptr) :: handle
        end function cublasCreate_v2
    
        integer(c_int) function &
             cublasDestroy_v2(handle) &
             bind(c, name="cublasDestroy_v2")
          use, intrinsic :: iso_c_binding
          type(c_ptr), value :: handle
        end function cublasDestroy_v2
    
        integer(c_int) function &
             cudaDeviceSynchronize_v2() &
             bind(c, name="cudaDeviceSynchronize")
          use, intrinsic :: iso_c_binding
        end function cudaDeviceSynchronize_v2

      use, intrinsic :: iso_c_binding
      type(c_ptr), value :: handle
      integer(c_int), value :: transa
      integer(c_int), value :: transb
      integer(c_int), value :: m
      integer(c_int), value :: n
      integer(c_int), value :: k
      real(c_double) :: alpha
      type(c_ptr), value :: dA
      integer(c_int), value :: ldda
      type(c_ptr), value :: dB
      integer(c_int), value :: lddb
      real(c_double) :: beta
      type(c_ptr), value :: dC
      integer(c_int), value :: lddc
      end interface
      DOUBLE PRECISION ALPHA, BETA
      INTEGER          M, K, N, I, J
      PARAMETER        (M=4, K=4, N=4)
      DOUBLE PRECISION A(M,K), B(K,N), C(M,N)
      INTEGER TA, TB
      error = 0
      alpha = 1d0
      beta = 1d0
      SIZE = 4
c     create cublas handle
      cublas_error = cublascreate_v2(cublas_handle)
      
      PRINT *, "This example computes real matrix C=alpha*A*B+beta*C"
      PRINT *, "using CUBLAS function cublasDgemm_v2, where A, B, and C"
      PRINT *, "are matrices and alpha and beta are double precision "
      PRINT *, "scalars"
      PRINT *, ""
      
      allocate(aa(SIZE*SIZE))
      allocate(bb(SIZE*SIZE))
      allocate(cc_gpu(SIZE*SIZE))
      allocate(cc_host(SIZE*SIZE))
      PRINT *, "Initializing data for matrix multiplication C=A*B for "
      PRINT *, ""
      ALPHA = 1.0 
      BETA = 0.0
      TA = 1
      TB = 1
      
      call srand(123456)
      PRINT *, "Intializing matrix data"
      PRINT *, ""
      do i=1,SIZE*SIZE
         aa(i) = rand()*10
         bb(i) = rand()*10
         !aa(i) = 1.1
         !bb(i) = 2.2
         cc_host(i) = 0d0
         cc_gpu(i) = 0d0
      enddo
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
      
!$omp target enter data map(to:aa,bb,cc_gpu)

!$omp target data use_device_ptr(aa,bb,cc_gpu)
      PRINT *, "Computing matrix product using Intel(R) MKL DGEMM "
      PRINT *, "subroutine"
      CALL DGEMM_WR(TA, TB, M, N, K, ALPHA, aa, M, bb, K, BETA, cc_gpu, M)
      PRINT *, "Computations completed."
      PRINT *, ""
      if(cublas_error .ne. CUBLAS_STATUS_SUCCESS ) then
         print *, "failed", cublas_error, cc_gpu(1)
         call exit(1)
      endif
   
c     wait for call to finish
      cublas_error = cudaDeviceSynchronize_v2()
      cublas_error = cublasDestroy_v2(cublas_handle)
!     error checking
      do i=1,SIZE*SIZE
         if( abs( cc_gpu(i) - cc_host(i) ) > 0.00001 ) then
            error=error+1
    	!print *, cc_gpu(i), cc_host(i)
         endif
      enddo
    
      if( error > 0 ) then
         print *, "Failed" 
         call exit(1)
      endif
    
      deallocate( aa, stat=status )
      deallocate( bb, stat=status )
      deallocate( cc_host, stat=status )
      deallocate( cc_gpu, stat=status )

!$omp target exit data map(from:cc_gpu)
      
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
