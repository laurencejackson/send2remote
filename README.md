# send2remote  

This a simple matlab wrapper for the SSH toolbox made by David Freedman and published on Matlab Central ([LINK](https://uk.mathworks.com/matlabcentral/fileexchange/35409-ssh-sftp-scp-for-matlab-v2))

The wrapper makes it simple to run a local matlab function on a remote machine via an SSH connection, this means you can create, edit and maintain your matlab code on your local machine and export it and its associated variables only at runtime. 

The main thing I've used this for is to speed up parfor loops. I manage my matlab code on a laptop with only 2 cores for parallel processing. When there is a machine available with more cores I offload the processing there but keep the code on my machine so I dont need to maintain multiple copies. 


What the function does:
1. Reads a .mat file that stores your username, passsword (plain text so be careful!), the SSH host address and the matlab run command.
2. Finds the file dependencies and variables needed for the function you wish to run and packs them into a zip folder
3. Sends the zip to the remote 
4. Runs the Matlab function using the run command from the .mat file
5. Sends the result back as another zip file and loads it into your workspace
6. deletes temporary data on remote machine


## Getting Started

Edit ssh_default.mat to match your unique setup.

*USERNAME: Change to your username on remote machine
*PASSWORD: Change to your password on remote machine
*sshhost: Name of machine used to connect via ssh
*matlabRunCmd: the command used to start matlab, point to your matlab install path (best to keep the startup flags in example)

Before running send2remote store make sure the necessary variables are saved in a matlab structure with the correct names.

e.g.  for some function sorting_script_parfor.m that uses a parfor to speed up processing [sorting_script_parfor(img,vox,sigma,order)]

  structtemp.img = img;
  structtemp.vox = vox;
  structtemp.sigma = sigma;
  structtemp.order = order;
  [output] = send2remote('sorting_script_parfor',structtemp,'ssh','ssh_machine_name');
                    

### Installing

Clone git repository and add to Matlab workspace

## License

See "\ssh2_v2_m1_r7\license.txt"
