# cube.odin

An Odin implementation of [cube.c](https://github.com/tarantino07/cube.c) which uses the following [rotation matrix](https://en.wikipedia.org/wiki/Rotation_matrix) to perform a basic 3-dimensional rotation in Euclidean space:
<br />
```math
<math display=block>
\begin{alignat}{1}
R_x(\theta) &= \begin{bmatrix}
1 & 0 & 0\\
0 & \cos(\theta)& -\sin(\theta) \\
0 & \sin(\theta) & \cos(\theta) \\
\end{bmatrix} \\
\\ \\
R_y(\theta) &= \begin{bmatrix}
\cos(\theta) & 0 & \sin(\theta) \\
0 & 1 & 0           \\
-\sin(\theta) & 0 &  \cos(\theta) \\
\end{bmatrix} \\
\\ \\
R_z(\theta) &= \begin{bmatrix}
\cos(\theta) & -\sin(\theta) & 0 \\
\sin(\theta) &  \cos(\theta) & 0 \\
0 &  0 & 1 \\
\end{bmatrix}
\end{alignat}
</math>
```
<br />

<p align="center">
<img src="https://github.com/JoshuaSloan/cube.odin/blob/main/cube.gif" alt="Spinning Cube" width="500" height="500">
</p>
