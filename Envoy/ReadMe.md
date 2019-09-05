Ensure firewall ports are open!

**envoyproxy:**
````
docker run --name=proxy -d -p 80:10000 -v $(pwd)/envoy.yaml:/etc/envoy/envoy.yaml envoyproxy/envoy:latest
````
**Eds Server:**
````
docker run -p 8080:8080 -d katacoda/eds_server
````
**Working EDS "envoy.yaml"**
````
admin:
  access_log_path: /dev/null
  address:
    socket_address:
      address: 127.0.0.1
      port_value: 9000

node:
  cluster: mycluster
  id: test-id

static_resources:
  listeners:
  - name: listener_0

    address:
      socket_address: { address: 0.0.0.0, port_value: 10000 }

    filter_chains:
    - filters:
      - name: envoy.http_connection_manager
        config:
          stat_prefix: ingress_http
          codec_type: AUTO
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: service_backend }
          http_filters:
          - name: envoy.router  

  clusters:
  - name: service_backend
    type: EDS  
    connect_timeout: 0.25s
    eds_cluster_config:
      service_name: myservice
      eds_config:
        api_config_source:
          #api_type: REST_LEGACY # GET /v1/registration/myservice
          #api_type: REST # POST /v2/discovery:endpoints
          api_type: REST
          cluster_names: [eds_cluster]
          refresh_delay: 5s
  - name: eds_cluster
    type: STATIC
    connect_timeout: 0.25s
    hosts: [{ socket_address: { address: ${IP_OF_EDS_SERVER}, port_value: 8080 }}]
````

**input services when running EDS server on local machine.**

Below curl input is inserting multiple services to be routed to, in "http://localhost:8080/edsservice/myservice" : "myservice" is equal to the "service_name:" configured in envoy.yaml. Also take note the entry reads "localhost" because we are running the command on the machine running the eds_server.

````
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{
  "hosts": [
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9200,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9201,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9202,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9203,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9200,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9201,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9202,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9203,
      "tags": {
        "load_balancing_weight": 50
      }                 
    },
    {
      "ip_address": "INSERT_IP",                                        
      "port": 9200,
      "tags": {
        "load_balancing_weight": 50
      }                 
    }
  ]    
}' http://localhost:8080/edsservice/myservice

````
Response from eds_server endpoint:
````
{
    "myservice": {
        "hosts": [
            {
                "ip_address": "192.178.200.126", 
                "port": 9200, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.178.200.136", 
                "port": 9201, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.178.200.136", 
                "port": 9202, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.178.200.136", 
                "port": 9203, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.168.200.126", 
                "port": 9200, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.168.200.126", 
                "port": 9201, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.168.200.126", 
                "port": 9202, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.168.200.126", 
                "port": 9203, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }, 
            {
                "ip_address": "192.178.200.126", 
                "port": 9200, 
                "tags": {
                    "load_balancing_weight": 50
                }
            }
        ]
    }
}
````