// common code that must be included starts here

def getNodesOfBricks(fname) {
  cmd = "getfattr -n glusterfs.pathinfo -e text ${fname}";
  msg=cmd.execute().text;
  def matcher = msg =~ /(<POSIX.*)/;
  def bricks = matcher[0][0].tokenize(" ")
  nodes = []
  for (b : bricks ) {
    if (b =~ /.*arbiter.*/) continue
    matcher  = b =~ /.*:(.*):.*/; 
    node = matcher[0][1]
    matcher = node  =~ /(.*?)\..*/;
    if (matcher)
      node=matcher[0][1]
    nodes << node
  }
  return nodes
}


possible_states = ['idle','alloc','mix' ]
free_states = ['idle','mix']

def getStatus(nodes) {
  node_states ='sinfo -p batch -O NodeHost,StateCompact'.execute().text.split("\n")
  state_map = [:]
  possible  = []
  num_free  = 0
  for (n : node_states) {
    line=n.split()
    the_node=line[0]
    the_state=line[1]
    state_map[the_node]=the_state
    if  (the_state in possible_states) possible << the_node
    if  ( !(the_node in nodes)) continue;
    if  (the_state in free_states) num_free++;
  }
  return [num_free,possible]
}


def nodeOption(fname,aggression=1,other="") {
  nodes = getNodesOfBricks(fname)
  state = getStatus(nodes)
  possible=state[1]
  if ((possible.intersect(nodes)).size()<aggression)
    return "${other}"
  else {
    possible=possible - nodes;
    options="--exclude="+possible.join(',')+" ${other}"
    return options
  }
}

// common code ends

// sample code that you should use as a template

bams = Channel.fromFilePairs("$src/*{.bam,.bam.bai}", size:2)
	      .map { [it[0],it[1][0], it[1][1], nodeOption(it[1][0])] }
        .randomSample(1000)
        




 process sample {
     input:
        tuple sample, file(bam), file(bai), val(cluster_opt) from bams
     output:
        ...   
     clusterOptions { cluster_opt }
