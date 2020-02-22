from flask import Flask, jsonify
import requests, json, sys, os
app = Flask(__name__)

headers = {'Content-Type': 'application/json'}
postdata = {"jsonrpc":"2.0","id":"0","method":"method_type"}

def search_for_sn(list_of_sns, sn_key):
    for dict in list_of_sns:
        if dict['service_node_pubkey'] == sn_key:
            return dict['pubkey_ed25519']

@app.route('/')
def index():
	return "Server Works!"

@app.route('/greet')
def say_hello():
    return "Hello from Server"

@app.route('/loki_sn_any_method/<method>')
def loki_sn_any_method(method):
    if method == "get_info":
        request_header={"jsonrpc":"2.0","id":"0","method":method}
        request_method = request_header
        request_response = requests.post("http://DEBIAN4-LOKI-MAINNET-BK-CN.sensiblebizsolutions.com:32022/json_rpc",json=request_method)
        ##Print headers in response
        #print(request_response.headers)
        ### Check attributes with dir
        #attr = dir(request_response.__dict__)
        #print(attr)
        #format = request_response.json()
        #print(request_response.text)
        #print(format['result']['top_block_hash'])
        return jsonify(request_response.json())
    #else:
        #return "nothing found"

@app.route('/loki_get_sn_details_LokiBlocks/<sn_key>')
def loki_get_sn_details(sn_key):
        SN_CMD = f"./Shell.sh GetSNStatsFromLokiBlocks {sn_key}"
        CMD_Execute = os.popen(SN_CMD)
        CMD_Execute_Read = (CMD_Execute.read())
        (CMD_Execute.close())
        JSONLoads = json.loads(CMD_Execute_Read)
        return jsonify(JSONLoads)

@app.route('/loki_get_specific_sn_details_LokiBlocks/<sn_key>&<Service_Node_IP>&<RPC_Port>')
def loki_get_specific_sn_details_LokiBlocks(sn_key):
        SN_CMD = f"./Shell.sh CheckServiceNodeActiveIndicators {sn_key}"
        CMD_Execute = os.popen(SN_CMD)
        CMD_Execute_Read = (CMD_Execute.read())
        (CMD_Execute.close())
        JSONLoads = json.loads(CMD_Execute_Read)
        return jsonify(SNActive=JSONLoads['active'],
        StorageServerReachable=JSONLoads['storage_server_reachable'],
        earned_downtime_blocks=JSONLoads['earned_downtime_blocks'],
        )

if __name__ == '__main__':
    app.run(host = '0.0.0.0',port=8080)

###NB NB NB NB
# Flask in HTTPS
# https://blog.miguelgrinberg.com/post/running-your-flask-application-over-https

### Loop example

    #for each in j['places']:
        #print each['latitude']

### curl -s -X POST http://DEBIAN4-LOKI-MAINNET-BK-CN.sensiblebizsolutions.com:32022/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_service_nodes"}

#result

##{
##  "id": "0",
##  "jsonrpc": "2.0",
##  "result": {
##    "as_json": "",
##    "block_hash": "6cc58b351f1047e97e0807b8664309bab27d9ba65e7f50a12910c8319fc53a66",
##    "height": 394042,
##    "service_node_states": [{
##      "active": false,
##      "contributors": [{
