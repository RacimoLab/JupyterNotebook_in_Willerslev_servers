# Jupyter Notebook on Willerslev servers

###### Moisès Coll Macià - 20/01/21


In this tutorial I'm going to explain the solution I found to run jupyter notebook in the Willerslev servers remotely from by personal computer. I'm mainly based on [this](https://medium.com/@sankarshan7/how-to-run-jupyter-notebook-in-server-which-is-at-multi-hop-distance-a02bc8e78314) blog post which explains a similar problem. The different steps are shown in **Figure 1** and explained below. The idea is to create an *ssh tunnel* from a computing node (C1), where your jupyther notebook will be running, to the front-end (C2) of Willerslev servers (Step 1 and 2) and another tunnel from the front-end in Willerslev servers to your working station (C3) to open jupyter notebook in your computer browser (Step 3 and Step 4). I assume you've already installed jupyter notebook and all it's dependences and you know how to login to the Willerslev servers. 

Notation summary:

- Computer (C):
    - C1 -> Computing node in one of the Willerslev servers. In Figure 1 denoted as `SSSSSS`
    - C2 -> Fron-end computer in Willerslev servers.
    - C3 -> Your local machine.
- Ports (P):
    - P1 -> C1's port. Here denoted as `9999`.
    - P2 -> C2's port. Here denoted as `8888`.
    - P3 -> C3's port. Here denoted as `7777`.
    
It's important to notice that P must be 1024 >= P <= 65535. More info about ports can be found [here](https://www.ssh.com/ssh/port) and [here](https://linuxhint.com/change_default_ssh_port/).


![](Figure1.png)

**Figure 1.** Schematic representation to run Jupyter Notebook in Willerslev servers. Highlighted are:
- Yellow : KU username
- Red : C1
- Green : P1
- Purple : P2
- Cyan : P3

### Step 1. Running jupyter notebook on C1

- Log into the Willerslev servers (on Figure 1.1, you should replace the Xs highlighted in yellow for your user).
- Check which computing node you want to run jupyter notebook on, by running `tmon` for example.
- Log into C1
- Run jupyter notebook in `--no-browser` mode. You must also specify P1, which must be unique to your connection (so be creative :) ), otherwise it gives problems. 


```python
ssh XXXXXX@ssh-snm-willerslev.science.ku.dk
tmon
ssh SSSSSS
jupyter lab --no-browser --port=9999
```

### Step 2. Open the first ssh tunnel on C2

- On a new terminal, log into the Willerslev servers (on Figure 1.2, you should replace the Xs highlighted in yellow for your user).
- Create an shh tunnel with the command shown in Figure 1.2. Ss highlighted in red represent the C1's name on which you are running the jupyter notebook. Again, you must decide a new port P2 (on Figure 1.2, represented as 8s highlighted in purple) indicated P1 (on Figure 1.2, represented as 9s highlighted in green).


```python
ssh XXXXXX@ssh-snm-willerslev.science.ku.dk
ssh SSSSSS -L 8888:localhost:9999 -N
```

### Step 3. Open the second ssh tunnel on C3

- On a new terminal (C3), create another shh tunnel with the command shown in Figure 1.3. Xs highlighted in yellow represent your user to connect to Willerslev servers. Again, you must decide a new port P3 (on Figure 1.3, represented as 7s highlighted in cyan) and indicate P2 (on Figure 1.3, represented as 8s highlighted in purple)


```python
ssh XXXXXX@ssh-snm-willerslev.science.ku.dk -L 7777:localhost:8888 -N
```

### Step 4. Jupyter notebook in your local machine browser

- Open your favourite browser and type `localhost:7777`
- TADAAAA!
    
### Caveats and considerations

#### 1. Difficult to automatize

I found a bit annoying to repeat all steps every time I want to work on jupyter notebook. I added some of the commands in my `.bash_profile` as aliases, but I'm not sure is the best way to automatize the whole thing.

#### 2. Port uniqueness

While P1, P2 and P3 can be the same number (1024 >= P <= 65535), if there are multiple users using the same ports in the same "computer" it's going to create some conflicts and errors. 

#### 3. Close shh tunnels

Sometimes, when I close the shh tunnels (Cntl+C), the process keeps running on the background, meaning that the port is still in use. Then, if I try to open again the tunnels, I get the error that... Surprise! the port is on use. To solve that, I kill the process that it's running that particular port with the following command


```python
for job in `ps aux | egrep 9999 | egrep "ssh" | egrep XXXXXX | awk '{print $2}'`; do kill -9 ${job}; done
```

This selects from all processes running, the ones that have the "9999" (port-id), "ssh" and "XXXXXX" (username) and kill them. 

#### 4. ssh termination

Sometimes, when the ssh doesn't receive orders, it automatically closes down. This kills the ssh tunnel. To prevent that, I first run `screen` so that even when my session is killed, the process goes on and it does not stop my jupyter notebook while working. 

Let me know if you find more problems while using these to run jupyter notebook that are not reported here and if you have improvements and suggestions!

### Acknowledgements

I would like to thank Graham Gower for his techical comments on ports and the proper way to kill a process (Cntrl-C) instead of suspending it (Cntrl-Z) when stopping shh tunnels. He's also giving me input for how atutomatize this whole process which I hope to achieve soon and update this instructions with it. 

I thank Antonio Fernandez Guerra for his tricks on how to connect directly to one computing node by customizing `.ssh/config` file. 
