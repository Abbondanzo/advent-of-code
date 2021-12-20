import numpy as np

def recover_homogenous_affine_transformation(p, p_prime):
    '''
    Find the unique homogeneous affine transformation that
    maps a set of 3 points to another set of 3 points in 3D
    space:

        p_prime == np.dot(p, R) + t

    where `R` is an unknown rotation matrix, `t` is an unknown
    translation vector, and `p` and `p_prime` are the original
    and transformed set of points stored as row vectors:

        p       = np.array((p1,       p2,       p3))
        p_prime = np.array((p1_prime, p2_prime, p3_prime))

    The result of this function is an augmented 4-by-4
    matrix `A` that represents this affine transformation:

        np.column_stack((p_prime, (1, 1, 1))) == \
            np.dot(np.column_stack((p, (1, 1, 1))), A)

    Source: https://math.stackexchange.com/a/222170 (robjohn)
    '''

    # construct intermediate matrix
    Q       = p[1:]       - p[0]
    Q_prime = p_prime[1:] - p_prime[0]

    # print(np.cross(*Q))
    # print(np.row_stack((Q, np.cross(*Q))))
    # print(np.row_stack((Q_prime, np.cross(*Q_prime))))
    # print(p[1:])
    # print(p[0])
    # print(Q)

    # print(p_prime[1:])
    # print(p_prime[0])
    # print(Q_prime)


    # calculate rotation matrix
    R = np.dot(np.linalg.inv(np.row_stack((Q, np.cross(*Q)))),
               np.row_stack((Q_prime, np.cross(*Q_prime))))
    # print(R)

    # calculate translation vector
    t = p_prime[0] - np.dot(p[0], R)

    # calculate affine transformation matrix



    return np.row_stack((np.column_stack((R, t)),
                            (0, 0, 0, 1))).round()




# matrix_a = np.array(((0.0,2.0,0.0),
#                   (4.0,1.0,0.0),
#                   (3.0,3.0,0.0)))
# matrix_b = np.array(((-5.0,0.0,0.0),
#                   (-1.0,-1.0,0.0),
#                   (-2.0,1.0,0.0)))

matrix_a = np.array(((-618, -824, -621),
                  (-537, -823, -458),
                  (-447, -329, 318)))
matrix_b = np.array(((686, 422, 578),
                  (605, 423, 415),
                  (515, 917, -361)))

result = recover_homogenous_affine_transformation(matrix_b, matrix_a)
print(result)
print(result.dot(np.array(((686, 422, 578, 1)))))
