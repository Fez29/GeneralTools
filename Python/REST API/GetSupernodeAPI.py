from flask import Flask, jsonify
import sys
import subprocess
import requests
import json
import objectpath
from time import gmtime, strftime, sleep

app = Flask(__name__)

#GraftSN = 'http://51.79.43.168:18690/debug/supernode_list/0'

#GraftSNRequest = requests.get(GraftSN)
#jsondatasn = json.loads(outputgraftserver.text)

#r = requests.get(url = GraftSN)
#data = r.json()


accounts = [
		{'name': "Billy", 'balance': 450.0},
		{'name': "Fez", 'balance': 250.0}
	]

financialaccounts = [
		{'name': "Billy", 'balance': 450.0, 'owing': 100.50},
                {'name': "Fez", 'balance': 250.0, 'owing': 10.25}
	]

@app.route("/graftsn", methods=["GET"])
def getGraftSN():
	GraftSNRequest = requests.get(GraftSN)
	r = requests.get(url = GraftSN)
	data = r.json()
	return jsonify(data)

@app.route("/accounts", methods=["GET"])
def getAccounts():
	return jsonify(accounts)

@app.route("/account/<id>", methods=["GET"])
def getAccount(id):
	id = int(id) - 1
	return jsonify(accounts[id])

@app.route("/financialaccounts", methods=["GET"])
def getFinancialAccounts():
        return jsonify(financialaccounts)

@app.route("/financialaccount/<id>", methods=["GET"])
def getFinancialAccount(id):
        id = int(id) - 1
        return jsonify(financialaccounts[id])

# Ensure Higher than Python 3.6 installed for f"http://{param2}/debug/supernode_list/0" to work correctly,
# otherwise try examples from https://matthew-brett.github.io/teaching/string_formatting.html
@app.route("/graftsnbyID/<param1>/<param2>", methods=["GET"])
def getGraftSNPublicID(param1, param2):
	GraftSN = f"http://{param2}/debug/supernode_list/0"
	graftsnrequest = requests.get(GraftSN)
	jsondatasn = json.loads(graftsnrequest.text)
	pos=0
	for i in range(1,len(jsondatasn["result"]["items"])):
		jsondatasnsw = (jsondatasn["result"]["items"][i])
	for (k, v) in jsondatasnsw.items():
		if str(v) == param2:
			pos=i
	jsondatasnsw = (jsondatasn["result"]["items"][pos])
	for (k, v) in jsondatasnsw.items():
		if k == 'LastUpdateAge':
			updateage = str(v)
	for (k, v) in jsondatasnsw.items():
		if k == 'StakeExpiringBlock':
			expblock = str(v)
			expblockdec = v
	for (k, v) in jsondatasnsw.items():
		if k == 'PublicId':
			snpubkey = str(v)
	height = (jsondatasn['result']['height'])
	#height = objectpath.Tree(jsondatasn['result'])
	#height = print(jsondatasn['result']['height'])
	#for i in range(1,len(jsondatasn["result"]["height"])):
		#jsondatasnswtest = jsondatasn
	#for (k, v) in jsondatasnswtest.items():
		#if k == 'height':
			#height = str(v)
			#expiredays = (expblockdec-heightdec)/720
	ReturnValue = f"{updateage} {expblockdec}, Block Height: {height}"
	return ReturnValue

#// Beware of using // host = '0.0.0.0' //

if __name__ == '__main__':
	app.run(host = '0.0.0.0',port=8080)
