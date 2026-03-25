# HTCondor aliases — loaded only when condor is present
if (( $+commands[condor_status] )); then
    alias cs='condor_status'
    alias css='diff ~/.cs =(cs |grep -e slot.@ |cut -d " " -f1 |cut -d "@" -f2 |uniq)'
    alias cq='condor_q -dag -wide'
    alias cj='condor_q -long -attributes RemoteHost,Arguments,NumJobStarts,ImageSize,LastJobStatus,JobStatus'
    alias cver='condor_status -master -autoformat:t Name CondorVersion'
    alias crm='rm **/*.(err|out|log|pyc)'
fi
