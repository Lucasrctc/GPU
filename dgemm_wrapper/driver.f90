program main
  use iso_c_binding
  use mywrapper
  implicit none

  double precision, allocatable, dimension(:) :: aa
  double precision, allocatable, dimension(:) :: bb
  double precision, allocatable, dimension(:) :: cc_gpu
  double precision, allocatable, dimension(:) :: cc_host

  integer :: status, SIZE, i, ic, ib, ia, error, istat
  double precision :: rand
  external rand
  double precision  :: alpha, beta
  double precision::wcStart,wcEnd
  integer(4)::get_walltime
  external get_walltime

  error = 0
  alpha = 1d0
  beta = 0d0
!  SIZE = 8192*4
  SIZE = 2


  print *,"SIZE*SIZE= ",SIZE*SIZE

  allocate(aa(SIZE*SIZE))
  allocate(bb(SIZE*SIZE))
  allocate(cc_host(SIZE*SIZE))
  allocate(cc_gpu(SIZE*SIZE))

  call srand(123456)

  do i=1,SIZE*SIZE
     aa(i) = rand()*10
!aa(i) = real(i)
     bb(i) = rand()*10
!bb(i) =  real(i)
     cc_host(i) = 0d0
     cc_gpu(i) = 0d0
  enddo

print *,"calculating on host"
print *,"Calling host's DGEMM"
istat=get_walltime(wcStart)
call dgemm('N','N',SIZE,SIZE,SIZE,1.0d0,AA,SIZE,BB,SIZE,0.0d0,CC_HOST,SIZE)
istat=get_walltime(wcEnd)
print *,"Done calling host's DGEMM"
print *,"Elapsed time:",wcEnd-wcStart


print *,"Calling GPU's DGEMM"
istat=get_walltime(wcStart)
call mgpu(SIZE,AA,BB,CC_GPU)
istat=get_walltime(wcEnd)
print *,"Done calling GPU's DGEMM"
print *,"Elapsed time:",wcEnd-wcStart

! get value from gpu

! error checking
  do i=1,SIZE*SIZE
!     print *,"i, cc_gpu(i), cc_host(i) ",i,cc_gpu(i),cc_host(i)
     if( abs( cc_gpu(i) - cc_host(i) ) > 0.00001 ) then
        error=error+1
     endif
  enddo

  if( error > 0 ) then
     print *, "Failed! Error = ",error 
     call exit(1)
  else
     print *, "Everything's ok! ",error 

  endif

  deallocate( aa, stat=status )
  deallocate( bb, stat=status )
  deallocate( cc_host, stat=status )
  deallocate( cc_gpu, stat=status )

end program main

