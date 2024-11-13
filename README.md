# algo-helm

Note: This is not the exact chart used to deploy, will be testing and modifying to validate (thanks)

### Current cluster setup

* 3 nodes running keepalived and ha-proxy
* each running as a control-plane (full HA)
* flannel for internal network
* longhorn for cluster storage (full HA)

following executed so they can run applications, the second for metallb (in arp mode)
```bash
kubectl taint node --all "node-role.kubernetes.io/control-plane:NoSchedule-"
kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-
```

(as an aside, will be using traefik for ingress, but this is not needed for this purpose)


### Install 
```bash
git clone https://github.com/gobha-me/algo-helm.git
```

edit values.yaml accordingly

```bash
helm upgrade --install -n alogrand alogrand --create-namespace .
```

edit template/deployment.yaml
comment out NETWORK and PROFILE (this one needs to be removed)

```bash
kubectl scale deployment --replicas 0 -n algorand algorand
helm upgrade --install -n alogrand alogrand --create-namespace .
kubectl scale deployment --replicas 1 -n algorand algorand
```

If you do not remove the ENV variables from the deployment, if there is a container restart for ANY REASON all data/algod* files will get overwritten with new ones

Still learning helm and kubernetes, have plans. On thing I would like to figure out is a restart policy.  The default is to scale an application up and then terminate the old one when the new one is available.  This doesn't work as the configuration of the Persistant Volume only allows one attachment (correctly).

```bash
kubectl exec -it -n algorand deployments/algorand -- /bin/bash
```

even with a logging config that has the "minimum" value set, there are no logs in /algod/data 

```bash
kubect logs -fn algorand deployments/algorand | grep -i votebroa
```
{"Context":"Agreement","Hash":"NNEJV5FQAGIRYPAYZBL5A47BX2IEOXDLMDUQ6JBJXV3UCYQ76FHA","ObjectPeriod":0,"ObjectRound":44353227,"ObjectStep":1,"Period":0,"Round":44353227,"Sender":"GM6JENL4ZKD7BBKS5I7UMFJQP6RGO2REI6QXEB2FIMNYXFTZJXBRBEVDNY","Step":1,"Type":"VoteBroadcast","Weight":1,"WeightTotal":1,"file":"pseudonode.go","function":"github.com/algorand/go-algorand/agreement.pseudonodeVotesTask.execute","level":"info","line":434,"msg":"vote created for broadcast (weight 1, total weight 1)","time":"2024-11-13T22:23:18.266367Z"}
{"Context":"Agreement","Hash":"5SDZ6BK2VEROLJ2RVNNIMWVLEF3LU2DHQX7YALLKVQM7KYCA3EPQ","ObjectPeriod":0,"ObjectRound":44353230,"ObjectStep":1,"Period":0,"Round":44353230,"Sender":"GM6JENL4ZKD7BBKS5I7UMFJQP6RGO2REI6QXEB2FIMNYXFTZJXBRBEVDNY","Step":1,"Type":"VoteBroadcast","Weight":1,"WeightTotal":1,"file":"pseudonode.go","function":"github.com/algorand/go-algorand/agreement.pseudonodeVotesTask.execute","level":"info","line":434,"msg":"vote created for broadcast (weight 1, total weight 1)","time":"2024-11-13T22:23:26.932372Z"}
{"Context":"Agreement","Hash":"ZOULPJAS644DP3IC5H2EWD6AEOF64NHDRAV7BBZBVDBKNRUGWU7Q","ObjectPeriod":0,"ObjectRound":44353231,"ObjectStep":1,"Period":0,"Round":44353231,"Sender":"GM6JENL4ZKD7BBKS5I7UMFJQP6RGO2REI6QXEB2FIMNYXFTZJXBRBEVDNY","Step":1,"Type":"VoteBroadcast","Weight":1,"WeightTotal":1,"file":"pseudonode.go","function":"github.com/algorand/go-algorand/agreement.pseudonodeVotesTask.execute","level":"info","line":434,"msg":"vote created for broadcast (weight 1, total weight 1)","time":"2024-11-13T22:23:29.817524Z"}
{"Context":"Agreement","Hash":"BD2Z24QNWYTXCNJRMVVX5C4J22OQ6NQONOE7EZPKRWAGQPH6WHRA","ObjectPeriod":0,"ObjectRound":44353247,"ObjectStep":2,"Period":0,"Round":44353247,"Sender":"GM6JENL4ZKD7BBKS5I7UMFJQP6RGO2REI6QXEB2FIMNYXFTZJXBRBEVDNY","Step":2,"Type":"VoteBroadcast","Weight":1,"WeightTotal":1,"file":"pseudonode.go","function":"github.com/algorand/go-algorand/agreement.pseudonodeVotesTask.execute","level":"info","line":434,"msg":"vote created for broadcast (weight 1, total weight 1)","time":"2024-11-13T22:24:16.049270Z"}

Assuming these are what I am expecting for "producing" blocks

issue here is the history is way to short, but functional

still trying to "prove" that the node is particaping

I did notice some things

```bash
kubectl exec -it -n algorand deployments/algorand -- /bin/bash
```

Last committed block: 44353258
Time since last block: 0.1s
Sync Time: 0.0s
Last consensus protocol: https://github.com/algorandfoundation/specs/tree/925a46433742afb0b51bb939354bd907fa88bf95
Next consensus protocol: https://github.com/algorandfoundation/specs/tree/925a46433742afb0b51bb939354bd907fa88bf95
Round for next consensus protocol: 44353259
Next consensus protocol supported: true
Last Catchpoint:
Genesis ID: mainnet-v1.0
Genesis hash: wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=

Sync Time could be down to 0.0, but Time since last block to go as high as 17 - 20s as far as could tell, this was an indication, the node was still behind
