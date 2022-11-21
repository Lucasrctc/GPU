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
  
      integer(c_int) function &
           cublasDgemm_v2(handle, transa, transb, m, n, k, alpha, dA,&
           ldda, dB, lddb, beta, dC, lddc) &
           bind(c, name="cublasDgemm_v2")
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
      end function cublasDgemm_v2
  
  
      end interface

      SUBROUTINE DGEMM_WR (cublas_handle,TA,TB,M,N,K
     2,AL,A,LDA,B,LDB,BT,C,LDC)
      use iso_c_binding
c     .. Scalar Arguments ..
      implicit none
      CHARACTER*1        TA, TB
      real*8   AL, BT
c     .. Array Arguments ..
      integer(c_int)   :: cublas_error
      type(c_ptr) :: cublas_handle

      INTEGER            M, N, K, LDA, LDB, LDC
       real*8   A( LDA, * ), B( LDB, * ), C( LDC, * )

      !$omp target data use_device_ptr(aa,bb,cc_gpu)
       cublas_error = cublasDgemm_v2(cublas_handle,1,1,M,N
     2,K,AL,A,LDA,B,LDB,BT,C,LDC);
      !$omp end target data
         if(cublas_error .ne. CUBLAS_STATUS_SUCCESS ) then
            print *, "failed", cublas_error, cc_gpu(1)
            call exit(1)
         endif
      
         ! wait for call to finish
         cublas_error = cudaDeviceSynchronize_v2()
         cublas_error = cublasDestroy_v2(cublas_handle)
c      call dgemm(TA,TB,M,N,K,AL,A,LDA,B,LDB,BT,C,LDC)
       
       return
       end
