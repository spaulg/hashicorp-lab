
server {
  # Specifies if this agent should run in server mode. All other server options depend on
  # this value being set.
  enabled = true

  # Specifies the number of server nodes to wait for before bootstrapping. It is most
  # common to use the odd-numbered integers 3 or 5 for this value, depending on the
  # cluster size. A value of 1 does not provide any fault tolerance and is not
  # recommended for production use cases.
  bootstrap_expect = 1
}
