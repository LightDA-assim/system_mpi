#ifdef HAVE_MPI_F08_MODULE
#define MPI_REQUEST_TYPE type(MPI_Request)
#define MPI_STATUS_TYPE type(MPI_Status)
#define MPI_COMM_TYPE type(MPI_Comm)
#define MPI_GROUP_TYPE type(MPI_Group)
#else
#define MPI_REQUEST_TYPE integer
#define MPI_STATUS_TYPE integer, dimension(MPI_STATUS_SIZE)
#define MPI_COMM_TYPE integer
#define MPI_GROUP_TYPE integer
#endif
