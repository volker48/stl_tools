cimport cython
import numpy as np
cimport numpy as np
from itertools import product

try:  # python2 & python3 compatibility
    xrange
except NameError:
    xrange = range

DTYPE = np.float
ctypedef np.float_t DTYPE_t

cdef int i


@cython.boundscheck(False)
def tessellate(np.ndarray[DTYPE_t, ndim=2] A,
               double mask_val,
               double min_thickness_percent,
               solid = False):
    cdef int m = A.shape[0]
    cdef int n = A.shape[1]
    cdef int i, j
    cdef int idx = 0
    cdef np.ndarray item
    cdef np.ndarray facets = np.zeros([4 * m * n, 12], dtype=np.float64)
    #cdef np.ndarray mask = np.zeros([m, n], dtype=DTYPE)

    #cdef np.ndarray edge_mask = np.sum([roll2d(mask, (i, k))
    #                                    for i, k in product([-1, 0, 1],
    #                                        repeat=2)], axis=0)
    cdef double zmin, zthickness, minval, xsize, ysize, zsize
    cdef np.ndarray X, Y
    cdef int facet_cut = 1

    for i in xrange(m - 1):
        for k in xrange(n - 1):
            if A[i, k] > mask_val and A[i, k + 1] > mask_val and A[i + 1, k ] > mask_val:
                facets[idx, 3] = i -m/2.
                facets[idx, 4] = k + 1 - n / 2.
                facets[idx, 5] = A[i, k + 1]

                facets[idx, 6] = i - m / 2.
                facets[idx, 7] = k - n / 2.
                facets[idx, 8] = A[i, k]

                facets[idx, 9] = i + 1 - m / 2.
                facets[idx, 10] = k + 1 - n / 2.
                facets[idx, 11] = A[i + 1, k + 1]

                #mask[i, k] = 1
                #mask[i, k + 1] = 1
                #mask[i + 1, k] = 1

                idx += 1

            if A[i + 1, k + 1] > mask_val and A[i, k] > mask_val and A[i + 1, k] > mask_val:
                facets[idx, 3] = i - m / 2.
                facets[idx, 4] = k - n / 2.
                facets[idx, 5] = A[i, k]

                facets[idx, 6] = i + 1 - m / 2.
                facets[idx, 7] = k - n / 2.
                facets[idx, 8] = A[i + 1, k]

                facets[idx, 9] = i + 1 - m / 2.
                facets[idx, 10] = k + 1 - n / 2.
                facets[idx, 11] = A[i + 1, k + 1]

                #mask[i, k] = 1
                #mask[i + 1, k + 1] = 1
                #mask[i + 1, k] = 1

                idx += 1

    # if solid:
    #     facet_cut = 2
    #     edge_mask[np.where(edge_mask == 9.)] = 0.
    #     edge_mask[np.where(edge_mask != 0.)] = 1.
    #     edge_mask[0::m - 1, :] = 1.
    #     edge_mask[:, 0::n - 1] = 1.
    #     X, Y = np.where(edge_mask == 1.)
    #     locs = np.array(zip(X - m / 2., Y - n / 2.))

    #     zvals = facets[:, 5::3]
    #     zmin, zthickness = zvals.min(), zvals.ptp()

    #     minval = zmin - min_thickness_percent * zthickness

    #     for i in xrange(idx):


    #             facets[idx+i, 3] = i_ - m / 2.
    #             facets[idx+i, 4] = k_ - n / 2.
    #             facets[idx+i, 5] = minval

    #             facets[idx+i, 6] = i_ + 1 - m / 2.
    #             facets[idx+i, 7] = k_ - n / 2.
    #             facets[idx+i, 8] = minval

    #             facets[idx+i, 9] = i_ + 1 - m / 2.
    #             facets[idx+i, 10] = k_ + 1 - n / 2.
    #             facets[idx+i, 11] = minval

    return facets[:idx]


@cython.boundscheck(False)
cdef np.ndarray roll2d(np.ndarray[DTYPE_t, ndim=2] image, shifts):
    return np.roll(np.roll(image, shifts[0], axis=0), shifts[1], axis=1)
