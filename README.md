# send2remote  

This a simple matlab wrapper for the SSH toolbox made by David Freedman and published on Matlab Central ([LINK](https://uk.mathworks.com/matlabcentral/fileexchange/35409-ssh-sftp-scp-for-matlab-v2))

The wrapper makes it simple to run a local matlab function on a remote machine via an SSH connection, this means you can create, edit and maintain your matlab code on your local machine and export it and its associated variables only at runtime. 

What the function does:
 *   1. Reads a .mat file that stores your username, passsword (plain text so be careful!), the SSH host address and the matlab run command.
 *   2. Finds the file dependencies and variables needed for the function you wish to run and packs them into a zip folder
 *   3. Sends the zip to the remote 
 *   4. Runs the Matlab function using the run command from the .mat file
 *   5. Sends the result back as another zip file and loads it into your workspace
 *   6. deletes temporary data on remote machine


## Getting Started

TODO

### Installing

Clone git repository and add to Matlab workspace

## License

See "\ssh2_v2_m1_r7\license.txt"
