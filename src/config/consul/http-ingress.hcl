Kind = "ingress-gateway"
Name = "http-ingress"

//TLS {
//  Enabled = true
//}

Listeners = [
  {
    Port     = 80
    Protocol = "http"
    Services = [{ Name = "nginx", Hosts = ["client2.test"]}]
  },{
    Port     = 5601
    Protocol = "http"
    Services = [{ Name = "kibana", Hosts = ["client2.test"]}]
  },{
    Port     = 9200
    Protocol = "http"
    Services = [{ Name = "elasticsearch", Hosts = ["client2.test"]}]
  }
]
