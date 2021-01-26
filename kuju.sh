#!/bin/sh

#A. Defining variables
ku_user="XXXXXX"
envname="ENVENV"
c1=$1
p1="9999"
p2="8888"
p3="7777"
m1="jupyter_notebook_c1"
m2="jupyter_notebook_c2"
m3="jupyter_notebook_c3"

if [ "$2" != "kill" ]
then
	#B. Step by  step
	#B.1 Step 1 - Running jupyter notebook on a computing node 
	if [ "`ssh -J ${ku_user}@ssh-snm-willerslev.science.ku.dk ${ku_user}@${c1} 'tmux ls | egrep '${m1}''`" = "" ]
	then
		echo "1) Starting jupyter notebook at ${c1} in a tmux session named ${m1} with port ${c1}"
		ssh -J ${ku_user}@ssh-snm-willerslev.science.ku.dk ${ku_user}@${c1} 'tmux new-session -s '${m1}' -d'
		ssh -J ${ku_user}@ssh-snm-willerslev.science.ku.dk ${ku_user}@${c1} 'tmux send-keys -t '${m1}' "conda activate '${envname}'" C-m "jupyter lab --no-browser --port='${p1}'" C-m'
	else
		echo "1) ${c1} already has a tmux session named ${m1}"
	fi

	#B.1 Step 1 - Running jupyter notebook on a computing node 
	if [ "`ssh ${ku_user}@ssh-snm-willerslev.science.ku.dk 'tmux ls | egrep '${m2}''`" = "" ]
	then
		echo "2) Starting a ssh tunnel from Willerslev servers' front-end (port ${p2}) to ${c1} (port ${p1}) in a tmux session named ${m2}"
		ssh ${ku_user}@ssh-snm-willerslev.science.ku.dk 'tmux new-session -s '${m2}' -d'
		ssh ${ku_user}@ssh-snm-willerslev.science.ku.dk 'tmux send-keys -t '${m2}' "ssh '${c1}' -L '${p2}':localhost:'${p1}' -N" C-m'
		                                                                                                                                            
	else
		echo "2) Willerslev servers' front-end already has a tmux session named ${m2}"
	fi

	#B.1 Step 1 - Running jupyter notebook on a computing node 
	if [ "`tmux ls | egrep ${m3}`" = "" ]
	then
		echo "3) Starting a ssh tunnel from Local computer (port ${p3}) to Willerslev servers' front-end (port ${p2}) in a tmux session named ${m3}"
		tmux new-session -s ${m3} -d
		tmux send-keys -t ${m3}  "ssh ${ku_user}@ssh-snm-willerslev.science.ku.dk -L '${p3}':localhost:'${p2}' -N" C-m

		                                                                                                                                            
	else
		echo "3) Local computer already has a tmux session named ${m3}"
	fi

	#B.4 Step 4 - Jupyter notebook in your local machine browser
	echo "4) Open Google Chrome to access jupyter notebook on your local computer"
	open --new -a "Google Chrome" --args "http://localhost:${p3}/"
else
	#C. If killing option, kill the 3 tmux servers
	echo "Killing tmux server from ${c1}"
	ssh -J ${ku_user}@ssh-snm-willerslev.science.ku.dk ${ku_user}@${c1} 'tmux kill-server'
	echo "Killing tmux server from Willerslev fron end"
	ssh ${ku_user}@ssh-snm-willerslev.science.ku.dk 'tmux kill-server'
	echo "Killing tmux server from local computer"
	tmux kill-server
fi